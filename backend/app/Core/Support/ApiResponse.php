<?php

declare(strict_types=1);

namespace App\Core\Support;

use Illuminate\Http\JsonResponse;
use Illuminate\Pagination\LengthAwarePaginator;

class ApiResponse
{
    /**
     * @param  array<string, mixed>  $meta
     */
    public static function success(mixed $data = null, ?string $message = null, int $status = 200, array $meta = []): JsonResponse
    {
        $payload = [
            'success' => true,
            'data' => $data,
            'message' => $message,
            'errors' => [],
        ];

        if ($meta !== []) {
            $payload['meta'] = $meta;
        }

        return response()->json($payload, $status);
    }

    /**
     * @param  array<string, mixed>|array<int, mixed>  $errors
     */
    public static function error(string $message, int $status = 400, array $errors = [], mixed $data = null): JsonResponse
    {
        return response()->json([
            'success' => false,
            'data' => $data,
            'message' => $message,
            'errors' => $errors === [] ? [] : $errors,
        ], $status);
    }

    public static function paginated(LengthAwarePaginator $paginator, mixed $data): JsonResponse
    {
        return self::success($data, null, 200, [
            'current_page' => $paginator->currentPage(),
            'per_page' => $paginator->perPage(),
            'total' => $paginator->total(),
            'last_page' => $paginator->lastPage(),
        ]);
    }
}
