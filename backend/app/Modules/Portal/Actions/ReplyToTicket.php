<?php

declare(strict_types=1);

namespace App\Modules\Portal\Actions;

use App\Core\Services\ActivityLogger;
use App\Modules\Identity\Models\User;
use App\Modules\Portal\Models\CustomerTicket;
use App\Modules\Portal\Models\CustomerTicketMessage;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class ReplyToTicket
{
    public function __construct(private readonly ActivityLogger $activity) {}

    public function handle(CustomerTicket $ticket, User $actor, string $body, bool $staff, ?string $status = null): CustomerTicket
    {
        if ($ticket->status === CustomerTicket::CLOSED) {
            throw ValidationException::withMessages([
                'ticket' => [__('messages.request_closed')],
            ]);
        }

        return DB::transaction(function () use ($ticket, $actor, $body, $staff, $status): CustomerTicket {
            CustomerTicketMessage::query()->create([
                'ticket_id' => $ticket->id,
                'user_id' => $actor->id,
                'body' => $body,
                'is_staff' => $staff,
            ]);

            $ticket->forceFill([
                'status' => $status ?: ($staff ? CustomerTicket::ANSWERED : CustomerTicket::OPEN),
            ])->save();

            $this->activity->log('CREATE', $ticket, null, [
                'staff' => $staff,
                'status' => $ticket->status,
            ], 'Customer ticket reply');

            return $ticket->fresh('messages.user:id,uuid,name');
        });
    }

    public function updateStatus(CustomerTicket $ticket, User $actor, string $status): CustomerTicket
    {
        $old = $ticket->status;
        $ticket->forceFill(['status' => $status])->save();
        $this->activity->log('UPDATE', $ticket, ['status' => $old], ['status' => $status], 'Customer ticket updated', null, $actor->id);

        return $ticket;
    }
}
