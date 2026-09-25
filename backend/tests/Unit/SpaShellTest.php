<?php

namespace Tests\Unit;

use App\Core\Support\SpaShell;
use PHPUnit\Framework\TestCase;

class SpaShellTest extends TestCase
{
    public function test_subdirectory_install_gets_absolute_assets_and_router_base(): void
    {
        $shell = new SpaShell;
        $html = <<<'HTML'
            <!doctype html>
            <html lang="fa" dir="rtl">
              <head>
                <meta charset="UTF-8" />
                <title>سامانه شرکت مجازی</title>
                <script type="module" crossorigin src="./assets/index-abc.js"></script>
                <link rel="stylesheet" crossorigin href="./assets/index-abc.css">
              </head>
              <body><div id="app"></div></body>
            </html>
            HTML;

        $rendered = $shell->render($html, '/laravel_company/backend/public');

        $this->assertStringContainsString(
            'src="/laravel_company/backend/public/app/assets/index-abc.js"',
            $rendered,
        );
        $this->assertStringContainsString(
            'href="/laravel_company/backend/public/app/assets/index-abc.css"',
            $rendered,
        );
        $this->assertStringContainsString(
            'window.__VCOS_BASE__="/laravel_company/backend/public"',
            $rendered,
        );
        $this->assertStringNotContainsString('src="./assets/', $rendered);
    }

    public function test_root_install_keeps_an_empty_base(): void
    {
        $shell = new SpaShell;
        $rendered = $shell->render('<head><script src="./assets/app.js"></script></head>', '');

        $this->assertStringContainsString('src="/app/assets/app.js"', $rendered);
        $this->assertStringContainsString('window.__VCOS_BASE__=""', $rendered);
    }
}
