<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Modules\Organizations\Models\Invitation */
class InvitationResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'uuid' => $this->uuid,
            'email' => $this->email,
            'name' => $this->name,
            'expires_at' => $this->expires_at?->toIso8601String(),
            'accepted_at' => $this->accepted_at?->toIso8601String(),
            'role' => $this->when($this->relationLoaded('role') && $this->role, fn () => [
                'uuid' => $this->role->uuid,
                'name' => $this->role->name,
                'slug' => $this->role->slug,
            ]),
        ];
    }
}
