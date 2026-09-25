<?php

namespace Tests\Feature;

use App\Core\Access\PermissionCatalog;
use App\Modules\Identity\Actions\CreateMember;
use App\Modules\Identity\Actions\MembershipService;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Actions\ProvisionCompany;
use App\Modules\Organizations\Models\Company;
use App\Modules\Organizations\Models\Department;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Mail;
use Tests\TestCase;

class FoundationApiTest extends TestCase
{
    use RefreshDatabase;

    private const PASSWORD = '123456';

    public function test_health_endpoint(): void
    {
        $this->getJson('/api/v1/health')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'ok');
    }

    public function test_onboarding_login_and_tenant_isolation(): void
    {
        $first = $this->onboard('شرکت الف', 'owner-a@example.test');
        $second = $this->onboard('شرکت ب', 'owner-b@example.test');

        $created = $this->withToken($first['token'])
            ->postJson('/api/v1/departments', ['name' => 'نرم‌افزار', 'code' => 'DEV'])
            ->assertCreated()
            ->assertJsonPath('success', true);

        $uuid = $created->json('data.uuid');

        // The test client reuses the application, so the auth guard must be
        // forgotten between identities. php-fpm starts a fresh process per request.
        $this->app['auth']->forgetGuards();

        $this->withToken($second['token'])
            ->getJson('/api/v1/departments/'.$uuid)
            ->assertNotFound()
            ->assertJsonPath('success', false);

        $this->app['auth']->forgetGuards();

        $this->withToken($second['token'])
            ->getJson('/api/v1/departments')
            ->assertOk()
            ->assertJsonCount(0, 'data');

        $this->withToken($first['token'])
            ->getJson('/api/v1/auth/me')
            ->assertOk()
            ->assertJsonPath('data.company.name', 'شرکت الف')
            ->assertJsonPath('data.user.email', 'owner-a@example.test')
            ->assertJsonFragment(['slug' => 'company-owner']);
    }

    public function test_employee_cannot_create_department_until_granted(): void
    {
        $owner = $this->onboard('شرکت دسترسی', 'owner-perm@example.test');
        $company = Company::query()->where('uuid', $owner['company_uuid'])->firstOrFail();
        $actor = User::query()->where('email', 'owner-perm@example.test')->firstOrFail();

        app(\App\Core\Support\TenantContext::class)->set($company);
        $employee = app(CreateMember::class)->handle($company, [
            'name' => 'کارمند',
            'email' => 'employee@example.test',
            'password' => self::PASSWORD,
            'role_slugs' => ['employee'],
        ], $actor);

        $login = $this->postJson('/api/v1/auth/login', [
            'email' => 'employee@example.test',
            'password' => self::PASSWORD,
        ])->assertOk();

        $token = $login->json('data.token');

        $this->withToken($token)
            ->postJson('/api/v1/departments', ['name' => 'مخفی'])
            ->assertForbidden();

        app(MembershipService::class)->syncDirectPermissions($employee, $company, [
            PermissionCatalog::DEPARTMENTS_CREATE,
        ]);

        $this->withToken($token)
            ->postJson('/api/v1/departments', ['name' => 'واحد مجاز'])
            ->assertCreated();
    }

    public function test_login_rejects_bad_password_and_logout_revokes_token(): void
    {
        $owner = $this->onboard('شرکت نشست', 'owner-session@example.test');

        $this->postJson('/api/v1/auth/login', [
            'email' => 'owner-session@example.test',
            'password' => 'wrong-password',
        ])->assertUnauthorized()->assertJsonPath('success', false);

        $this->withToken($owner['token'])
            ->getJson('/api/v1/auth/sessions')
            ->assertOk()
            ->assertJsonPath('data.0.is_current', true);

        $this->withToken($owner['token'])
            ->postJson('/api/v1/auth/logout')
            ->assertOk();

        $this->assertDatabaseCount('personal_access_tokens', 0);
        $this->app['auth']->forgetGuards();

        $this->withToken($owner['token'])
            ->getJson('/api/v1/auth/me')
            ->assertUnauthorized();
    }

    public function test_activity_log_role_protection_and_schedule(): void
    {
        $owner = $this->onboard('شرکت گزارش', 'owner-log@example.test');
        $token = $owner['token'];

        $this->withToken($token)
            ->postJson('/api/v1/departments', ['name' => 'مالی', 'code' => 'FIN'])
            ->assertCreated();

        $this->withToken($token)
            ->getJson('/api/v1/activity-logs')
            ->assertOk()
            ->assertJsonFragment(['action' => 'CREATE']);

        $roles = $this->withToken($token)->getJson('/api/v1/roles')->assertOk()->json('data');
        $ownerRole = collect($roles)->firstWhere('slug', 'company-owner');
        $employeeRole = collect($roles)->firstWhere('slug', 'employee');

        $this->withToken($token)
            ->deleteJson('/api/v1/roles/'.$employeeRole['uuid'])
            ->assertStatus(422);

        $this->withToken($token)
            ->putJson('/api/v1/roles/'.$ownerRole['uuid'], [
                'name' => 'مالک شرکت',
                'permissions' => ['dashboard.view'],
            ])
            ->assertOk();

        $fresh = $this->withToken($token)->getJson('/api/v1/roles')->json('data');
        $updatedOwner = collect($fresh)->firstWhere('slug', 'company-owner');
        $this->assertContains('users.create', $updatedOwner['permissions']);

        $days = [];
        foreach (range(0, 6) as $weekday) {
            $days[] = [
                'weekday' => $weekday,
                'is_working_day' => $weekday !== 5,
                'start_time' => '08:30',
                'end_time' => '16:30',
                'break_minutes' => 45,
                'grace_minutes' => 10,
            ];
        }

        $this->withToken($token)
            ->putJson('/api/v1/work-schedules', ['days' => $days])
            ->assertOk()
            ->assertJsonPath('data.0.start_time', '08:30');
    }

    public function test_team_rejects_outsider_and_department_with_team_cannot_be_deleted(): void
    {
        $owner = $this->onboard('شرکت تیم', 'owner-team@example.test');
        $other = $this->onboard('شرکت دیگر', 'owner-other@example.test');

        $department = $this->withToken($owner['token'])
            ->postJson('/api/v1/departments', ['name' => 'فروش'])
            ->assertCreated()
            ->json('data');

        $this->withToken($owner['token'])
            ->postJson('/api/v1/teams', [
                'name' => 'میز فروش',
                'department_uuid' => $department['uuid'],
                'members' => [[
                    'uuid' => $other['user_uuid'],
                    'role' => 'member',
                ]],
            ])
            ->assertStatus(422);

        $this->withToken($owner['token'])
            ->postJson('/api/v1/teams', [
                'name' => 'میز فروش',
                'department_uuid' => $department['uuid'],
            ])
            ->assertCreated();

        $this->withToken($owner['token'])
            ->deleteJson('/api/v1/departments/'.$department['uuid'])
            ->assertStatus(422);
    }

    public function test_department_patch_keeps_manager_and_sort_when_omitted(): void
    {
        $owner = $this->onboard('شرکت واحد', 'dept-owner@example.test');

        $created = $this->withToken($owner['token'])
            ->postJson('/api/v1/departments', [
                'name' => 'توسعه',
                'sort_order' => 4,
                'manager_uuid' => $owner['user_uuid'],
            ])
            ->assertCreated()
            ->json('data');

        $this->assertSame($owner['user_uuid'], $created['manager']['uuid']);

        $this->withToken($owner['token'])
            ->patchJson('/api/v1/departments/'.$created['uuid'], [
                'name' => 'توسعه نرم‌افزار',
                'description' => 'محصول',
            ])
            ->assertOk()
            ->assertJsonPath('data.manager.uuid', $owner['user_uuid'])
            ->assertJsonPath('data.sort_order', 4)
            ->assertJsonPath('data.name', 'توسعه نرم‌افزار');

        $this->withToken($owner['token'])
            ->patchJson('/api/v1/departments/'.$created['uuid'], [
                'name' => 'توسعه نرم‌افزار',
                'manager_uuid' => null,
            ])
            ->assertOk()
            ->assertJsonPath('data.manager', null);
    }

    public function test_invitation_can_be_accepted_once(): void
    {
        Mail::fake();
        $owner = $this->onboard('شرکت دعوت', 'owner-invite@example.test');

        $roleUuid = collect($this->withToken($owner['token'])->getJson('/api/v1/roles')->json('data'))
            ->firstWhere('slug', 'employee')['uuid'];

        $invite = $this->withToken($owner['token'])
            ->postJson('/api/v1/invitations', [
                'email' => 'new.person@example.test',
                'name' => 'شخص جدید',
                'role_uuid' => $roleUuid,
            ])
            ->assertCreated();

        $token = basename(parse_url($invite->json('data.accept_url'), PHP_URL_PATH) ? '' : '');
        $acceptUrl = $invite->json('data.accept_url');
        parse_str((string) parse_url($acceptUrl, PHP_URL_QUERY), $query);

        $accepted = $this->postJson('/api/v1/auth/accept-invite', [
            'token' => $query['token'],
            'name' => 'شخص جدید',
            'password' => self::PASSWORD,
            'password_confirmation' => self::PASSWORD,
        ])->assertOk()->assertJsonPath('data.user.email', 'new.person@example.test');

        $this->withToken($accepted->json('data.token'))
            ->getJson('/api/v1/dashboard')
            ->assertOk()
            ->assertJsonPath('data.company.name', 'شرکت دعوت');

        $this->postJson('/api/v1/auth/accept-invite', [
            'token' => $query['token'],
            'name' => 'شخص جدید',
            'password' => self::PASSWORD,
            'password_confirmation' => self::PASSWORD,
        ])->assertStatus(422);
    }

    public function test_forgot_password_does_not_reveal_unknown_emails(): void
    {
        $this->postJson('/api/v1/auth/forgot-password', ['email' => 'missing@example.test'])
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->onboard('شرکت بازیابی', 'known@example.test');

        $this->postJson('/api/v1/auth/forgot-password', ['email' => 'known@example.test'])
            ->assertOk()
            ->assertJsonPath('success', true);
    }

    public function test_platform_admin_lists_companies_but_needs_context_for_tenant_data(): void
    {
        $this->onboard('شرکت پلتفرم', 'owner-platform@example.test');

        $admin = User::query()->create([
            'name' => 'ادمین',
            'email' => 'root@example.test',
            'password' => self::PASSWORD,
            'status' => 'active',
            'is_platform_admin' => true,
            'locale' => 'fa',
        ]);

        $login = $this->postJson('/api/v1/auth/login', [
            'email' => 'root@example.test',
            'password' => self::PASSWORD,
        ])->assertOk();

        $token = $login->json('data.token');

        $this->withToken($token)
            ->getJson('/api/v1/platform/companies')
            ->assertOk()
            ->assertJsonFragment(['name' => 'شرکت پلتفرم']);

        $this->withToken($token)
            ->getJson('/api/v1/departments')
            ->assertStatus(409);

        $companyUuid = Company::query()->where('name', 'شرکت پلتفرم')->firstOrFail()->uuid;

        $this->withToken($token)
            ->withHeader('X-Company-Id', $companyUuid)
            ->getJson('/api/v1/departments')
            ->assertOk();

        $this->assertNotNull($admin->id);
    }

    public function test_suspended_user_cannot_login(): void
    {
        $this->onboard('شرکت تعلیق', 'suspended-owner@example.test');
        $user = User::query()->where('email', 'suspended-owner@example.test')->firstOrFail();
        $user->forceFill(['status' => 'suspended'])->save();

        $this->postJson('/api/v1/auth/login', [
            'email' => 'suspended-owner@example.test',
            'password' => self::PASSWORD,
        ])->assertUnauthorized();
    }

    public function test_search_is_scoped_to_the_current_company(): void
    {
        $first = $this->onboard('شرکت جستجو', 'search-owner@example.test');
        $this->onboard('شرکت پنهان', 'hidden-owner@example.test');

        $this->withToken($first['token'])
            ->getJson('/api/v1/search?q=hidden-owner')
            ->assertOk()
            ->assertJsonCount(0, 'data.users');

        $this->withToken($first['token'])
            ->getJson('/api/v1/search?q=search-owner')
            ->assertOk()
            ->assertJsonPath('data.users.0.email', 'search-owner@example.test');
    }

    /**
     * @return array{token: string, company_uuid: string, user_uuid: string}
     */
    private function onboard(string $company, string $email): array
    {
        $response = $this->postJson('/api/v1/onboarding/company', [
            'company_name' => $company,
            'admin_name' => 'مالک',
            'email' => $email,
            'password' => self::PASSWORD,
            'password_confirmation' => self::PASSWORD,
            'timezone' => 'Asia/Tehran',
            'locale' => 'fa',
        ])->assertCreated();

        return [
            'token' => $response->json('data.token'),
            'company_uuid' => $response->json('data.company.uuid'),
            'user_uuid' => $response->json('data.user.uuid'),
        ];
    }
}
