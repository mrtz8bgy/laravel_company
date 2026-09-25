<?php

namespace Tests\Unit;

use App\Core\Support\SpaShell;
use PHPUnit\Framework\TestCase;

class SpaShellTest extends TestCase
{
    public function test_relative_asset_urls_stay_under_the_public_directory(): void
    {
        $html = '<head><script type="module" crossorigin src="./assets/index-abc.js"></script></head><body><div id="app"></div></body>';
        $rendered = (new SpaShell)->render($html);

        $this->assertStringContainsString('src="app/assets/index-abc.js"', $rendered);
        $this->assertStringNotContainsString('crossorigin', $rendered);
        $this->assertStringContainsString('window.__VCOS_BASE__', $rendered);
        $this->assertStringNotContainsString('src="/app/assets/', $rendered);
        $this->assertStringNotContainsString('src="/laravel_company/', $rendered);
    }

    public function test_existing_boot_script_is_not_duplicated(): void
    {
        $html = '<head><script>window.__VCOS_BASE__="";</script><script src="app/assets/app.js"></script></head>';
        $rendered = (new SpaShell)->render($html);

        $this->assertSame(1, substr_count($rendered, 'window.__VCOS_BASE__'));
        $this->assertStringContainsString('src="app/assets/app.js"', $rendered);
    }
}
