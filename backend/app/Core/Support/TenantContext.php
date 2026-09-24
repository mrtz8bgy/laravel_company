<?php

declare(strict_types=1);

namespace App\Core\Support;

use App\Modules\Organizations\Models\Company;

/**
 * Request-scoped company context.
 *
 * Tenant isolation is enforced by middleware (who may enter a company)
 * and by BelongsToCompany (every tenant query is constrained).
 * A later database-per-tenant resolver can replace the internals of this
 * class without rewriting module code.
 */
class TenantContext
{
    private ?Company $company = null;

    public function set(?Company $company): void
    {
        $this->company = $company;
    }

    public function clear(): void
    {
        $this->company = null;
    }

    public function company(): ?Company
    {
        return $this->company;
    }

    public function id(): ?int
    {
        return $this->company?->id;
    }

    public function check(): Company
    {
        if ($this->company === null) {
            throw new \RuntimeException('Company context is required.');
        }

        return $this->company;
    }
}
