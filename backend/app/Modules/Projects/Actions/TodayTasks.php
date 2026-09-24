<?php

declare(strict_types=1);

namespace App\Modules\Projects\Actions;

use App\Modules\Identity\Models\User;
use App\Modules\Projects\Models\Task;

class TodayTasks
{
    /**
     * @return list<array<string, mixed>>
     */
    public function for(User $user): array
    {
        $today = now(tenant()->timezone ?: 'Asia/Tehran')->toDateString();

        return Task::query()
            ->with(['project:id,uuid,name', 'column:id,name,is_done'])
            ->where('assignee_id', $user->id)
            ->whereHas('column', fn ($query) => $query->where('is_done', false))
            ->where(function ($query) use ($today): void {
                $query->whereNull('due_date')->orWhereDate('due_date', '<=', $today);
            })
            ->orderByRaw('case when due_date is null then 1 else 0 end')
            ->orderBy('due_date')
            ->limit(8)
            ->get()
            ->map(fn (Task $task) => [
                'uuid' => $task->uuid,
                'title' => $task->title,
                'priority' => $task->priority,
                'due_date' => $task->due_date?->toDateString(),
                'column' => $task->column?->name,
                'project' => $task->project ? [
                    'uuid' => $task->project->uuid,
                    'name' => $task->project->name,
                ] : null,
            ])
            ->all();
    }
}
