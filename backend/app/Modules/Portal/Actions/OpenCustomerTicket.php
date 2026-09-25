<?php

declare(strict_types=1);

namespace App\Modules\Portal\Actions;

use App\Core\Services\ActivityLogger;
use App\Modules\Portal\Models\Customer;
use App\Modules\Portal\Models\CustomerTicket;
use App\Modules\Portal\Models\CustomerTicketMessage;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class OpenCustomerTicket
{
    public function __construct(private readonly ActivityLogger $activity) {}

    public function handle(Customer $customer, string $desk, string $subject, string $body, string $priority = 'normal'): CustomerTicket
    {
        if (! $customer->isActive()) {
            throw ValidationException::withMessages([
                'customer' => [__('messages.portal_pending')],
            ]);
        }

        return DB::transaction(function () use ($customer, $desk, $subject, $body, $priority): CustomerTicket {
            $ticket = CustomerTicket::query()->create([
                'customer_id' => $customer->id,
                'number' => $this->nextNumber(),
                'desk' => $desk,
                'subject' => $subject,
                'priority' => $priority,
                'status' => CustomerTicket::OPEN,
            ]);

            CustomerTicketMessage::query()->create([
                'ticket_id' => $ticket->id,
                'user_id' => $customer->user_id,
                'body' => $body,
                'is_staff' => false,
            ]);

            $this->activity->log('CREATE', $ticket, null, [
                'desk' => $desk,
                'number' => $ticket->number,
            ], 'Customer ticket opened');

            return $ticket->fresh('messages.user:id,uuid,name');
        });
    }

    private function nextNumber(): string
    {
        $latest = CustomerTicket::query()->lockForUpdate()->orderByDesc('id')->value('number');
        $sequence = 1;
        if (is_string($latest) && preg_match('/(\d+)$/', $latest, $match)) {
            $sequence = ((int) $match[1]) + 1;
        }

        return 'TKT-'.str_pad((string) $sequence, 4, '0', STR_PAD_LEFT);
    }
}
