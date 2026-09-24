<?php

declare(strict_types=1);

namespace App\Modules\Operations\Http\Controllers;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\ActivityLogger;
use App\Core\Services\AuthorizationService;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Identity\Models\User;
use App\Modules\Operations\Models\Ticket;
use App\Modules\Operations\Models\TicketMessage;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TicketController extends Controller
{
    public function __construct(
        private readonly AuthorizationService $authorization,
        private readonly ActivityLogger $activity,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $query = Ticket::query()->with('requester:id,uuid,name')->latest();
        if (! $this->authorization->allows($request->user(), PermissionCatalog::TICKETS_MANAGE)) {
            $query->where('requester_id', $request->user()->id);
        }

        return ApiResponse::success($query->limit(100)->get()->map(fn (Ticket $ticket) => $this->payload($ticket))->all());
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'subject' => ['required', 'string', 'max:160'],
            'body' => ['required', 'string', 'min:3', 'max:5000'],
            'priority' => ['nullable', 'in:low,normal,high,urgent'],
        ]);
        $ticket = Ticket::query()->create([
            ...$data,
            'priority' => $data['priority'] ?? 'normal',
            'status' => 'open',
            'requester_id' => $request->user()->id,
        ]);
        $this->activity->log('CREATE', $ticket, null, ['subject' => $ticket->subject]);

        return ApiResponse::success($this->payload($ticket->load('requester')), __('messages.created'), 201);
    }

    public function update(Request $request, Ticket $ticket): JsonResponse
    {
        $this->visible($request, $ticket);
        if (! $this->authorization->allows($request->user(), PermissionCatalog::TICKETS_MANAGE)) {
            throw new AuthorizationException(__('auth.forbidden'));
        }
        $data = $request->validate([
            'status' => ['sometimes', 'in:open,pending,resolved,closed'],
            'assignee_uuid' => ['sometimes', 'nullable', 'uuid'],
        ]);
        if (array_key_exists('assignee_uuid', $data)) {
            $data['assignee_id'] = $data['assignee_uuid']
                ? User::query()->where('uuid', $data['assignee_uuid'])->value('id')
                : null;
            unset($data['assignee_uuid']);
        }
        $ticket->update($data);

        return ApiResponse::success($this->payload($ticket->fresh('requester')), __('messages.updated'));
    }

    public function reply(Request $request, Ticket $ticket): JsonResponse
    {
        $this->visible($request, $ticket);
        $data = $request->validate(['body' => ['required', 'string', 'min:1', 'max:4000']]);
        $message = TicketMessage::query()->create([
            'ticket_id' => $ticket->id,
            'user_id' => $request->user()->id,
            'body' => $data['body'],
        ]);

        return ApiResponse::success(['uuid' => $message->uuid, 'body' => $message->body], __('messages.created'), 201);
    }

    private function visible(Request $request, Ticket $ticket): void
    {
        if ($this->authorization->allows($request->user(), PermissionCatalog::TICKETS_MANAGE)) {
            return;
        }
        if ($ticket->requester_id !== $request->user()->id) {
            throw (new ModelNotFoundException())->setModel(Ticket::class);
        }
    }

    /**
     * @return array<string, mixed>
     */
    private function payload(Ticket $ticket): array
    {
        return [
            'uuid' => $ticket->uuid,
            'subject' => $ticket->subject,
            'body' => $ticket->body,
            'status' => $ticket->status,
            'priority' => $ticket->priority,
            'requester' => $ticket->relationLoaded('requester') && $ticket->requester ? [
                'uuid' => $ticket->requester->uuid,
                'name' => $ticket->requester->name,
            ] : null,
        ];
    }
}
