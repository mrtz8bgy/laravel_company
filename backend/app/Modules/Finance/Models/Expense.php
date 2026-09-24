<?php

declare(strict_types=1);

namespace App\Modules\Finance\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Core\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Model;

class Expense extends Model
{
    use BelongsToCompany, HasUuid;

    protected $fillable = ['company_id', 'uuid', 'category', 'amount', 'currency', 'status', 'spent_on', 'note'];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:0',
            'spent_on' => 'date',
        ];
    }
}
