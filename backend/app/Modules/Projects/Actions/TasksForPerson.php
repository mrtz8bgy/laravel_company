<?php

declare(strict_types=1);

namespace App\Modules\Projects\Actions;

use App\Modules\Identity\Models\User;
use App\Modules\Projects\Http\Resources\TaskResource;
use App\Modules\Projects\Models\Task;
use App\Modules\Projects\Services\ProjectAccess;
use Carbon\CarbonImmutable;

/**
 * Tasks a manager can see for one person, limited to projects the viewer may open.
 */
class TasksForPerson
{
    private const LIMIT = 200;

    public function __construct(private readonly ProjectAccess $access) {}

    /**
     * @return array<string, mixed>
     */
    public function for(User $viewer, User $person, string $timezone, bool $openOnly = false): array
    {
        $projectIds = $this->access->visibleQuery($viewer)->pluck('id');
        $today = CarbonImmutable::now($timezone)->toDateString();

        $tasks = Task::query()
            ->with(['project:id,uuid,name', 'column:id,name,is_done', 'assignee:id,uuid,name'])
            ->where('assignee_id', $person->id)
            ->whereIn('project_id', $projectIds)
            ->when($openOnly, fn ($query) => $query->whereHas('column', fn ($column) => $column->where('is_done', false)))
            ->orderByRaw('case when due_date is null then 1 else 0 end')
            ->orderBy('due_date')
            ->orderByDesc('id')
            ->limit(self::LIMIT)
            ->get();

        return [
            'tasks' => TaskResource::collection($tasks)->resolve(),
            'summary' => [
                'total' => $tasks->count(),
                'open' => $tasks->filter(fn (Task $task) => ! $task->column?->is_done)->count(),
                'done' => $tasks->filter(fn (Task $task) => (bool) $task->column?->is_done)->count(),
                'overdue' => $tasks->filter(
                    fn (Task $task) => ! $task->column?->is_done
                        && $task->due_date !== null
                        && $task->due_date->toDateString() < $today
                )->count(),
            ],
        ];
    }
}
