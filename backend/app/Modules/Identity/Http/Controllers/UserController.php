<?php

declare(strict_types=1);

namespace App\Modules\Identity\Http\Controllers;

use App\Core\Services\ActivityLogger;
use App\Core\Services\AuthorizationService;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Identity\Actions\CreateMember;
use App\Modules\Identity\Actions\MembershipService;
use App\Modules\Identity\Http\Requests\StoreUserRequest;
use App\Modules\Identity\Http\Requests\UpdateUserRequest;
use App\Modules\Identity\Http\Resources\UserResource;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\CompanyMembership;
use App\Modules\Organizations\Models\Department;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function __construct(
        private readonly CreateMember $createMember,
        private readonly MembershipService $memberships,
        private readonly AuthorizationService $authorization,
        private readonly ActivityLogger $activity,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', User::class);

        $query = $this->directoryQuery()
            ->when($request->filled('q'), function ($builder) use ($request): void {
                $term = '%'.addcslashes($request->string('q')->toString(), '%_').'%';
                $builder->where(function ($inner) use ($term): void {
                    $inner->where('name', 'like', $term)->orWhere('email', 'like', $term);
                });
            })
            ->orderBy('name');

        $paginator = $query->paginate(min($request->integer('per_page', 20), 100));

        return ApiResponse::paginated($paginator, UserResource::collection($paginator->getCollection())->resolve());
    }

    public function store(StoreUserRequest $request): JsonResponse
    {
        $this->authorize('create', User::class);

        $user = $this->createMember->handle(tenant(), $request->validated(), $request->user());
        $user->load($this->relations());

        return ApiResponse::success((new UserResource($user))->resolve(), __('messages.created'), 201);
    }

    public function show(string $user): JsonResponse
    {
        $member = $this->findMember($user);
        $this->authorize('view', $member);

        return ApiResponse::success((new UserResource($member))->resolve());
    }

    public function update(UpdateUserRequest $request, string $user): JsonResponse
    {
        $member = $this->findMember($user);
        $this->authorize('update', $member);
        $company = tenant();
        $actor = $request->user();

        if ($request->filled('status') && $request->input('status') !== 'active') {
            $this->memberships->assertNotLastOwner($company, $member);
        }

        $old = [
            'name' => $member->name,
            'phone' => $member->phone,
            'status' => $member->status,
        ];

        $member->forceFill($request->only(['name', 'phone', 'locale', 'timezone']))->save();

        $membership = CompanyMembership::query()
            ->where('company_id', $company->id)
            ->where('user_id', $member->id)
            ->firstOrFail();

        $membershipData = [];
        foreach (['job_title', 'employee_code', 'status'] as $field) {
            if ($request->exists($field)) {
                $membershipData[$field] = $request->input($field) ?: ($field === 'status' ? $membership->status : null);
            }
        }
        if ($request->exists('department_uuid')) {
            $membershipData['department_id'] = $request->filled('department_uuid')
                ? Department::query()->where('uuid', $request->string('department_uuid')->toString())->firstOrFail()->id
                : null;
        }
        if ($membershipData !== []) {
            $membership->update($membershipData);
        }

        if ($request->exists('role_slugs')) {
            $slugs = $request->input('role_slugs', []);
            $this->authorization->assertCanAssignRoles($actor, $slugs, $company);
            if ($membership->is_owner && ! in_array('company-owner', $slugs, true)) {
                $this->memberships->assertNotLastOwner($company, $member);
            }
            $this->memberships->syncRoles($member, $company, $slugs);
            $this->activity->log('ASSIGN', $member, null, ['roles' => $slugs]);
        }

        if ($request->exists('direct_permissions')) {
            $names = $request->input('direct_permissions', []);
            $this->authorization->assertCanGrant($actor, $names, $company);
            $this->memberships->syncDirectPermissions($member, $company, $names);
        }

        if ($request->filled('password')) {
            $member->forceFill(['password' => $request->string('password')->toString()])->save();
            $member->tokens()->delete();
            $this->activity->log('UPDATE', $member, null, ['password' => '[redacted]'], 'Password reset by admin');
        }

        $member->load($this->relations());
        $this->activity->log('UPDATE', $member, $old, $member->only(['name', 'phone', 'status']));

        return ApiResponse::success((new UserResource($member))->resolve(), __('messages.updated'));
    }

    public function destroy(Request $request, string $user): JsonResponse
    {
        $member = $this->findMember($user);
        $this->authorize('delete', $member);
        $company = tenant();
        $this->memberships->assertNotLastOwner($company, $member);

        if ($member->id === $request->user()->id) {
            return ApiResponse::error(__('messages.cannot_remove_self'), 422);
        }

        CompanyMembership::query()
            ->where('company_id', $company->id)
            ->where('user_id', $member->id)
            ->delete();

        \Illuminate\Support\Facades\DB::table('user_roles')
            ->where('company_id', $company->id)
            ->where('user_id', $member->id)
            ->delete();
        \Illuminate\Support\Facades\DB::table('user_permissions')
            ->where('company_id', $company->id)
            ->where('user_id', $member->id)
            ->delete();

        $this->activity->log('DELETE', $member, ['email' => $member->email], null, 'Membership removed');

        if (! $member->is_platform_admin && ! $member->memberships()->exists()) {
            $member->tokens()->delete();
            $member->delete();
        }

        return ApiResponse::success(null, __('messages.deleted'));
    }

    private function findMember(string $uuid): User
    {
        $member = $this->directoryQuery()->where('uuid', $uuid)->first();
        abort_if($member === null, 404);

        return $member;
    }

    private function directoryQuery()
    {
        return User::query()
            ->whereHas('memberships', fn ($query) => $query->where('company_id', tenantId()))
            ->with($this->relations());
    }

    /**
     * @return array<int|string, mixed>
     */
    private function relations(): array
    {
        $companyId = tenantId();

        return [
            'memberships' => fn ($query) => $query->where('company_id', $companyId)->with('department:id,uuid,name'),
            'roles' => fn ($query) => $query->withoutGlobalScope('company')
                ->where('roles.company_id', $companyId)
                ->where('user_roles.company_id', $companyId),
            'teams' => fn ($query) => $query->withoutGlobalScope('company')->where('teams.company_id', $companyId),
        ];
    }
}
