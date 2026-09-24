<?php

declare(strict_types=1);

namespace App\Modules\Projects\Actions;

use App\Core\Services\ActivityLogger;
use App\Core\Support\Slugger;
use App\Modules\Identity\Models\User;
use App\Modules\Projects\Models\KanbanColumn;
use App\Modules\Projects\Models\Project;
use App\Modules\Projects\Models\ProjectMember;
use Illuminate\Support\Facades\DB;

class CreateProject
{
    public function __construct(private readonly ActivityLogger $activity) {}

    /**
     * @param  array<string, mixed>  $input
     */
    public function handle(User $actor, array $input): Project
    {
        return DB::transaction(function () use ($actor, $input): Project {
            $name = (string) $input['name'];
            $project = Project::query()->create([
                'name' => $name,
                'slug' => $input['slug'] ?? Slugger::unique(
                    $name,
                    fn (string $candidate): bool => Project::query()->where('slug', $candidate)->exists(),
                    'prj',
                ),
                'code' => $input['code'] ?? null,
                'description' => $input['description'] ?? null,
                'status' => $input['status'] ?? 'active',
                'visibility' => $input['visibility'] ?? 'company',
                'department_id' => $input['department_id'] ?? null,
                'owner_id' => $actor->id,
                'start_date' => $input['start_date'] ?? null,
                'due_date' => $input['due_date'] ?? null,
            ]);

            foreach ([
                ['صف انتظار', false],
                ['در حال انجام', false],
                ['بازبینی', false],
                ['انجام شد', true],
            ] as $order => [$columnName, $done]) {
                KanbanColumn::query()->create([
                    'project_id' => $project->id,
                    'name' => $columnName,
                    'sort_order' => $order,
                    'is_done' => $done,
                ]);
            }

            ProjectMember::query()->create([
                'project_id' => $project->id,
                'user_id' => $actor->id,
                'role' => 'manager',
            ]);

            $this->activity->log('CREATE', $project, null, ['name' => $project->name, 'visibility' => $project->visibility]);

            return $project->load('columns');
        });
    }
}
