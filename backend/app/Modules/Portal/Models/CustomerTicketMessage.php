<?php

declare(strict_types=1);

namespace App\Modules\Portal\Models;

use App\Core\Models\Concerns\BelongsToCompany;
use App\Modules\Identity\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CustomerTicketMessage extends Model
{
    use BelongsToCompany;

    protected $fillable = [
        'company_id',
        'ticket_id',
        'user_id',
        'body',
        'is_staff',
    ];

    protected function casts(): array
    {
        return [
            'is_staff' => 'boolean',
        ];
    }

    public function ticket(): BelongsTo
    {
        return $this->belongsTo(CustomerTicket::class, 'ticket_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
