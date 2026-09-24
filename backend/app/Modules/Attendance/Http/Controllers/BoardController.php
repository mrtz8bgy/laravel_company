<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Http\Controllers;

use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Attendance\Actions\CorrectAttendanceDay;
use App\Modules\Attendance\Http\Requests\CorrectAttendanceRequest;
use App\Modules\Attendance\Http\Resources\AttendanceDayResource;
use App\Modules\Attendance\Models\AttendanceDay;
use App\Modules\Attendance\Models\WorkPresence;
use App\Modules\Attendance\Services\AttendanceAccess;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\CompanyMembership;
use App\Modules\Organizations\Models\WorkSchedule;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BoardController extends Controller
{
    public function __construct(
        private readonly AttendanceAccess $access,
        private readonly CorrectAttendanceDay $correct,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $viewer = $this->user($request);
        $timezone = tenant()->timezone ?: 'Asia/Tehran';
        $date = $request->date('date')?->timezone($timezone)->toDateString() ?: now($timezone)->toDateString();
        $weekday = (int) \Carbon\CarbonImmutable::parse($date, $timezone)->dayOfWeek;
        $schedule = WorkSchedule::query()->where('weekday', $weekday)->first();
        $visible = $this->access->visibleUserIds($viewer);

        $members = CompanyMembership::query()
            ->where('company_id', tenantId())
            ->where('status', 'active')
            ->when($visible !== null, fn ($query) => $query->whereIn('user_id', $visible))
            ->with(['user:id,uuid,name', 'department:id,uuid,name'])
            ->orderBy('id')
            ->get();

        $userIds = $members->pluck('user_id');
        $days = AttendanceDay::query()
            ->whereDate('work_date', $date)
            ->whereIn('user_id', $userIds)
            ->get()
            ->keyBy('user_id');
        $presences = WorkPresence::query()->whereIn('user_id', $userIds)->get()->keyBy('user_id');

        $rows = $members->map(function (CompanyMembership $member) use ($days, $presences) {
            $day = $days->get($member->user_id);
            $presence = $presences->get($member->user_id);

            return [
                'user' => [
                    'uuid' => $member->user?->uuid,
                    'name' => $member->user?->name,
                    'job_title' => $member->job_title,
                ],
                'department' => $member->department ? [
                    'uuid' => $member->department->uuid,
                    'name' => $member->department->name,
                ] : null,
                'status' => $presence?->status ?: 'off',
                'day' => $day ? (new AttendanceDayResource($day))->resolve() : null,
            ];
        })->values();

        $summary = [
            'people' => $rows->count(),
            'present' => $rows->filter(fn (array $row) => in_array($row['status'], ['office', 'remote', 'break', 'meeting'], true))->count(),
            'remote' => $rows->where('status', 'remote')->count(),
            'leave' => $rows->where('status', 'leave')->count(),
            'late' => $rows->filter(fn (array $row) => ($row['day']['late_minutes'] ?? 0) > 0)->count(),
        ];

        return ApiResponse::success([
            'date' => $date,
            'timezone' => $timezone,
            'is_working_day' => (bool) ($schedule?->is_working_day),
            'schedule' => $schedule ? [
                'start_time' => substr((string) $schedule->start_time, 0, 5),
                'end_time' => substr((string) $schedule->end_time, 0, 5),
                'grace_minutes' => $schedule->grace_minutes,
            ] : null,
            'summary' => $summary,
            'rows' => $rows,
        ]);
    }

    public function correct(CorrectAttendanceRequest $request, AttendanceDay $day): JsonResponse
    {
        $this->authorize('correct', $day);
        $updated = $this->correct->handle($day, $this->user($request), $request->validated());

        return ApiResponse::success((new AttendanceDayResource($updated))->resolve(), __('messages.updated'));
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
