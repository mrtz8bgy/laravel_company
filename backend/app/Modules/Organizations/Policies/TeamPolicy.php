<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Policies;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\AuthorizationService;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Team;

class TeamPolicy
{
    public function __construct(private readonly AuthorizationService $authorization) {}

    public function viewAny(User $user): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::TEAMS_VIEW);
    }

    public function view(User $user, Team $team): bool
    {
        return $this->viewAny($user);
    }

    public function create(User $user): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::TEAMS_CREATE);
    }

    public function update(User $user, Team $team): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::TEAMS_UPDATE);
    }

    public function delete(User $user, Team $team): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::TEAMS_DELETE);
    }
}
