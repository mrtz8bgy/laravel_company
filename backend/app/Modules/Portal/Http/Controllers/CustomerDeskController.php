<?php

declare(strict_types=1);

namespace App\Modules\Portal\Http\Controllers;

use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Identity\Models\User;
use App\Modules\Portal\Actions\ReplyToThread;
use App\Modules\Portal\Actions\ReplyToTicket;
use App\Modules\Portal\Actions\ReviewCustomer;
use App\Modules\Portal\Actions\UpdateOrderStatus;
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
use App\Modules\Portal\Services\PortalAccess;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class CustomerDeskController extends Controller
{
    public function __construct(
        private readonly PortalAccess $access,
        private readonly ReviewCustomer $review,
        private readonly UpdateOrderStatus $updateOrder,
        private readonly ReplyToThread $reply,
        private readonly ReplyToTicket $replyTicket,
    ) {}

    public function home(Request $request): JsonResponse
    {
        $user = $request->user();
        $desks = $this->access->desksFor($user);
        if ($desks === [] && ! $this->access->canViewCustomers($user) && ! $this->access->canViewOrders($user)) {
            return ApiResponse::error(__('auth.forbidden'), 403);
        }

        return ApiResponse::success([
            'desks' => $desks,
            'can_review' => $this->access->canReview($user),
            'can_customers' => $this->access->canViewCustomers($user),
            'can_orders' => $this->access->canViewOrders($user),
            'can_manage_orders' => $this->access->canManageOrders($user),
            'can_products' => $this->access->canViewProducts($user),
            'can_manage_products' => $this->access->canManageProducts($user),
            'pending_customers' => $this->access->canReview($user)
                ? Customer::query()->where('status', Customer::PENDING)->count()
                : 0,
        ]);
    }

    public function customers(Request $request): JsonResponse
    {
        $customers = Customer::query()
            ->with('user:id,uuid,name,email,phone')
            ->when($request->filled('status'), fn ($query) => $query->where('status', $request->string('status')->toString()))
            ->latest()
            ->limit(100)
            ->get();

        return ApiResponse::success(CustomerResource::collection($customers)->resolve());
    }

    public function reviewCustomer(Request $request, string $customer): JsonResponse
    {
        $data = $request->validate([
            'decision' => ['required', 'in:approve,reject'],
            'review_note' => ['nullable', 'string', 'max:1000'],
        ]);

        $record = Customer::query()->where('uuid', $customer)->first();
        if (! $record) {
            return ApiResponse::error(__('messages.not_found'), 404);
        }

        try {
            $updated = $this->review->handle($record, $request->user(), $data['decision'], $data['review_note'] ?? null);
        } catch (ValidationException $exception) {
            return ApiResponse::error(__('messages.invalid'), 422, $exception->errors());
        }

        return ApiResponse::success(
            (new CustomerResource($updated))->resolve(),
            $data['decision'] === 'approve' ? __('messages.portal_approved') : __('messages.portal_rejected'),
        );
    }

    public function products(): JsonResponse
    {
        return ApiResponse::success(ProductResource::collection(Product::query()->orderBy('name')->get())->resolve());
    }

    public function storeProduct(Request $request): JsonResponse
    {
        $product = Product::query()->create($this->productData($request));

        return ApiResponse::success((new ProductResource($product))->resolve(), __('messages.created'), 201);
    }

    public function updateProduct(Request $request, string $product): JsonResponse
    {
        $record = Product::query()->where('uuid', $product)->first();
        if (! $record) {
            return ApiResponse::error(__('messages.not_found'), 404);
        }

        $record->fill($this->productData($request, false))->save();

        return ApiResponse::success((new ProductResource($record))->resolve(), __('messages.saved'));
    }

    public function orders(): JsonResponse
    {
        $orders = CustomerOrder::query()
            ->with(['items', 'customer.user:id,uuid,name,email,phone'])
            ->latest()
            ->limit(100)
            ->get();

        return ApiResponse::success(OrderResource::collection($orders)->resolve());
    }

    public function updateOrder(Request $request, string $order): JsonResponse
    {
        $data = $request->validate([
            'status' => ['required', 'in:reviewing,confirmed,rejected,fulfilled'],
            'staff_note' => ['nullable', 'string', 'max:2000'],
        ]);

        $record = CustomerOrder::query()->where('uuid', $order)->first();
        if (! $record) {
            return ApiResponse::error(__('messages.not_found'), 404);
        }

        try {
            $updated = $this->updateOrder->handle($record, $request->user(), $data['status'], $data['staff_note'] ?? null);
        } catch (ValidationException $exception) {
            return ApiResponse::error(__('messages.invalid'), 422, $exception->errors());
        }

        return ApiResponse::success((new OrderResource($updated))->resolve(), __('messages.saved'));
    }

    public function threads(Request $request): JsonResponse
    {
        $desk = $request->string('desk')->toString();
        if (! $this->access->canOpenDesk($request->user(), $desk)) {
            return ApiResponse::error(__('auth.forbidden'), 403);
        }

        $threads = CustomerThread::query()
            ->where('desk', $desk)
            ->with('customer.user:id,uuid,name,email')
            ->latest('updated_at')
            ->limit(100)
            ->get();

        return ApiResponse::success(ThreadResource::collection($threads)->resolve());
    }

    public function showThread(Request $request, string $thread): JsonResponse
    {
        $record = $this->staffThread($request->user(), $thread);
        if (! $record) {
            return ApiResponse::error(__('messages.not_found'), 404);
        }

        return ApiResponse::success((new ThreadResource($record))->resolve());
    }

    public function reply(Request $request, string $thread): JsonResponse
    {
        $data = $request->validate([
            'body' => ['required', 'string', 'max:5000'],
            'close' => ['sometimes', 'boolean'],
        ]);

        $record = $this->staffThread($request->user(), $thread);
        if (! $record) {
            return ApiResponse::error(__('messages.not_found'), 404);
        }

        try {
            $updated = $this->reply->handle($record, $request->user(), $data['body'], true);
            if (! empty($data['close'])) {
                $updated = $this->reply->close($updated, $request->user());
            }
        } catch (ValidationException $exception) {
            return ApiResponse::error(__('messages.invalid'), 422, $exception->errors());
        }

        return ApiResponse::success((new ThreadResource($updated->fresh('messages.user:id,uuid,name')))->resolve(), __('messages.message_sent'));
    }

    public function tickets(Request $request): JsonResponse
    {
        $desk = $request->string('desk')->toString();
        if (! $this->access->canOpenDesk($request->user(), $desk)) {
            return ApiResponse::error(__('auth.forbidden'), 403);
        }

        $tickets = CustomerTicket::query()
            ->where('desk', $desk)
            ->with('customer.user:id,uuid,name,email')
            ->latest('updated_at')
            ->limit(100)
            ->get();

        return ApiResponse::success(TicketResource::collection($tickets)->resolve());
    }

    public function showTicket(Request $request, string $ticket): JsonResponse
    {
        $record = $this->staffTicket($request->user(), $ticket);
        if (! $record) {
            return ApiResponse::error(__('messages.not_found'), 404);
        }

        return ApiResponse::success((new TicketResource($record))->resolve());
    }

    public function replyTicket(Request $request, string $ticket): JsonResponse
    {
        $data = $request->validate([
            'body' => ['required', 'string', 'max:5000'],
            'status' => ['sometimes', 'in:open,in_progress,answered,closed'],
        ]);

        $record = $this->staffTicket($request->user(), $ticket);
        if (! $record) {
            return ApiResponse::error(__('messages.not_found'), 404);
        }

        try {
            $updated = $this->replyTicket->handle(
                $record,
                $request->user(),
                $data['body'],
                true,
                $data['status'] ?? null,
            );
        } catch (ValidationException $exception) {
            return ApiResponse::error(__('messages.invalid'), 422, $exception->errors());
        }

        return ApiResponse::success((new TicketResource($updated->fresh(['messages.user:id,uuid,name', 'customer.user:id,uuid,name,email'])))->resolve(), __('messages.message_sent'));
    }

    public function updateTicket(Request $request, string $ticket): JsonResponse
    {
        $data = $request->validate([
            'status' => ['required', 'in:open,in_progress,answered,closed'],
        ]);
        $record = $this->staffTicket($request->user(), $ticket);
        if (! $record) {
            return ApiResponse::error(__('messages.not_found'), 404);
        }

        $updated = $this->replyTicket->updateStatus($record, $request->user(), $data['status']);

        return ApiResponse::success((new TicketResource($updated))->resolve(), __('messages.saved'));
    }

    /**
     * @return array<string, mixed>
     */
    private function productData(Request $request, bool $creating = true): array
    {
        $data = $request->validate([
            'name' => [$creating ? 'required' : 'sometimes', 'string', 'max:160'],
            'sku' => ['nullable', 'string', 'max:40'],
            'description' => ['nullable', 'string', 'max:2000'],
            'unit_price' => [$creating ? 'required' : 'sometimes', 'integer', 'min:0'],
            'currency' => ['sometimes', 'string', 'size:3'],
            'stock' => ['nullable', 'integer', 'min:0'],
            'is_active' => ['sometimes', 'boolean'],
        ]);

        if (array_key_exists('sku', $data) && $data['sku'] === '') {
            $data['sku'] = null;
        }

        return $data;
    }

    private function staffThread(User $user, string $uuid): ?CustomerThread
    {
        $thread = CustomerThread::query()
            ->where('uuid', $uuid)
            ->with(['messages.user:id,uuid,name', 'customer.user:id,uuid,name,email,phone'])
            ->first();

        if (! $thread || ! $this->access->canOpenDesk($user, $thread->desk)) {
            return null;
        }

        return $thread;
    }

    private function staffTicket(User $user, string $uuid): ?CustomerTicket
    {
        $ticket = CustomerTicket::query()
            ->where('uuid', $uuid)
            ->with(['messages.user:id,uuid,name', 'customer.user:id,uuid,name,email,phone'])
            ->first();

        if (! $ticket || ! $this->access->canOpenDesk($user, $ticket->desk)) {
            return null;
        }

        return $ticket;
    }
}
