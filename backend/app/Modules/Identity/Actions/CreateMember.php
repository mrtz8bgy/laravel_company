<?php

declare(strict_types=1);

namespace App\Modules\Identity\Actions;

use App\Core\Services\ActivityLogger;
use App\Core\Services\AuthorizationService;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use App\Modules\Organizations\Models\Department;
use App\Modules\Organizations\Models\Team;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class CreateMember
{
    public function __construct(
        private readonly MembershipService $memberships,
        private readonly AuthorizationService $authorization,
        private readonly ActivityLogger $activity,
    ) {}

    /**
     * @param  array<string, mixed>  $input
     */
    public function handle(Company $company, array $input, User $actor): User
    {
        $roleSlugs = $input['role_slugs'] ?? [];
        $this->authorization->assertCanAssignRoles($actor, $roleSlugs, $company);

        $email = strtolower(trim((string) $input['email']));
        $existing = User::query()->where('email', $email)->first();

        if ($existing && $existing->memberships()->where('company_id', $company->id)->exists()) {
            throw ValidationException::withMessages([
                'email' => [__('messages.already_member')],
            ]);
        }

        return DB::transaction(function () use ($company, $input, $actor, $existing, $email, $roleSlugs): User {
            $user = $existing ?? User::query()->create([
                'name' => $input['name'],
                'email' => $email,
                'phone' => $input['phone'] ?? null,
                'password' => $input['password'],
                'locale' => $input['locale'] ?? $company->locale,
                'timezone' => $input['timezone'] ?? $company->timezone,
                'status' => 'active',
                'email_verified_at' => now(),
            ]);

            if ($existing && ! empty($input['name'])) {
                $user->forceFill(['name' => $input['name']])->save();
            }

            $departmentId = $this->departmentId($input['department_uuid'] ?? null);
            $this->memberships->attach($company, $user, [
                'job_title' => $input['job_title'] ?? null,
                'employee_code' => $input['employee_code'] ?? null,
                'department_id' => $departmentId,
                'status' => 'active',
            ], $roleSlugs);

            if (! empty($input['team_uuid'])) {
                $this->joinTeam($user, (string) $input['team_uuid'], (string) ($input['team_role'] ?? 'member'));
            }

            $this->activity->log('CREATE', $user, null, [
                'email' => $user->email,
                'roles' => $roleSlugs,
            ], 'Member added');

            return $user;
        });
    }

    private function departmentId(?string $uuid): ?int
    {
        if (! $uuid) {
            return null;
        }

        $department = Department::query()->where('uuid', $uuid)->first();
        if (! $department) {
            throw ValidationException::withMessages([
                'department_uuid' => [__('messages.not_found')],
            ]);
        }

        return $department->id;
    }

    private function joinTeam(User $user, string $uuid, string $role): void
    {
        $team = Team::query()->where('uuid', $uuid)->first();
        if (! $team) {
            throw ValidationException::withMessages([
                'team_uuid' => [__('messages.not_found')],
            ]);
        }

        $team->members()->syncWithoutDetaching([
            $user->id => ['role' => $role === 'leader' ? 'leader' : 'member'],
        ]);

        if ($role === 'leader') {
            $team->forceFill(['leader_id' => $user->id])->save();
        }
    }
}
