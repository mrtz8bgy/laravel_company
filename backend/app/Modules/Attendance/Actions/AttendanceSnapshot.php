<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Actions;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\AuthorizationService;
use App\Modules\Attendance\Http\Resources\AttendanceDayResource;
use App\Modules\Attendance\Http\Resources\DailyReportResource;
use App\Modules\Attendance\Models\AttendanceDay;
use App\Modules\Attendance\Models\DailyReport;
use App\Modules\Attendance\Models\WorkPresence;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Feature;
use App\Modules\Organizations\Models\WorkSchedule;
use App\Modules\Projects\Actions\TodayTasks;

class AttendanceSnapshot
{
    public function __construct(
        private readonly TodayTasks $todayTasks,
        private readonly AuthorizationService $authorization,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function today(User $user): array
    {
        $timezone = tenant()->timezone ?: 'Asia/Tehran';
        $now = now($timezone);
        $schedule = WorkSchedule::query()->where('weekday', $now->dayOfWeek)->first();
        $day = AttendanceDay::query()
            ->where('user_id', $user->id)
            ->whereDate('work_date', $now->toDateString())
            ->first();
        $presence = WorkPresence::query()->where('user_id', $user->id)->first();
        $reports = DailyReport::query()
            ->where('user_id', $user->id)
            ->whereDate('work_date', $now->toDateString())
            ->get()
            ->keyBy('kind');
        $tasksAvailable = (bool) Feature::query()->where('key', 'projects')->value('enabled')
            && $this->authorization->allows($user, PermissionCatalog::TASKS_VIEW);

        return [
            'date' => $now->toDateString(),
            'timezone' => $timezone,
            'is_working_day' => (bool) ($schedule?->is_working_day),
            'schedule' => $schedule ? [
                'start_time' => substr((string) $schedule->start_time, 0, 5),
                'end_time' => substr((string) $schedule->end_time, 0, 5),
                'break_minutes' => $schedule->break_minutes,
                'grace_minutes' => $schedule->grace_minutes,
            ] : null,
            'presence' => [
                'status' => $presence?->status ?: 'off',
                'since' => $presence?->since?->toIso8601String(),
                'note' => $presence?->note,
            ],
            'day' => $day ? (new AttendanceDayResource($day))->resolve() : null,
            'reports' => [
                'morning' => isset($reports['morning']) ? (new DailyReportResource($reports['morning']))->resolve() : null,
                'daily' => isset($reports['daily']) ? (new DailyReportResource($reports['daily']))->resolve() : null,
            ],
            'tasks' => $tasksAvailable ? $this->todayTasks->for($user) : [],
            'tasks_available' => $tasksAvailable,
        ];
    }
}
