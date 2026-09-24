<?php

declare(strict_types=1);

return [
    'frontend_url' => env('FRONTEND_URL', 'http://localhost:5173'),
    'default_timezone' => env('VCOS_DEFAULT_TIMEZONE', 'Asia/Tehran'),
    'default_locale' => env('VCOS_DEFAULT_LOCALE', 'fa'),
    'invitation_ttl_hours' => (int) env('VCOS_INVITATION_TTL_HOURS', 72),
];
