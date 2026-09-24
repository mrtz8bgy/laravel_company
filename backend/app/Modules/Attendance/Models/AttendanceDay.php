<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Core\Models\Concerns\HasUuid;
use App\Modules\Identity\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AttendanceDay extends Model
{
    use BelongsToCompany, HasUuid;

    protected $fillable = [
        'company_id',
        'uuid',
        'user_id',
        'work_date',
        'location',
        'day_status',
        'check_in_at',
        'check_out_at',
        'late_minutes',
        'worked_minutes',
        'break_minutes',
        'expected_minutes',
        'excused',
        'note',
    ];

    protected function casts(): array
    {
        return [
            'work_date' => 'date',
            'check_in_at' => 'datetime',
            'check_out_at' => 'datetime',
            'late_minutes' => 'integer',
            'worked_minutes' => 'integer',
            'break_minutes' => 'integer',
            'expected_minutes' => 'integer',
            'excused' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function events(): HasMany
    {
        return $this->hasMany(AttendanceEvent::class);
    }
}
