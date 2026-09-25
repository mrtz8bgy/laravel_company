<?php

declare(strict_types=1);

namespace App\Modules\Portal\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Core\Models\Concerns\HasUuid;
use App\Modules\Identity\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Customer extends Model
{
    use BelongsToCompany, HasUuid;

    public const PENDING = 'pending';

    public const ACTIVE = 'active';

    public const REJECTED = 'rejected';

    protected $fillable = [
        'company_id',
        'uuid',
        'user_id',
        'status',
        'organization_name',
        'phone',
        'note',
        'review_note',
        'reviewer_id',
        'reviewed_at',
    ];

    protected function casts(): array
    {
        return [
            'reviewed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewer_id');
    }

    public function orders(): HasMany
    {
        return $this->hasMany(CustomerOrder::class);
    }

    public function threads(): HasMany
    {
        return $this->hasMany(CustomerThread::class);
    }

    public function tickets(): HasMany
    {
        return $this->hasMany(CustomerTicket::class);
    }

    public function isActive(): bool
    {
        return $this->status === self::ACTIVE;
    }
}
