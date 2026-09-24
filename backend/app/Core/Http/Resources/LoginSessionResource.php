<?php

declare(strict_types=1);

namespace App\Core\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Core\Models\LoginSession */
class LoginSessionResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $currentId = $request->user()?->currentAccessToken()?->id;

        return [
            'uuid' => $this->uuid,
            'device' => $this->device,
            'ip' => $this->ip,
            'logged_in_at' => $this->logged_in_at?->toIso8601String(),
            'logged_out_at' => $this->logged_out_at?->toIso8601String(),
            'last_activity_at' => $this->last_activity_at?->toIso8601String(),
            'is_current' => $currentId !== null && $this->token_id === $currentId,
        ];
    }
}
