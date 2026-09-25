<?php

use App\Http\Controllers\SpaController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
 * The built Vue app is served by Apache from this same public directory.
 * Session and CSRF middleware are not used: the panel authenticates with a bearer token.
 */
$spa = Route::withoutMiddleware([
    \Illuminate\Cookie\Middleware\EncryptCookies::class,
    \Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse::class,
    \Illuminate\Session\Middleware\StartSession::class,
    \Illuminate\View\Middleware\ShareErrorsFromSession::class,
    \Illuminate\Foundation\Http\Middleware\ValidateCsrfToken::class,
    \Illuminate\Routing\Middleware\SubstituteBindings::class,
]);

$redirectHome = function (Request $request) {
    $base = rtrim($request->getBasePath(), '/');

    return redirect()->to($base === '' ? '/' : $base.'/');
};

$spa->get('/app', $redirectHome);
$spa->get('/app/index.html', $redirectHome);
$spa->get('/', SpaController::class);
$spa->get('/{path}', SpaController::class)
    ->where('path', '^(?!api(?:/|$)|up(?:/|$)|sanctum(?:/|$)|app(?:/|$)).*$');
