<?php

declare(strict_types=1);

namespace App\Modules\Projects\Actions;

use App\Core\Services\ActivityLogger;
use App\Modules\Projects\Models\KanbanColumn;
use App\Modules\Projects\Models\Task;
use Illuminate\Validation\ValidationException;

class MoveTask
{
    public function __construct(private readonly ActivityLogger $activity) {}

    public function handle(Task $task, KanbanColumn $column, ?int $sortOrder = null): Task
    {
        if ($column->project_id !== $task->project_id) {
            throw ValidationException::withMessages([
                'column_uuid' => [__('messages.invalid')],
            ]);
        }

        $old = $task->only(['column_id', 'sort_order', 'completed_at']);
        $task->fill([
            'column_id' => $column->id,
            'sort_order' => $sortOrder ?? $task->sort_order,
            'completed_at' => $column->is_done ? ($task->completed_at ?? now()) : null,
        ])->save();

        $this->activity->log('MOVE', $task, $old, $task->only(['column_id', 'sort_order', 'completed_at']));

        return $task->fresh(['column', 'assignee', 'project']);
    }
}
