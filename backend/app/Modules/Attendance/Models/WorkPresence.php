<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Modules\Identity\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WorkPresence extends Model
{
    use BelongsToCompany;

    protected $fillable = [
        'company_id',
        'user_id',
        'status',
        'resume_status',
        'note',
        'since',
    ];

    protected function casts(): array
    {
        return [
            'since' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
