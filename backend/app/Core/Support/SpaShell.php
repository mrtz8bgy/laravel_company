<?php

declare(strict_types=1);

namespace App\Core\Support;

/**
 * Turns the Vite production shell into HTML that works from any install path.
 * XAMPP serves this project from a subdirectory, so asset URLs cannot be root-absolute.
 */
final class SpaShell
{
    public function render(string $html, string $basePath): string
    {
        $basePath = rtrim($basePath, '/');
        $assetPrefix = ($basePath === '' ? '' : $basePath).'/app/';
        $html = $this->absolutizeAssets($html, $assetPrefix);

        return $this->injectBase($html, $basePath);
    }

    private function absolutizeAssets(string $html, string $assetPrefix): string
    {
        $rewritten = preg_replace_callback(
            '/\b(src|href)=(["\'])(?:\.\/)?assets\//',
            static fn (array $match): string => $match[1].'='.$match[2].$assetPrefix.'assets/',
            $html,
        );

        return is_string($rewritten) ? $rewritten : $html;
    }

    private function injectBase(string $html, string $basePath): string
    {
        $boot = '<script>window.__VCOS_BASE__='.json_encode(
            $basePath,
            JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT
        ).';</script>';

        $injected = preg_replace('/<head([^>]*)>/i', '<head$1>'.$boot, $html, 1);

        return is_string($injected) ? $injected : $boot.$html;
    }
}
