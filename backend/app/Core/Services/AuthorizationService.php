<?php

declare(strict_types=1);

namespace App\Core\Services;

use App\Core\Access\PermissionCatalog;
use App\Core\Support\TenantContext;
use App\Modules\Access\Models\Role;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Support\Facades\DB;

class AuthorizationService
{
    /** @var array<string, list<string>> */
    private array $cache = [];

    /**
     * Effective permissions are the union of role grants and direct grants.
     * Queries are explicit by company_id so a missing tenant scope cannot leak or hide rows.
     *
     * @return list<string>
     */
    public function permissionsFor(User $user, Company $company): array
    {
        $key = $user->id.':'.$company->id;
        if (isset($this->cache[$key])) {
            return $this->cache[$key];
        }

        if ($user->is_platform_admin) {
            return $this->cache[$key] = PermissionCatalog::companyNames();
        }

        $roleIds = DB::table('user_roles')
            ->where('user_id', $user->id)
            ->where('company_id', $company->id)
            ->pluck('role_id');

        $fromRoles = DB::table('role_permissions')
            ->join('permissions', 'permissions.id', '=', 'role_permissions.permission_id')
            ->whereIn('role_permissions.role_id', $roleIds)
            ->pluck('permissions.name');

        $direct = DB::table('user_permissions')
            ->join('permissions', 'permissions.id', '=', 'user_permissions.permission_id')
            ->where('user_permissions.user_id', $user->id)
            ->where('user_permissions.company_id', $company->id)
            ->pluck('permissions.name');

        return $this->cache[$key] = $fromRoles
            ->merge($direct)
            ->unique()
            ->values()
            ->all();
    }

    public function allows(User $user, string $permission, ?Company $company = null): bool
    {
        $company ??= app(TenantContext::class)->company();
        if ($company === null) {
            return false;
        }

        return in_array($permission, $this->permissionsFor($user, $company), true);
    }

    public function forget(User $user, Company $company): void
    {
        unset($this->cache[$user->id.':'.$company->id]);
    }

    /**
     * @param  list<string>  $permissionNames
     */
    public function assertCanGrant(User $actor, array $permissionNames, ?Company $company = null): void
    {
        $company ??= app(TenantContext::class)->check();

        if ($this->isPrivileged($actor, $company)) {
            return;
        }

        $held = $this->permissionsFor($actor, $company);
        foreach ($permissionNames as $name) {
            if (! in_array($name, $held, true)) {
                throw new AuthorizationException(__('messages.cannot_grant'));
            }
        }
    }

    /**
     * @param  list<string>  $roleSlugs
     */
    public function assertCanAssignRoles(User $actor, array $roleSlugs, ?Company $company = null): void
    {
        $company ??= app(TenantContext::class)->check();
        if ($this->isPrivileged($actor, $company)) {
            return;
        }

        $roles = Role::query()
            ->withoutGlobalScope('company')
            ->where('company_id', $company->id)
            ->whereIn('slug', $roleSlugs)
            ->with('permissions')
            ->get();

        $names = $roles
            ->flatMap(fn (Role $role) => $role->permissions->pluck('name'))
            ->unique()
            ->values()
            ->all();

        $this->assertCanGrant($actor, $names, $company);
    }

    public function isPrivileged(User $user, Company $company): bool
    {
        if ($user->is_platform_admin) {
            return true;
        }

        return DB::table('user_roles')
            ->join('roles', 'roles.id', '=', 'user_roles.role_id')
            ->where('user_roles.user_id', $user->id)
            ->where('user_roles.company_id', $company->id)
            ->where('roles.company_id', $company->id)
            ->whereIn('roles.slug', ['company-owner', 'ceo'])
            ->exists();
    }
}
