<?php

declare(strict_types=1);

namespace App\Modules\Projects\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Core\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class KanbanColumn extends Model
{
    use BelongsToCompany, HasUuid;

    protected $fillable = [
        'company_id',
        'project_id',
        'uuid',
        'name',
        'sort_order',
        'is_done',
    ];

    protected function casts(): array
    {
        return [
            'sort_order' => 'integer',
            'is_done' => 'boolean',
        ];
    }

    public function project(): BelongsTo
    {
        return $this->belongsTo(Project::class);
    }

    public function tasks(): HasMany
    {
        return $this->hasMany(Task::class, 'column_id')->orderBy('sort_order');
    }
}
