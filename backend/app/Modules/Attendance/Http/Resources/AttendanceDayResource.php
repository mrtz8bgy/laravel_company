<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Modules\Attendance\Models\AttendanceDay */
class AttendanceDayResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $timezone = tenant()?->timezone ?: 'Asia/Tehran';

        return [
            'uuid' => $this->uuid,
            'work_date' => $this->work_date?->toDateString(),
            'location' => $this->location,
            'day_status' => $this->day_status,
            'check_in_at' => $this->check_in_at?->toIso8601String(),
            'check_out_at' => $this->check_out_at?->toIso8601String(),
            'check_in_local' => $this->local($this->check_in_at, $timezone),
            'check_out_local' => $this->local($this->check_out_at, $timezone),
            'late_minutes' => $this->late_minutes,
            'worked_minutes' => $this->worked_minutes,
            'break_minutes' => $this->break_minutes,
            'expected_minutes' => $this->expected_minutes,
            'excused' => $this->excused,
            'note' => $this->note,
        ];
    }

    private function local(mixed $time, string $timezone): ?string
    {
        return $time?->copy()->timezone($timezone)->format('H:i');
    }
}
