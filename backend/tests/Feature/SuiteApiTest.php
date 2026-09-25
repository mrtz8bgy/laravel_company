<?php

namespace Tests\Feature;

use App\Modules\Identity\Actions\CreateMember;
use App\Modules\Organizations\Models\Department;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SuiteApiTest extends TestCase
{
    use RefreshDatabase;

    private const PASSWORD = 'Secret@123';

    public function test_finance_and_crm_stay_inside_their_roles_and_company(): void
    {
        $owner = $this->onboard('شرکت سوئیت', 'suite-owner@example.test');
        $employee = $this->member($owner, 'کارمند', 'suite-employee@example.test', ['employee']);
        $sales = $this->member($owner, 'فروش', 'suite-sales@example.test', ['sales']);
        $finance = $this->member($owner, 'مالی', 'suite-finance@example.test', ['finance']);
        $other = $this->onboard('شرکت بیگانه', 'suite-other@example.test');

        $this->withToken($employee['token'])->getJson('/api/v1/finance/invoices')->assertForbidden();
        $this->withToken($employee['token'])->getJson('/api/v1/crm/deals')->assertForbidden();
        $this->withToken($sales['token'])->getJson('/api/v1/finance/invoices')->assertForbidden();

        $deal = $this->withToken($sales['token'])
            ->postJson('/api/v1/crm/deals', ['title' => 'معاملهٔ خصوصی', 'amount' => 9000000])
            ->assertCreated()
            ->json('data');

        $this->withToken($other['token'])
            ->patchJson('/api/v1/crm/deals/'.$deal['uuid'], ['stage' => 'won'])
            ->assertNotFound();

        $invoice = $this->withToken($finance['token'])
            ->postJson('/api/v1/finance/invoices', [
                'number' => 'INV-1',
                'party_name' => 'مشتری',
                'amount' => 5000000,
                'status' => 'sent',
            ])
            ->assertCreated()
            ->json('data');

        $this->withToken($other['token'])
            ->getJson('/api/v1/finance/invoices')
            ->assertOk()
            ->assertJsonCount(0, 'data');

        $this->assertNotSame($owner['company_uuid'], $other['company_uuid']);
        $this->assertNotEmpty($invoice['uuid']);
    }

    public function test_reviewer_cannot_approve_own_request_and_private_document_is_hidden(): void
    {
        $owner = $this->onboard('شرکت گردش', 'flow-owner@example.test');
        $employee = $this->member($owner, 'درخواست‌دهنده', 'flow-employee@example.test', ['employee']);

        $own = $this->withToken($owner['token'])
            ->postJson('/api/v1/approvals', ['title' => 'درخواست خودم', 'note' => 'نباید بسته شود'])
            ->assertCreated()
            ->json('data');

        $this->withToken($owner['token'])
            ->postJson('/api/v1/approvals/'.$own['uuid'].'/review', ['decision' => 'approved'])
            ->assertStatus(422);

        $request = $this->withToken($employee['token'])
            ->postJson('/api/v1/approvals', ['title' => 'خرید ابزار', 'note' => 'برای تیم'])
            ->assertCreated()
            ->json('data');

        $this->withToken($owner['token'])
            ->postJson('/api/v1/approvals/'.$request['uuid'].'/review', ['decision' => 'approved'])
            ->assertOk()
            ->assertJsonPath('data.status', 'approved');

        $document = $this->withToken($owner['token'])
            ->postJson('/api/v1/documents', [
                'title' => 'یادداشت خصوصی',
                'body' => 'فقط مالک',
                'visibility' => 'private',
            ])
            ->assertCreated()
            ->json('data');

        $this->withToken($employee['token'])
            ->getJson('/api/v1/documents/'.$document['uuid'])
            ->assertNotFound();
    }

    public function test_analytics_hides_metrics_the_role_cannot_see(): void
    {
        $owner = $this->onboard('شرکت سنجه', 'metric-owner@example.test');
        $employee = $this->member($owner, 'کارمند سنجه', 'metric-employee@example.test', ['employee']);
        $finance = $this->member($owner, 'مالی سنجه', 'metric-finance@example.test', ['finance']);

        $this->withToken($finance['token'])
            ->postJson('/api/v1/finance/invoices', [
                'number' => 'INV-9',
                'party_name' => 'طرف',
                'amount' => 1000,
                'status' => 'sent',
            ])
            ->assertCreated();

        $this->withToken($employee['token'])->getJson('/api/v1/analytics/overview')->assertForbidden();

        $cards = $this->withToken($finance['token'])
            ->getJson('/api/v1/analytics/overview')
            ->assertOk()
            ->json('data');

        $keys = collect($cards)->pluck('key');
        $this->assertTrue($keys->contains('outstanding'));
        $this->assertFalse($keys->contains('pipeline'));
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
            'name' => 'واحد',
            'slug' => 'unit-'.substr(md5($email), 0, 8),
        ]);
        app(\App\Core\Support\TenantContext::class)->set(\App\Modules\Organizations\Models\Company::query()->find($companyId));
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
        $login = $this->postJson('/api/v1/auth/login', ['email' => $email, 'password' => self::PASSWORD])->assertOk();

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
