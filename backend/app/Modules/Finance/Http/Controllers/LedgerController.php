<?php

declare(strict_types=1);

namespace App\Modules\Finance\Http\Controllers;

use App\Core\Services\ActivityLogger;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Finance\Models\Expense;
use App\Modules\Finance\Models\Invoice;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LedgerController extends Controller
{
    public function __construct(private readonly ActivityLogger $activity) {}

    public function invoices(): JsonResponse
    {
        return ApiResponse::success(Invoice::query()->latest()->limit(100)->get()->map(fn (Invoice $invoice) => [
            'uuid' => $invoice->uuid,
            'number' => $invoice->number,
            'party_name' => $invoice->party_name,
            'amount' => $invoice->amount,
            'currency' => $invoice->currency,
            'status' => $invoice->status,
            'issued_on' => $invoice->issued_on?->toDateString(),
            'due_on' => $invoice->due_on?->toDateString(),
        ])->all());
    }

    public function storeInvoice(Request $request): JsonResponse
    {
        $data = $request->validate([
            'number' => ['required', 'string', 'max:32'],
            'party_name' => ['required', 'string', 'max:160'],
            'amount' => ['required', 'integer', 'min:0'],
            'currency' => ['nullable', 'string', 'size:3'],
            'status' => ['nullable', 'in:draft,sent,paid,overdue'],
            'issued_on' => ['nullable', 'date'],
            'due_on' => ['nullable', 'date'],
        ]);
        $invoice = Invoice::query()->create([
            ...$data,
            'currency' => $data['currency'] ?? 'IRR',
            'status' => $data['status'] ?? 'draft',
        ]);
        $this->activity->log('CREATE', $invoice, null, ['number' => $invoice->number, 'status' => $invoice->status]);

        return ApiResponse::success(['uuid' => $invoice->uuid, 'number' => $invoice->number], __('messages.created'), 201);
    }

    public function expenses(): JsonResponse
    {
        return ApiResponse::success(Expense::query()->latest()->limit(100)->get()->map(fn (Expense $expense) => [
            'uuid' => $expense->uuid,
            'category' => $expense->category,
            'amount' => $expense->amount,
            'currency' => $expense->currency,
            'status' => $expense->status,
            'spent_on' => $expense->spent_on?->toDateString(),
            'note' => $expense->note,
        ])->all());
    }

    public function storeExpense(Request $request): JsonResponse
    {
        $data = $request->validate([
            'category' => ['required', 'string', 'max:64'],
            'amount' => ['required', 'integer', 'min:0'],
            'currency' => ['nullable', 'string', 'size:3'],
            'spent_on' => ['nullable', 'date'],
            'note' => ['nullable', 'string', 'max:500'],
        ]);
        $expense = Expense::query()->create([
            ...$data,
            'currency' => $data['currency'] ?? 'IRR',
            'status' => 'recorded',
        ]);
        $this->activity->log('CREATE', $expense, null, ['category' => $expense->category, 'status' => $expense->status]);

        return ApiResponse::success(['uuid' => $expense->uuid], __('messages.created'), 201);
    }
}
