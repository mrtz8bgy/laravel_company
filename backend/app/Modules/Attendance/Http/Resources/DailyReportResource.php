<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Modules\Attendance\Models\DailyReport */
class DailyReportResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'uuid' => $this->uuid,
            'work_date' => $this->work_date?->toDateString(),
            'kind' => $this->kind,
            'body' => $this->body,
            'blockers' => $this->blockers,
            'submitted_at' => $this->submitted_at?->toIso8601String(),
            'user' => $this->when($this->relationLoaded('user') && $this->user, fn () => [
                'uuid' => $this->user->uuid,
                'name' => $this->user->name,
            ]),
        ];
    }
}
