<?php

declare(strict_types=1);

namespace App\Core\Http\Middleware;

use App\Core\Services\AuthorizationService;
use App\Core\Support\ApiResponse;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsurePermission
{
    public function __construct(private readonly AuthorizationService $authorization) {}

    public function handle(Request $request, Closure $next, string $permission): Response
    {
        $user = $request->user();
        if (! $user || ! $this->authorization->allows($user, $permission)) {
            return ApiResponse::error(__('auth.forbidden'), 403);
        }

        return $next($request);
    }
}
