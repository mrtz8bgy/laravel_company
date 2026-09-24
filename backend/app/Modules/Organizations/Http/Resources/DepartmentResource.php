<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Modules\Organizations\Models\Department */
class DepartmentResource extends JsonResource
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
            'is_active' => $this->is_active,
            'sort_order' => $this->sort_order,
            'manager' => $this->when($this->relationLoaded('manager'), fn () => $this->manager ? [
                'uuid' => $this->manager->uuid,
                'name' => $this->manager->name,
            ] : null),
            'parent' => $this->when($this->relationLoaded('parent'), fn () => $this->parent ? [
                'uuid' => $this->parent->uuid,
                'name' => $this->parent->name,
            ] : null),
            'teams_count' => $this->whenCounted('teams'),
            'members_count' => $this->whenCounted('memberships'),
        ];
    }
}
