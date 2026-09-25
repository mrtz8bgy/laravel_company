<?php

declare(strict_types=1);

namespace App\Modules\Portal\Actions;

use App\Core\Services\ActivityLogger;
use App\Modules\Identity\Models\User;
use App\Modules\Portal\Models\CustomerThread;
use App\Modules\Portal\Models\CustomerThreadMessage;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class ReplyToThread
{
    public function __construct(private readonly ActivityLogger $activity) {}

    public function handle(CustomerThread $thread, User $actor, string $body, bool $staff): CustomerThread
    {
        if ($thread->status === CustomerThread::CLOSED) {
            throw ValidationException::withMessages([
                'thread' => [__('messages.request_closed')],
            ]);
        }

        return DB::transaction(function () use ($thread, $actor, $body, $staff): CustomerThread {
            CustomerThreadMessage::query()->create([
                'thread_id' => $thread->id,
                'user_id' => $actor->id,
                'body' => $body,
                'is_staff' => $staff,
            ]);

            $thread->forceFill([
                'status' => $staff ? CustomerThread::ANSWERED : CustomerThread::OPEN,
            ])->save();

            $this->activity->log('CREATE', $thread, null, [
                'staff' => $staff,
            ], 'Customer message reply');

            return $thread->fresh('messages.user:id,uuid,name');
        });
    }

    public function close(CustomerThread $thread, User $actor): CustomerThread
    {
        $thread->forceFill(['status' => CustomerThread::CLOSED])->save();
        $this->activity->log('UPDATE', $thread, null, ['status' => CustomerThread::CLOSED], 'Customer thread closed', null, $actor->id);

        return $thread;
    }
}
