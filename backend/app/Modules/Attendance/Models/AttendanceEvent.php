<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Core\Models\Concerns\HasUuid;
use App\Modules\Identity\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AttendanceEvent extends Model
{
    use BelongsToCompany, HasUuid;

    protected $fillable = [
        'company_id',
        'uuid',
        'attendance_day_id',
        'user_id',
        'type',
        'occurred_at',
        'location',
        'status',
        'note',
        'source',
        'actor_id',
        'ip',
    ];

    protected function casts(): array
    {
        return [
            'occurred_at' => 'datetime',
        ];
    }

    public function day(): BelongsTo
    {
        return $this->belongsTo(AttendanceDay::class, 'attendance_day_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function actor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'actor_id');
    }
}
