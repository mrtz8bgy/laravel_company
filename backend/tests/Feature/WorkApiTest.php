<?php

namespace Tests\Feature;

use App\Modules\Attendance\Models\AttendanceDay;
use App\Modules\Hr\Models\HrProfile;
use App\Modules\Identity\Actions\CreateMember;
use App\Modules\Organizations\Models\Department;
use App\Modules\Organizations\Models\Feature;
use App\Modules\Projects\Models\Project;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WorkApiTest extends TestCase
{
    use RefreshDatabase;

    private const PASSWORD = '123456';

    protected function tearDown(): void
    {
        Carbon::setTestNow();
        parent::tearDown();
    }

    public function test_private_project_stays_hidden_and_today_tasks_fill_attendance(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-09-26 10:00:00', 'Asia/Tehran'));
        $owner = $this->onboard('شرکت پروژه', 'work-owner@example.test');
        $employee = $this->member($owner, 'کارمند پروژه', 'work-employee@example.test', ['employee']);
        $other = $this->onboard('شرکت دیگر', 'work-other@example.test');

        $project = $this->withToken($owner['token'])
            ->postJson('/api/v1/projects', [
                'name' => 'دفتر خصوصی',
                'visibility' => 'private',
            ])
            ->assertCreated()
            ->assertJsonPath('data.visibility', 'private')
            ->json('data');

        $this->withToken($employee['token'])
            ->getJson('/api/v1/projects')
            ->assertOk()
            ->assertJsonCount(0, 'data');

        $this->withToken($employee['token'])
            ->getJson('/api/v1/projects/'.$project['uuid'])
            ->assertNotFound();

        $this->withToken($other['token'])
            ->getJson('/api/v1/projects/'.$project['uuid'])
            ->assertNotFound();

        $this->withToken($owner['token'])
            ->postJson('/api/v1/projects/'.$project['uuid'].'/members', [
                'user_uuid' => $employee['user_uuid'],
                'role' => 'member',
            ])
            ->assertOk();

        $board = $this->withToken($employee['token'])
            ->getJson('/api/v1/projects/'.$project['uuid'].'/board')
            ->assertOk()
            ->json('data');

        $this->assertCount(4, $board['columns']);

        $this->withToken($employee['token'])
            ->postJson('/api/v1/tasks', [
                'project_uuid' => $project['uuid'],
                'title' => 'وظیفه امروز',
                'assignee_uuid' => $employee['user_uuid'],
                'due_date' => '2026-09-26',
            ])
            ->assertCreated();

        $this->withToken($employee['token'])
            ->getJson('/api/v1/attendance/today')
            ->assertOk()
            ->assertJsonPath('data.tasks_available', true)
            ->assertJsonPath('data.tasks.0.title', 'وظیفه امروز');

        Feature::query()->withoutGlobalScope('company')->where('key', 'projects')->update(['enabled' => false]);

        $this->withToken($employee['token'])
            ->getJson('/api/v1/projects')
            ->assertForbidden();

        $this->withToken($employee['token'])
            ->getJson('/api/v1/attendance/today')
            ->assertOk()
            ->assertJsonPath('data.tasks_available', false)
            ->assertJsonCount(0, 'data.tasks');
    }

    public function test_assignee_can_move_own_task_but_cannot_reassign_it(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-09-26 10:00:00', 'Asia/Tehran'));
        $owner = $this->onboard('شرکت کانبان', 'kanban-owner@example.test');
        $employee = $this->member($owner, 'مسئول وظیفه', 'kanban-employee@example.test', ['employee']);
        $other = $this->member($owner, 'همکار', 'kanban-other@example.test', ['employee']);

        $project = $this->withToken($owner['token'])
            ->postJson('/api/v1/projects', ['name' => 'فروشگاه', 'visibility' => 'company'])
            ->assertCreated()
            ->json('data');

        $board = $this->withToken($owner['token'])
            ->getJson('/api/v1/projects/'.$project['uuid'].'/board')
            ->assertOk()
            ->json('data');

        $task = $this->withToken($owner['token'])
            ->postJson('/api/v1/tasks', [
                'project_uuid' => $project['uuid'],
                'title' => 'کاتالوگ',
                'assignee_uuid' => $employee['user_uuid'],
            ])
            ->assertCreated()
            ->json('data');

        $this->withToken($other['token'])
            ->patchJson('/api/v1/tasks/'.$task['uuid'], ['title' => 'دستکاری'])
            ->assertForbidden();

        $done = collect($board['columns'])->firstWhere('is_done', true);

        $this->withToken($employee['token'])
            ->postJson('/api/v1/tasks/'.$task['uuid'].'/move', ['column_uuid' => $done['uuid']])
            ->assertOk()
            ->assertJsonPath('data.column.is_done', true);

        $this->withToken($employee['token'])
            ->patchJson('/api/v1/tasks/'.$task['uuid'], ['assignee_uuid' => $other['user_uuid']])
            ->assertForbidden();
    }

    public function test_salary_is_hidden_and_approved_leave_excuses_today(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-09-26 10:20:00', 'Asia/Tehran'));
        $owner = $this->onboard('شرکت منابع', 'hr-owner@example.test');
        $hr = $this->member($owner, 'کارشناس منابع', 'hr-user@example.test', ['hr']);
        $finance = $this->member($owner, 'مالی', 'hr-finance@example.test', ['finance']);
        $employee = $this->member($owner, 'کارمند مرخصی', 'hr-employee@example.test', ['employee']);

        $this->withToken($employee['token'])
            ->getJson('/api/v1/hr/me')
            ->assertOk()
            ->assertJsonMissingPath('data.national_id')
            ->assertJsonMissingPath('data.salary_amount');

        $this->withToken($finance['token'])
            ->getJson('/api/v1/hr/people/'.$employee['user_uuid'])
            ->assertForbidden();

        $this->withToken($hr['token'])
            ->patchJson('/api/v1/hr/people/'.$employee['user_uuid'], [
                'employment_type' => 'full_time',
                'national_id' => '0012345678',
                'salary_amount' => 420000000,
                'salary_currency' => 'IRR',
            ])
            ->assertOk()
            ->assertJsonPath('data.national_id', '0012345678');

        $this->withToken($employee['token'])
            ->getJson('/api/v1/hr/me')
            ->assertOk()
            ->assertJsonMissingPath('data.national_id');

        $this->withToken($hr['token'])
            ->getJson('/api/v1/hr/people/'.$employee['user_uuid'])
            ->assertOk()
            ->assertJsonPath('data.salary_amount', '420000000');

        $own = $this->withToken($hr['token'])
            ->postJson('/api/v1/hr/leave', [
                'type' => 'annual',
                'starts_on' => '2026-09-26',
                'ends_on' => '2026-09-26',
                'reason' => 'مرخصی خودم',
            ])
            ->assertCreated()
            ->json('data');

        $this->withToken($hr['token'])
            ->postJson('/api/v1/hr/leave/'.$own['uuid'].'/review', ['decision' => 'approved'])
            ->assertStatus(422);

        $this->withToken($employee['token'])
            ->postJson('/api/v1/attendance/check-in', ['location' => 'office'])
            ->assertOk();

        $leave = $this->withToken($employee['token'])
            ->postJson('/api/v1/hr/leave', [
                'type' => 'sick',
                'starts_on' => '2026-09-26',
                'ends_on' => '2026-09-28',
                'reason' => 'استعلاجی',
            ])
            ->assertCreated()
            ->json('data');

        $this->withToken($finance['token'])
            ->getJson('/api/v1/hr/leave')
            ->assertOk()
            ->assertJsonCount(0, 'data');

        $this->withToken($hr['token'])
            ->postJson('/api/v1/hr/leave/'.$leave['uuid'].'/review', ['decision' => 'approved'])
            ->assertOk()
            ->assertJsonPath('data.status', 'approved');

        $day = AttendanceDay::query()->withoutGlobalScope('company')->where('user_id', \App\Modules\Identity\Models\User::query()->where('uuid', $employee['user_uuid'])->value('id'))->first();
        $this->assertTrue((bool) $day?->excused);
        $this->assertSame(0, (int) $day?->late_minutes);

        $logged = \App\Core\Models\ActivityLog::query()->where('entity_type', 'hr_profile')->latest('id')->first();
        $this->assertNotNull($logged);
        $this->assertArrayNotHasKey('national_id', $logged->new_values ?? []);
        $this->assertArrayNotHasKey('salary_amount', $logged->new_values ?? []);

        Feature::query()->withoutGlobalScope('company')->where('key', 'attendance')->update(['enabled' => false]);
        $mission = $this->withToken($employee['token'])
            ->postJson('/api/v1/hr/missions', [
                'destination' => 'اصفهان',
                'starts_on' => '2026-09-26',
                'ends_on' => '2026-09-26',
                'purpose' => 'بازدید مشتری',
            ])
            ->assertCreated()
            ->json('data');

        $before = AttendanceDay::query()->withoutGlobalScope('company')->count();
        $this->withToken($hr['token'])
            ->postJson('/api/v1/hr/missions/'.$mission['uuid'].'/review', ['decision' => 'approved'])
            ->assertOk();
        $this->assertSame($before, AttendanceDay::query()->withoutGlobalScope('company')->count());
    }

    /**
     * @param  list<string>  $roles
     * @return array{token: string, user_uuid: string}
     */
    private function member(array $owner, string $name, string $email, array $roles): array
    {
        $companyId = \App\Modules\Organizations\Models\Company::query()->where('uuid', $owner['company_uuid'])->value('id');
        $department = Department::query()->withoutGlobalScope('company')->create([
            'company_id' => $companyId,
            'name' => 'واحد تست',
            'slug' => 'unit-'.substr(md5($email), 0, 8),
        ]);

        app(\App\Core\Support\TenantContext::class)->set(
            \App\Modules\Organizations\Models\Company::query()->find($companyId)
        );

        $user = app(CreateMember::class)->handle(
            \App\Modules\Organizations\Models\Company::query()->find($companyId),
            [
                'name' => $name,
                'email' => $email,
                'password' => self::PASSWORD,
                'department_uuid' => $department->uuid,
                'role_slugs' => $roles,
                'locale' => 'fa',
                'timezone' => 'Asia/Tehran',
            ],
            \App\Modules\Identity\Models\User::query()->where('uuid', $owner['user_uuid'])->first(),
        );

        $login = $this->postJson('/api/v1/auth/login', [
            'email' => $email,
            'password' => self::PASSWORD,
        ])->assertOk();

        return [
            'token' => $login->json('data.token'),
            'user_uuid' => $user->uuid,
        ];
    }

    /**
     * @return array{token: string, company_uuid: string, user_uuid: string, email: string}
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
            'email' => $email,
        ];
    }
}
