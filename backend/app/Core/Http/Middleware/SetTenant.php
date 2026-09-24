<?php

declare(strict_types=1);

namespace App\Core\Http\Middleware;

use App\Core\Support\ApiResponse;
use App\Core\Support\TenantContext;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SetTenant
{
    public function __construct(private readonly TenantContext $tenant) {}

    public function handle(Request $request, Closure $next): Response
    {
        $this->tenant->clear();

        /** @var User|null $user */
        $user = $request->user();
        if (! $user) {
            return ApiResponse::error(__('auth.unauthenticated'), 401);
        }

        $token = $user->currentAccessToken();
        $companyId = $token?->company_id;

        if (! $companyId && $user->is_platform_admin && $request->headers->has('X-Company-Id')) {
            $company = Company::query()->where('uuid', (string) $request->header('X-Company-Id'))->first();
            if (! $company) {
                return ApiResponse::error(__('messages.not_found'), 404);
            }

            return $this->bind($company, $user, $next, $request);
        }

        if (! $companyId) {
            return ApiResponse::error(__('auth.company_required'), 409);
        }

        $company = Company::query()->find($companyId);
        if (! $company || ! $company->isActive()) {
            return ApiResponse::error(__('auth.company_unavailable'), 403);
        }

        if (! $user->is_platform_admin && ! $user->belongsToCompany($company)) {
            return ApiResponse::error(__('auth.forbidden'), 403);
        }

        $membership = $user->membershipIn($company);
        if ($membership && $membership->status !== 'active' && ! $user->is_platform_admin) {
            return ApiResponse::error(__('auth.inactive'), 403);
        }

        return $this->bind($company, $user, $next, $request);
    }

    private function bind(Company $company, User $user, Closure $next, Request $request): Response
    {
        if (! $company->isActive()) {
            return ApiResponse::error(__('auth.company_unavailable'), 403);
        }

        $this->tenant->set($company);
        app()->setLocale($user->locale ?: $company->locale ?: config('app.locale'));

        return $next($request);
    }
}
