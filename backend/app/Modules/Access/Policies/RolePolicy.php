<?php

declare(strict_types=1);

namespace App\Modules\Access\Policies;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\AuthorizationService;
use App\Modules\Access\Models\Role;
use App\Modules\Identity\Models\User;

class RolePolicy
{
    public function __construct(private readonly AuthorizationService $authorization) {}

    public function viewAny(User $user): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::ROLES_VIEW);
    }

    public function create(User $user): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::ROLES_CREATE);
    }

    public function update(User $user, Role $role): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::ROLES_UPDATE);
    }

    public function delete(User $user, Role $role): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::ROLES_DELETE);
    }
}
