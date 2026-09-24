<?php

declare(strict_types=1);

namespace App\Modules\Projects\Policies;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\AuthorizationService;
use App\Modules\Identity\Models\User;
use App\Modules\Projects\Models\Project;
use App\Modules\Projects\Services\ProjectAccess;

class ProjectPolicy
{
    public function __construct(
        private readonly AuthorizationService $authorization,
        private readonly ProjectAccess $access,
    ) {}

    public function view(User $user, Project $project): bool
    {
        return $this->access->canView($user, $project);
    }

    public function update(User $user, Project $project): bool
    {
        return $this->access->canManage($user, $project);
    }

    public function delete(User $user, Project $project): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::PROJECTS_DELETE)
            && $this->access->canView($user, $project);
    }
}
