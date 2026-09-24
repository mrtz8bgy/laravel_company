<?php

declare(strict_types=1);

use App\Core\Support\TenantContext;
use App\Modules\Organizations\Models\Company;

if (! function_exists('tenant')) {
    function tenant(): ?Company
    {
        return app(TenantContext::class)->company();
    }
}

if (! function_exists('tenantId')) {
    function tenantId(): ?int
    {
        return app(TenantContext::class)->id();
    }
}
