<?php

declare(strict_types=1);

namespace App\Modules\Portal\Actions;

use App\Core\Services\ActivityLogger;
use App\Modules\Portal\Models\Customer;
use App\Modules\Portal\Models\CustomerOrder;
use App\Modules\Portal\Models\CustomerOrderItem;
use App\Modules\Portal\Models\Product;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class PlaceOrder
{
    public function __construct(private readonly ActivityLogger $activity) {}

    /**
     * @param  list<array{product_uuid: string, quantity: int}>  $lines
     */
    public function handle(Customer $customer, array $lines, ?string $note = null): CustomerOrder
    {
        if (! $customer->isActive()) {
            throw ValidationException::withMessages([
                'customer' => [__('messages.portal_pending')],
            ]);
        }

        if ($lines === []) {
            throw ValidationException::withMessages([
                'items' => [__('messages.invalid')],
            ]);
        }

        return DB::transaction(function () use ($customer, $lines, $note): CustomerOrder {
            $currency = 'IRR';
            $total = 0;
            $prepared = [];

            foreach ($lines as $line) {
                $product = Product::query()
                    ->where('uuid', $line['product_uuid'])
                    ->lockForUpdate()
                    ->first();

                if (! $product || ! $product->is_active) {
                    throw ValidationException::withMessages([
                        'items' => [__('messages.not_found')],
                    ]);
                }

                $quantity = (int) $line['quantity'];
                if ($product->stock !== null && $quantity > $product->stock) {
                    throw ValidationException::withMessages([
                        'items' => [__('messages.insufficient_stock')],
                    ]);
                }

                $lineTotal = (int) $product->unit_price * $quantity;
                $total += $lineTotal;
                $currency = $product->currency ?: $currency;
                $prepared[] = [$product, $quantity, $lineTotal];
            }

            $order = CustomerOrder::query()->create([
                'customer_id' => $customer->id,
                'number' => $this->nextNumber(),
                'status' => CustomerOrder::SUBMITTED,
                'note' => $note,
                'total_amount' => $total,
                'currency' => $currency,
            ]);

            foreach ($prepared as [$product, $quantity, $lineTotal]) {
                CustomerOrderItem::query()->create([
                    'order_id' => $order->id,
                    'product_id' => $product->id,
                    'name' => $product->name,
                    'quantity' => $quantity,
                    'unit_price' => (int) $product->unit_price,
                    'line_total' => $lineTotal,
                ]);
                if ($product->stock !== null) {
                    $product->decrement('stock', $quantity);
                }
            }

            $this->activity->log('CREATE', $order, null, [
                'number' => $order->number,
                'total_amount' => $total,
            ], 'Customer order placed');

            return $order->fresh('items');
        });
    }

    private function nextNumber(): string
    {
        $latest = CustomerOrder::query()->lockForUpdate()->orderByDesc('id')->value('number');
        $sequence = 1;
        if (is_string($latest) && preg_match('/(\d+)$/', $latest, $match)) {
            $sequence = ((int) $match[1]) + 1;
        }

        return 'ORD-'.str_pad((string) $sequence, 4, '0', STR_PAD_LEFT);
    }
}
