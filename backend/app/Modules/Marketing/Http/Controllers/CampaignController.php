<?php

declare(strict_types=1);

namespace App\Modules\Marketing\Http\Controllers;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\ActivityLogger;
use App\Core\Services\AuthorizationService;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Marketing\Models\Campaign;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CampaignController extends Controller
{
    public function __construct(
        private readonly ActivityLogger $activity,
        private readonly AuthorizationService $authorization,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $ads = $request->is('api/v1/advertising/campaigns') || $request->query('channel') === 'ads';
        $permission = $ads ? PermissionCatalog::ADVERTISING_VIEW : PermissionCatalog::MARKETING_VIEW;
        if (! $this->authorization->allows($request->user(), $permission) && ! $this->authorization->allows($request->user(), PermissionCatalog::MARKETING_VIEW)) {
            throw new AuthorizationException(__('auth.forbidden'));
        }

        $query = Campaign::query()->latest();
        if ($ads) {
            $query->where('channel', 'ads');
        }

        return ApiResponse::success($query->limit(80)->get()->map(fn (Campaign $campaign) => $this->payload($campaign))->all());
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:160'],
            'channel' => ['required', 'in:social,email,ads,event'],
            'status' => ['nullable', 'in:draft,active,paused,done'],
            'budget_amount' => ['nullable', 'integer', 'min:0'],
            'currency' => ['nullable', 'string', 'size:3'],
            'starts_on' => ['nullable', 'date'],
            'ends_on' => ['nullable', 'date'],
        ]);
        $needed = $data['channel'] === 'ads' ? PermissionCatalog::ADVERTISING_MANAGE : PermissionCatalog::MARKETING_MANAGE;
        if (! $this->authorization->allows($request->user(), $needed)) {
            throw new AuthorizationException(__('auth.forbidden'));
        }
        $campaign = Campaign::query()->create([
            ...$data,
            'status' => $data['status'] ?? 'draft',
            'currency' => $data['currency'] ?? 'IRR',
        ]);
        $this->activity->log('CREATE', $campaign, null, ['name' => $campaign->name, 'channel' => $campaign->channel]);

        return ApiResponse::success($this->payload($campaign), __('messages.created'), 201);
    }

    /**
     * @return array<string, mixed>
     */
    private function payload(Campaign $campaign): array
    {
        return [
            'uuid' => $campaign->uuid,
            'name' => $campaign->name,
            'channel' => $campaign->channel,
            'status' => $campaign->status,
            'budget_amount' => $campaign->budget_amount,
            'currency' => $campaign->currency,
            'starts_on' => $campaign->starts_on?->toDateString(),
            'ends_on' => $campaign->ends_on?->toDateString(),
        ];
    }
}
