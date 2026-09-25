<?php

namespace Tests\Feature;

use App\Core\Support\TenantContext;
use App\Modules\Identity\Actions\CreateMember;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use App\Modules\Organizations\Models\Department;
use App\Modules\Portal\Models\Product;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PortalApiTest extends TestCase
{
    use RefreshDatabase;

    private const PASSWORD = 'Secret@123';

    public function test_customer_registers_waits_for_approval_then_orders_and_messages(): void
    {
        $owner = $this->onboard('شرکت پورتال', 'portal-owner@example.test');
        $slug = Company::query()->where('uuid', $owner['company_uuid'])->value('slug');
        $employee = $this->member($owner, 'کارمند', 'portal-employee@example.test', ['employee'], 'software');

        $registered = $this->postJson('/api/v1/portal/register', [
            'company_slug' => $slug,
            'name' => 'مشتری تازه',
            'email' => 'buyer@example.test',
            'password' => self::PASSWORD,
            'password_confirmation' => self::PASSWORD,
            'phone' => '09120000000',
            'organization_name' => 'شرکت خریدار',
        ])->assertCreated();

        $this->assertSame('pending', $registered->json('data.customer.status'));
        $token = $registered->json('data.token');

        $this->withToken($token)->getJson('/api/v1/portal/me')->assertOk()->assertJsonPath('data.customer.status', 'pending');
        $this->withToken($token)->getJson('/api/v1/dashboard')->assertForbidden();

        $this->withToken($owner['token'])
            ->postJson('/api/v1/portal/desk/products', [
                'name' => 'بسته نصب',
                'sku' => 'SETUP',
                'unit_price' => 1000,
                'stock' => 5,
            ])->assertCreated();

        $product = Product::query()->where('sku', 'SETUP')->first();
        $this->withToken($token)
            ->postJson('/api/v1/portal/orders', [
                'items' => [['product_uuid' => $product->uuid, 'quantity' => 1]],
            ])->assertStatus(422);

        $this->withToken($employee['token'])
            ->postJson('/api/v1/portal/desk/customers/'.$registered->json('data.customer.uuid').'/review', [
                'decision' => 'approve',
            ])->assertForbidden();

        $this->withToken($owner['token'])
            ->postJson('/api/v1/portal/desk/customers/'.$registered->json('data.customer.uuid').'/review', [
                'decision' => 'approve',
                'review_note' => 'مورد تأیید است',
            ])->assertOk()
            ->assertJsonPath('data.status', 'active');

        $this->withToken($token)
            ->postJson('/api/v1/portal/orders', [
                'note' => 'تحویل در دفتر',
                'items' => [['product_uuid' => $product->uuid, 'quantity' => 2]],
            ])->assertCreated()
            ->assertJsonPath('data.total_amount', 2000)
            ->assertJsonPath('data.status', 'submitted');

        $this->withToken($token)
            ->postJson('/api/v1/portal/threads', [
                'desk' => 'sales',
                'subject' => 'زمان تحویل',
                'body' => 'لطفاً زمان را اعلام کنید.',
            ])->assertCreated();

        $this->withToken($owner['token'])
            ->getJson('/api/v1/portal/desk/orders')
            ->assertOk()
            ->assertJsonPath('data.0.total_amount', 2000);

        $this->withToken($owner['token'])
            ->getJson('/api/v1/users')
            ->assertOk()
            ->assertJsonMissing(['email' => 'buyer@example.test']);
    }

    public function test_customer_data_is_hidden_from_another_company_and_another_customer(): void
    {
        $first = $this->onboard('شرکت اول پورتال', 'portal-a@example.test');
        $second = $this->onboard('شرکت دوم پورتال', 'portal-b@example.test');
        $slug = Company::query()->where('uuid', $first['company_uuid'])->value('slug');

        $registered = $this->postJson('/api/v1/portal/register', $this->registration($slug, 'hidden@example.test'))->assertCreated();
        $this->withToken($first['token'])
            ->postJson('/api/v1/portal/desk/customers/'.$registered->json('data.customer.uuid').'/review', ['decision' => 'approve'])
            ->assertOk();

        $this->withToken($first['token'])->postJson('/api/v1/portal/desk/products', [
            'name' => 'کالای خصوصی',
            'unit_price' => 50,
        ])->assertCreated();
        $product = Product::query()->withoutGlobalScope('company')->where('name', 'کالای خصوصی')->first();

        $order = $this->withToken($registered->json('data.token'))
            ->postJson('/api/v1/portal/orders', [
                'items' => [['product_uuid' => $product->uuid, 'quantity' => 1]],
            ])->assertCreated();

        $this->withToken($second['token'])
            ->getJson('/api/v1/portal/desk/customers')
            ->assertOk()
            ->assertJsonMissing(['email' => 'hidden@example.test']);

        $other = $this->postJson('/api/v1/portal/register', $this->registration(
            Company::query()->where('uuid', $second['company_uuid'])->value('slug'),
            'other-buyer@example.test',
        ))->assertCreated();
        $this->withToken($second['token'])
            ->postJson('/api/v1/portal/desk/customers/'.$other->json('data.customer.uuid').'/review', ['decision' => 'approve'])
            ->assertOk();

        $this->withToken($other->json('data.token'))
            ->getJson('/api/v1/portal/orders')
            ->assertOk()
            ->assertJsonMissing(['number' => $order->json('data.number')]);
    }

    public function test_support_unit_sees_support_messages_and_sales_does_not(): void
    {
        $owner = $this->onboard('شرکت میز', 'desk-owner@example.test');
        $support = $this->member($owner, 'پشتیبان', 'desk-support@example.test', ['employee'], 'operations');
        $sales = $this->member($owner, 'فروشنده', 'desk-sales@example.test', ['sales'], 'sales');
        $slug = Company::query()->where('uuid', $owner['company_uuid'])->value('slug');

        $registered = $this->postJson('/api/v1/portal/register', $this->registration($slug, 'desk-buyer@example.test'))->assertCreated();
        $this->withToken($owner['token'])
            ->postJson('/api/v1/portal/desk/customers/'.$registered->json('data.customer.uuid').'/review', ['decision' => 'approve'])
            ->assertOk();

        $thread = $this->withToken($registered->json('data.token'))
            ->postJson('/api/v1/portal/threads', [
                'desk' => 'support',
                'subject' => 'قطعی سرویس',
                'body' => 'از صبح قطع است.',
            ])->assertCreated();

        $this->withToken($support['token'])
            ->getJson('/api/v1/portal/desk/threads?desk=support')
            ->assertOk()
            ->assertJsonPath('data.0.subject', 'قطعی سرویس');

        $this->withToken($support['token'])
            ->postJson('/api/v1/portal/desk/threads/'.$thread->json('data.uuid').'/replies', [
                'body' => 'در حال بررسی است.',
            ])->assertOk();

        $this->withToken($sales['token'])
            ->getJson('/api/v1/portal/desk/threads?desk=support')
            ->assertForbidden();

        $this->withToken($sales['token'])
            ->getJson('/api/v1/portal/desk/threads?desk=sales')
            ->assertOk()
            ->assertJsonCount(0, 'data');

        $ticket = $this->withToken($registered->json('data.token'))
            ->postJson('/api/v1/portal/tickets', [
                'desk' => 'management',
                'priority' => 'high',
                'subject' => 'جلسه با مدیریت',
                'body' => 'لطفاً زمان جلسه را اعلام کنید.',
            ])->assertCreated()
            ->assertJsonPath('data.priority', 'high');

        $this->withToken($support['token'])
            ->getJson('/api/v1/portal/desk/tickets?desk=management')
            ->assertForbidden();

        $this->withToken($owner['token'])
            ->postJson('/api/v1/portal/desk/tickets/'.$ticket->json('data.uuid').'/replies', [
                'body' => 'فردا ساعت ۱۰ هماهنگ است.',
                'status' => 'answered',
            ])->assertOk()
            ->assertJsonPath('data.status', 'answered');
    }

    public function test_unknown_company_registration_is_not_found(): void
    {
        $this->postJson('/api/v1/portal/register', $this->registration('missing-company', 'nobody@example.test'))
            ->assertNotFound();
    }

    /**
     * @return array<string, string>
     */
    private function registration(string $slug, string $email): array
    {
        return [
            'company_slug' => $slug,
            'name' => 'خریدار',
            'email' => $email,
            'password' => self::PASSWORD,
            'password_confirmation' => self::PASSWORD,
        ];
    }

    /**
     * @param  list<string>  $roles
     * @return array{token: string, user_uuid: string}
     */
    private function member(array $owner, string $name, string $email, array $roles, string $departmentSlug): array
    {
        $company = Company::query()->where('uuid', $owner['company_uuid'])->first();
        app(TenantContext::class)->set($company);
        $department = Department::query()->create([
            'name' => $departmentSlug,
            'slug' => $departmentSlug,
        ]);

        $user = app(CreateMember::class)->handle($company, [
            'name' => $name,
            'email' => $email,
            'password' => self::PASSWORD,
            'department_uuid' => $department->uuid,
            'role_slugs' => $roles,
            'locale' => 'fa',
            'timezone' => 'Asia/Tehran',
        ], User::query()->where('uuid', $owner['user_uuid'])->first());

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
