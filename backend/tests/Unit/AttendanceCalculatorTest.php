<?php

namespace Tests\Unit;

use App\Modules\Attendance\Services\AttendanceCalculator;
use Carbon\CarbonImmutable;
use PHPUnit\Framework\TestCase;

class AttendanceCalculatorTest extends TestCase
{
    public function test_late_minutes_start_after_grace_and_breaks_are_subtracted(): void
    {
        $calc = new AttendanceCalculator;
        $zone = 'Asia/Tehran';
        $in = CarbonImmutable::parse('2026-09-26 09:40:00', $zone);
        $out = CarbonImmutable::parse('2026-09-26 17:10:00', $zone);

        $result = $calc->measure(
            $zone,
            '2026-09-26',
            [
                'is_working_day' => true,
                'start_time' => '09:00',
                'end_time' => '17:00',
                'break_minutes' => 60,
                'grace_minutes' => 15,
            ],
            $in,
            $out,
            [
                ['type' => 'break_start', 'occurred_at' => CarbonImmutable::parse('2026-09-26 13:00:00', $zone)],
                ['type' => 'break_end', 'occurred_at' => CarbonImmutable::parse('2026-09-26 13:30:00', $zone)],
            ],
            false,
            CarbonImmutable::parse('2026-09-26 18:00:00', $zone),
        );

        $this->assertSame(25, $result['late_minutes']);
        $this->assertSame(30, $result['break_minutes']);
        $this->assertSame(420, $result['worked_minutes']);
        $this->assertSame(420, $result['expected_minutes']);
    }

    public function test_leave_and_friday_do_not_count_as_late(): void
    {
        $calc = new AttendanceCalculator;
        $zone = 'Asia/Tehran';
        $in = CarbonImmutable::parse('2026-09-25 11:00:00', $zone);

        $friday = $calc->measure($zone, '2026-09-25', [
            'is_working_day' => false,
            'start_time' => '09:00',
            'end_time' => '17:00',
            'break_minutes' => 60,
            'grace_minutes' => 15,
        ], $in, null, [], false, $in);

        $excused = $calc->measure($zone, '2026-09-26', [
            'is_working_day' => true,
            'start_time' => '09:00',
            'end_time' => '17:00',
            'break_minutes' => 60,
            'grace_minutes' => 15,
        ], $in, null, [], true, $in);

        $this->assertSame(0, $friday['late_minutes']);
        $this->assertSame(0, $excused['late_minutes']);
    }
}
