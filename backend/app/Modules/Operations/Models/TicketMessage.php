<?php

declare(strict_types=1);

namespace App\Modules\Operations\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Core\Models\Concerns\HasUuid;
use App\Modules\Identity\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TicketMessage extends Model
{
    use BelongsToCompany, HasUuid;

    protected $fillable = ['company_id', 'ticket_id', 'user_id', 'uuid', 'body'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
