<?php

declare(strict_types=1);

namespace App\Core\Http\Middleware;

use App\Core\Support\ApiResponse;
use App\Core\Support\TenantContext;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use App\Modules\Portal\Models\Customer;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Binds the company for a customer, including a registration that is still pending.
 * Staff routes keep using SetTenant, which refuses a non-active membership.
 */
class SetPortalTenant
{
    public function __construct(private readonly TenantContext $tenant) {}

    public function handle(Request $request, Closure $next): Response
    {
        $this->tenant->clear();

        /** @var User|null $user */
        $user = $request->user();
        if (! $user || ! $user->isActive()) {
            return ApiResponse::error(__('auth.unauthenticated'), 401);
        }

        $companyId = $user->currentAccessToken()?->company_id;
        $company = $companyId ? Company::query()->find($companyId) : null;
        if (! $company || ! $company->isActive()) {
            return ApiResponse::error(__('auth.company_unavailable'), 403);
        }

        $customer = Customer::query()
            ->withoutGlobalScope('company')
            ->where('company_id', $company->id)
            ->where('user_id', $user->id)
            ->first();

        if (! $customer) {
            return ApiResponse::error(__('auth.forbidden'), 403);
        }

        $this->tenant->set($company);
        app()->setLocale($user->locale ?: $company->locale ?: config('app.locale'));
        $request->attributes->set('portal_customer', $customer);

        return $next($request);
    }
}
