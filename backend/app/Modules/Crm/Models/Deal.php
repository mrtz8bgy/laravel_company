<?php

declare(strict_types=1);

namespace App\Modules\Crm\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Core\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Deal extends Model
{
    use BelongsToCompany, HasUuid;

    protected $table = 'crm_deals';

    protected $fillable = ['company_id', 'uuid', 'account_id', 'title', 'stage', 'amount', 'currency', 'owner_id'];

    protected function casts(): array
    {
        return ['amount' => 'decimal:0'];
    }

    public function account(): BelongsTo
    {
        return $this->belongsTo(Account::class, 'account_id');
    }
}
