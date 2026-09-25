<?php

namespace Tests\Feature;

use App\Modules\Identity\Actions\CreateMember;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use App\Modules\Organizations\Models\Department;
use App\Core\Support\TenantContext;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PersonWorkApiTest extends TestCase
{
    use RefreshDatabase;

    private const PASSWORD = 'Secret@123';

    protected function tearDown(): void
    {
        Carbon::setTestNow();
        parent::tearDown();
    }

    public function test_manager_reads_one_persons_work_log_hours_and_reports(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-09-26 18:00:00', 'Asia/Tehran'));
        $owner = $this->onboard('شرکت گزارش', 'log-owner@example.test');
        $employee = $this->member($owner, 'کارمند گزارش', 'log-employee@example.test', ['employee']);

        $this->withToken($employee['token'])
            ->postJson('/api/v1/attendance/check-in', ['location' => 'office'])
            ->assertOk();

        Carbon::setTestNow(Carbon::parse('2026-09-26 18:30:00', 'Asia/Tehran'));
        $this->withToken($employee['token'])
            ->postJson('/api/v1/attendance/reports', [
                'kind' => 'daily',
                'body' => 'گزارش پایان روز برای مدیر.',
                'blockers' => 'ندارد',
            ])
            ->assertOk();

        Carbon::setTestNow(Carbon::parse('2026-09-26 19:00:00', 'Asia/Tehran'));
        $log = $this->withToken($owner['token'])
            ->getJson('/api/v1/attendance/people/'.$employee['user_uuid'])
            ->assertOk()
            ->json('data');

        $this->assertSame('Asia/Tehran', $log['timezone']);
        $this->assertSame('jalali', $log['calendar']);
        $this->assertSame(1, $log['summary']['days']);
        $this->assertSame(1, $log['summary']['present_days']);
        $this->assertSame(1, $log['summary']['reports']);
        $this->assertSame('گزارش پایان روز برای مدیر.', $log['reports'][0]['body']);
        $this->assertSame('2026-09-26', $log['days'][0]['work_date']);
        $this->assertArrayHasKey('worked_minutes', $log['days'][0]);
        $this->assertArrayHasKey('expected_minutes', $log['days'][0]);
    }

    public function test_work_log_is_hidden_from_other_companies_and_from_plain_colleagues(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-09-26 09:00:00', 'Asia/Tehran'));
        $first = $this->onboard('شرکت اول گزارش', 'log-a@example.test');
        $second = $this->onboard('شرکت دوم گزارش', 'log-b@example.test');
        $employee = $this->member($first, 'کارمند اول', 'log-a-employee@example.test', ['employee']);
        $colleague = $this->member($first, 'همکار اول', 'log-a-peer@example.test', ['employee']);

        $this->withToken($second['token'])
            ->getJson('/api/v1/attendance/people/'.$employee['user_uuid'])
            ->assertNotFound();

        $this->withToken($colleague['token'])
            ->getJson('/api/v1/attendance/people/'.$employee['user_uuid'])
            ->assertForbidden();
    }

    public function test_manager_sends_a_task_to_a_person_and_sees_it_in_their_task_list(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-09-26 10:00:00', 'Asia/Tehran'));
        $owner = $this->onboard('شرکت وظیفه', 'task-owner@example.test');
        $employee = $this->member($owner, 'کارمند وظیفه', 'task-employee@example.test', ['employee']);
        $other = $this->member($owner, 'همکار وظیفه', 'task-peer@example.test', ['employee']);

        $project = $this->withToken($owner['token'])
            ->postJson('/api/v1/projects', ['name' => 'پروژه ارسال وظیفه'])
            ->assertCreated()
            ->json('data');

        $task = $this->withToken($owner['token'])
            ->postJson('/api/v1/tasks', [
                'project_uuid' => $project['uuid'],
                'title' => 'وظیفه برای کارمند',
                'assignee_uuid' => $employee['user_uuid'],
                'priority' => 'high',
                'due_date' => '2026-09-30',
            ])
            ->assertCreated()
            ->assertJsonPath('data.assignee.uuid', $employee['user_uuid'])
            ->json('data');

        $list = $this->withToken($owner['token'])
            ->getJson('/api/v1/tasks/people/'.$employee['user_uuid'])
            ->assertOk()
            ->json('data');

        $this->assertSame(1, $list['summary']['total']);
        $this->assertSame(1, $list['summary']['open']);
        $this->assertSame('وظیفه برای کارمند', $list['tasks'][0]['title']);

        $this->withToken($employee['token'])
            ->getJson('/api/v1/tasks/people/'.$other['user_uuid'])
            ->assertOk()
            ->assertJsonPath('data.summary.total', 0);
    }

    public function test_employee_can_assign_to_self_but_not_to_somebody_else(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-09-26 10:00:00', 'Asia/Tehran'));
        $owner = $this->onboard('شرکت انتساب', 'assign-owner@example.test');
        $employee = $this->member($owner, 'کارمند انتساب', 'assign-employee@example.test', ['employee']);
        $other = $this->member($owner, 'هدف انتساب', 'assign-target@example.test', ['employee']);

        $project = $this->withToken($owner['token'])
            ->postJson('/api/v1/projects', ['name' => 'پروژه انتساب'])
            ->assertCreated()
            ->json('data');

        $this->withToken($employee['token'])
            ->postJson('/api/v1/tasks', [
                'project_uuid' => $project['uuid'],
                'title' => 'وظیفه شخصی',
                'assignee_uuid' => $employee['user_uuid'],
            ])
            ->assertCreated();

        $this->withToken($employee['token'])
            ->postJson('/api/v1/tasks', [
                'project_uuid' => $project['uuid'],
                'title' => 'وظیفه برای دیگری',
                'assignee_uuid' => $other['user_uuid'],
            ])
            ->assertForbidden();
    }

    public function test_company_calendar_system_is_stored_and_reported_to_the_client(): void
    {
        $owner = $this->onboard('شرکت تقویم', 'calendar-owner@example.test');

        $this->withToken($owner['token'])
            ->getJson('/api/v1/auth/me')
            ->assertOk()
            ->assertJsonPath('data.company.calendar', 'jalali')
            ->assertJsonPath('data.company.timezone', 'Asia/Tehran');

        $this->withToken($owner['token'])
            ->patchJson('/api/v1/company', ['calendar' => 'gregorian'])
            ->assertOk()
            ->assertJsonPath('data.calendar', 'gregorian');

        $this->withToken($owner['token'])
            ->getJson('/api/v1/auth/me')
            ->assertOk()
            ->assertJsonPath('data.company.calendar', 'gregorian');

        $this->withToken($owner['token'])
            ->patchJson('/api/v1/company', ['calendar' => 'solar-hijri'])
            ->assertStatus(422);
    }

    /**
     * @param  list<string>  $roles
     * @return array{token: string, user_uuid: string}
     */
    private function member(array $owner, string $name, string $email, array $roles): array
    {
        $companyId = Company::query()->where('uuid', $owner['company_uuid'])->value('id');
        $department = Department::query()->withoutGlobalScope('company')->create([
            'company_id' => $companyId,
            'name' => 'واحد گزارش',
            'slug' => 'unit-'.substr(md5($email), 0, 8),
        ]);

        app(TenantContext::class)->set(Company::query()->find($companyId));

        $user = app(CreateMember::class)->handle(
            Company::query()->find($companyId),
            [
                'name' => $name,
                'email' => $email,
                'password' => self::PASSWORD,
                'department_uuid' => $department->uuid,
                'role_slugs' => $roles,
                'locale' => 'fa',
                'timezone' => 'Asia/Tehran',
            ],
            User::query()->where('uuid', $owner['user_uuid'])->first(),
        );

        $login = $this->postJson('/api/v1/auth/login', [
            'email' => $email,
            'password' => self::PASSWORD,
        ])->assertOk();

        return ['token' => $login->json('data.token'), 'user_uuid' => $user->uuid];
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
