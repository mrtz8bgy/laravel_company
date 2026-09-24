<?php

declare(strict_types=1);

namespace App\Modules\Access\Http\Controllers;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\ActivityLogger;
use App\Core\Services\AuthorizationService;
use App\Core\Support\ApiResponse;
use App\Core\Support\Slugger;
use App\Http\Controllers\Controller;
use App\Modules\Access\Http\Requests\RoleRequest;
use App\Modules\Access\Http\Resources\PermissionResource;
use App\Modules\Access\Http\Resources\RoleResource;
use App\Modules\Access\Models\Permission;
use App\Modules\Access\Models\Role;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RoleController extends Controller
{
    public function __construct(
        private readonly ActivityLogger $activity,
        private readonly AuthorizationService $authorization,
    ) {}

    public function index(): JsonResponse
    {
        $this->authorize('viewAny', Role::class);

        $roles = Role::query()->with('permissions')->withCount('users')->orderBy('name')->get();

        return ApiResponse::success(RoleResource::collection($roles)->resolve());
    }

    public function permissions(): JsonResponse
    {
        $this->authorize('viewAny', Permission::class);

        $permissions = Permission::query()
            ->whereIn('name', PermissionCatalog::companyNames())
            ->orderBy('module')
            ->orderBy('name')
            ->get();

        return ApiResponse::success(PermissionResource::collection($permissions)->resolve());
    }

    public function store(RoleRequest $request): JsonResponse
    {
        $this->authorize('create', Role::class);
        $names = $request->input('permissions', []);
        $this->authorization->assertCanGrant($request->user(), $names);

        $role = Role::query()->create([
            'name' => $request->string('name')->toString(),
            'slug' => $request->input('slug') ?: Slugger::unique(
                $request->string('name')->toString(),
                fn (string $candidate): bool => Role::query()->where('slug', $candidate)->exists(),
                'role',
            ),
            'description' => $request->input('description'),
            'is_system' => false,
        ]);
        $this->syncPermissions($role, $names);
        $role->load('permissions');
        $this->activity->log('CREATE', $role, null, ['name' => $role->name, 'permissions' => $names]);

        return ApiResponse::success((new RoleResource($role))->resolve(), __('messages.created'), 201);
    }

    public function update(RoleRequest $request, Role $role): JsonResponse
    {
        $this->authorize('update', $role);
        $names = $request->input('permissions', []);
        $this->authorization->assertCanGrant($request->user(), $names);

        if ($role->slug === 'company-owner') {
            $names = PermissionCatalog::companyNames();
        }

        $old = ['name' => $role->name, 'permissions' => $role->permissions()->pluck('name')->all()];
        $role->update([
            'name' => $request->string('name')->toString(),
            'description' => $request->input('description'),
        ]);
        $this->syncPermissions($role, $names);
        $role->load('permissions');
        $this->activity->log('UPDATE', $role, $old, ['name' => $role->name, 'permissions' => $names]);

        return ApiResponse::success((new RoleResource($role))->resolve(), __('messages.updated'));
    }

    public function destroy(Role $role): JsonResponse
    {
        $this->authorize('delete', $role);

        if ($role->is_system) {
            return ApiResponse::error(__('messages.system_role'), 422);
        }

        $assigned = DB::table('user_roles')->where('role_id', $role->id)->exists();
        if ($assigned) {
            return ApiResponse::error(__('messages.role_in_use'), 422);
        }

        $this->activity->log('DELETE', $role, ['name' => $role->name, 'slug' => $role->slug], null);
        $role->delete();

        return ApiResponse::success(null, __('messages.deleted'));
    }

    /**
     * @param  list<string>  $names
     */
    private function syncPermissions(Role $role, array $names): void
    {
        $names = array_values(array_unique($names));
        $allowed = array_values(array_intersect($names, PermissionCatalog::companyNames()));
        if (count($allowed) !== count($names)) {
            abort(ApiResponse::error(__('messages.invalid_permission'), 422, [
                'permissions' => [__('messages.invalid_permission')],
            ]));
        }

        $ids = Permission::query()->whereIn('name', $allowed)->pluck('id')->all();
        if (count($ids) !== count($allowed)) {
            abort(ApiResponse::error(__('messages.invalid_permission'), 422, [
                'permissions' => [__('messages.invalid_permission')],
            ]));
        }

        $role->permissions()->sync($ids);
    }
}
