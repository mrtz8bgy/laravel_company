<?php

declare(strict_types=1);

namespace App\Core\Support;

class DeviceParser
{
    public static function fromUserAgent(?string $userAgent): string
    {
        $ua = $userAgent ?? '';

        $browser = 'Browser';
        foreach ([
            'Edg' => 'Edge',
            'Chrome' => 'Chrome',
            'Firefox' => 'Firefox',
            'Safari' => 'Safari',
        ] as $needle => $name) {
            if (str_contains($ua, $needle)) {
                $browser = $name;
                break;
            }
        }

        $os = 'Unknown';
        foreach ([
            'Windows' => 'Windows',
            'Mac OS' => 'macOS',
            'Android' => 'Android',
            'iPhone' => 'iOS',
            'iPad' => 'iPadOS',
            'Linux' => 'Linux',
        ] as $needle => $name) {
            if (str_contains($ua, $needle)) {
                $os = $name;
                break;
            }
        }

        return $browser.' / '.$os;
    }
}
