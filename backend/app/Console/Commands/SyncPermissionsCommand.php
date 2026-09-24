<?php

declare(strict_types=1);

namespace App\Console\Commands;

use App\Modules\Access\Actions\AlignSystemRoles;
use App\Modules\Access\Actions\SyncPermissions;
use Illuminate\Console\Command;

class SyncPermissionsCommand extends Command
{
    protected $signature = 'permissions:sync';

    protected $description = 'Upsert the permission catalog and grant new template permissions to system roles';

    public function handle(SyncPermissions $sync, AlignSystemRoles $align): int
    {
        $count = $sync->handle();
        $added = $align->handle();
        $this->info("Synced {$count} permissions. Added {$added} system-role grants.");

        return self::SUCCESS;
    }
}
