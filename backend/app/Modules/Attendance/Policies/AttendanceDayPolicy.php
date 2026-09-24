<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Policies;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\AuthorizationService;
use App\Modules\Attendance\Models\AttendanceDay;
use App\Modules\Attendance\Services\AttendanceAccess;
use App\Modules\Identity\Models\User;

class AttendanceDayPolicy
{
    public function __construct(
        private readonly AuthorizationService $authorization,
        private readonly AttendanceAccess $access,
    ) {}

    public function view(User $user, AttendanceDay $day): bool
    {
        return $this->access->canSee($user, (int) $day->user_id);
    }

    public function correct(User $user, AttendanceDay $day): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::ATTENDANCE_CORRECT)
            && $this->access->canSee($user, (int) $day->user_id);
    }
}
