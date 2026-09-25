<?php

declare(strict_types=1);

namespace App\Modules\Portal\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Core\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class CustomerThread extends Model
{
    use BelongsToCompany, HasUuid;

    public const SALES = 'sales';

    public const SUPPORT = 'support';

    public const MANAGEMENT = 'management';

    public const OPEN = 'open';

    public const ANSWERED = 'answered';

    public const CLOSED = 'closed';

    protected $fillable = [
        'company_id',
        'uuid',
        'customer_id',
        'desk',
        'subject',
        'status',
    ];

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    public function messages(): HasMany
    {
        return $this->hasMany(CustomerThreadMessage::class, 'thread_id');
    }
}
