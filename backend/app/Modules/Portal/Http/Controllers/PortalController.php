<?php

declare(strict_types=1);

namespace App\Modules\Portal\Http\Controllers;

use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Identity\Models\User;
use App\Modules\Portal\Actions\OpenCustomerThread;
use App\Modules\Portal\Actions\OpenCustomerTicket;
use App\Modules\Portal\Actions\PlaceOrder;
use App\Modules\Portal\Actions\ReplyToThread;
use App\Modules\Portal\Actions\ReplyToTicket;
use App\Modules\Portal\Http\Resources\CustomerResource;
use App\Modules\Portal\Http\Resources\OrderResource;
use App\Modules\Portal\Http\Resources\ProductResource;
use App\Modules\Portal\Http\Resources\ThreadResource;
use App\Modules\Portal\Http\Resources\TicketResource;
use App\Modules\Portal\Models\Customer;
use App\Modules\Portal\Models\CustomerOrder;
use App\Modules\Portal\Models\CustomerThread;
use App\Modules\Portal\Models\CustomerTicket;
use App\Modules\Portal\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class PortalController extends Controller
{
    public function __construct(
        private readonly PlaceOrder $placeOrder,
        private readonly OpenCustomerThread $openThread,
        private readonly ReplyToThread $reply,
        private readonly OpenCustomerTicket $openTicket,
        private readonly ReplyToTicket $replyTicket,
    ) {}

    public function me(Request $request): JsonResponse
    {
        $customer = $this->customer($request)->load('user:id,uuid,name,email,phone');

        return ApiResponse::success([
            'customer' => (new CustomerResource($customer))->resolve(),
            'summary' => [
                'orders' => $customer->orders()->count(),
                'open_threads' => $customer->threads()->where('status', '!=', CustomerThread::CLOSED)->count(),
                'open_tickets' => $customer->tickets()->where('status', '!=', CustomerTicket::CLOSED)->count(),
            ],
        ]);
    }

    public function updateMe(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:120'],
            'phone' => ['nullable', 'string', 'max:32'],
            'organization_name' => ['nullable', 'string', 'max:160'],
            'note' => ['nullable', 'string', 'max:1000'],
        ]);

        $customer = $this->customer($request);
        $user = $request->user();
        if (array_key_exists('name', $data)) {
            $user->forceFill(['name' => $data['name']])->save();
        }
        if (array_key_exists('phone', $data)) {
            $user->forceFill(['phone' => $data['phone']])->save();
            $customer->phone = $data['phone'];
        }
        if (array_key_exists('organization_name', $data)) {
            $customer->organization_name = $data['organization_name'];
        }
        if (array_key_exists('note', $data)) {
            $customer->note = $data['note'];
        }
        $customer->save();

        return ApiResponse::success(
            (new CustomerResource($customer->fresh('user:id,uuid,name,email,phone')))->resolve(),
            __('messages.saved'),
        );
    }

    public function products(): JsonResponse
    {
        $products = Product::query()->where('is_active', true)->orderBy('name')->get();

        return ApiResponse::success(ProductResource::collection($products)->resolve());
    }

    public function orders(Request $request): JsonResponse
    {
        $orders = CustomerOrder::query()
            ->where('customer_id', $this->customer($request)->id)
            ->with('items')
            ->latest()
            ->limit(50)
            ->get();

        return ApiResponse::success(OrderResource::collection($orders)->resolve());
    }

    public function storeOrder(Request $request): JsonResponse
    {
        $data = $request->validate([
            'note' => ['nullable', 'string', 'max:2000'],
            'items' => ['required', 'array', 'min:1', 'max:30'],
            'items.*.product_uuid' => ['required', 'uuid'],
            'items.*.quantity' => ['required', 'integer', 'min:1', 'max:999'],
        ]);

        try {
            $order = $this->placeOrder->handle($this->customer($request), $data['items'], $data['note'] ?? null);
        } catch (ValidationException $exception) {
            return ApiResponse::error($exception->getMessage() ?: __('messages.invalid'), 422, $exception->errors());
        }

        return ApiResponse::success((new OrderResource($order))->resolve(), __('messages.order_placed'), 201);
    }

    public function threads(Request $request): JsonResponse
    {
        $threads = CustomerThread::query()
            ->where('customer_id', $this->customer($request)->id)
            ->latest('updated_at')
            ->limit(50)
            ->get();

        return ApiResponse::success(ThreadResource::collection($threads)->resolve());
    }

    public function showThread(Request $request, string $thread): JsonResponse
    {
        $record = $this->ownThread($request, $thread);

        return ApiResponse::success((new ThreadResource($record))->resolve());
    }

    public function storeThread(Request $request): JsonResponse
    {
        $data = $request->validate([
            'desk' => ['required', 'in:sales,support,management'],
            'subject' => ['required', 'string', 'max:160'],
            'body' => ['required', 'string', 'max:5000'],
        ]);

        try {
            $thread = $this->openThread->handle(
                $this->customer($request),
                $data['desk'],
                $data['subject'],
                $data['body'],
            );
        } catch (ValidationException $exception) {
            return ApiResponse::error(__('messages.invalid'), 422, $exception->errors());
        }

        return ApiResponse::success((new ThreadResource($thread))->resolve(), __('messages.message_sent'), 201);
    }

    public function reply(Request $request, string $thread): JsonResponse
    {
        $data = $request->validate([
            'body' => ['required', 'string', 'max:5000'],
        ]);

        $record = $this->ownThread($request, $thread);

        try {
            $updated = $this->reply->handle($record, $request->user(), $data['body'], false);
        } catch (ValidationException $exception) {
            return ApiResponse::error(__('messages.invalid'), 422, $exception->errors());
        }

        return ApiResponse::success((new ThreadResource($updated))->resolve(), __('messages.message_sent'));
    }

    private function customer(Request $request): Customer
    {
        /** @var Customer $customer */
        $customer = $request->attributes->get('portal_customer');

        return $customer;
    }

    private function ownThread(Request $request, string $uuid): CustomerThread
    {
        $thread = CustomerThread::query()
            ->where('customer_id', $this->customer($request)->id)
            ->where('uuid', $uuid)
            ->with(['messages.user:id,uuid,name'])
            ->first();

        abort_if($thread === null, 404);

        return $thread;
    }

    public function tickets(Request $request): JsonResponse
    {
        $tickets = CustomerTicket::query()
            ->where('customer_id', $this->customer($request)->id)
            ->latest('updated_at')
            ->limit(50)
            ->get();

        return ApiResponse::success(TicketResource::collection($tickets)->resolve());
    }

    public function showTicket(Request $request, string $ticket): JsonResponse
    {
        return ApiResponse::success((new TicketResource($this->ownTicket($request, $ticket)))->resolve());
    }

    public function storeTicket(Request $request): JsonResponse
    {
        $data = $request->validate([
            'desk' => ['required', 'in:sales,support,management'],
            'subject' => ['required', 'string', 'max:160'],
            'body' => ['required', 'string', 'max:5000'],
            'priority' => ['sometimes', 'in:low,normal,high'],
        ]);

        try {
            $ticket = $this->openTicket->handle(
                $this->customer($request),
                $data['desk'],
                $data['subject'],
                $data['body'],
                $data['priority'] ?? 'normal',
            );
        } catch (ValidationException $exception) {
            return ApiResponse::error(__('messages.invalid'), 422, $exception->errors());
        }

        return ApiResponse::success((new TicketResource($ticket))->resolve(), __('messages.ticket_opened'), 201);
    }

    public function replyTicket(Request $request, string $ticket): JsonResponse
    {
        $data = $request->validate([
            'body' => ['required', 'string', 'max:5000'],
        ]);
        $record = $this->ownTicket($request, $ticket);

        try {
            $updated = $this->replyTicket->handle($record, $request->user(), $data['body'], false);
        } catch (ValidationException $exception) {
            return ApiResponse::error(__('messages.invalid'), 422, $exception->errors());
        }

        return ApiResponse::success((new TicketResource($updated))->resolve(), __('messages.message_sent'));
    }

    private function ownTicket(Request $request, string $uuid): CustomerTicket
    {
        $ticket = CustomerTicket::query()
            ->where('customer_id', $this->customer($request)->id)
            ->where('uuid', $uuid)
            ->with(['messages.user:id,uuid,name'])
            ->first();

        abort_if($ticket === null, 404);

        return $ticket;
    }
}
