<?php

declare(strict_types=1);

namespace App\Modules\Crm\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Core\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Contact extends Model
{
    use BelongsToCompany, HasUuid;

    protected $table = 'crm_contacts';

    protected $fillable = ['company_id', 'uuid', 'account_id', 'name', 'email', 'phone'];

    public function account(): BelongsTo
    {
        return $this->belongsTo(Account::class, 'account_id');
    }
}
