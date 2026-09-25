<?php

declare(strict_types=1);

namespace App\Modules\Attendance\Http\Controllers;

use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Attendance\Actions\PersonWorkLog;
use App\Modules\Attendance\Services\AttendanceAccess;
use App\Modules\Identity\Models\User;
use App\Modules\Identity\Services\MemberLookup;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Per-person work report: presence days, worked hours and submitted reports.
 */
class WorkLogController extends Controller
{
    public function __construct(
        private readonly PersonWorkLog $workLog,
        private readonly AttendanceAccess $access,
        private readonly MemberLookup $members,
    ) {}

    public function show(Request $request, string $user): JsonResponse
    {
        $viewer = $this->user($request);
        $person = $this->members->activeMember($user);

        if (! $this->access->canSee($viewer, $person->id)) {
            throw new AuthorizationException(__('auth.forbidden'));
        }

        return ApiResponse::success($this->workLog->for(
            tenant(),
            $person,
            $request->date('from')?->toDateString(),
            $request->date('to')?->toDateString(),
        ));
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
