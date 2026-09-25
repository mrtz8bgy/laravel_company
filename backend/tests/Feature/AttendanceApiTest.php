<?php

namespace Tests\Feature;

use App\Modules\Identity\Actions\CreateMember;
use App\Modules\Organizations\Models\Department;
use App\Modules\Organizations\Models\Feature;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AttendanceApiTest extends TestCase
{
    use RefreshDatabase;

    private const PASSWORD = '123456';

    protected function tearDown(): void
    {
        Carbon::setTestNow();
        parent::tearDown();
    }

    public function test_employee_clocks_break_and_late_is_calculated(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-09-26 09:40:00', 'Asia/Tehran'));
        $owner = $this->onboard('شرکت حضور', 'att-owner@example.test');
        $employee = $this->member($owner, 'کارمند حضور', 'att-employee@example.test', ['employee']);

        $this->withToken($employee['token'])
            ->postJson('/api/v1/attendance/check-in', ['location' => 'office'])
            ->assertOk()
            ->assertJsonPath('data.late_minutes', 25)
            ->assertJsonPath('data.check_in_local', '09:40');

        $this->withToken($employee['token'])
            ->postJson('/api/v1/attendance/check-in', ['location' => 'office'])
            ->assertStatus(422);

        Carbon::setTestNow(Carbon::parse('2026-09-26 13:00:00', 'Asia/Tehran'));
        $this->withToken($employee['token'])
            ->postJson('/api/v1/attendance/break/start')
            ->assertOk()
            ->assertJsonPath('data.day_status', 'open');

        Carbon::setTestNow(Carbon::parse('2026-09-26 13:20:00', 'Asia/Tehran'));
        $this->withToken($employee['token'])
            ->postJson('/api/v1/attendance/break/end')
            ->assertOk()
            ->assertJsonPath('data.break_minutes', 20);

        Carbon::setTestNow(Carbon::parse('2026-09-26 17:00:00', 'Asia/Tehran'));
        $this->withToken($employee['token'])
            ->postJson('/api/v1/attendance/check-out')
            ->assertOk()
            ->assertJsonPath('data.day_status', 'closed')
            ->assertJsonPath('data.worked_minutes', 420);

        $this->withToken($employee['token'])
            ->postJson('/api/v1/attendance/reports', [
                'kind' => 'daily',
                'body' => 'گزارش پایان روز: هستهٔ حضور بسته شد.',
            ])
            ->assertOk()
            ->assertJsonPath('data.kind', 'daily');
    }

    public function test_employee_cannot_see_another_company_or_correct_records(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-09-26 09:10:00', 'Asia/Tehran'));
        $first = $this->onboard('شرکت اول حضور', 'att-a@example.test');
        $second = $this->onboard('شرکت دوم حضور', 'att-b@example.test');
        $employee = $this->member($first, 'کارمند محدود', 'att-limited@example.test', ['employee']);

        $day = $this->withToken($first['token'])
            ->postJson('/api/v1/attendance/check-in', ['location' => 'remote'])
            ->assertOk()
            ->json('data');

        $this->withToken($second['token'])
            ->getJson('/api/v1/attendance/board')
            ->assertOk()
            ->assertJsonPath('data.summary.people', 1);

        $this->withToken($second['token'])
            ->patchJson('/api/v1/attendance/days/'.$day['uuid'], [
                'check_in_at' => '2026-09-26T09:00:00+03:30',
            ])
            ->assertStatus(404);

        $this->withToken($employee['token'])
            ->getJson('/api/v1/attendance/board')
            ->assertForbidden();

        $this->withToken($employee['token'])
            ->patchJson('/api/v1/attendance/days/'.$day['uuid'], [
                'excused' => true,
            ])
            ->assertForbidden();
    }

    public function test_hr_can_correct_and_feature_can_be_disabled(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-09-26 10:00:00', 'Asia/Tehran'));
        $owner = $this->onboard('شرکت منابع', 'att-hr-owner@example.test');
        $hr = $this->member($owner, 'کارشناس منابع', 'att-hr@example.test', ['hr']);
        $employee = $this->member($owner, 'کارمند دیر', 'att-late@example.test', ['employee']);

        $day = $this->withToken($employee['token'])
            ->postJson('/api/v1/attendance/check-in', ['location' => 'office'])
            ->assertOk()
            ->json('data');

        $this->assertGreaterThan(0, $day['late_minutes']);

        $this->withToken($hr['token'])
            ->getJson('/api/v1/attendance/board')
            ->assertOk()
            ->assertJsonPath('data.summary.late', 1);

        $this->withToken($hr['token'])
            ->patchJson('/api/v1/attendance/days/'.$day['uuid'], [
                'check_in_at' => '2026-09-26T09:05:00+03:30',
                'excused' => false,
            ])
            ->assertOk()
            ->assertJsonPath('data.late_minutes', 0)
            ->assertJsonPath('data.check_in_local', '09:05');

        Feature::query()->withoutGlobalScope('company')->where('key', 'attendance')->update(['enabled' => false]);

        $this->withToken($employee['token'])
            ->postJson('/api/v1/attendance/check-out')
            ->assertForbidden();
    }

    public function test_leave_status_excuses_lateness_and_tasks_placeholder_is_empty(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-09-26 11:15:00', 'Asia/Tehran'));
        $owner = $this->onboard('شرکت مرخصی', 'att-leave-owner@example.test');

        $this->withToken($owner['token'])
            ->putJson('/api/v1/attendance/status', ['status' => 'leave', 'note' => 'مرخصی'])
            ->assertOk()
            ->assertJsonPath('data.excused', true)
            ->assertJsonPath('data.late_minutes', 0);

        $this->withToken($owner['token'])
            ->getJson('/api/v1/attendance/today')
            ->assertOk()
            ->assertJsonPath('data.presence.status', 'leave')
            ->assertJsonPath('data.tasks_available', true)
            ->assertJsonCount(0, 'data.tasks');
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
            \App\Modules\Identity\Models\User::query()->where('email', $owner['email'] ?? 'unused')->first()
                ?? \App\Modules\Identity\Models\User::query()->where('uuid', $owner['user_uuid'])->first(),
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
