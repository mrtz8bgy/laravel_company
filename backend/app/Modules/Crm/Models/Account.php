<?php

declare(strict_types=1);

namespace App\Modules\Crm\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Core\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Account extends Model
{
    use BelongsToCompany, HasUuid;

    protected $table = 'crm_accounts';

    protected $fillable = ['company_id', 'uuid', 'name', 'status'];

    public function contacts(): HasMany
    {
        return $this->hasMany(Contact::class, 'account_id');
    }

    public function deals(): HasMany
    {
        return $this->hasMany(Deal::class, 'account_id');
    }
}
