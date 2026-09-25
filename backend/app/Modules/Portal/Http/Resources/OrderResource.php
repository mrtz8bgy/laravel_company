<?php

declare(strict_types=1);

namespace App\Modules\Portal\Http\Resources;

use App\Modules\Portal\Models\CustomerOrder;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin CustomerOrder */
class OrderResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'uuid' => $this->uuid,
            'number' => $this->number,
            'status' => $this->status,
            'note' => $this->note,
            'staff_note' => $this->when(request()->user() && ! request()->attributes->has('portal_customer'), $this->staff_note),
            'total_amount' => (int) $this->total_amount,
            'currency' => $this->currency,
            'created_at' => $this->created_at?->toIso8601String(),
            'reviewed_at' => $this->reviewed_at?->toIso8601String(),
            'customer' => new CustomerResource($this->whenLoaded('customer')),
            'items' => $this->whenLoaded('items', fn () => $this->items->map(fn ($item) => [
                'name' => $item->name,
                'quantity' => (int) $item->quantity,
                'unit_price' => (int) $item->unit_price,
                'line_total' => (int) $item->line_total,
            ])->values()),
        ];
    }
}
