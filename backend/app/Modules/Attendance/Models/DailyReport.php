<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Core\Models\Concerns\HasUuid;
use App\Modules\Identity\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DailyReport extends Model
{
    use BelongsToCompany, HasUuid;

    protected $fillable = [
        'company_id',
        'uuid',
        'user_id',
        'work_date',
        'kind',
        'body',
        'blockers',
        'submitted_at',
    ];

    protected function casts(): array
    {
        return [
            'work_date' => 'date',
            'submitted_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
