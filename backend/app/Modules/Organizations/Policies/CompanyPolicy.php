<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Policies;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\AuthorizationService;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;

class CompanyPolicy
{
    public function __construct(private readonly AuthorizationService $authorization) {}

    public function view(User $user, Company $company): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::COMPANY_VIEW, $company);
    }

    public function update(User $user, Company $company): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::COMPANY_UPDATE, $company);
    }

    public function manageSettings(User $user, Company $company): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::COMPANY_SETTINGS_MANAGE, $company);
    }
}
