<?php

declare(strict_types=1);

namespace App\Modules\Portal\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Core\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use BelongsToCompany, HasUuid;

    protected $fillable = [
        'company_id',
        'uuid',
        'name',
        'sku',
        'description',
        'unit_price',
        'currency',
        'stock',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'unit_price' => 'integer',
            'stock' => 'integer',
            'is_active' => 'boolean',
        ];
    }
}
