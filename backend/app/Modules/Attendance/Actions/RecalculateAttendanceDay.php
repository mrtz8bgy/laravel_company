<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Actions;

use App\Modules\Attendance\Models\AttendanceDay;
use App\Modules\Attendance\Services\AttendanceCalculator;
use App\Modules\Organizations\Models\WorkSchedule;
use Carbon\CarbonImmutable;

class RecalculateAttendanceDay
{
    public function __construct(private readonly AttendanceCalculator $calculator) {}

    public function handle(AttendanceDay $day): AttendanceDay
    {
        $company = tenant();
        $timezone = $company->timezone ?: 'Asia/Tehran';
        $workDate = $day->work_date->toDateString();
        $weekday = (int) CarbonImmutable::parse($workDate, $timezone)->dayOfWeek;
        $schedule = WorkSchedule::query()->where('weekday', $weekday)->first();

        $events = $day->events()
            ->orderBy('occurred_at')
            ->orderBy('id')
            ->get()
            ->map(fn ($event) => [
                'type' => $event->type,
                'occurred_at' => $event->occurred_at,
            ])
            ->all();

        $measure = $this->calculator->measure(
            $timezone,
            $workDate,
            $schedule ? [
                'is_working_day' => $schedule->is_working_day,
                'start_time' => (string) $schedule->start_time,
                'end_time' => (string) $schedule->end_time,
                'break_minutes' => (int) $schedule->break_minutes,
                'grace_minutes' => (int) $schedule->grace_minutes,
            ] : null,
            $day->check_in_at,
            $day->check_out_at,
            $events,
            (bool) $day->excused,
            CarbonImmutable::now($timezone),
        );

        $day->fill([
            'late_minutes' => $measure['late_minutes'],
            'worked_minutes' => $measure['worked_minutes'],
            'break_minutes' => $measure['break_minutes'],
            'expected_minutes' => $measure['expected_minutes'],
            'day_status' => $day->check_out_at ? 'closed' : ($day->check_in_at ? 'open' : 'marked'),
        ])->save();

        return $day;
    }
}
