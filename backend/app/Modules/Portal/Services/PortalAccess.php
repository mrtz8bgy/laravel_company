<?php

declare(strict_types=1);

namespace App\Modules\Portal\Services;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\AuthorizationService;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\CompanyMembership;
use App\Modules\Portal\Models\CustomerThread;

/**
 * Staff desks follow the company units: sales, operations (support), management.
 * A customer never receives another customer's rows. Privileged roles see every desk.
 */
class PortalAccess
{
    public function __construct(private readonly AuthorizationService $authorization) {}

    /**
     * @return list<string>
     */
    public function desksFor(User $user): array
    {
        if ($this->authorization->isPrivileged($user, tenant())) {
            return [CustomerThread::SALES, CustomerThread::SUPPORT, CustomerThread::MANAGEMENT];
        }

        $desks = [];
        $slug = $this->departmentSlug($user);
        $mapped = [
            'sales' => CustomerThread::SALES,
            'operations' => CustomerThread::SUPPORT,
            'management' => CustomerThread::MANAGEMENT,
        ];
        if (isset($mapped[$slug])) {
            $desks[] = $mapped[$slug];
        }

        if ($this->hasRole($user, 'sales') && ! in_array(CustomerThread::SALES, $desks, true)) {
            $desks[] = CustomerThread::SALES;
        }

        return $desks;
    }

    public function canOpenDesk(User $user, string $desk): bool
    {
        return in_array($desk, $this->desksFor($user), true);
    }

    public function canReview(User $user): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::CUSTOMERS_REVIEW);
    }

    public function canViewCustomers(User $user): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::CUSTOMERS_VIEW);
    }

    public function canViewOrders(User $user): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::CUSTOMER_ORDERS_VIEW);
    }

    public function canManageOrders(User $user): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::CUSTOMER_ORDERS_MANAGE);
    }

    public function canManageProducts(User $user): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::PRODUCTS_MANAGE);
    }

    public function canViewProducts(User $user): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::PRODUCTS_VIEW)
            || $this->canManageProducts($user);
    }

    private function departmentSlug(User $user): ?string
    {
        $membership = CompanyMembership::query()
            ->where('user_id', $user->id)
            ->where('status', 'active')
            ->with('department:id,slug')
            ->first();

        return $membership?->department?->slug;
    }

    private function hasRole(User $user, string $slug): bool
    {
        return $user->roles()
            ->withoutGlobalScope('company')
            ->where('roles.company_id', tenantId())
            ->where('user_roles.company_id', tenantId())
            ->where('roles.slug', $slug)
            ->exists();
    }
}
