<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Http\Controllers;

use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Attendance\Actions\SubmitDailyReport;
use App\Modules\Attendance\Http\Requests\DailyReportRequest;
use App\Modules\Attendance\Http\Resources\DailyReportResource;
use App\Modules\Attendance\Models\DailyReport;
use App\Modules\Attendance\Services\AttendanceAccess;
use App\Modules\Identity\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DailyReportController extends Controller
{
    public function __construct(
        private readonly SubmitDailyReport $submit,
        private readonly AttendanceAccess $access,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $timezone = tenant()->timezone ?: 'Asia/Tehran';
        $date = $request->date('date')?->toDateString() ?: now($timezone)->toDateString();
        $visible = $this->access->visibleUserIds($this->user($request));

        $reports = DailyReport::query()
            ->with('user:id,uuid,name')
            ->whereDate('work_date', $date)
            ->when($visible !== null, fn ($query) => $query->whereIn('user_id', $visible))
            ->orderBy('kind')
            ->get();

        return ApiResponse::success(DailyReportResource::collection($reports)->resolve());
    }

    public function store(DailyReportRequest $request): JsonResponse
    {
        $report = $this->submit->handle(
            $this->user($request),
            $request->string('kind')->toString(),
            $request->string('body')->toString(),
            $request->input('blockers'),
        );

        return ApiResponse::success((new DailyReportResource($report))->resolve(), __('messages.report_saved'));
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
