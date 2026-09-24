<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Http\Controllers;

use App\Core\Services\ActivityLogger;
use App\Core\Support\ApiResponse;
use App\Core\Support\Slugger;
use App\Http\Controllers\Controller;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Http\Requests\TeamRequest;
use App\Modules\Organizations\Http\Resources\TeamResource;
use App\Modules\Organizations\Models\Department;
use App\Modules\Organizations\Models\Team;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class TeamController extends Controller
{
    public function __construct(private readonly ActivityLogger $activity) {}

    public function index(): JsonResponse
    {
        $this->authorize('viewAny', Team::class);

        $teams = Team::query()
            ->with(['department:id,uuid,name', 'leader:id,uuid,name'])
            ->withCount('members')
            ->orderBy('name')
            ->get();

        return ApiResponse::success(TeamResource::collection($teams)->resolve());
    }

    public function store(TeamRequest $request): JsonResponse
    {
        $this->authorize('create', Team::class);
        $team = Team::query()->create($this->attributes($request));
        $this->syncMembers($team, $request->input('members', []), $request->input('leader_uuid'));
        $team->load(['department:id,uuid,name', 'leader:id,uuid,name', 'members:id,uuid,name,email'])->loadCount('members');
        $this->activity->log('CREATE', $team, null, ['name' => $team->name]);

        return ApiResponse::success((new TeamResource($team))->resolve(), __('messages.created'), 201);
    }

    public function show(Team $team): JsonResponse
    {
        $this->authorize('view', $team);
        $team->load(['department:id,uuid,name', 'leader:id,uuid,name', 'members:id,uuid,name,email'])->loadCount('members');

        return ApiResponse::success((new TeamResource($team))->resolve());
    }

    public function update(TeamRequest $request, Team $team): JsonResponse
    {
        $this->authorize('update', $team);
        $old = $team->only(['name', 'description', 'is_active', 'department_id', 'leader_id']);
        $team->update($this->attributes($request, $team));
        if ($request->exists('members')) {
            $this->syncMembers($team, $request->input('members', []), $request->input('leader_uuid'));
        }
        $team->load(['department:id,uuid,name', 'leader:id,uuid,name', 'members:id,uuid,name,email'])->loadCount('members');
        $this->activity->log('UPDATE', $team, $old, $team->only(array_keys($old)));

        return ApiResponse::success((new TeamResource($team))->resolve(), __('messages.updated'));
    }

    public function destroy(Team $team): JsonResponse
    {
        $this->authorize('delete', $team);
        $this->activity->log('DELETE', $team, ['name' => $team->name], null);
        $team->delete();

        return ApiResponse::success(null, __('messages.deleted'));
    }

    public function addMember(Request $request, Team $team): JsonResponse
    {
        $this->authorize('update', $team);
        $data = $request->validate([
            'user_uuid' => ['required', 'uuid'],
            'role' => ['nullable', 'in:member,leader'],
        ]);

        $user = $this->memberOrFail($data['user_uuid']);
        $role = $data['role'] ?? 'member';
        $team->members()->syncWithoutDetaching([$user->id => ['role' => $role]]);
        if ($role === 'leader') {
            $team->forceFill(['leader_id' => $user->id])->save();
        }
        $this->activity->log('ASSIGN', $team, null, ['user' => $user->uuid, 'role' => $role]);

        return ApiResponse::success(null, __('messages.updated'));
    }

    public function removeMember(Team $team, string $user): JsonResponse
    {
        $this->authorize('update', $team);
        $member = $this->memberOrFail($user);
        $team->members()->detach($member->id);
        if ($team->leader_id === $member->id) {
            $team->forceFill(['leader_id' => null])->save();
        }
        $this->activity->log('ASSIGN', $team, ['user' => $member->uuid], ['removed' => true]);

        return ApiResponse::success(null, __('messages.updated'));
    }

    /**
     * @return array<string, mixed>
     */
    private function attributes(TeamRequest $request, ?Team $current = null): array
    {
        $department = Department::query()->where('uuid', $request->string('department_uuid')->toString())->first();
        if (! $department) {
            throw ValidationException::withMessages(['department_uuid' => [__('messages.not_found')]]);
        }

        $name = $request->string('name')->toString();

        return [
            'department_id' => $department->id,
            'name' => $name,
            'slug' => $request->input('slug') ?: Slugger::unique(
                $name,
                fn (string $candidate): bool => Team::query()
                    ->when($current, fn ($query) => $query->whereKeyNot($current->id))
                    ->where('slug', $candidate)
                    ->exists(),
                'team',
            ),
            'description' => $request->input('description'),
            'is_active' => $request->boolean('is_active', true),
        ];
    }

    /**
     * @param  list<array{uuid: string, role?: string}>|list<string>  $members
     */
    private function syncMembers(Team $team, array $members, ?string $leaderUuid): void
    {
        $sync = [];
        foreach ($members as $member) {
            $uuid = is_array($member) ? ($member['uuid'] ?? null) : $member;
            $role = is_array($member) ? ($member['role'] ?? 'member') : 'member';
            if (! $uuid) {
                continue;
            }
            $user = $this->memberOrFail((string) $uuid);
            $sync[$user->id] = ['role' => $role === 'leader' ? 'leader' : 'member'];
        }

        $team->members()->sync($sync);

        $leaderId = null;
        if ($leaderUuid) {
            $leader = $this->memberOrFail($leaderUuid);
            if (! isset($sync[$leader->id])) {
                $team->members()->syncWithoutDetaching([$leader->id => ['role' => 'leader']]);
            } else {
                $team->members()->updateExistingPivot($leader->id, ['role' => 'leader']);
            }
            $leaderId = $leader->id;
        }

        $team->forceFill(['leader_id' => $leaderId])->save();
    }

    private function memberOrFail(string $uuid): User
    {
        $user = User::query()
            ->where('uuid', $uuid)
            ->whereHas('memberships', fn ($query) => $query->where('company_id', tenantId())->where('status', 'active'))
            ->first();

        if (! $user) {
            throw ValidationException::withMessages([
                'user_uuid' => [__('messages.member_required')],
            ]);
        }

        return $user;
    }
}
