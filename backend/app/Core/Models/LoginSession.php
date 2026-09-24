<?php

declare(strict_types=1);

namespace App\Core\Models;

use App\Core\Models\Concerns\HasUuid;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LoginSession extends Model
{
    use HasUuid;

    protected $fillable = [
        'uuid',
        'user_id',
        'company_id',
        'token_id',
        'ip',
        'user_agent',
        'device',
        'logged_in_at',
        'logged_out_at',
        'last_activity_at',
    ];

    protected function casts(): array
    {
        return [
            'logged_in_at' => 'datetime',
            'logged_out_at' => 'datetime',
            'last_activity_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }
}
