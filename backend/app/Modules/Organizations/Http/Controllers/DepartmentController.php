<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Http\Controllers;

use App\Core\Services\ActivityLogger;
use App\Core\Support\ApiResponse;
use App\Core\Support\Slugger;
use App\Http\Controllers\Controller;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Http\Requests\DepartmentRequest;
use App\Modules\Organizations\Http\Resources\DepartmentResource;
use App\Modules\Organizations\Models\Department;
use Illuminate\Http\JsonResponse;

class DepartmentController extends Controller
{
    public function __construct(private readonly ActivityLogger $activity) {}

    public function index(): JsonResponse
    {
        $this->authorize('viewAny', Department::class);

        $departments = Department::query()
            ->with(['manager:id,uuid,name', 'parent:id,uuid,name'])
            ->withCount(['teams', 'memberships'])
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();

        return ApiResponse::success(DepartmentResource::collection($departments)->resolve());
    }

    public function store(DepartmentRequest $request): JsonResponse
    {
        $this->authorize('create', Department::class);

        $department = Department::query()->create($this->attributes($request));
        $department->load(['manager:id,uuid,name', 'parent:id,uuid,name']);
        $this->activity->log('CREATE', $department, null, $department->only(['name', 'slug', 'code']));

        return ApiResponse::success((new DepartmentResource($department))->resolve(), __('messages.created'), 201);
    }

    public function show(Department $department): JsonResponse
    {
        $this->authorize('view', $department);
        $department->load(['manager:id,uuid,name', 'parent:id,uuid,name'])->loadCount(['teams', 'memberships']);

        return ApiResponse::success((new DepartmentResource($department))->resolve());
    }

    public function update(DepartmentRequest $request, Department $department): JsonResponse
    {
        $this->authorize('update', $department);
        $old = $department->only(['name', 'slug', 'code', 'description', 'is_active', 'manager_id', 'parent_id']);
        $department->update($this->attributes($request, $department));
        $department->load(['manager:id,uuid,name', 'parent:id,uuid,name']);
        $this->activity->log('UPDATE', $department, $old, $department->only(array_keys($old)));

        return ApiResponse::success((new DepartmentResource($department))->resolve(), __('messages.updated'));
    }

    public function destroy(Department $department): JsonResponse
    {
        $this->authorize('delete', $department);

        if ($department->teams()->exists() || $department->children()->exists()) {
            return ApiResponse::error(__('messages.department_in_use'), 422);
        }

        $this->activity->log('DELETE', $department, $department->only(['name', 'slug']), null);
        $department->delete();

        return ApiResponse::success(null, __('messages.deleted'));
    }

    /**
     * @return array<string, mixed>
     */
    private function attributes(DepartmentRequest $request, ?Department $current = null): array
    {
        $name = $request->string('name')->toString();
        $slug = $request->input('slug') ?: Slugger::unique(
            $name,
            fn (string $candidate): bool => Department::query()
                ->when($current, fn ($query) => $query->whereKeyNot($current->id))
                ->where('slug', $candidate)
                ->exists(),
            'dep',
        );

        $attributes = [
            'name' => $name,
            'slug' => $slug,
            'is_active' => $request->exists('is_active')
                ? $request->boolean('is_active')
                : ($current?->is_active ?? true),
            'sort_order' => $request->exists('sort_order')
                ? $request->integer('sort_order')
                : ($current?->sort_order ?? 0),
        ];

        if ($current === null || $request->exists('code')) {
            $attributes['code'] = $request->input('code') ?: null;
        }

        if ($current === null || $request->exists('description')) {
            $attributes['description'] = $request->input('description');
        }

        // Absent keys must not clear relations. The department form does not always send them.
        if ($current === null || $request->exists('manager_uuid')) {
            $attributes['manager_id'] = $this->resolveManagerId($request);
        }

        if ($current === null || $request->exists('parent_uuid')) {
            $attributes['parent_id'] = $this->resolveParentId($request, $current);
        }

        return $attributes;
    }

    private function resolveManagerId(DepartmentRequest $request): ?int
    {
        if (! $request->filled('manager_uuid')) {
            return null;
        }

        $manager = User::query()
            ->where('uuid', $request->string('manager_uuid')->toString())
            ->whereHas('memberships', fn ($query) => $query->where('company_id', tenantId())->where('status', 'active'))
            ->first();

        if (! $manager) {
            abort(ApiResponse::error(__('messages.member_required'), 422, [
                'manager_uuid' => [__('messages.member_required')],
            ]));
        }

        return $manager->id;
    }

    private function resolveParentId(DepartmentRequest $request, ?Department $current): ?int
    {
        if (! $request->filled('parent_uuid')) {
            return null;
        }

        $parent = Department::query()->where('uuid', $request->string('parent_uuid')->toString())->first();
        if (! $parent || ($current && $parent->id === $current->id) || ($current && $this->createsCycle($current, $parent))) {
            abort(ApiResponse::error(__('messages.invalid_parent'), 422, [
                'parent_uuid' => [__('messages.invalid_parent')],
            ]));
        }

        return $parent->id;
    }

    private function createsCycle(Department $department, Department $parent): bool
    {
        $cursor = $parent;
        $guard = 0;
        while ($cursor && $guard < 25) {
            if ($cursor->id === $department->id) {
                return true;
            }
            $cursor = $cursor->parent;
            $guard++;
        }

        return false;
    }
}
