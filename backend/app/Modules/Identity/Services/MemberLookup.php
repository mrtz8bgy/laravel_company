<?php

declare(strict_types=1);

namespace App\Modules\Identity\Services;

use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\CompanyMembership;
use Illuminate\Database\Eloquent\ModelNotFoundException;

/**
 * Resolve a person inside the current company.
 *
 * An outsider is always a 404, never a 403, so a guessed uuid does not confirm
 * that the person exists somewhere else.
 */
class MemberLookup
{
    public function activeMember(string $uuid): User
    {
        $ids = User::query()->where('uuid', $uuid)->select('id');

        $exists = CompanyMembership::query()
            ->where('company_id', tenantId())
            ->where('status', 'active')
            ->whereIn('user_id', $ids)
            ->exists();

        if (! $exists) {
            throw (new ModelNotFoundException())->setModel(User::class);
        }

        /** @var User $user */
        $user = User::query()->where('uuid', $uuid)->firstOrFail();

        return $user;
    }
}
