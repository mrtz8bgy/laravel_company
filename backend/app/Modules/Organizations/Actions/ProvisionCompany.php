<?php

declare(strict_types=1);

namespace App\Modules\Organizations\Actions;

use App\Core\Access\FeatureCatalog;
use App\Core\Access\PermissionCatalog;
use App\Core\Services\ActivityLogger;
use App\Core\Support\Slugger;
use App\Core\Support\TenantContext;
use App\Modules\Access\Actions\SyncPermissions;
use App\Modules\Access\Models\Permission;
use App\Modules\Access\Models\Role;
use App\Modules\Identity\Actions\MembershipService;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use App\Modules\Organizations\Models\Feature;
use App\Modules\Organizations\Models\WorkSchedule;
use Illuminate\Support\Facades\DB;

class ProvisionCompany
{
    public function __construct(
        private readonly SyncPermissions $syncPermissions,
        private readonly MembershipService $memberships,
        private readonly ActivityLogger $activity,
        private readonly TenantContext $tenant,
    ) {}

    /**
     * @param  array{
     *     company_name: string,
     *     legal_name?: string|null,
     *     slug?: string|null,
     *     timezone?: string|null,
     *     locale?: string|null,
     *     admin_name: string,
     *     email: string,
     *     password: string,
     *     phone?: string|null
     * }  $input
     * @return array{company: Company, user: User}
     */
    public function handle(array $input): array
    {
        return DB::transaction(function () use ($input): array {
            $this->syncPermissions->handle();

            $slug = Slugger::unique(
                $input['slug'] ?? $input['company_name'],
                fn (string $candidate): bool => Company::query()->where('slug', $candidate)->exists(),
                'co',
            );

            $company = Company::query()->create([
                'name' => $input['company_name'],
                'legal_name' => $input['legal_name'] ?? $input['company_name'],
                'slug' => $slug,
                'status' => 'active',
                'timezone' => $input['timezone'] ?? config('vcos.default_timezone'),
                'locale' => $input['locale'] ?? config('vcos.default_locale'),
                'plan' => null,
                'settings' => [
                    'onboarding' => [
                        'departments' => false,
                        'teams' => false,
                        'invites' => false,
                        'schedule' => false,
                    ],
                ],
            ]);

            $user = User::query()->create([
                'name' => $input['admin_name'],
                'email' => strtolower(trim($input['email'])),
                'phone' => $input['phone'] ?? null,
                'password' => $input['password'],
                'locale' => $company->locale,
                'timezone' => $company->timezone,
                'status' => 'active',
                'email_verified_at' => now(),
            ]);

            $this->tenant->set($company);
            $this->seedRoles($company);
            $this->seedSchedule($company);
            $this->seedFeatures($company);

            $this->memberships->attach($company, $user, [
                'job_title' => 'مالک شرکت',
                'is_owner' => true,
                'status' => 'active',
            ], ['company-owner']);

            $this->activity->log('CREATE', $company, null, [
                'name' => $company->name,
                'slug' => $company->slug,
            ], 'Company provisioned', $company->id, $user->id);

            return ['company' => $company, 'user' => $user];
        });
    }

    private function seedRoles(Company $company): void
    {
        $permissions = Permission::query()->pluck('id', 'name');

        foreach (PermissionCatalog::roleTemplates() as $slug => $template) {
            $role = Role::query()->create([
                'company_id' => $company->id,
                'name' => $template['name'],
                'slug' => $slug,
                'description' => $template['description'],
                'is_system' => true,
            ]);

            $ids = collect($template['permissions'])
                ->map(fn (string $name) => $permissions[$name] ?? null)
                ->filter()
                ->values()
                ->all();

            $role->permissions()->sync($ids);
        }
    }

    private function seedSchedule(Company $company): void
    {
        // PHP date('w'): 0 Sunday ... 6 Saturday. Iran default: Sat–Thu.
        $working = [6, 0, 1, 2, 3, 4];
        foreach (range(0, 6) as $weekday) {
            WorkSchedule::query()->create([
                'company_id' => $company->id,
                'weekday' => $weekday,
                'is_working_day' => in_array($weekday, $working, true),
                'start_time' => '09:00',
                'end_time' => '17:00',
                'break_minutes' => 60,
                'grace_minutes' => 15,
            ]);
        }
    }

    private function seedFeatures(Company $company): void
    {
        foreach (FeatureCatalog::defaults() as $key => $enabled) {
            Feature::query()->create([
                'company_id' => $company->id,
                'key' => $key,
                'enabled' => $enabled,
            ]);
        }
    }
}
