<?php

declare(strict_types=1);

namespace App\Modules\Hr\Http\Controllers;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\ActivityLogger;
use App\Core\Services\AuthorizationService;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Hr\Actions\ReviewRequest;
use App\Modules\Hr\Models\LeaveRequest;
use App\Modules\Identity\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LeaveController extends Controller
{
    public function __construct(
        private readonly AuthorizationService $authorization,
        private readonly ReviewRequest $review,
        private readonly ActivityLogger $activity,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $query = LeaveRequest::query()->with(['user:id,uuid,name'])->latest();
        if (! $this->authorization->allows($this->user($request), PermissionCatalog::LEAVE_REVIEW)) {
            $query->where('user_id', $request->user()->id);
        }

        return ApiResponse::success($query->limit(100)->get()->map(fn (LeaveRequest $item) => $this->payload($item))->all());
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'type' => ['required', 'in:annual,sick,unpaid,hourly'],
            'starts_on' => ['required', 'date'],
            'ends_on' => ['required', 'date', 'after_or_equal:starts_on'],
            'reason' => ['required', 'string', 'min:3', 'max:2000'],
        ]);
        $leave = LeaveRequest::query()->create([
            ...$data,
            'user_id' => $request->user()->id,
            'status' => 'pending',
        ]);
        $this->activity->log('CREATE', $leave, null, ['type' => $leave->type]);

        return ApiResponse::success($this->payload($leave->load('user')), __('messages.created'), 201);
    }

    public function reviewRequest(Request $request, LeaveRequest $leave): JsonResponse
    {
        $data = $request->validate([
            'decision' => ['required', 'in:approved,rejected'],
            'review_note' => ['nullable', 'string', 'max:1000'],
        ]);
        $leave = $this->review->handle($this->user($request), $leave, $data['decision'], $data['review_note'] ?? null);

        return ApiResponse::success($this->payload($leave), __('messages.updated'));
    }

    /**
     * @return array<string, mixed>
     */
    private function payload(LeaveRequest $leave): array
    {
        return [
            'uuid' => $leave->uuid,
            'type' => $leave->type,
            'starts_on' => $leave->starts_on?->toDateString(),
            'ends_on' => $leave->ends_on?->toDateString(),
            'reason' => $leave->reason,
            'status' => $leave->status,
            'review_note' => $leave->review_note,
            'user' => $leave->relationLoaded('user') && $leave->user ? [
                'uuid' => $leave->user->uuid,
                'name' => $leave->user->name,
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
