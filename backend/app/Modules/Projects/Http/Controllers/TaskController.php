<?php

declare(strict_types=1);

namespace App\Modules\Projects\Http\Controllers;

use App\Core\Access\PermissionCatalog;
use App\Core\Services\ActivityLogger;
use App\Core\Services\AuthorizationService;
use App\Core\Support\ApiResponse;
use App\Http\Controllers\Controller;
use App\Modules\Identity\Models\User;
use App\Modules\Identity\Services\MemberLookup;
use App\Modules\Projects\Actions\MoveTask;
use App\Modules\Projects\Actions\TasksForPerson;
use App\Modules\Projects\Actions\TodayTasks;
use App\Modules\Projects\Http\Resources\TaskResource;
use App\Modules\Projects\Models\KanbanColumn;
use App\Modules\Projects\Models\Project;
use App\Modules\Projects\Models\Task;
use App\Modules\Projects\Models\TaskComment;
use App\Modules\Projects\Services\ProjectAccess;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class TaskController extends Controller
{
    public function __construct(
        private readonly ProjectAccess $access,
        private readonly AuthorizationService $authorization,
        private readonly MoveTask $moveTask,
        private readonly TodayTasks $todayTasks,
        private readonly TasksForPerson $tasksForPerson,
        private readonly MemberLookup $members,
        private readonly ActivityLogger $activity,
    ) {}

    public function mine(Request $request): JsonResponse
    {
        return ApiResponse::success($this->todayTasks->for($this->user($request)));
    }

    /**
     * Tasks assigned to one person, limited to projects the viewer may open.
     */
    public function forPerson(Request $request, string $user): JsonResponse
    {
        $viewer = $this->user($request);
        $person = $this->members->activeMember($user);

        return ApiResponse::success(
            $this->tasksForPerson->for(
                $viewer,
                $person,
                tenant()->displayTimezone(),
                $request->boolean('open'),
            ) + ['user' => ['uuid' => $person->uuid, 'name' => $person->name]],
        );
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'project_uuid' => ['required', 'uuid'],
            'column_uuid' => ['nullable', 'uuid'],
            'title' => ['required', 'string', 'max:180'],
            'description' => ['nullable', 'string', 'max:5000'],
            'priority' => ['nullable', 'in:low,normal,high,urgent'],
            'assignee_uuid' => ['nullable', 'uuid'],
            'due_date' => ['nullable', 'date'],
        ]);

        $project = Project::query()->where('uuid', $data['project_uuid'])->firstOrFail();
        if (! $this->access->canView($this->user($request), $project)) {
            throw new AuthorizationException(__('auth.forbidden'));
        }

        $column = ! empty($data['column_uuid'])
            ? KanbanColumn::query()->where('project_id', $project->id)->where('uuid', $data['column_uuid'])->first()
            : KanbanColumn::query()->where('project_id', $project->id)->orderBy('sort_order')->first();
        if (! $column) {
            throw ValidationException::withMessages(['column_uuid' => [__('messages.not_found')]]);
        }

        $assigneeId = $this->assigneeId($data['assignee_uuid'] ?? null);
        if ($assigneeId !== null && $assigneeId !== $request->user()->id && ! $this->canAssign($this->user($request), $project)) {
            throw new AuthorizationException(__('auth.forbidden'));
        }
        $task = Task::query()->create([
            'project_id' => $project->id,
            'column_id' => $column->id,
            'title' => $data['title'],
            'description' => $data['description'] ?? null,
            'priority' => $data['priority'] ?? 'normal',
            'assignee_id' => $assigneeId,
            'reporter_id' => $request->user()->id,
            'due_date' => $data['due_date'] ?? null,
            'sort_order' => (int) Task::query()->where('column_id', $column->id)->max('sort_order') + 1,
        ]);
        $task->load(['column', 'assignee', 'project']);
        $this->activity->log('CREATE', $task, null, ['title' => $task->title]);

        return ApiResponse::success((new TaskResource($task))->resolve(), __('messages.created'), 201);
    }

    public function update(Request $request, Task $task): JsonResponse
    {
        $this->visibleTask($request, $task);
        if (! $this->access->canUpdateTask($this->user($request), $task)) {
            throw new AuthorizationException(__('auth.forbidden'));
        }
        $data = $request->validate([
            'title' => ['sometimes', 'string', 'max:180'],
            'description' => ['sometimes', 'nullable', 'string', 'max:5000'],
            'priority' => ['sometimes', 'in:low,normal,high,urgent'],
            'due_date' => ['sometimes', 'nullable', 'date'],
            'assignee_uuid' => ['sometimes', 'nullable', 'uuid'],
        ]);
        $canAssign = $this->canAssign($this->user($request), $task->project);
        if (array_key_exists('assignee_uuid', $data) && ! $canAssign) {
            throw new AuthorizationException(__('auth.forbidden'));
        }
        if (array_key_exists('assignee_uuid', $data)) {
            $data['assignee_id'] = $this->assigneeId($data['assignee_uuid']);
            unset($data['assignee_uuid']);
        }
        $task->update($data);
        $task->load(['column', 'assignee', 'project']);

        return ApiResponse::success((new TaskResource($task))->resolve(), __('messages.updated'));
    }

    public function move(Request $request, Task $task): JsonResponse
    {
        $this->visibleTask($request, $task);
        if (! $this->access->canUpdateTask($this->user($request), $task)) {
            throw new AuthorizationException(__('auth.forbidden'));
        }
        $data = $request->validate([
            'column_uuid' => ['required', 'uuid'],
            'sort_order' => ['nullable', 'integer', 'min:0', 'max:10000'],
        ]);
        $column = KanbanColumn::query()->where('uuid', $data['column_uuid'])->firstOrFail();
        $task = $this->moveTask->handle($task, $column, $data['sort_order'] ?? null);

        return ApiResponse::success((new TaskResource($task))->resolve(), __('messages.updated'));
    }

    public function destroy(Request $request, Task $task): JsonResponse
    {
        $this->visibleTask($request, $task);
        $this->activity->log('DELETE', $task, ['title' => $task->title], null);
        $task->delete();

        return ApiResponse::success(null, __('messages.deleted'));
    }

    public function comment(Request $request, Task $task): JsonResponse
    {
        $this->visibleTask($request, $task);
        $data = $request->validate(['body' => ['required', 'string', 'min:1', 'max:2000']]);
        $comment = TaskComment::query()->create([
            'task_id' => $task->id,
            'user_id' => $request->user()->id,
            'body' => $data['body'],
        ]);

        return ApiResponse::success([
            'uuid' => $comment->uuid,
            'body' => $comment->body,
            'user' => ['uuid' => $request->user()->uuid, 'name' => $request->user()->name],
        ], __('messages.created'), 201);
    }

    /**
     * Handing a task to somebody else needs the assign permission or project management.
     */
    private function canAssign(User $user, Project $project): bool
    {
        return $this->authorization->allows($user, PermissionCatalog::TASKS_ASSIGN)
            || $this->access->memberRole($user, $project) === 'manager';
    }

    private function assigneeId(?string $uuid): ?int
    {
        if (! $uuid) {
            return null;
        }
        $user = User::query()
            ->where('uuid', $uuid)
            ->whereHas('memberships', fn ($query) => $query->where('company_id', tenantId())->where('status', 'active'))
            ->first();
        if (! $user) {
            throw ValidationException::withMessages(['assignee_uuid' => [__('messages.member_required')]]);
        }

        return $user->id;
    }

    private function visibleTask(Request $request, Task $task): void
    {
        $task->loadMissing('project');
        if (! $task->project || ! $this->access->canView($this->user($request), $task->project)) {
            throw (new ModelNotFoundException())->setModel(Task::class);
        }
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
