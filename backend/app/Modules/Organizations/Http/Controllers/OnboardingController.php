<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Http\Controllers;

use App\Core\Services\ActivityLogger;
use App\Core\Support\ApiResponse;
use App\Core\Support\Slugger;
use App\Core\Support\TenantContext;
use App\Http\Controllers\Controller;
use App\Modules\Auth\Actions\AuthPayload;
use App\Modules\Auth\Actions\IssueToken;
use App\Modules\Auth\Http\Requests\OnboardingCompanyRequest;
use App\Modules\Organizations\Actions\InviteMember;
use App\Modules\Organizations\Actions\MarkOnboarding;
use App\Modules\Organizations\Actions\ProvisionCompany;
use App\Modules\Organizations\Http\Resources\DepartmentResource;
use App\Modules\Organizations\Http\Resources\TeamResource;
use App\Modules\Organizations\Models\Department;
use App\Modules\Organizations\Models\Team;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OnboardingController extends Controller
{
    public function __construct(
        private readonly ProvisionCompany $provision,
        private readonly IssueToken $issueToken,
        private readonly AuthPayload $payload,
        private readonly MarkOnboarding $progress,
        private readonly TenantContext $tenant,
        private readonly ActivityLogger $activity,
    ) {}

    public function company(OnboardingCompanyRequest $request): JsonResponse
    {
        $result = $this->provision->handle($request->validated());
        $this->tenant->set($result['company']);
        $issued = $this->issueToken->handle($result['user'], $result['company'], $request);

        return ApiResponse::success(
            $this->payload->make($result['user'], $result['company'], $issued['token']),
            __('messages.company_created'),
            201,
        );
    }

    public function departments(Request $request): JsonResponse
    {
        $this->authorize('create', Department::class);
        $data = $request->validate([
            'departments' => ['required', 'array', 'min:1', 'max:30'],
            'departments.*.name' => ['required', 'string', 'max:120'],
            'departments.*.description' => ['nullable', 'string', 'max:2000'],
            'departments.*.code' => ['nullable', 'string', 'max:32'],
        ]);

        $created = [];
        foreach ($data['departments'] as $index => $row) {
            $created[] = Department::query()->create([
                'name' => $row['name'],
                'slug' => Slugger::unique($row['name'], fn (string $slug): bool => Department::query()->where('slug', $slug)->exists(), 'dep'),
                'code' => $row['code'] ?? null,
                'description' => $row['description'] ?? null,
                'sort_order' => $index,
            ]);
        }

        $this->progress->mark(tenant(), 'departments');
        $this->activity->log('CREATE', tenant(), null, ['departments' => count($created)], 'Onboarding departments');

        return ApiResponse::success(DepartmentResource::collection(collect($created))->resolve(), __('messages.created'), 201);
    }

    public function teams(Request $request): JsonResponse
    {
        $this->authorize('create', Team::class);
        $data = $request->validate([
            'teams' => ['required', 'array', 'min:1', 'max:40'],
            'teams.*.name' => ['required', 'string', 'max:120'],
            'teams.*.department_uuid' => ['required', 'uuid'],
            'teams.*.description' => ['nullable', 'string', 'max:2000'],
        ]);

        $created = [];
        foreach ($data['teams'] as $row) {
            $department = Department::query()->where('uuid', $row['department_uuid'])->first();
            if (! $department) {
                return ApiResponse::error(__('messages.not_found'), 422, [
                    'department_uuid' => [__('messages.not_found')],
                ]);
            }
            $created[] = Team::query()->create([
                'department_id' => $department->id,
                'name' => $row['name'],
                'slug' => Slugger::unique($row['name'], fn (string $slug): bool => Team::query()->where('slug', $slug)->exists(), 'team'),
                'description' => $row['description'] ?? null,
            ]);
        }

        $this->progress->mark(tenant(), 'teams');

        return ApiResponse::success(TeamResource::collection(collect($created))->resolve(), __('messages.created'), 201);
    }

    public function invites(Request $request, InviteMember $inviteMember): JsonResponse
    {
        $this->authorize('create', \App\Modules\Identity\Models\User::class);
        $data = $request->validate([
            'invites' => ['required', 'array', 'min:1', 'max:20'],
            'invites.*.email' => ['required', 'email'],
            'invites.*.name' => ['nullable', 'string', 'max:120'],
            'invites.*.role_uuid' => ['nullable', 'uuid'],
            'invites.*.department_uuid' => ['nullable', 'uuid'],
            'invites.*.team_uuid' => ['nullable', 'uuid'],
        ]);

        $sent = [];
        foreach ($data['invites'] as $row) {
            $sent[] = $inviteMember->handle($row, $request->user());
        }
        $this->progress->mark(tenant(), 'invites');

        return ApiResponse::success(array_map(fn ($row) => [
            'email' => $row['invitation']->email,
            'accept_url' => $row['accept_url'],
            'expires_at' => $row['invitation']->expires_at?->toIso8601String(),
        ], $sent), __('messages.invited'), 201);
    }

    public function complete(Request $request): JsonResponse
    {
        $company = $this->progress->complete(tenant());
        $this->activity->log('UPDATE', $company, null, ['onboarded_at' => $company->onboarded_at?->toIso8601String()], 'Onboarding completed');

        return ApiResponse::success([
            'onboarding' => $company->onboardingState(),
        ], __('messages.onboarding_done'));
    }
}
