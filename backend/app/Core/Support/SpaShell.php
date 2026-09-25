<?php

declare(strict_types=1);

namespace App\Core\Support;

/**
 * Makes the Vite shell safe to open from an XAMPP subdirectory.
 * Asset URLs stay relative to backend/public. The browser computes the install path.
 */
final class SpaShell
{
    public function render(string $html): string
    {
        $html = preg_replace('/\s+crossorigin(?:="[^"]*")?/i', '', $html) ?? $html;
        $html = preg_replace(
            '/\b(src|href)=(["\'])(?:\.\/)?assets\//',
            '$1=$2app/assets/',
            $html,
        ) ?? $html;
        $html = str_replace('app/app/assets/', 'app/assets/', $html);

        if (! str_contains($html, 'window.__VCOS_BASE__')) {
            $html = $this->injectBoot($html);
        }

        if (! str_contains($html, 'id="app"')) {
            return $html;
        }

        return $html;
    }

    private function injectBoot(string $html): string
    {
        $boot = <<<'HTML'
<script>(function(){var path=location.pathname.replace(/\\/g,'/');var marker='/backend/public';var at=path.indexOf(marker);var basePath=at>=0?path.slice(0,at+marker.length):'';window.__VCOS_BASE__=basePath;if(!document.querySelector('base')){var el=document.createElement('base');el.href=location.origin+(basePath||'')+'/';document.head.appendChild(el);}})();</script>
HTML;
        $injected = preg_replace('/<head([^>]*)>/i', '<head$1>'.$boot, $html, 1);

        return is_string($injected) ? $injected : $boot.$html;
    }
}
