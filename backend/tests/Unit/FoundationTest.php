<?php

namespace Tests\Unit;

use App\Core\Access\PermissionCatalog;
use App\Core\Support\DeviceParser;
use App\Core\Support\Slugger;
use PHPUnit\Framework\TestCase;

class FoundationTest extends TestCase
{
    public function test_slugger_keeps_ascii_and_falls_back_for_persian(): void
    {
        $slug = Slugger::unique('Software', fn () => false, 'dep');
        $this->assertSame('software', $slug);

        $persian = Slugger::unique('توسعه نرم‌افزار', fn () => false, 'dep');
        $this->assertNotSame('', $persian);
        $this->assertMatchesRegularExpression('/^[a-z0-9-]+$/', $persian);
    }

    public function test_slugger_increments_when_taken(): void
    {
        $slug = Slugger::unique('sales', fn (string $candidate) => $candidate === 'sales', 'dep');
        $this->assertSame('sales-2', $slug);
    }

    public function test_device_parser_prefers_chrome_over_safari_token(): void
    {
        $device = DeviceParser::fromUserAgent('Mozilla/5.0 Chrome/120.0 Safari/537.36 Linux');
        $this->assertSame('Chrome / Linux', $device);
    }

    public function test_owner_template_contains_every_company_permission(): void
    {
        $template = PermissionCatalog::roleTemplates()['company-owner']['permissions'];
        $this->assertEqualsCanonicalizing(PermissionCatalog::companyNames(), $template);
        $this->assertNotContains('platform.companies.view', $template);
    }
}
