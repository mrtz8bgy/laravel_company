<?php

declare(strict_types=1);

namespace App\Modules\Identity\Policies;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\AuthorizationService;
use App\Modules\Identity\Models\User;

class UserPolicy
{
    public function __construct(private readonly AuthorizationService $authorization) {}

    public function viewAny(User $user): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::USERS_VIEW);
    }

    public function view(User $user, User $member): bool
    {
        return $this->viewAny($user);
    }

    public function create(User $user): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::USERS_CREATE);
    }

    public function update(User $user, User $member): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::USERS_UPDATE);
    }

    public function delete(User $user, User $member): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::USERS_DELETE);
    }
}
