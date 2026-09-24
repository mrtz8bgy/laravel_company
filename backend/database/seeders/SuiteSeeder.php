<?php

namespace Database\Seeders;

use App\Core\Support\TenantContext;
use App\Modules\Communication\Models\Announcement;
use App\Modules\Communication\Models\Channel;
use App\Modules\Communication\Models\Message;
use App\Modules\Calendar\Models\Event;
use App\Modules\Crm\Models\Account;
use App\Modules\Crm\Models\Contact;
use App\Modules\Crm\Models\Deal;
use App\Modules\Documents\Models\Document;
use App\Modules\Finance\Models\Expense;
use App\Modules\Finance\Models\Invoice;
use App\Modules\Identity\Models\User;
use App\Modules\Marketing\Models\Campaign;
use App\Modules\Operations\Models\Ticket;
use App\Modules\Organizations\Models\Company;
use App\Modules\Workflows\Models\Approval;
use Illuminate\Database\Seeder;

class SuiteSeeder extends Seeder
{
    public function run(): void
    {
        $company = Company::query()->where('slug', 'ideban-almas')->first();
        if (! $company || Channel::query()->where('slug', 'general')->exists()) {
            return;
        }

        app(TenantContext::class)->set($company);
        $byEmail = User::query()->whereIn('email', [
            'ceo@ideban.test',
            'developer@ideban.test',
            'sales@ideban.test',
            'marketing@ideban.test',
            'finance@ideban.test',
            'support@ideban.test',
        ])->get()->keyBy('email');
        if (! $byEmail->has('ceo@ideban.test')) {
            return;
        }

        $ceo = $byEmail['ceo@ideban.test'];
        $channel = Channel::query()->create([
            'name' => 'عمومی',
            'slug' => 'general',
            'kind' => 'company',
        ]);
        Message::query()->create([
            'channel_id' => $channel->id,
            'user_id' => $ceo->id,
            'body' => 'صبح بخیر. اولویت امروز: فروشگاه و دفتر مجازی.',
        ]);
        Announcement::query()->create([
            'title' => 'شروع هفته',
            'body' => 'جلسهٔ هماهنگی ساعت ۱۰ در تقویم شرکت است.',
            'author_id' => $ceo->id,
        ]);

        $start = now($company->timezone ?: 'Asia/Tehran')->setTime(10, 0);
        Event::query()->create([
            'title' => 'هماهنگی هفتگی',
            'location' => 'اتاق مجازی',
            'starts_at' => $start,
            'ends_at' => $start->copy()->addHour(),
            'visibility' => 'company',
            'owner_id' => $ceo->id,
        ]);

        $account = Account::query()->create(['name' => 'خانهٔ کتاب', 'status' => 'active']);
        Contact::query()->create([
            'account_id' => $account->id,
            'name' => 'نگار سلیمانی',
            'email' => 'negar@example.test',
            'phone' => '02144000000',
        ]);
        Deal::query()->create([
            'account_id' => $account->id,
            'title' => 'قرارداد فروشگاه',
            'stage' => 'proposal',
            'amount' => 240000000,
            'currency' => 'IRR',
            'owner_id' => $byEmail['sales@ideban.test']->id ?? $ceo->id,
        ]);

        Campaign::query()->create([
            'name' => 'کمپین پاییز',
            'channel' => 'social',
            'status' => 'active',
            'budget_amount' => 80000000,
            'currency' => 'IRR',
            'starts_on' => now()->toDateString(),
            'ends_on' => now()->addMonth()->toDateString(),
        ]);
        Campaign::query()->create([
            'name' => 'تبلیغ جستجو',
            'channel' => 'ads',
            'status' => 'draft',
            'budget_amount' => 45000000,
            'currency' => 'IRR',
        ]);

        Invoice::query()->create([
            'number' => 'INV-1405-001',
            'party_name' => 'خانهٔ کتاب',
            'amount' => 120000000,
            'currency' => 'IRR',
            'status' => 'sent',
            'issued_on' => now()->toDateString(),
            'due_on' => now()->addDays(14)->toDateString(),
        ]);
        Expense::query()->create([
            'category' => 'زیرساخت',
            'amount' => 18000000,
            'currency' => 'IRR',
            'status' => 'recorded',
            'spent_on' => now()->toDateString(),
            'note' => 'هزینهٔ نمونه',
        ]);

        Ticket::query()->create([
            'subject' => 'دسترسی گزارش روزانه',
            'body' => 'همکار جدید صفحهٔ حضور را نمی‌بیند.',
            'status' => 'open',
            'priority' => 'high',
            'requester_id' => $byEmail['support@ideban.test']->id ?? $ceo->id,
        ]);

        Approval::query()->create([
            'title' => 'خرید دامنهٔ فروشگاه',
            'kind' => 'purchase',
            'status' => 'pending',
            'requester_id' => $byEmail['developer@ideban.test']->id ?? $ceo->id,
            'note' => 'تمدید یک‌ساله',
        ]);

        Document::query()->create([
            'title' => 'راهنمای دفتر مجازی',
            'body' => 'ورود، وظیفهٔ امروز، گزارش روزانه و مرخصی از همین سامانه انجام می‌شود.',
            'visibility' => 'company',
            'author_id' => $ceo->id,
        ]);
    }
}
