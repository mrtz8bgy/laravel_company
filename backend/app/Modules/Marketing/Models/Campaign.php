<?php

declare(strict_types=1);

namespace App\Modules\Marketing\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Core\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Model;

class Campaign extends Model
{
    use BelongsToCompany, HasUuid;

    protected $fillable = ['company_id', 'uuid', 'name', 'channel', 'status', 'budget_amount', 'currency', 'starts_on', 'ends_on'];

    protected function casts(): array
    {
        return [
            'budget_amount' => 'decimal:0',
            'starts_on' => 'date',
            'ends_on' => 'date',
        ];
    }
}
