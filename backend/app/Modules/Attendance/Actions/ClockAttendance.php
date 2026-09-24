<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Actions;

use App\Core\Services\ActivityLogger;
use App\Modules\Attendance\Models\AttendanceDay;
use App\Modules\Attendance\Models\AttendanceEvent;
use App\Modules\Attendance\Models\WorkPresence;
use App\Modules\Identity\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class ClockAttendance
{
    public function __construct(
        private readonly RecalculateAttendanceDay $recalculate,
        private readonly ActivityLogger $activity,
    ) {}

    public function checkIn(User $user, string $location, ?string $note = null): AttendanceDay
    {
        return DB::transaction(function () use ($user, $location, $note): AttendanceDay {
            $day = $this->dayFor($user);
            if ($day->check_in_at && ! $day->check_out_at) {
                throw ValidationException::withMessages(['attendance' => [__('messages.already_checked_in')]]);
            }
            if ($day->check_out_at) {
                throw ValidationException::withMessages(['attendance' => [__('messages.already_checked_out')]]);
            }

            $now = now();
            $day->fill([
                'location' => $location,
                'check_in_at' => $now,
                'day_status' => 'open',
            ])->save();

            $this->event($day, $user, 'check_in', $location, null, $note);
            $this->presence($user, $location === 'remote' ? 'remote' : 'office', null, $note);
            $this->recalculate->handle($day);
            $this->activity->log('CLOCK_IN', $day, null, [
                'location' => $location,
                'work_date' => $day->work_date->toDateString(),
            ]);

            return $day->fresh();
        });
    }

    public function checkOut(User $user, ?string $note = null): AttendanceDay
    {
        return DB::transaction(function () use ($user, $note): AttendanceDay {
            $day = $this->openDay($user);
            $presence = $this->currentPresence($user);
            if ($presence?->status === 'break') {
                $this->event($day, $user, 'break_end', $day->location, 'break', null);
            }

            $day->fill([
                'check_out_at' => now(),
                'day_status' => 'closed',
            ])->save();
            $this->event($day, $user, 'check_out', $day->location, 'off', $note);
            $this->presence($user, 'off', null, $note);
            $this->recalculate->handle($day);
            $this->activity->log('CLOCK_OUT', $day, null, ['work_date' => $day->work_date->toDateString()]);

            return $day->fresh();
        });
    }

    public function startBreak(User $user, ?string $note = null): AttendanceDay
    {
        return DB::transaction(function () use ($user, $note): AttendanceDay {
            $day = $this->openDay($user);
            $presence = $this->currentPresence($user);
            if ($presence?->status === 'break') {
                throw ValidationException::withMessages(['attendance' => [__('messages.already_on_break')]]);
            }

            $resume = in_array($presence?->status, ['office', 'remote'], true) ? $presence->status : ($day->location === 'remote' ? 'remote' : 'office');
            $this->event($day, $user, 'break_start', $day->location, 'break', $note);
            $this->presence($user, 'break', $resume, $note);
            $this->recalculate->handle($day);
            $this->activity->log('BREAK_START', $day, null, ['work_date' => $day->work_date->toDateString()]);

            return $day->fresh();
        });
    }

    public function endBreak(User $user, ?string $note = null): AttendanceDay
    {
        return DB::transaction(function () use ($user, $note): AttendanceDay {
            $day = $this->openDay($user);
            $presence = $this->currentPresence($user);
            if ($presence?->status !== 'break') {
                throw ValidationException::withMessages(['attendance' => [__('messages.not_on_break')]]);
            }

            $resume = $presence->resume_status ?: ($day->location === 'remote' ? 'remote' : 'office');
            $this->event($day, $user, 'break_end', $day->location, $resume, $note);
            $this->presence($user, $resume, null, $note);
            $this->recalculate->handle($day);
            $this->activity->log('BREAK_END', $day, null, ['work_date' => $day->work_date->toDateString()]);

            return $day->fresh();
        });
    }

    public function setStatus(User $user, string $status, ?string $note = null): AttendanceDay
    {
        return DB::transaction(function () use ($user, $status, $note): AttendanceDay {
            $day = $this->dayFor($user);
            if (in_array($status, ['leave', 'mission'], true)) {
                $day->excused = true;
            }
            if (in_array($status, ['office', 'remote'], true)) {
                $day->location = $status;
            }
            $day->save();

            $presence = $this->currentPresence($user);
            $resume = in_array($presence?->status, ['office', 'remote'], true)
                ? $presence->status
                : ($presence?->resume_status ?: ($day->location === 'remote' ? 'remote' : 'office'));

            $this->event($day, $user, 'status', $day->location, $status, $note);
            $this->presence($user, $status, in_array($status, ['meeting', 'mission', 'leave'], true) ? $resume : null, $note);
            $this->recalculate->handle($day);
            $this->activity->log('STATUS', $day, null, ['status' => $status]);

            return $day->fresh();
        });
    }

    private function openDay(User $user): AttendanceDay
    {
        $day = $this->dayFor($user);
        if (! $day->check_in_at) {
            throw ValidationException::withMessages(['attendance' => [__('messages.not_checked_in')]]);
        }
        if ($day->check_out_at) {
            throw ValidationException::withMessages(['attendance' => [__('messages.already_checked_out')]]);
        }

        return $day;
    }

    private function dayFor(User $user): AttendanceDay
    {
        $today = now(tenant()->timezone ?: 'Asia/Tehran')->toDateString();
        $existing = AttendanceDay::query()
            ->where('user_id', $user->id)
            ->whereDate('work_date', $today)
            ->first();

        if ($existing) {
            return $existing;
        }

        return AttendanceDay::query()->create([
            'user_id' => $user->id,
            'work_date' => $today,
            'location' => 'office',
            'day_status' => 'marked',
        ]);
    }

    private function event(AttendanceDay $day, User $user, string $type, ?string $location, ?string $status, ?string $note, string $source = 'self'): void
    {
        AttendanceEvent::query()->create([
            'attendance_day_id' => $day->id,
            'user_id' => $user->id,
            'type' => $type,
            'occurred_at' => now(),
            'location' => $location,
            'status' => $status,
            'note' => $note,
            'source' => $source,
            'actor_id' => request()->user()?->id ?: $user->id,
            'ip' => request()->ip(),
        ]);
    }

    private function presence(User $user, string $status, ?string $resume, ?string $note): void
    {
        WorkPresence::query()->updateOrCreate(
            ['user_id' => $user->id],
            [
                'status' => $status,
                'resume_status' => $resume,
                'note' => $note,
                'since' => now(),
            ],
        );
    }

    private function currentPresence(User $user): ?WorkPresence
    {
        return WorkPresence::query()->where('user_id', $user->id)->first();
    }
}
