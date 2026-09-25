<?php

declare(strict_types=1);

namespace App\Modules\Portal\Http\Resources;

use App\Modules\Portal\Models\CustomerTicket;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin CustomerTicket */
class TicketResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'uuid' => $this->uuid,
            'number' => $this->number,
            'desk' => $this->desk,
            'subject' => $this->subject,
            'priority' => $this->priority,
            'status' => $this->status,
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
            'customer' => new CustomerResource($this->whenLoaded('customer')),
            'messages' => $this->whenLoaded('messages', fn () => $this->messages->map(fn ($message) => [
                'body' => $message->body,
                'is_staff' => (bool) $message->is_staff,
                'created_at' => $message->created_at?->toIso8601String(),
                'author' => $message->relationLoaded('user') && $message->user ? [
                    'uuid' => $message->user->uuid,
                    'name' => $message->user->name,
                ] : null,
            ])->values()),
        ];
    }
}
