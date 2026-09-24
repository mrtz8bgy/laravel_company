<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Actions;

use App\Core\Services\ActivityLogger;
use App\Modules\Attendance\Models\AttendanceDay;
use App\Modules\Attendance\Models\AttendanceEvent;
use App\Modules\Identity\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class CorrectAttendanceDay
{
    public function __construct(
        private readonly RecalculateAttendanceDay $recalculate,
        private readonly ActivityLogger $activity,
    ) {}

    /**
     * @param  array{check_in_at?: string|null, check_out_at?: string|null, note?: string|null, excused?: bool}  $input
     */
    public function handle(AttendanceDay $day, User $actor, array $input): AttendanceDay
    {
        return DB::transaction(function () use ($day, $actor, $input): AttendanceDay {
            $old = $day->only(['check_in_at', 'check_out_at', 'note', 'excused', 'late_minutes']);
            $timezone = tenant()->timezone ?: 'Asia/Tehran';
            $workDate = $day->work_date->toDateString();

            if (array_key_exists('check_in_at', $input)) {
                $day->check_in_at = $this->onWorkDate($input['check_in_at'], $workDate, $timezone, 'check_in_at');
            }
            if (array_key_exists('check_out_at', $input)) {
                $day->check_out_at = $this->onWorkDate($input['check_out_at'], $workDate, $timezone, 'check_out_at');
            }
            if ($day->check_in_at && $day->check_out_at && $day->check_out_at->lt($day->check_in_at)) {
                throw ValidationException::withMessages([
                    'check_out_at' => [__('messages.invalid_hours')],
                ]);
            }
            if (array_key_exists('note', $input)) {
                $day->note = $input['note'];
            }
            if (array_key_exists('excused', $input)) {
                $day->excused = (bool) $input['excused'];
            }
            $day->save();

            AttendanceEvent::query()->create([
                'attendance_day_id' => $day->id,
                'user_id' => $day->user_id,
                'type' => 'correction',
                'occurred_at' => now(),
                'location' => $day->location,
                'note' => $input['note'] ?? null,
                'source' => 'correction',
                'actor_id' => $actor->id,
                'ip' => request()->ip(),
            ]);

            $this->recalculate->handle($day);
            $this->activity->log('CORRECTION', $day, [
                'check_in_at' => $old['check_in_at'],
                'check_out_at' => $old['check_out_at'],
                'excused' => $old['excused'],
            ], $day->only(['check_in_at', 'check_out_at', 'excused', 'late_minutes', 'worked_minutes']));

            return $day->fresh();
        });
    }

    private function onWorkDate(mixed $value, string $workDate, string $timezone, string $field): ?CarbonImmutable
    {
        if ($value === null || $value === '') {
            return null;
        }

        $parsed = CarbonImmutable::parse((string) $value)->timezone($timezone);
        if ($parsed->toDateString() !== $workDate) {
            throw ValidationException::withMessages([
                $field => [__('messages.invalid')],
            ]);
        }

        return $parsed->utc();
    }
}
