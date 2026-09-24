<?php

declare(strict_types=1);

namespace App\Modules\Projects\Http\Controllers;

use App\Core\Services\ActivityLogger;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Department;
use App\Modules\Projects\Actions\CreateProject;
use App\Modules\Projects\Http\Resources\ProjectResource;
use App\Modules\Projects\Http\Resources\TaskResource;
use App\Modules\Projects\Models\Project;
use App\Modules\Projects\Models\ProjectMember;
use App\Modules\Projects\Services\ProjectAccess;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class ProjectController extends Controller
{
    public function __construct(
        private readonly CreateProject $createProject,
        private readonly ProjectAccess $access,
        private readonly ActivityLogger $activity,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $projects = $this->access->visibleQuery($this->user($request))
            ->with(['owner:id,uuid,name', 'department:id,uuid,name'])
            ->withCount('tasks')
            ->orderBy('name')
            ->get();

        return ApiResponse::success(ProjectResource::collection($projects)->resolve());
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:160'],
            'code' => ['nullable', 'string', 'max:32'],
            'description' => ['nullable', 'string', 'max:5000'],
            'visibility' => ['nullable', 'in:company,private'],
            'department_uuid' => ['nullable', 'uuid'],
            'due_date' => ['nullable', 'date'],
        ]);

        $departmentId = null;
        if (! empty($data['department_uuid'])) {
            $departmentId = Department::query()->where('uuid', $data['department_uuid'])->value('id');
            if (! $departmentId) {
                throw ValidationException::withMessages(['department_uuid' => [__('messages.not_found')]]);
            }
        }

        $project = $this->createProject->handle($this->user($request), [
            ...$data,
            'department_id' => $departmentId,
        ]);

        return ApiResponse::success((new ProjectResource($project))->resolve(), __('messages.created'), 201);
    }

    public function show(Request $request, Project $project): JsonResponse
    {
        $this->visible($request, $project);
        $project->load(['owner:id,uuid,name', 'department:id,uuid,name'])->loadCount('tasks');

        return ApiResponse::success((new ProjectResource($project))->resolve());
    }

    public function update(Request $request, Project $project): JsonResponse
    {
        $this->visible($request, $project);
        if (! $this->access->canManage($this->user($request), $project)) {
            throw new AuthorizationException(__('auth.forbidden'));
        }
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:160'],
            'description' => ['sometimes', 'nullable', 'string', 'max:5000'],
            'status' => ['sometimes', 'in:planned,active,on_hold,done,archived'],
            'visibility' => ['sometimes', 'in:company,private'],
            'due_date' => ['sometimes', 'nullable', 'date'],
        ]);
        $project->update($data);
        $this->activity->log('UPDATE', $project, null, $data);

        return ApiResponse::success((new ProjectResource($project->fresh()))->resolve(), __('messages.updated'));
    }

    public function destroy(Request $request, Project $project): JsonResponse
    {
        $this->visible($request, $project);
        $this->authorize('delete', $project);
        $this->activity->log('DELETE', $project, ['name' => $project->name], null);
        $project->update(['status' => 'archived']);

        return ApiResponse::success(null, __('messages.deleted'));
    }

    public function board(Request $request, Project $project): JsonResponse
    {
        $this->visible($request, $project);
        $project->load([
            'columns.tasks.assignee:id,uuid,name',
            'columns.tasks.column:id,uuid,name,is_done',
            'members.user:id,uuid,name',
        ]);

        return ApiResponse::success([
            'project' => (new ProjectResource($project))->resolve(),
            'members' => $project->members->map(fn ($member) => [
                'role' => $member->role,
                'user' => $member->user ? [
                    'uuid' => $member->user->uuid,
                    'name' => $member->user->name,
                ] : null,
            ])->values(),
            'columns' => $project->columns->map(fn ($column) => [
                'uuid' => $column->uuid,
                'name' => $column->name,
                'sort_order' => $column->sort_order,
                'is_done' => $column->is_done,
                'tasks' => TaskResource::collection($column->tasks)->resolve(),
            ])->values(),
        ]);
    }

    public function addMember(Request $request, Project $project): JsonResponse
    {
        $this->visible($request, $project);
        if (! $this->access->canManage($this->user($request), $project)) {
            throw new AuthorizationException(__('auth.forbidden'));
        }
        $data = $request->validate([
            'user_uuid' => ['required', 'uuid'],
            'role' => ['nullable', 'in:manager,member,viewer'],
        ]);
        $member = $this->activeMember($data['user_uuid']);
        ProjectMember::query()->updateOrCreate(
            ['project_id' => $project->id, 'user_id' => $member->id],
            ['role' => $data['role'] ?? 'member'],
        );
        $this->activity->log('ASSIGN', $project, null, ['user' => $member->uuid, 'role' => $data['role'] ?? 'member']);

        return ApiResponse::success(null, __('messages.updated'));
    }

    public function removeMember(Request $request, Project $project, string $user): JsonResponse
    {
        $this->visible($request, $project);
        if (! $this->access->canManage($this->user($request), $project)) {
            throw new AuthorizationException(__('auth.forbidden'));
        }
        $member = User::query()->where('uuid', $user)->firstOrFail();
        if ($member->id === $project->owner_id) {
            return ApiResponse::error(__('messages.last_owner'), 422);
        }
        ProjectMember::query()->where('project_id', $project->id)->where('user_id', $member->id)->delete();

        return ApiResponse::success(null, __('messages.deleted'));
    }

    private function activeMember(string $uuid): User
    {
        $user = User::query()
            ->where('uuid', $uuid)
            ->whereHas('memberships', fn ($query) => $query->where('company_id', tenantId())->where('status', 'active'))
            ->first();
        if (! $user) {
            throw ValidationException::withMessages(['user_uuid' => [__('messages.member_required')]]);
        }

        return $user;
    }

    private function visible(Request $request, Project $project): void
    {
        if (! $this->access->canView($this->user($request), $project)) {
            throw (new ModelNotFoundException())->setModel(Project::class);
        }
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
