<?php

namespace Database\Seeders;

use App\Core\Support\TenantContext;
use App\Modules\Attendance\Actions\RecalculateAttendanceDay;
use App\Modules\Attendance\Models\AttendanceDay;
use App\Modules\Attendance\Models\AttendanceEvent;
use App\Modules\Attendance\Models\DailyReport;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use App\Modules\Organizations\Models\WorkSchedule;
use App\Modules\Projects\Models\Project;
use App\Modules\Projects\Models\Task;
use Carbon\CarbonImmutable;
use Illuminate\Database\Seeder;

/**
 * Demo history for the per-person work report.
 *
 * Idempotent: an existing past attendance day, or the marker task, is left
 * alone. Safe to run on a database that already has the demo company.
 * Dates stay Gregorian/UTC. The company calendar flag only changes display.
 */
class DemoWorkHistorySeeder extends Seeder
{
    private const MARKER_TASK = 'جمع‌بندی گزارش کار هفته';

    public function run(): void
    {
        $company = Company::query()->where('slug', 'ideban-almas')->first();
        if (! $company) {
            return;
        }

        app(TenantContext::class)->set($company);
        $this->ensureCalendar($company);
        $this->seedHistory($company);
        $this->seedAssignedTasks($company);
    }

    private function ensureCalendar(Company $company): void
    {
        $settings = $company->settings ?? [];
        if (in_array($settings['calendar'] ?? null, ['jalali', 'gregorian'], true)) {
            return;
        }

        $settings['calendar'] = 'jalali';
        $company->settings = $settings;
        $company->save();
    }

    private function seedHistory(Company $company): void
    {
        $timezone = $company->displayTimezone();
        $today = CarbonImmutable::now($timezone)->startOfDay();

        if (AttendanceDay::query()->whereDate('work_date', '<', $today->toDateString())->exists()) {
            return;
        }

        $users = User::query()->whereIn('email', array_keys($this->patterns()))->get()->keyBy('email');
        if ($users->isEmpty()) {
            return;
        }

        $working = WorkSchedule::query()
            ->get()
            ->filter(fn (WorkSchedule $day) => $day->is_working_day)
            ->map(fn (WorkSchedule $day) => (int) $day->weekday)
            ->all();

        $recalculate = app(RecalculateAttendanceDay::class);
        $dates = [];
        for ($cursor = $today->subDays(21); $cursor->lt($today); $cursor = $cursor->addDay()) {
            if (in_array($cursor->dayOfWeek, $working, true)) {
                $dates[] = $cursor;
            }
        }

        $last = count($dates) - 1;
        foreach ($dates as $index => $date) {
            foreach ($this->patterns() as $email => $pattern) {
                $user = $users->get($email);
                if (! $user) {
                    continue;
                }

                $this->seedDay($recalculate, $user, $date, $index, $last, $pattern, $timezone, $users->get('ceo@ideban.test'));
            }
        }
    }

    /**
     * @param  array{location: string, in: string, out: string, break: int, late_every: int, absent_on: int, leave_on: int, mission_on: int, reports: bool}  $pattern
     */
    private function seedDay(
        RecalculateAttendanceDay $recalculate,
        User $user,
        CarbonImmutable $date,
        int $index,
        int $last,
        array $pattern,
        string $timezone,
        ?User $manager,
    ): void {
        $workDate = $date->toDateString();
        $leave = $pattern['leave_on'] === $index;
        $mission = $pattern['mission_on'] === $index;
        $absent = $pattern['absent_on'] === $index;
        $present = ! $leave && ! $mission && ! $absent;

        $day = AttendanceDay::query()->create([
            'user_id' => $user->id,
            'work_date' => $workDate,
            'location' => $pattern['location'],
            'day_status' => 'marked',
            'excused' => $leave || $mission,
            'note' => $leave ? 'مرخصی استحقاقی' : ($mission ? 'مأموریت مشتری' : null),
        ]);

        if ($present) {
            $in = $pattern['in'];
            if ($pattern['late_every'] > 0 && $index % $pattern['late_every'] === 0) {
                $in = '09:28';
            }
            $checkIn = CarbonImmutable::parse($workDate.' '.$in, $timezone)->utc();
            $checkOut = CarbonImmutable::parse($workDate.' '.$pattern['out'], $timezone)->utc();
            $breakStart = CarbonImmutable::parse($workDate.' 13:00', $timezone)->utc();
            $breakEnd = $breakStart->addMinutes($pattern['break']);

            $day->fill([
                'check_in_at' => $checkIn,
                'check_out_at' => $checkOut,
            ])->save();

            $this->event($day, $user, 'check_in', $checkIn, $pattern['location'], null, 'self', $user->id);
            $this->event($day, $user, 'break_start', $breakStart, $pattern['location'], 'break', 'self', $user->id);
            $this->event($day, $user, 'break_end', $breakEnd, $pattern['location'], $pattern['location'] === 'remote' ? 'remote' : 'office', 'self', $user->id);
            $this->event($day, $user, 'check_out', $checkOut, $pattern['location'], 'off', 'self', $user->id);

            if ($manager && $user->email === 'developer@ideban.test' && $index === $last) {
                $day->note = 'اصلاح ساعت توسط مدیر';
                $day->save();
                $this->event($day, $user, 'correction', $checkOut, $pattern['location'], null, 'correction', $manager->id, 'اصلاح ساعت توسط مدیر');
            }

            if ($pattern['reports'] && $index > $last - 4) {
                $this->report($user, $workDate, 'morning', $this->morningBody($user->name), $checkIn->addMinutes(20));
                $this->report($user, $workDate, 'daily', $this->dailyBody($user->name), $checkOut->subMinutes(15), $index === 1 ? 'منتظر تأیید طراحی' : null);
            }
        }

        $recalculate->handle($day);
    }

    private function event(
        AttendanceDay $day,
        User $user,
        string $type,
        CarbonImmutable $at,
        ?string $location,
        ?string $status,
        string $source,
        int $actorId,
        ?string $note = null,
    ): void {
        AttendanceEvent::query()->create([
            'attendance_day_id' => $day->id,
            'user_id' => $user->id,
            'type' => $type,
            'occurred_at' => $at,
            'location' => $location,
            'status' => $status,
            'note' => $note,
            'source' => $source,
            'actor_id' => $actorId,
        ]);
    }

    private function report(User $user, string $workDate, string $kind, string $body, CarbonImmutable $at, ?string $blockers = null): void
    {
        DailyReport::query()->create([
            'user_id' => $user->id,
            'work_date' => $workDate,
            'kind' => $kind,
            'body' => $body,
            'blockers' => $blockers,
            'submitted_at' => $at,
        ]);
    }

    private function seedAssignedTasks(Company $company): void
    {
        if (Task::query()->where('title', self::MARKER_TASK)->exists()) {
            return;
        }

        $office = Project::query()->where('slug', 'virtual-office')->first();
        $shop = Project::query()->where('slug', 'shop')->first();
        if (! $office || ! $shop) {
            return;
        }

        $timezone = $company->displayTimezone();
        $today = CarbonImmutable::now($timezone)->startOfDay();
        $users = User::query()->whereIn('email', [
            'ceo@ideban.test',
            'developer@ideban.test',
            'devops@ideban.test',
            'support@ideban.test',
            'sales@ideban.test',
            'marketing@ideban.test',
            'finance@ideban.test',
            'hr@ideban.test',
        ])->get()->keyBy('email');
        $manager = $users->get('ceo@ideban.test');
        if (! $manager) {
            return;
        }

        $rows = [
            [$office, self::MARKER_TASK, 'high', 'developer@ideban.test', $today->addDays(2), false, 'گزارش ساعت و تأخیر هفته را برای مدیرعامل جمع کنید.'],
            [$office, 'بستن گزارش روزانه پنجشنبه', 'normal', 'developer@ideban.test', $today->subDays(3), true, 'گزارش روزانه ثبت و تحویل شد.'],
            [$office, 'بررسی تأخیر ورود', 'high', 'devops@ideban.test', $today->subDays(2), false, 'ساعت ورود دو روز اخیر را با مدیر هماهنگ کنید.'],
            [$office, 'پاسخ تیکت‌های باز صبح', 'normal', 'support@ideban.test', $today->addDay(), false, 'تیکت‌های بدون پاسخ را تا پایان شیفت ببندید.'],
            [$shop, 'پیگیری پیش‌فاکتور مشتری', 'high', 'sales@ideban.test', $today->addDays(3), false, 'پیش‌فاکتور را برای مشتری ارسال کنید.'],
            [$shop, 'به‌روزرسانی متن کمپین', 'normal', 'marketing@ideban.test', $today->addDays(4), false, 'متن کمپین پاییز را با فروش هماهنگ کنید.'],
            [$shop, 'ثبت هزینهٔ جلسه مشتری', 'normal', 'finance@ideban.test', $today->addDay(), false, 'هزینه را در مالی ثبت کنید. مبلغ نمونه است.'],
            [$office, 'تکمیل پروندهٔ حضور ماه', 'normal', 'hr@ideban.test', $today->addDays(5), false, 'مرخصی و مأموریت‌های باز را بررسی کنید.'],
        ];

        foreach ($rows as [$project, $title, $priority, $email, $due, $done, $description]) {
            $assignee = $users->get($email);
            $column = $project->columns()
                ->where('is_done', $done)
                ->orderBy('sort_order')
                ->first();
            if (! $assignee || ! $column) {
                continue;
            }

            Task::query()->create([
                'project_id' => $project->id,
                'column_id' => $column->id,
                'title' => $title,
                'description' => $description,
                'priority' => $priority,
                'assignee_id' => $assignee->id,
                'reporter_id' => $manager->id,
                'due_date' => $due->toDateString(),
                'sort_order' => (int) Task::query()->where('column_id', $column->id)->max('sort_order') + 1,
                'completed_at' => $done ? $today->subDay() : null,
            ]);
        }
    }

    /**
     * @return array<string, array{location: string, in: string, out: string, break: int, late_every: int, absent_on: int, leave_on: int, mission_on: int, reports: bool}>
     */
    private function patterns(): array
    {
        return [
            'ceo@ideban.test' => $this->pattern('office', '08:50', '17:10', 60, reports: true),
            'developer@ideban.test' => $this->pattern('remote', '09:06', '17:20', 55, lateEvery: 5, reports: true),
            'devops@ideban.test' => $this->pattern('office', '09:04', '17:00', 60, leaveOn: 7),
            'support@ideban.test' => $this->pattern('office', '09:08', '17:05', 60, lateEvery: 4, reports: true),
            'sales@ideban.test' => $this->pattern('office', '09:00', '16:40', 45, missionOn: 3),
            'marketing@ideban.test' => $this->pattern('office', '09:12', '17:00', 60, absentOn: 11),
            'finance@ideban.test' => $this->pattern('office', '08:55', '17:15', 60),
            'hr@ideban.test' => $this->pattern('office', '09:01', '17:00', 60, reports: true),
        ];
    }

    /**
     * @return array{location: string, in: string, out: string, break: int, late_every: int, absent_on: int, leave_on: int, mission_on: int, reports: bool}
     */
    private function pattern(
        string $location,
        string $in,
        string $out,
        int $break,
        int $lateEvery = 0,
        int $absentOn = -1,
        int $leaveOn = -1,
        int $missionOn = -1,
        bool $reports = false,
    ): array {
        return [
            'location' => $location,
            'in' => $in,
            'out' => $out,
            'break' => $break,
            'late_every' => $lateEvery,
            'absent_on' => $absentOn,
            'leave_on' => $leaveOn,
            'mission_on' => $missionOn,
            'reports' => $reports,
        ];
    }

    private function morningBody(string $name): string
    {
        return $name.' — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.';
    }

    private function dailyBody(string $name): string
    {
        return $name.' — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.';
    }
}
