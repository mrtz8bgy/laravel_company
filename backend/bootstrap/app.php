<?php

use App\Core\Http\Middleware\EnsureFeature;
use App\Core\Http\Middleware\EnsurePermission;
use App\Core\Http\Middleware\EnsurePlatformAdmin;
use App\Core\Http\Middleware\ResetTenant;
use App\Core\Http\Middleware\SecurityHeaders;
use App\Core\Http\Middleware\SetTenant;
use App\Core\Support\ApiResponse;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Exceptions\ThrottleRequestsException;
use Illuminate\Http\Request;
use Illuminate\Routing\Exceptions\HttpResponseException;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
        apiPrefix: 'api/v1',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'tenant' => SetTenant::class,
            'permission' => EnsurePermission::class,
            'feature' => EnsureFeature::class,
            'platform' => EnsurePlatformAdmin::class,
        ]);
        $middleware->prepend(ResetTenant::class);
        $middleware->append(SecurityHeaders::class);
        $middleware->throttleApi('api');
        // Tenant must be bound before implicit route-model binding, otherwise
        // the fail-closed company scope hides every record (or, worse, a
        // leftover context from a previous worker request is reused).
        $middleware->prependToPriorityList(
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
            SetTenant::class,
        );
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
        );

        $exceptions->render(function (Throwable $e, Request $request) {
            if (! $request->is('api/*') && ! $request->expectsJson()) {
                return null;
            }

            if ($e instanceof HttpResponseException) {
                return $e->getResponse();
            }

            if ($e instanceof ValidationException) {
                return ApiResponse::error(__('messages.invalid'), $e->status, $e->errors());
            }

            if ($e instanceof AuthenticationException) {
                return ApiResponse::error(__('auth.unauthenticated'), 401);
            }

            if ($e instanceof AuthorizationException) {
                return ApiResponse::error($e->getMessage() ?: __('auth.forbidden'), 403);
            }

            if ($e instanceof ThrottleRequestsException) {
                return ApiResponse::error(__('auth.throttle'), 429);
            }

            if ($e instanceof ModelNotFoundException || $e instanceof NotFoundHttpException) {
                return ApiResponse::error(__('messages.not_found'), 404);
            }

            if ($e instanceof HttpExceptionInterface) {
                $status = $e->getStatusCode();

                return ApiResponse::error($e->getMessage() !== '' ? $e->getMessage() : __('messages.server_error'), $status);
            }

            if (config('app.debug')) {
                return null;
            }

            report($e);

            return ApiResponse::error(__('messages.server_error'), 500);
        });
    })->create();
