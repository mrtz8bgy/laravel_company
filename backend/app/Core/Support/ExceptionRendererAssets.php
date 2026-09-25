<?php

declare(strict_types=1);

namespace App\Core\Support;

use Illuminate\Foundation\Exceptions\Renderer\Renderer;

/**
 * Laravel's HTML exception page reads compiled assets from vendor/.../dist.
 * Some copies of the project omit that directory, and the error page then
 * crashes before the real exception can be shown.
 */
final class ExceptionRendererAssets
{
    public static function ensure(): void
    {
        $dist = base_path('vendor/laravel/framework/src/Illuminate/Foundation/resources/exceptions/renderer/dist');
        $source = resource_path('exceptions-renderer');

        try {
            foreach (['styles.css', 'scripts.js'] as $file) {
                $target = $dist.DIRECTORY_SEPARATOR.$file;
                if (is_file($target)) {
                    continue;
                }
                if (! is_dir($dist)) {
                    @mkdir($dist, 0775, true);
                }
                $from = $source.DIRECTORY_SEPARATOR.$file;
                if (is_file($from)) {
                    @copy($from, $target);
                }
            }
        } catch (\Throwable) {
            // The Symfony error page is the fallback below.
        }

        if (! is_file($dist.DIRECTORY_SEPARATOR.'styles.css') || ! is_file($dist.DIRECTORY_SEPARATOR.'scripts.js')) {
            if (app()->bound(Renderer::class)) {
                app()->offsetUnset(Renderer::class);
            }
        }
    }
}
