<?php

declare(strict_types=1);

namespace App\Modules\Projects\Services;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\AuthorizationService;
use App\Modules\Identity\Models\User;
use App\Modules\Projects\Models\Project;
use App\Modules\Projects\Models\ProjectMember;
use App\Modules\Projects\Models\Task;
use Illuminate\Database\Eloquent\Builder;

class ProjectAccess
{
    public function __construct(private readonly AuthorizationService $authorization) {}

    public function canView(User $user, Project $project): bool
    {
        if (! $this->authorization->allows($user, PermissionCatalog::PROJECTS_VIEW) && ! $this->isMember($user, $project)) {
            return false;
        }

        if ($project->visibility !== 'private' || $this->authorization->isPrivileged($user, tenant())) {
            return $this->authorization->allows($user, PermissionCatalog::PROJECTS_VIEW) || $this->isMember($user, $project);
        }

        return $this->isMember($user, $project);
    }

    public function canManage(User $user, Project $project): bool
    {
        if (! $this->canView($user, $project)) {
            return false;
        }

        if ($this->authorization->isPrivileged($user, tenant()) || $this->authorization->allows($user, PermissionCatalog::PROJECTS_UPDATE)) {
            return $project->visibility !== 'private' || $this->isMember($user, $project) || $this->authorization->isPrivileged($user, tenant());
        }

        return $this->memberRole($user, $project) === 'manager';
    }

    public function canUpdateTask(User $user, Task $task): bool
    {
        if (! $this->canView($user, $task->project)) {
            return false;
        }

        if ($this->authorization->allows($user, PermissionCatalog::TASKS_ASSIGN) || $this->memberRole($user, $task->project) === 'manager') {
            return true;
        }

        return $this->authorization->allows($user, PermissionCatalog::TASKS_UPDATE)
            && in_array($user->id, array_filter([$task->assignee_id, $task->reporter_id]), true);
    }

    public function visibleQuery(User $user): Builder
    {
        $query = Project::query()->where('status', '!=', 'archived');
        if ($this->authorization->isPrivileged($user, tenant())) {
            return $query;
        }

        return $query->where(function (Builder $inner) use ($user): void {
            $inner->where('visibility', 'company')
                ->orWhereIn('id', ProjectMember::query()->where('user_id', $user->id)->select('project_id'));
        });
    }

    public function isMember(User $user, Project $project): bool
    {
        return ProjectMember::query()
            ->where('project_id', $project->id)
            ->where('user_id', $user->id)
            ->exists();
    }

    public function memberRole(User $user, Project $project): ?string
    {
        return ProjectMember::query()
            ->where('project_id', $project->id)
            ->where('user_id', $user->id)
            ->value('role');
    }
}
