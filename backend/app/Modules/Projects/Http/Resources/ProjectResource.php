<?php

declare(strict_types=1);

namespace App\Modules\Projects\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Modules\Projects\Models\Project */
class ProjectResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'uuid' => $this->uuid,
            'name' => $this->name,
            'slug' => $this->slug,
            'code' => $this->code,
            'description' => $this->description,
            'status' => $this->status,
            'visibility' => $this->visibility,
            'start_date' => $this->start_date?->toDateString(),
            'due_date' => $this->due_date?->toDateString(),
            'tasks_count' => $this->whenCounted('tasks'),
            'department' => $this->when($this->relationLoaded('department') && $this->department, fn () => [
                'uuid' => $this->department->uuid,
                'name' => $this->department->name,
            ]),
            'owner' => $this->when($this->relationLoaded('owner') && $this->owner, fn () => [
                'uuid' => $this->owner->uuid,
                'name' => $this->owner->name,
            ]),
        ];
    }
}
