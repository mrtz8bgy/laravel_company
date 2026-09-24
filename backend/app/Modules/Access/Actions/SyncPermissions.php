<?php

declare(strict_types=1);

namespace App\Modules\Access\Actions;

use App\Core\Access\PermissionCatalog;
use App\Modules\Access\Models\Permission;

class SyncPermissions
{
    public function handle(): int
    {
        $count = 0;
        foreach (PermissionCatalog::definitions() as $name => $meta) {
            Permission::query()->updateOrCreate(
                ['name' => $name],
                ['module' => $meta['module'], 'description' => $meta['description']],
            );
            $count++;
        }

        return $count;
    }
}
