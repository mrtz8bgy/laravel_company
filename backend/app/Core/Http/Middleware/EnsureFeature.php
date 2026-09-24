<?php

declare(strict_types=1);

namespace App\Core\Http\Middleware;

use App\Core\Support\ApiResponse;
use App\Modules\Organizations\Models\Feature;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureFeature
{
    public function handle(Request $request, Closure $next, string $key): Response
    {
        $enabled = Feature::query()->where('key', $key)->value('enabled');

        if (! $enabled) {
            return ApiResponse::error(__('messages.feature_disabled'), 403);
        }

        return $next($request);
    }
}
