<?php

declare(strict_types=1);

namespace App\Modules\Access\Policies;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\AuthorizationService;
use App\Modules\Access\Models\Permission;
use App\Modules\Identity\Models\User;

class PermissionPolicy
{
    public function __construct(private readonly AuthorizationService $authorization) {}

    public function viewAny(User $user): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::PERMISSIONS_VIEW);
    }

    public function view(User $user, Permission $permission): bool
    {
        return $this->viewAny($user);
    }
}
