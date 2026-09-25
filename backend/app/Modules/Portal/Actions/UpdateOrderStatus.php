<?php

declare(strict_types=1);

namespace App\Modules\Portal\Actions;

use App\Core\Services\ActivityLogger;
use App\Modules\Identity\Models\User;
use App\Modules\Portal\Models\CustomerOrder;
use Illuminate\Validation\ValidationException;

class UpdateOrderStatus
{
    public function __construct(private readonly ActivityLogger $activity) {}

    public function handle(CustomerOrder $order, User $actor, string $status, ?string $staffNote = null): CustomerOrder
    {
        if ($order->status === CustomerOrder::CANCELLED && $status !== CustomerOrder::CANCELLED) {
            throw ValidationException::withMessages([
                'status' => [__('messages.request_closed')],
            ]);
        }

        $old = $order->status;
        $order->forceFill([
            'status' => $status,
            'staff_note' => $staffNote ?? $order->staff_note,
            'reviewer_id' => $actor->id,
            'reviewed_at' => now(),
        ])->save();

        $this->activity->log('UPDATE', $order, ['status' => $old], [
            'status' => $status,
        ], 'Customer order updated');

        return $order->fresh(['items', 'customer.user:id,uuid,name,email']);
    }
}
