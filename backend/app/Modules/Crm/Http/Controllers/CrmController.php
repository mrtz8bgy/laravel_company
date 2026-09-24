<?php

declare(strict_types=1);

namespace App\Modules\Crm\Http\Controllers;

use App\Core\Services\ActivityLogger;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Crm\Models\Account;
use App\Modules\Crm\Models\Contact;
use App\Modules\Crm\Models\Deal;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CrmController extends Controller
{
    public function __construct(private readonly ActivityLogger $activity) {}

    public function accounts(): JsonResponse
    {
        return ApiResponse::success(Account::query()->orderBy('name')->get()->map(fn (Account $account) => [
            'uuid' => $account->uuid,
            'name' => $account->name,
            'status' => $account->status,
        ])->all());
    }

    public function storeAccount(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:160'],
            'status' => ['nullable', 'in:active,paused'],
        ]);
        $account = Account::query()->create(['name' => $data['name'], 'status' => $data['status'] ?? 'active']);
        $this->activity->log('CREATE', $account, null, ['name' => $account->name]);

        return ApiResponse::success(['uuid' => $account->uuid, 'name' => $account->name], __('messages.created'), 201);
    }

    public function contacts(): JsonResponse
    {
        return ApiResponse::success(Contact::query()->with('account:id,uuid,name')->orderBy('name')->get()->map(fn (Contact $contact) => [
            'uuid' => $contact->uuid,
            'name' => $contact->name,
            'email' => $contact->email,
            'phone' => $contact->phone,
            'account' => $contact->account ? ['uuid' => $contact->account->uuid, 'name' => $contact->account->name] : null,
        ])->all());
    }

    public function storeContact(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:160'],
            'email' => ['nullable', 'email', 'max:160'],
            'phone' => ['nullable', 'string', 'max:32'],
            'account_uuid' => ['nullable', 'uuid'],
        ]);
        $accountId = ! empty($data['account_uuid'])
            ? Account::query()->where('uuid', $data['account_uuid'])->value('id')
            : null;
        $contact = Contact::query()->create([
            'name' => $data['name'],
            'email' => $data['email'] ?? null,
            'phone' => $data['phone'] ?? null,
            'account_id' => $accountId,
        ]);

        return ApiResponse::success(['uuid' => $contact->uuid, 'name' => $contact->name], __('messages.created'), 201);
    }

    public function deals(): JsonResponse
    {
        return ApiResponse::success(Deal::query()->with('account:id,uuid,name')->latest()->limit(100)->get()->map(fn (Deal $deal) => [
            'uuid' => $deal->uuid,
            'title' => $deal->title,
            'stage' => $deal->stage,
            'amount' => $deal->amount,
            'currency' => $deal->currency,
            'account' => $deal->account ? ['name' => $deal->account->name] : null,
        ])->all());
    }

    public function storeDeal(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title' => ['required', 'string', 'max:160'],
            'stage' => ['nullable', 'in:lead,qualified,proposal,won,lost'],
            'amount' => ['nullable', 'integer', 'min:0'],
            'currency' => ['nullable', 'string', 'size:3'],
            'account_uuid' => ['nullable', 'uuid'],
        ]);
        $deal = Deal::query()->create([
            'title' => $data['title'],
            'stage' => $data['stage'] ?? 'lead',
            'amount' => $data['amount'] ?? 0,
            'currency' => $data['currency'] ?? 'IRR',
            'account_id' => ! empty($data['account_uuid']) ? Account::query()->where('uuid', $data['account_uuid'])->value('id') : null,
            'owner_id' => $request->user()->id,
        ]);
        $this->activity->log('CREATE', $deal, null, ['title' => $deal->title, 'stage' => $deal->stage]);

        return ApiResponse::success(['uuid' => $deal->uuid, 'title' => $deal->title], __('messages.created'), 201);
    }

    public function updateDeal(Request $request, Deal $deal): JsonResponse
    {
        $data = $request->validate(['stage' => ['required', 'in:lead,qualified,proposal,won,lost']]);
        $deal->update($data);
        $this->activity->log('UPDATE', $deal, null, ['stage' => $deal->stage]);

        return ApiResponse::success(['uuid' => $deal->uuid, 'stage' => $deal->stage], __('messages.updated'));
    }
}
