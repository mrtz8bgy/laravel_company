<?php

declare(strict_types=1);

namespace App\Modules\Identity\Actions;

use App\Core\Services\AuthorizationService;
use App\Modules\Access\Models\Permission;
use App\Modules\Access\Models\Role;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use App\Modules\Organizations\Models\CompanyMembership;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class MembershipService
{
    public function __construct(private readonly AuthorizationService $authorization) {}

    /**
     * @param  array<string, mixed>  $attributes
     * @param  list<string>  $roleSlugs
     */
    public function attach(Company $company, User $user, array $attributes = [], array $roleSlugs = []): CompanyMembership
    {
        $existing = CompanyMembership::query()
            ->where('company_id', $company->id)
            ->where('user_id', $user->id)
            ->first();

        if ($existing) {
            throw ValidationException::withMessages([
                'email' => [__('messages.already_member')],
            ]);
        }

        if (! empty($attributes['employee_code'])) {
            $taken = CompanyMembership::query()
                ->where('company_id', $company->id)
                ->where('employee_code', $attributes['employee_code'])
                ->exists();
            if ($taken) {
                throw ValidationException::withMessages([
                    'employee_code' => [__('messages.employee_code_taken')],
                ]);
            }
        }

        $membership = CompanyMembership::query()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'department_id' => $attributes['department_id'] ?? null,
            'job_title' => $attributes['job_title'] ?? null,
            'employee_code' => $attributes['employee_code'] ?? null,
            'status' => $attributes['status'] ?? 'active',
            'is_owner' => (bool) ($attributes['is_owner'] ?? false),
            'joined_at' => $attributes['joined_at'] ?? now(),
        ]);

        if ($roleSlugs !== []) {
            $this->syncRoles($user, $company, $roleSlugs);
        }

        return $membership;
    }

    /**
     * @param  list<string>  $roleSlugs
     */
    public function syncRoles(User $user, Company $company, array $roleSlugs): void
    {
        $roles = Role::query()
            ->withoutGlobalScope('company')
            ->where('company_id', $company->id)
            ->whereIn('slug', $roleSlugs)
            ->get();

        if ($roles->count() !== count(array_unique($roleSlugs))) {
            throw ValidationException::withMessages([
                'roles' => [__('messages.invalid_role')],
            ]);
        }

        DB::transaction(function () use ($user, $company, $roles): void {
            DB::table('user_roles')
                ->where('user_id', $user->id)
                ->where('company_id', $company->id)
                ->delete();

            $now = now();
            foreach ($roles as $role) {
                DB::table('user_roles')->insert([
                    'company_id' => $company->id,
                    'user_id' => $user->id,
                    'role_id' => $role->id,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
            }
        });

        $this->authorization->forget($user, $company);
    }

    /**
     * @param  list<string>  $permissionNames
     */
    public function syncDirectPermissions(User $user, Company $company, array $permissionNames): void
    {
        $permissionNames = array_values(array_unique($permissionNames));
        $unknown = array_diff($permissionNames, \App\Core\Access\PermissionCatalog::companyNames());
        if ($unknown !== []) {
            throw ValidationException::withMessages([
                'permissions' => [__('messages.invalid_permission')],
            ]);
        }

        $permissions = Permission::query()->whereIn('name', $permissionNames)->get();
        if ($permissions->count() !== count($permissionNames)) {
            throw ValidationException::withMessages([
                'permissions' => [__('messages.invalid_permission')],
            ]);
        }

        DB::transaction(function () use ($user, $company, $permissions): void {
            DB::table('user_permissions')
                ->where('user_id', $user->id)
                ->where('company_id', $company->id)
                ->delete();

            $now = now();
            foreach ($permissions as $permission) {
                DB::table('user_permissions')->insert([
                    'company_id' => $company->id,
                    'user_id' => $user->id,
                    'permission_id' => $permission->id,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
            }
        });

        $this->authorization->forget($user, $company);
    }

    public function assertNotLastOwner(Company $company, User $user): void
    {
        $membership = CompanyMembership::query()
            ->where('company_id', $company->id)
            ->where('user_id', $user->id)
            ->first();

        if (! $membership?->is_owner) {
            return;
        }

        $owners = CompanyMembership::query()
            ->where('company_id', $company->id)
            ->where('is_owner', true)
            ->where('status', 'active')
            ->count();

        if ($owners <= 1) {
            throw ValidationException::withMessages([
                'user' => [__('messages.last_owner')],
            ]);
        }
    }
}
