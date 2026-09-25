<?php

$origins = array_filter(array_map('trim', explode(',', (string) env('CORS_ALLOWED_ORIGINS', '*'))));

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie', 'up'],
    'allowed_methods' => ['*'],
    'allowed_origins' => $origins === [] ? ['*'] : $origins,
    'allowed_origins_patterns' => env('APP_ENV', 'production') === 'local'
        ? ['#^https?://(localhost|127\\.0\\.0\\.1)(:\\d+)?$#']
        : [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];
