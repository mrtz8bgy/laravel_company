<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Services;

use Carbon\CarbonInterface;

/**
 * Late and worked minutes are derived from the company schedule.
 * Overnight shifts are out of scope: a punch belongs to the company-local date.
 */
final class AttendanceCalculator
{
    /**
     * @param  array{is_working_day: bool, start_time: string, end_time: string, break_minutes: int, grace_minutes: int}|null  $schedule
     * @param  list<array{type: string, occurred_at: CarbonInterface}>  $events
     * @return array{late_minutes: int, worked_minutes: int, break_minutes: int, expected_minutes: int, is_working_day: bool}
     */
    public function measure(
        string $timezone,
        string $workDate,
        ?array $schedule,
        ?CarbonInterface $checkIn,
        ?CarbonInterface $checkOut,
        array $events,
        bool $excused,
        CarbonInterface $now,
    ): array {
        $working = (bool) ($schedule['is_working_day'] ?? false);
        $expected = 0;
        $late = 0;

        if ($working && $schedule) {
            $start = \Carbon\CarbonImmutable::parse($workDate.' '.$schedule['start_time'], $timezone);
            $end = \Carbon\CarbonImmutable::parse($workDate.' '.$schedule['end_time'], $timezone);
            $expected = max(0, $this->minutesBetween($start, $end) - (int) $schedule['break_minutes']);

            if ($checkIn && ! $excused) {
                $deadline = $start->addMinutes((int) $schedule['grace_minutes']);
                $late = $this->minutesBetween($deadline, $checkIn);
            }
        }

        $boundary = $checkOut ?? ($checkIn ? $now : null);
        $break = $this->breakMinutes($events, $boundary);
        $worked = 0;
        if ($checkIn && $boundary) {
            $worked = max(0, $this->minutesBetween($checkIn, $boundary) - $break);
        }

        return [
            'late_minutes' => $late,
            'worked_minutes' => $worked,
            'break_minutes' => $break,
            'expected_minutes' => $expected,
            'is_working_day' => $working,
        ];
    }

    /**
     * @param  list<array{type: string, occurred_at: CarbonInterface}>  $events
     */
    private function breakMinutes(array $events, ?CarbonInterface $boundary): int
    {
        $seconds = 0;
        $open = null;

        foreach ($events as $event) {
            $at = $event['occurred_at'];
            if ($event['type'] === 'break_start' && $open === null) {
                $open = $at;
            }
            if ($open !== null && in_array($event['type'], ['break_end', 'check_out'], true)) {
                $seconds += max(0, $at->getTimestamp() - $open->getTimestamp());
                $open = null;
            }
        }

        if ($open !== null && $boundary !== null) {
            $seconds += max(0, $boundary->getTimestamp() - $open->getTimestamp());
        }

        return intdiv($seconds, 60);
    }

    private function minutesBetween(CarbonInterface $start, CarbonInterface $end): int
    {
        return intdiv(max(0, $end->getTimestamp() - $start->getTimestamp()), 60);
    }
}
