<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use Illuminate\Database\Eloquent\Model;

class WorkSchedule extends Model
{
    use BelongsToCompany;

    protected $fillable = [
        'company_id',
        'weekday',
        'is_working_day',
        'start_time',
        'end_time',
        'break_minutes',
        'grace_minutes',
    ];

    protected function casts(): array
    {
        return [
            'weekday' => 'integer',
            'is_working_day' => 'boolean',
            'break_minutes' => 'integer',
            'grace_minutes' => 'integer',
        ];
    }
}
