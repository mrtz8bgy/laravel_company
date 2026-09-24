<?php

declare(strict_types=1);

namespace App\Modules\Analytics\Http\Controllers;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\AuthorizationService;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Attendance\Models\WorkPresence;
use App\Modules\Crm\Models\Deal;
use App\Modules\Finance\Models\Invoice;
use App\Modules\Marketing\Models\Campaign;
use App\Modules\Operations\Models\Ticket;
use App\Modules\Organizations\Models\CompanyMembership;
use App\Modules\Projects\Models\Task;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OverviewController extends Controller
{
    public function __construct(private readonly AuthorizationService $authorization) {}

    public function __invoke(Request $request): JsonResponse
    {
        $user = $request->user();
        $cards = [];

        if ($this->authorization->allows($user, PermissionCatalog::USERS_VIEW)) {
            $cards[] = ['key' => 'employees', 'value' => CompanyMembership::query()->where('company_id', tenantId())->where('status', 'active')->count()];
        }
        if ($this->authorization->allows($user, PermissionCatalog::TASKS_VIEW)) {
            $cards[] = ['key' => 'open_tasks', 'value' => Task::query()->whereNull('completed_at')->count()];
        }
        if ($this->authorization->allows($user, PermissionCatalog::ATTENDANCE_VIEW)) {
            $cards[] = ['key' => 'present_today', 'value' => WorkPresence::query()->whereIn('status', ['office', 'remote', 'break', 'meeting'])->count()];
        }
        if ($this->authorization->allows($user, PermissionCatalog::TICKETS_MANAGE)) {
            $cards[] = ['key' => 'open_tickets', 'value' => Ticket::query()->whereIn('status', ['open', 'pending'])->count()];
        } elseif ($this->authorization->allows($user, PermissionCatalog::TICKETS_CREATE)) {
            $cards[] = ['key' => 'open_tickets', 'value' => Ticket::query()->where('requester_id', $user->id)->whereIn('status', ['open', 'pending'])->count()];
        }
        if ($this->authorization->allows($user, PermissionCatalog::CRM_VIEW)) {
            $cards[] = ['key' => 'pipeline', 'value' => (int) Deal::query()->whereNotIn('stage', ['won', 'lost'])->sum('amount')];
        }
        if ($this->authorization->allows($user, PermissionCatalog::FINANCE_VIEW)) {
            $cards[] = ['key' => 'outstanding', 'value' => (int) Invoice::query()->whereIn('status', ['sent', 'overdue'])->sum('amount')];
        }
        if ($this->authorization->allows($user, PermissionCatalog::MARKETING_VIEW)) {
            $cards[] = ['key' => 'campaigns', 'value' => Campaign::query()->where('status', 'active')->count()];
        }

        return ApiResponse::success($cards);
    }
}
