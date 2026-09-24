<?php

declare(strict_types=1);

namespace App\Modules\Workflows\Http\Controllers;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\ActivityLogger;
use App\Core\Services\AuthorizationService;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Workflows\Models\Approval;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class ApprovalController extends Controller
{
    public function __construct(
        private readonly AuthorizationService $authorization,
        private readonly ActivityLogger $activity,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $query = Approval::query()->with('requester:id,uuid,name')->latest();
        if (! $this->authorization->allows($request->user(), PermissionCatalog::WORKFLOWS_REVIEW)) {
            $query->where('requester_id', $request->user()->id);
        }

        return ApiResponse::success($query->limit(100)->get()->map(fn (Approval $item) => $this->payload($item))->all());
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title' => ['required', 'string', 'max:160'],
            'kind' => ['nullable', 'in:general,purchase,leave,publish'],
            'note' => ['nullable', 'string', 'max:2000'],
        ]);
        $item = Approval::query()->create([
            ...$data,
            'kind' => $data['kind'] ?? 'general',
            'status' => 'pending',
            'requester_id' => $request->user()->id,
        ]);
        $this->activity->log('CREATE', $item, null, ['title' => $item->title]);

        return ApiResponse::success($this->payload($item->load('requester')), __('messages.created'), 201);
    }

    public function review(Request $request, Approval $approval): JsonResponse
    {
        if ($approval->requester_id === $request->user()->id) {
            throw ValidationException::withMessages(['decision' => [__('messages.cannot_review_own')]]);
        }
        if ($approval->status !== 'pending') {
            throw ValidationException::withMessages(['decision' => [__('messages.request_closed')]]);
        }
        $data = $request->validate([
            'decision' => ['required', 'in:approved,rejected'],
            'review_note' => ['nullable', 'string', 'max:1000'],
        ]);
        $approval->fill([
            'status' => $data['decision'],
            'reviewer_id' => $request->user()->id,
            'review_note' => $data['review_note'] ?? null,
            'reviewed_at' => now(),
        ])->save();
        $this->activity->log('UPDATE', $approval, ['status' => 'pending'], ['status' => $approval->status]);

        return ApiResponse::success($this->payload($approval->fresh('requester')), __('messages.updated'));
    }

    /**
     * @return array<string, mixed>
     */
    private function payload(Approval $item): array
    {
        return [
            'uuid' => $item->uuid,
            'title' => $item->title,
            'kind' => $item->kind,
            'status' => $item->status,
            'note' => $item->note,
            'review_note' => $item->review_note,
            'requester' => $item->relationLoaded('requester') && $item->requester ? [
                'uuid' => $item->requester->uuid,
                'name' => $item->requester->name,
            ] : null,
        ];
    }
}
