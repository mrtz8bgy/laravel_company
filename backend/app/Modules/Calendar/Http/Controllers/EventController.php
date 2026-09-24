<?php

declare(strict_types=1);

namespace App\Modules\Calendar\Http\Controllers;

use App\Core\Services\ActivityLogger;
use App\Core\Services\AuthorizationService;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Calendar\Models\Event;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EventController extends Controller
{
    public function __construct(
        private readonly ActivityLogger $activity,
        private readonly AuthorizationService $authorization,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $query = Event::query()->orderBy('starts_at');
        if (! $this->authorization->isPrivileged($request->user(), tenant())) {
            $query->where(function ($inner) use ($request): void {
                $inner->where('visibility', 'company')->orWhere('owner_id', $request->user()->id);
            });
        }

        return ApiResponse::success($query->limit(100)->get()->map(fn (Event $event) => $this->payload($event))->all());
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title' => ['required', 'string', 'max:160'],
            'location' => ['nullable', 'string', 'max:160'],
            'starts_at' => ['required', 'date'],
            'ends_at' => ['required', 'date', 'after:starts_at'],
            'visibility' => ['nullable', 'in:company,private'],
        ]);
        $event = Event::query()->create([
            ...$data,
            'visibility' => $data['visibility'] ?? 'company',
            'owner_id' => $request->user()->id,
        ]);
        $this->activity->log('CREATE', $event, null, ['title' => $event->title]);

        return ApiResponse::success($this->payload($event), __('messages.created'), 201);
    }

    public function show(Request $request, Event $event): JsonResponse
    {
        $this->visible($request, $event);

        return ApiResponse::success($this->payload($event));
    }

    private function visible(Request $request, Event $event): void
    {
        if ($event->visibility === 'private' && $event->owner_id !== $request->user()->id && ! $this->authorization->isPrivileged($request->user(), tenant())) {
            throw (new ModelNotFoundException())->setModel(Event::class);
        }
    }

    /**
     * @return array<string, mixed>
     */
    private function payload(Event $event): array
    {
        return [
            'uuid' => $event->uuid,
            'title' => $event->title,
            'location' => $event->location,
            'starts_at' => $event->starts_at?->toIso8601String(),
            'ends_at' => $event->ends_at?->toIso8601String(),
            'visibility' => $event->visibility,
        ];
    }
}
