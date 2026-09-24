<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    use BelongsToCompany;

    protected $fillable = [
        'company_id',
        'key',
        'value',
    ];

    protected function casts(): array
    {
        return [
            'value' => 'array',
        ];
    }
}
