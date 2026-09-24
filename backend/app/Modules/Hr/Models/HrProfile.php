<?php

declare(strict_types=1);

namespace App\Modules\Hr\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Modules\Identity\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HrProfile extends Model
{
    use BelongsToCompany;

    protected $fillable = [
        'company_id',
        'user_id',
        'hire_date',
        'employment_type',
        'national_id',
        'emergency_name',
        'emergency_phone',
        'salary_amount',
        'salary_currency',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'hire_date' => 'date',
            'salary_amount' => 'decimal:0',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
