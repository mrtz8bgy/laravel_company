<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Modules\Organizations\Models\Team */
class TeamResource extends JsonResource
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
            'description' => $this->description,
            'is_active' => $this->is_active,
            'department' => $this->when($this->relationLoaded('department') && $this->department, fn () => [
                'uuid' => $this->department->uuid,
                'name' => $this->department->name,
            ]),
            'leader' => $this->when($this->relationLoaded('leader') && $this->leader, fn () => [
                'uuid' => $this->leader->uuid,
                'name' => $this->leader->name,
            ]),
            'members_count' => $this->whenCounted('members'),
            'members' => $this->whenLoaded('members', fn () => $this->members->map(fn ($member) => [
                'uuid' => $member->uuid,
                'name' => $member->name,
                'email' => $member->email,
                'role' => $member->pivot->role,
            ])->values()),
        ];
    }
}
