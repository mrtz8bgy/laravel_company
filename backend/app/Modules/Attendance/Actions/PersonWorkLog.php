<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Actions;

use App\Modules\Attendance\Http\Resources\AttendanceDayResource;
use App\Modules\Attendance\Http\Resources\DailyReportResource;
use App\Modules\Attendance\Models\AttendanceDay;
use App\Modules\Attendance\Models\DailyReport;
use App\Modules\Attendance\Models\WorkPresence;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use App\Modules\Organizations\Models\CompanyMembership;
use Carbon\CarbonImmutable;

/**
 * Read-only work report for one person: presence days, hours and submitted reports.
 *
 * Tasks belong to the projects module and are served by their own endpoint so
 * the attendance module never has to depend on it.
 */
class PersonWorkLog
{
    private const MAX_RANGE_DAYS = 92;

    /**
     * @return array<string, mixed>
     */
    public function for(Company $company, User $person, ?string $from, ?string $to): array
    {
        $timezone = $company->displayTimezone();
        $to = $to ?: now($timezone)->toDateString();
        $from = $from ?: CarbonImmutable::parse($to, $timezone)->subDays(29)->toDateString();

        if (CarbonImmutable::parse($from, $timezone)->diffInDays(CarbonImmutable::parse($to, $timezone)) > self::MAX_RANGE_DAYS) {
            $from = CarbonImmutable::parse($to, $timezone)->subDays(self::MAX_RANGE_DAYS)->toDateString();
        }

        if (CarbonImmutable::parse($from, $timezone)->gt(CarbonImmutable::parse($to, $timezone))) {
            [$from, $to] = [$to, $from];
        }

        $days = AttendanceDay::query()
            ->where('user_id', $person->id)
            ->whereDate('work_date', '>=', $from)
            ->whereDate('work_date', '<=', $to)
            ->orderByDesc('work_date')
            ->get();

        $reports = DailyReport::query()
            ->where('user_id', $person->id)
            ->whereDate('work_date', '>=', $from)
            ->whereDate('work_date', '<=', $to)
            ->orderByDesc('work_date')
            ->orderBy('kind')
            ->get();

        $presence = WorkPresence::query()->where('user_id', $person->id)->first();

        return [
            'user' => $this->person($person),
            'timezone' => $timezone,
            'calendar' => $company->calendarSystem(),
            'range' => ['from' => $from, 'to' => $to],
            'presence' => [
                'status' => $presence?->status ?: 'off',
                'updated_at' => $presence?->updated_at?->toIso8601String(),
            ],
            'summary' => [
                'days' => $days->count(),
                'present_days' => $days->filter(fn (AttendanceDay $day) => $day->check_in_at !== null)->count(),
                'worked_minutes' => (int) $days->sum('worked_minutes'),
                'expected_minutes' => (int) $days->sum('expected_minutes'),
                'late_minutes' => (int) $days->sum('late_minutes'),
                'break_minutes' => (int) $days->sum('break_minutes'),
                'balance_minutes' => (int) $days->sum('worked_minutes') - (int) $days->sum('expected_minutes'),
                'reports' => $reports->count(),
            ],
            'days' => AttendanceDayResource::collection($days)->resolve(),
            'reports' => DailyReportResource::collection($reports)->resolve(),
        ];
    }

    /**
     * @return array<string, mixed>
     */
    private function person(User $person): array
    {
        /** @var CompanyMembership|null $membership */
        $membership = $person->memberships()
            ->where('company_id', tenantId())
            ->with('department:id,uuid,name')
            ->first();

        return [
            'uuid' => $person->uuid,
            'name' => $person->name,
            'email' => $person->email,
            'job_title' => $membership?->job_title,
            'employee_code' => $membership?->employee_code,
            'membership_status' => $membership?->status,
            'department' => $membership?->department ? [
                'uuid' => $membership->department->uuid,
                'name' => $membership->department->name,
            ] : null,
        ];
    }
}
