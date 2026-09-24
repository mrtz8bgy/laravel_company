<?php

declare(strict_types=1);

namespace App\Core\Http\Middleware;

use App\Core\Support\ApiResponse;
use App\Core\Support\TenantContext;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsurePlatformAdmin
{
    public function __construct(private readonly TenantContext $tenant) {}

    public function handle(Request $request, Closure $next): Response
    {
        $this->tenant->clear();

        $user = $request->user();
        if (! $user || ! $user->is_platform_admin) {
            return ApiResponse::error(__('auth.forbidden'), 403);
        }

        return $next($request);
    }
}
