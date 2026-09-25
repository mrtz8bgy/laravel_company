<?php

declare(strict_types=1);

namespace App\Modules\Portal\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Core\Models\Concerns\HasUuid;
use App\Modules\Identity\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class CustomerOrder extends Model
{
    use BelongsToCompany, HasUuid;

    public const SUBMITTED = 'submitted';

    public const REVIEWING = 'reviewing';

    public const CONFIRMED = 'confirmed';

    public const REJECTED = 'rejected';

    public const FULFILLED = 'fulfilled';

    public const CANCELLED = 'cancelled';

    protected $fillable = [
        'company_id',
        'uuid',
        'customer_id',
        'number',
        'status',
        'note',
        'staff_note',
        'total_amount',
        'currency',
        'reviewer_id',
        'reviewed_at',
    ];

    protected function casts(): array
    {
        return [
            'total_amount' => 'integer',
            'reviewed_at' => 'datetime',
        ];
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewer_id');
    }

    public function items(): HasMany
    {
        return $this->hasMany(CustomerOrderItem::class, 'order_id');
    }
}
