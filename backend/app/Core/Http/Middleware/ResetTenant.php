<?php

declare(strict_types=1);

namespace App\Core\Http\Middleware;

use App\Core\Support\TenantContext;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Clears any leftover company context at the start of a request.
 * Required for long-lived workers and for the test suite, where the
 * container is reused between HTTP calls.
 */
class ResetTenant
{
    public function __construct(private readonly TenantContext $tenant) {}

    public function handle(Request $request, Closure $next): Response
    {
        $this->tenant->clear();
        auth()->forgetGuards();

        return $next($request);
    }
}
