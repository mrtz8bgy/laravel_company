<?php

declare(strict_types=1);

namespace App\Modules\Access\Actions;

use App\Core\Access\PermissionCatalog;
use App\Modules\Access\Models\Permission;
use App\Modules\Access\Models\Role;
use Illuminate\Support\Facades\DB;

/**
 * Adds missing template permissions to existing system roles.
 * Does not remove grants an administrator already customized.
 * The owner role always receives the full company catalog.
 */
class AlignSystemRoles
{
    public function handle(): int
    {
        $permissions = Permission::query()->pluck('id', 'name');
        $templates = PermissionCatalog::roleTemplates();
        $added = 0;

        $roles = Role::query()->withoutGlobalScope('company')->where('is_system', true)->get();

        foreach ($roles as $role) {
            $template = $templates[$role->slug] ?? null;
            if ($template === null) {
                continue;
            }

            $names = $role->slug === 'company-owner'
                ? PermissionCatalog::companyNames()
                : $template['permissions'];

            foreach ($names as $name) {
                $permissionId = $permissions[$name] ?? null;
                if (! $permissionId) {
                    continue;
                }

                $exists = DB::table('role_permissions')
                    ->where('role_id', $role->id)
                    ->where('permission_id', $permissionId)
                    ->exists();

                if ($exists) {
                    continue;
                }

                DB::table('role_permissions')->insert([
                    'role_id' => $role->id,
                    'permission_id' => $permissionId,
                ]);
                $added++;
            }
        }

        return $added;
    }
}
