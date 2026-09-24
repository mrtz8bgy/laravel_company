<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Services;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\AuthorizationService;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\CompanyMembership;
use App\Modules\Organizations\Models\Department;
use App\Modules\Organizations\Models\Team;
use Illuminate\Support\Facades\DB;

class AttendanceAccess
{
    public function __construct(private readonly AuthorizationService $authorization) {}

    /**
     * Null means the viewer may see every active member of the company.
     *
     * @return list<int>|null
     */
    public function visibleUserIds(User $viewer): ?array
    {
        if ($viewer->is_platform_admin || $this->authorization->allows($viewer, PermissionCatalog::ATTENDANCE_CORRECT)) {
            return null;
        }

        $companyId = (int) tenantId();
        $ids = [$viewer->id];

        $departmentIds = Department::query()->where('manager_id', $viewer->id)->pluck('id');
        if ($departmentIds->isNotEmpty()) {
            $ids = array_merge($ids, $this->membersInDepartments($companyId, $departmentIds->all()));
        }

        $teamIds = Team::query()->where('leader_id', $viewer->id)->pluck('id');
        if ($teamIds->isNotEmpty()) {
            $ids = array_merge($ids, DB::table('team_user')->whereIn('team_id', $teamIds)->pluck('user_id')->all());
        }

        $slugs = DB::table('user_roles')
            ->join('roles', 'roles.id', '=', 'user_roles.role_id')
            ->where('user_roles.user_id', $viewer->id)
            ->where('user_roles.company_id', $companyId)
            ->pluck('roles.slug');

        if ($slugs->contains('department-manager')) {
            $departmentId = CompanyMembership::query()
                ->where('company_id', $companyId)
                ->where('user_id', $viewer->id)
                ->value('department_id');
            if ($departmentId) {
                $ids = array_merge($ids, $this->membersInDepartments($companyId, [(int) $departmentId]));
            }
        }

        return array_values(array_unique(array_map('intval', $ids)));
    }

    public function canSee(User $viewer, int $userId): bool
    {
        $ids = $this->visibleUserIds($viewer);

        return $ids === null || in_array($userId, $ids, true);
    }

    /**
     * @param  list<int>  $departmentIds
     * @return list<int>
     */
    private function membersInDepartments(int $companyId, array $departmentIds): array
    {
        return CompanyMembership::query()
            ->where('company_id', $companyId)
            ->where('status', 'active')
            ->whereIn('department_id', $departmentIds)
            ->pluck('user_id')
            ->all();
    }
}
