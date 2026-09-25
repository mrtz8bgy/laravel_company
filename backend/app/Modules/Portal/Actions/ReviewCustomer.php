<?php

declare(strict_types=1);

namespace App\Modules\Portal\Actions;

use App\Core\Services\ActivityLogger;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\CompanyMembership;
use App\Modules\Portal\Models\Customer;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class ReviewCustomer
{
    public function __construct(private readonly ActivityLogger $activity) {}

    public function handle(Customer $customer, User $actor, string $decision, ?string $note = null): Customer
    {
        if ($customer->user_id === $actor->id) {
            throw ValidationException::withMessages([
                'customer' => [__('messages.cannot_review_own')],
            ]);
        }

        if (! in_array($customer->status, [Customer::PENDING, Customer::REJECTED], true) && $decision === 'reject') {
            throw ValidationException::withMessages([
                'status' => [__('messages.request_closed')],
            ]);
        }

        return DB::transaction(function () use ($customer, $actor, $decision, $note): Customer {
            $approved = $decision === 'approve';
            $customer->forceFill([
                'status' => $approved ? Customer::ACTIVE : Customer::REJECTED,
                'review_note' => $note,
                'reviewer_id' => $actor->id,
                'reviewed_at' => now(),
            ])->save();

            CompanyMembership::query()
                ->where('company_id', $customer->company_id)
                ->where('user_id', $customer->user_id)
                ->update([
                    'status' => $approved ? 'active' : 'rejected',
                    'joined_at' => $approved ? now() : null,
                    'updated_at' => now(),
                ]);

            $this->activity->log('UPDATE', $customer, null, [
                'status' => $customer->status,
            ], $approved ? 'Customer approved' : 'Customer rejected');

            return $customer->fresh(['user:id,uuid,name,email,phone']);
        });
    }
}
