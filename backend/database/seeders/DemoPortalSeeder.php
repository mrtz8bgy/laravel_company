<?php

namespace Database\Seeders;

use App\Core\Support\TenantContext;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use App\Modules\Portal\Actions\OpenCustomerThread;
use App\Modules\Portal\Actions\OpenCustomerTicket;
use App\Modules\Portal\Actions\PlaceOrder;
use App\Modules\Portal\Actions\RegisterCustomer;
use App\Modules\Portal\Actions\ReviewCustomer;
use App\Modules\Portal\Models\Customer;
use App\Modules\Portal\Models\Product;
use Illuminate\Database\Seeder;

class DemoPortalSeeder extends Seeder
{
    public function run(): void
    {
        $company = Company::query()->where('slug', 'ideban-almas')->first();
        if (! $company) {
            return;
        }

        app(TenantContext::class)->set($company);
        $this->products();

        if (Customer::query()->whereHas('user', fn ($query) => $query->where('email', 'customer@ideban.test'))->exists()) {
            return;
        }

        $register = app(RegisterCustomer::class);
        $approved = $register->handle($company, [
            'name' => 'نگار احمدی',
            'email' => 'customer@ideban.test',
            'password' => '123456',
            'phone' => '09120001111',
            'organization_name' => 'آتیه‌سازان نمونه',
        ]);
        $register->handle($company, [
            'name' => 'پارسا نعمتی',
            'email' => 'pending@ideban.test',
            'password' => '123456',
            'phone' => '09120002222',
            'organization_name' => 'بازرگانی در انتظار',
        ]);

        $manager = User::query()->where('email', 'ceo@ideban.test')->first();
        if ($manager) {
            app(ReviewCustomer::class)->handle($approved['customer'], $manager, 'approve', 'مشتری نمونه تأیید شد.');
        }

        $customer = Customer::query()->where('user_id', $approved['user']->id)->first();
        $setup = Product::query()->where('sku', 'NET-SETUP')->first();
        $support = Product::query()->where('sku', 'SUP-YEAR')->first();
        if ($customer && $setup && $support) {
            app(PlaceOrder::class)->handle($customer, [
                ['product_uuid' => $setup->uuid, 'quantity' => 1],
                ['product_uuid' => $support->uuid, 'quantity' => 1],
            ], 'راه‌اندازی دفتر و پشتیبانی سال اول.');
            app(OpenCustomerThread::class)->handle(
                $customer,
                'sales',
                'هماهنگی تحویل سفارش',
                'لطفاً زمان نصب را با واحد فروش هماهنگ کنید.',
            );
            app(OpenCustomerThread::class)->handle(
                $customer,
                'support',
                'سؤال درباره پشتیبانی',
                'ساعت پاسخ‌گویی پشتیبانی را اعلام کنید.',
            );
            app(OpenCustomerTicket::class)->handle(
                $customer,
                'support',
                'درخواست پیگیری نصب',
                'لطفاً این مورد را به صورت تیکت پیگیری کنید.',
                'high',
            );
            app(OpenCustomerTicket::class)->handle(
                $customer,
                'management',
                'درخواست جلسه با مدیریت',
                'برای تمدید قرارداد یک جلسه کوتاه می‌خواهیم.',
                'normal',
            );
        }
    }

    private function products(): void
    {
        $catalog = [
            ['sku' => 'NET-SETUP', 'name' => 'بسته راه‌اندازی شبکه', 'description' => 'طراحی و راه‌اندازی شبکه دفتر.', 'unit_price' => 185000000, 'stock' => 12],
            ['sku' => 'SUP-YEAR', 'name' => 'پشتیبانی سالانه', 'description' => 'پشتیبانی نرم‌افزار و شبکه برای یک سال.', 'unit_price' => 96000000, 'stock' => null],
            ['sku' => 'CON-VISIT', 'name' => 'مشاوره حضوری', 'description' => 'یک جلسه مشاوره در تهران.', 'unit_price' => 25000000, 'stock' => 40],
        ];

        foreach ($catalog as $item) {
            Product::query()->updateOrCreate(
                ['sku' => $item['sku']],
                [...$item, 'currency' => 'IRR', 'is_active' => true],
            );
        }
    }
}
