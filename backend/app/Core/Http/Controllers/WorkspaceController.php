<?php

declare(strict_types=1);

namespace App\Core\Http\Controllers;

use App\Core\Access\PermissionCatalog;
use App\Core\Http\Resources\ActivityLogResource;
use App\Core\Models\ActivityLog;
use App\Core\Services\ActivityLogger;
use App\Core\Services\AuthorizationService;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Attendance\Actions\AttendanceSnapshot;
use App\Modules\Attendance\Services\AttendanceAccess;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Feature;
use App\Modules\Organizations\Models\CompanyMembership;
use App\Modules\Organizations\Models\Department;
use App\Modules\Organizations\Models\Invitation;
use App\Modules\Organizations\Models\Team;
use App\Modules\Projects\Models\Project;
use App\Modules\Projects\Services\ProjectAccess;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rules\Password;

class WorkspaceController extends Controller
{
    public function __construct(
        private readonly AuthorizationService $authorization,
        private readonly ActivityLogger $activity,
    ) {}

    public function dashboard(Request $request): JsonResponse
    {
        $company = tenant();
        $user = $request->user();
        $canActivity = $this->authorization->allows($user, PermissionCatalog::ACTIVITY_LOGS_VIEW, $company);

        $widgets = [
            ['key' => 'employees', 'value' => CompanyMembership::query()->where('company_id', $company->id)->where('status', 'active')->count()],
            ['key' => 'departments', 'value' => Department::query()->count()],
            ['key' => 'teams', 'value' => Team::query()->count()],
            ['key' => 'pending_invitations', 'value' => Invitation::query()->whereNull('accepted_at')->where('expires_at', '>', now())->count()],
        ];

        $attendance = null;
        $attendanceEnabled = (bool) Feature::query()->where('key', 'attendance')->value('enabled');
        if ($attendanceEnabled && $this->authorization->allows($user, PermissionCatalog::ATTENDANCE_CLOCK)) {
            $attendance = app(AttendanceSnapshot::class)->today($user);
            $widgets[] = ['key' => 'late_minutes', 'value' => $attendance['day']['late_minutes'] ?? 0];
            $widgets[] = ['key' => 'worked_minutes', 'value' => $attendance['day']['worked_minutes'] ?? 0];
            if ($this->authorization->allows($user, PermissionCatalog::ATTENDANCE_VIEW)) {
                $visible = app(AttendanceAccess::class)->visibleUserIds($user);
                $present = \App\Modules\Attendance\Models\WorkPresence::query()
                    ->whereIn('status', ['office', 'remote', 'break', 'meeting'])
                    ->when($visible !== null, fn ($query) => $query->whereIn('user_id', $visible))
                    ->count();
                $widgets[] = ['key' => 'present_today', 'value' => $present];
            }
        }

        return ApiResponse::success([
            'greeting_name' => $user->name,
            'company' => [
                'uuid' => $company->uuid,
                'name' => $company->name,
                'timezone' => $company->timezone,
                'locale' => $company->locale,
            ],
            'widgets' => $widgets,
            'attendance' => $attendance,
            'onboarding' => $company->onboardingState(),
            'recent_activity' => $canActivity
                ? ActivityLogResource::collection(
                    ActivityLog::query()->where('company_id', $company->id)->with('user:id,uuid,name')->latest('id')->limit(8)->get()
                )->resolve()
                : [],
        ]);
    }

    public function search(Request $request): JsonResponse
    {
        $q = trim($request->string('q')->toString());
        if (mb_strlen($q) < 2) {
            return ApiResponse::success(['users' => [], 'departments' => [], 'teams' => [], 'projects' => []]);
        }

        $term = '%'.addcslashes($q, '%_\\').'%';
        $user = $request->user();
        $results = ['users' => [], 'departments' => [], 'teams' => [], 'projects' => []];

        if ($this->authorization->allows($user, PermissionCatalog::USERS_VIEW)) {
            $results['users'] = User::query()
                ->whereHas('memberships', fn ($query) => $query->where('company_id', tenantId()))
                ->where(fn ($query) => $query->where('name', 'like', $term)->orWhere('email', 'like', $term))
                ->orderBy('name')
                ->limit(8)
                ->get(['uuid', 'name', 'email'])
                ->map(fn (User $member) => [
                    'uuid' => $member->uuid,
                    'name' => $member->name,
                    'email' => $member->email,
                    'type' => 'user',
                ])
                ->all();
        }

        if ($this->authorization->allows($user, PermissionCatalog::DEPARTMENTS_VIEW)) {
            $results['departments'] = Department::query()
                ->where('name', 'like', $term)
                ->orderBy('name')
                ->limit(8)
                ->get(['uuid', 'name'])
                ->map(fn (Department $department) => [
                    'uuid' => $department->uuid,
                    'name' => $department->name,
                    'type' => 'department',
                ])
                ->all();
        }

        if ($this->authorization->allows($user, PermissionCatalog::PROJECTS_VIEW)) {
            $results['projects'] = app(ProjectAccess::class)->visibleQuery($user)
                ->where('name', 'like', $term)
                ->orderBy('name')
                ->limit(8)
                ->get(['uuid', 'name'])
                ->map(fn (Project $project) => [
                    'uuid' => $project->uuid,
                    'name' => $project->name,
                    'type' => 'project',
                ])
                ->all();
        }

        if ($this->authorization->allows($user, PermissionCatalog::TEAMS_VIEW)) {
            $results['teams'] = Team::query()
                ->where('name', 'like', $term)
                ->orderBy('name')
                ->limit(8)
                ->get(['uuid', 'name'])
                ->map(fn (Team $team) => [
                    'uuid' => $team->uuid,
                    'name' => $team->name,
                    'type' => 'team',
                ])
                ->all();
        }

        return ApiResponse::success($results);
    }

    public function activity(Request $request): JsonResponse
    {
        $this->authorize('viewAny', ActivityLog::class);

        $logs = ActivityLog::query()
            ->where('company_id', tenantId())
            ->with('user:id,uuid,name')
            ->when($request->filled('action'), fn ($query) => $query->where('action', $request->string('action')->toString()))
            ->latest('id')
            ->paginate(min($request->integer('per_page', 20), 100));

        return ApiResponse::paginated($logs, ActivityLogResource::collection($logs->getCollection())->resolve());
    }

    public function profile(Request $request): JsonResponse
    {
        $user = $request->user();
        $companyId = $user->currentAccessToken()?->company_id;
        if ($companyId) {
            $user->load([
                'memberships' => fn ($query) => $query->where('company_id', $companyId)->with('department:id,uuid,name'),
                'roles' => fn ($query) => $query->withoutGlobalScope('company')->where('roles.company_id', $companyId)->where('user_roles.company_id', $companyId),
                'teams' => fn ($query) => $query->withoutGlobalScope('company')->where('teams.company_id', $companyId),
            ]);
            app(\App\Core\Support\TenantContext::class)->set(\App\Modules\Organizations\Models\Company::query()->find($companyId));
        }

        return ApiResponse::success((new \App\Modules\Identity\Http\Resources\UserResource($user))->resolve());
    }

    public function updateProfile(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:120'],
            'phone' => ['sometimes', 'nullable', 'string', 'max:32'],
            'locale' => ['sometimes', 'in:fa,en'],
            'timezone' => ['sometimes', 'nullable', 'timezone'],
            'current_password' => ['required_with:password', 'string'],
            'password' => ['sometimes', 'confirmed', Password::min(8)->mixedCase()->numbers()->symbols()],
        ]);

        if (! empty($data['password'])) {
            if (! \Illuminate\Support\Facades\Hash::check($data['current_password'] ?? '', $user->password)) {
                return ApiResponse::error(__('auth.failed'), 422, [
                    'current_password' => [__('auth.failed')],
                ]);
            }
            $user->password = $data['password'];
        }

        $user->fill(collect($data)->only(['name', 'phone', 'locale', 'timezone'])->all());
        $user->save();
        $this->activity->log('UPDATE', $user, null, $user->only(['name', 'phone', 'locale', 'timezone']), 'Profile updated', $user->currentAccessToken()?->company_id, $user->id);

        return $this->profile($request);
    }
}
