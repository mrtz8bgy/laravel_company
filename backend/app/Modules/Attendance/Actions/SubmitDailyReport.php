<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Actions;

use App\Core\Services\ActivityLogger;
use App\Modules\Attendance\Models\DailyReport;
use App\Modules\Identity\Models\User;
use Illuminate\Support\Facades\DB;

class SubmitDailyReport
{
    public function __construct(private readonly ActivityLogger $activity) {}

    public function handle(User $user, string $kind, string $body, ?string $blockers = null): DailyReport
    {
        return DB::transaction(function () use ($user, $kind, $body, $blockers): DailyReport {
            $today = now(tenant()->timezone ?: 'Asia/Tehran')->toDateString();
            $report = DailyReport::query()
                ->where('user_id', $user->id)
                ->whereDate('work_date', $today)
                ->where('kind', $kind)
                ->first();

            if ($report) {
                $report->update([
                    'body' => $body,
                    'blockers' => $blockers,
                    'submitted_at' => now(),
                ]);
            } else {
                $report = DailyReport::query()->create([
                    'user_id' => $user->id,
                    'work_date' => $today,
                    'kind' => $kind,
                    'body' => $body,
                    'blockers' => $blockers,
                    'submitted_at' => now(),
                ]);
            }

            $this->activity->log('REPORT', $report, null, [
                'kind' => $kind,
                'work_date' => $today,
            ]);

            return $report->fresh();
        });
    }
}
