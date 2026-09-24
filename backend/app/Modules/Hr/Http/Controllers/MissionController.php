<?php

declare(strict_types=1);

namespace App\Modules\Hr\Http\Controllers;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\ActivityLogger;
use App\Core\Services\AuthorizationService;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Hr\Actions\ReviewRequest;
use App\Modules\Hr\Models\MissionRequest;
use App\Modules\Identity\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MissionController extends Controller
{
    public function __construct(
        private readonly AuthorizationService $authorization,
        private readonly ReviewRequest $review,
        private readonly ActivityLogger $activity,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $query = MissionRequest::query()->with(['user:id,uuid,name'])->latest();
        if (! $this->authorization->allows($this->user($request), PermissionCatalog::MISSION_REVIEW)) {
            $query->where('user_id', $request->user()->id);
        }

        return ApiResponse::success($query->limit(100)->get()->map(fn (MissionRequest $item) => $this->payload($item))->all());
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'destination' => ['required', 'string', 'max:160'],
            'starts_on' => ['required', 'date'],
            'ends_on' => ['required', 'date', 'after_or_equal:starts_on'],
            'purpose' => ['required', 'string', 'min:3', 'max:2000'],
        ]);
        $mission = MissionRequest::query()->create([
            ...$data,
            'user_id' => $request->user()->id,
            'status' => 'pending',
        ]);
        $this->activity->log('CREATE', $mission, null, ['destination' => $mission->destination]);

        return ApiResponse::success($this->payload($mission->load('user')), __('messages.created'), 201);
    }

    public function reviewRequest(Request $request, MissionRequest $mission): JsonResponse
    {
        $data = $request->validate([
            'decision' => ['required', 'in:approved,rejected'],
            'review_note' => ['nullable', 'string', 'max:1000'],
        ]);
        $mission = $this->review->handle($this->user($request), $mission, $data['decision'], $data['review_note'] ?? null);

        return ApiResponse::success($this->payload($mission), __('messages.updated'));
    }

    /**
     * @return array<string, mixed>
     */
    private function payload(MissionRequest $mission): array
    {
        return [
            'uuid' => $mission->uuid,
            'destination' => $mission->destination,
            'starts_on' => $mission->starts_on?->toDateString(),
            'ends_on' => $mission->ends_on?->toDateString(),
            'purpose' => $mission->purpose,
            'status' => $mission->status,
            'review_note' => $mission->review_note,
            'user' => $mission->relationLoaded('user') && $mission->user ? [
                'uuid' => $mission->user->uuid,
                'name' => $mission->user->name,
            ] : null,
        ];
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
