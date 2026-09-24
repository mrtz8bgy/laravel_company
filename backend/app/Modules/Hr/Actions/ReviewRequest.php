<?php

declare(strict_types=1);

namespace App\Modules\Hr\Actions;

use App\Core\Services\ActivityLogger;
use App\Modules\Attendance\Actions\RecalculateAttendanceDay;
use App\Modules\Attendance\Models\AttendanceDay;
use App\Modules\Hr\Models\LeaveRequest;
use App\Modules\Hr\Models\MissionRequest;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Feature;
use Carbon\CarbonImmutable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Validation\ValidationException;

class ReviewRequest
{
    public function __construct(
        private readonly ActivityLogger $activity,
        private readonly RecalculateAttendanceDay $recalculate,
    ) {}

    public function handle(User $reviewer, Model $request, string $decision, ?string $note): Model
    {
        if ((int) $request->getAttribute('user_id') === $reviewer->id) {
            throw ValidationException::withMessages([
                'decision' => [__('messages.cannot_review_own')],
            ]);
        }
        if ($request->getAttribute('status') !== 'pending') {
            throw ValidationException::withMessages([
                'decision' => [__('messages.request_closed')],
            ]);
        }

        $request->fill([
            'status' => $decision,
            'reviewer_id' => $reviewer->id,
            'reviewed_at' => now(),
            'review_note' => $note,
        ])->save();

        if ($decision === 'approved' && $request instanceof LeaveRequest) {
            $this->excuseCoveredDay($request);
        }

        $this->activity->log('UPDATE', $request, ['status' => 'pending'], [
            'status' => $decision,
            'kind' => $request instanceof LeaveRequest ? 'leave' : 'mission',
        ]);

        return $request->fresh(['user', 'reviewer']);
    }

    private function excuseCoveredDay(LeaveRequest $leave): void
    {
        if (! Feature::query()->where('key', 'attendance')->value('enabled')) {
            return;
        }

        $timezone = tenant()->timezone ?: 'Asia/Tehran';
        $today = CarbonImmutable::now($timezone)->startOfDay();
        $start = CarbonImmutable::parse($leave->starts_on->toDateString(), $timezone);
        $end = CarbonImmutable::parse($leave->ends_on->toDateString(), $timezone);
        if ($today->lt($start) || $today->gt($end)) {
            return;
        }

        $day = AttendanceDay::query()
            ->where('user_id', $leave->user_id)
            ->whereDate('work_date', $today->toDateString())
            ->first();

        if (! $day) {
            $day = AttendanceDay::query()->create([
                'user_id' => $leave->user_id,
                'work_date' => $today->toDateString(),
                'location' => 'office',
                'day_status' => 'marked',
                'excused' => true,
            ]);
        } else {
            $day->excused = true;
            $day->save();
        }

        $this->recalculate->handle($day);
    }
}
