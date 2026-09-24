<?php

declare(strict_types=1);

namespace App\Modules\Finance\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Core\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Model;

class Invoice extends Model
{
    use BelongsToCompany, HasUuid;

    protected $fillable = ['company_id', 'uuid', 'number', 'party_name', 'amount', 'currency', 'status', 'issued_on', 'due_on'];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:0',
            'issued_on' => 'date',
            'due_on' => 'date',
        ];
    }
}
