<?php

declare(strict_types=1);

namespace App\Core\Policies;

use App\Core\Access\PermissionCatalog;
use App\Core\Models\ActivityLog;
use App\Core\Services\AuthorizationService;
use App\Modules\Identity\Models\User;

class ActivityLogPolicy
{
    public function __construct(private readonly AuthorizationService $authorization) {}

    public function viewAny(User $user): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::ACTIVITY_LOGS_VIEW);
    }

    public function view(User $user, ActivityLog $log): bool
    {
        return $this->viewAny($user);
    }
}
