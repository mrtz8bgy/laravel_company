<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Policies;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\AuthorizationService;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Department;

class DepartmentPolicy
{
    public function __construct(private readonly AuthorizationService $authorization) {}

    public function viewAny(User $user): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::DEPARTMENTS_VIEW);
    }

    public function view(User $user, Department $department): bool
    {
        return $this->viewAny($user);
    }

    public function create(User $user): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::DEPARTMENTS_CREATE);
    }

    public function update(User $user, Department $department): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::DEPARTMENTS_UPDATE);
    }

    public function delete(User $user, Department $department): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::DEPARTMENTS_DELETE);
    }
}
