<?php

declare(strict_types=1);

namespace App\Core\Http\Controllers;

use App\Core\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class HealthController
{
    public function __invoke(): JsonResponse
    {
        try {
            DB::select('select 1');
        } catch (\Throwable) {
            return ApiResponse::error('Database unavailable.', 503, [], [
                'status' => 'degraded',
                'service' => 'virtual-company-os',
            ]);
        }

        return ApiResponse::success([
            'status' => 'ok',
            'service' => 'virtual-company-os',
            'time' => now()->toIso8601String(),
        ]);
    }
}
