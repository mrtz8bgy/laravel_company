<?php

declare(strict_types=1);

namespace App\Modules\Projects\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Modules\Projects\Models\Task */
class TaskResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'uuid' => $this->uuid,
            'title' => $this->title,
            'description' => $this->description,
            'priority' => $this->priority,
            'due_date' => $this->due_date?->toDateString(),
            'sort_order' => $this->sort_order,
            'completed_at' => $this->completed_at?->toIso8601String(),
            'column' => $this->when($this->relationLoaded('column') && $this->column, fn () => [
                'uuid' => $this->column->uuid,
                'name' => $this->column->name,
                'is_done' => $this->column->is_done,
            ]),
            'assignee' => $this->when($this->relationLoaded('assignee'), fn () => $this->assignee ? [
                'uuid' => $this->assignee->uuid,
                'name' => $this->assignee->name,
            ] : null),
            'project' => $this->when($this->relationLoaded('project') && $this->project, fn () => [
                'uuid' => $this->project->uuid,
                'name' => $this->project->name,
            ]),
        ];
    }
}
