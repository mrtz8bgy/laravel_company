<?php

declare(strict_types=1);

namespace App\Modules\Portal\Actions;

use App\Core\Services\ActivityLogger;
use App\Modules\Portal\Models\Customer;
use App\Modules\Portal\Models\CustomerThread;
use App\Modules\Portal\Models\CustomerThreadMessage;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class OpenCustomerThread
{
    public function __construct(private readonly ActivityLogger $activity) {}

    public function handle(Customer $customer, string $desk, string $subject, string $body): CustomerThread
    {
        if (! $customer->isActive()) {
            throw ValidationException::withMessages([
                'customer' => [__('messages.portal_pending')],
            ]);
        }

        return DB::transaction(function () use ($customer, $desk, $subject, $body): CustomerThread {
            $thread = CustomerThread::query()->create([
                'customer_id' => $customer->id,
                'desk' => $desk,
                'subject' => $subject,
                'status' => CustomerThread::OPEN,
            ]);

            CustomerThreadMessage::query()->create([
                'thread_id' => $thread->id,
                'user_id' => $customer->user_id,
                'body' => $body,
                'is_staff' => false,
            ]);

            $this->activity->log('CREATE', $thread, null, [
                'desk' => $desk,
                'subject' => $subject,
            ], 'Customer message opened');

            return $thread->fresh('messages.user:id,uuid,name');
        });
    }
}
