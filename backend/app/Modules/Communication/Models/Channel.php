<?php

declare(strict_types=1);

namespace App\Modules\Communication\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Core\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Channel extends Model
{
    use BelongsToCompany, HasUuid;

    protected $fillable = ['company_id', 'uuid', 'name', 'slug', 'kind'];

    public function messages(): HasMany
    {
        return $this->hasMany(Message::class);
    }
}
