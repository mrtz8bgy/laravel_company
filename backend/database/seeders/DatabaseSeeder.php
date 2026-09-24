<?php

namespace Database\Seeders;

use App\Core\Support\TenantContext;
use App\Modules\Access\Actions\AlignSystemRoles;
use App\Modules\Access\Actions\SyncPermissions;
use App\Modules\Attendance\Actions\ClockAttendance;
use App\Modules\Attendance\Actions\SubmitDailyReport;
use App\Modules\Attendance\Models\AttendanceDay;
use App\Modules\Identity\Actions\CreateMember;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Actions\MarkOnboarding;
use App\Modules\Organizations\Actions\ProvisionCompany;
use App\Modules\Organizations\Models\Company;
use App\Modules\Organizations\Models\Department;
use App\Modules\Organizations\Models\Feature;
use App\Modules\Organizations\Models\Team;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        app(SyncPermissions::class)->handle();
        app(AlignSystemRoles::class)->handle();

        if (User::query()->where('email', 'platform@virtual-company.test')->doesntExist()) {
            User::query()->create([
                'name' => 'Platform Admin',
                'email' => 'platform@virtual-company.test',
                'password' => 'ChangeMe!2026',
                'locale' => 'fa',
                'timezone' => 'Asia/Tehran',
                'status' => 'active',
                'is_platform_admin' => true,
                'email_verified_at' => now(),
            ]);
        }

        if (Company::query()->where('slug', 'ideban-almas')->exists()) {
            $company = Company::query()->where('slug', 'ideban-almas')->first();
            $this->seedDemoAttendance($company);
            $this->call(DemoWorkSeeder::class);
            $this->call(SuiteSeeder::class);

            return;
        }

        $provisioned = app(ProvisionCompany::class)->handle([
            'company_name' => 'شبکه پردازان ایده‌بان الماس',
            'legal_name' => 'شبکه پردازان ایده‌بان الماس',
            'slug' => 'ideban-almas',
            'timezone' => 'Asia/Tehran',
            'locale' => 'fa',
            'admin_name' => 'سارا محمدی',
            'email' => 'ceo@ideban.test',
            'password' => 'ChangeMe!2026',
            'phone' => '02191000000',
        ]);

        $company = $provisioned['company'];
        $owner = $provisioned['user'];
        $owner->memberships()->where('company_id', $company->id)->update(['job_title' => 'مدیرعامل']);

        app(TenantContext::class)->set($company);

        $definitions = [
            'management' => ['مدیریت', 'MGT'],
            'software' => ['توسعه نرم‌افزار', 'DEV'],
            'devops' => ['دوآپس', 'OPSINF'],
            'operations' => ['عملیات و پشتیبانی', 'OPS'],
            'sales' => ['فروش', 'SAL'],
            'marketing' => ['بازاریابی', 'MKT'],
            'advertising' => ['تبلیغات', 'ADV'],
            'finance' => ['مالی', 'FIN'],
            'hr' => ['منابع انسانی', 'HR'],
        ];

        $departments = [];
        $order = 0;
        foreach ($definitions as $slug => [$name, $code]) {
            $departments[$slug] = Department::query()->create([
                'name' => $name,
                'slug' => $slug,
                'code' => $code,
                'sort_order' => $order++,
                'is_active' => true,
            ]);
        }

        $creator = app(CreateMember::class);
        $people = [
            [
                'name' => 'آرمان کاظمی',
                'email' => 'developer@ideban.test',
                'job_title' => 'توسعه‌دهنده',
                'employee_code' => 'DEV-01',
                'department' => 'software',
                'roles' => ['team-leader'],
            ],
            [
                'name' => 'نیلوفر رضایی',
                'email' => 'devops@ideban.test',
                'job_title' => 'مهندس دوآپس',
                'employee_code' => 'OPS-01',
                'department' => 'devops',
                'roles' => ['employee'],
            ],
            [
                'name' => 'حسین مرادی',
                'email' => 'support@ideban.test',
                'job_title' => 'کارشناس پشتیبانی',
                'employee_code' => 'SUP-01',
                'department' => 'operations',
                'roles' => ['employee'],
            ],
            [
                'name' => 'مریم حسینی',
                'email' => 'sales@ideban.test',
                'job_title' => 'مدیر فروش',
                'employee_code' => 'SAL-01',
                'department' => 'sales',
                'roles' => ['sales', 'department-manager'],
            ],
            [
                'name' => 'کیان نادری',
                'email' => 'marketing@ideban.test',
                'job_title' => 'کارشناس بازاریابی',
                'employee_code' => 'MKT-01',
                'department' => 'marketing',
                'roles' => ['marketing'],
            ],
            [
                'name' => 'لیلا اکبری',
                'email' => 'finance@ideban.test',
                'job_title' => 'مدیر مالی',
                'employee_code' => 'FIN-01',
                'department' => 'finance',
                'roles' => ['finance', 'department-manager'],
            ],
            [
                'name' => 'رضا شریفی',
                'email' => 'hr@ideban.test',
                'job_title' => 'کارشناس منابع انسانی',
                'employee_code' => 'HR-01',
                'department' => 'hr',
                'roles' => ['hr'],
            ],
        ];

        $users = [];
        foreach ($people as $person) {
            $users[$person['email']] = $creator->handle($company, [
                'name' => $person['name'],
                'email' => $person['email'],
                'password' => 'ChangeMe!2026',
                'job_title' => $person['job_title'],
                'employee_code' => $person['employee_code'],
                'department_uuid' => $departments[$person['department']]->uuid,
                'role_slugs' => $person['roles'],
                'locale' => 'fa',
                'timezone' => 'Asia/Tehran',
            ], $owner);
        }

        $departments['management']->update(['manager_id' => $owner->id]);
        $departments['software']->update(['manager_id' => $users['developer@ideban.test']->id]);
        $departments['sales']->update(['manager_id' => $users['sales@ideban.test']->id]);
        $departments['finance']->update(['manager_id' => $users['finance@ideban.test']->id]);
        $departments['hr']->update(['manager_id' => $users['hr@ideban.test']->id]);

        $backend = Team::query()->create([
            'department_id' => $departments['software']->id,
            'name' => 'تیم محصول',
            'slug' => 'product',
            'description' => 'توسعه محصول‌های نرم‌افزاری شرکت',
            'leader_id' => $users['developer@ideban.test']->id,
        ]);
        $backend->members()->sync([
            $users['developer@ideban.test']->id => ['role' => 'leader'],
        ]);

        $infra = Team::query()->create([
            'department_id' => $departments['devops']->id,
            'name' => 'تیم زیرساخت',
            'slug' => 'infrastructure',
            'leader_id' => $users['devops@ideban.test']->id,
        ]);
        $infra->members()->sync([
            $users['devops@ideban.test']->id => ['role' => 'leader'],
        ]);

        $salesDesk = Team::query()->create([
            'department_id' => $departments['sales']->id,
            'name' => 'میز فروش',
            'slug' => 'sales-desk',
            'leader_id' => $users['sales@ideban.test']->id,
        ]);
        $salesDesk->members()->sync([
            $users['sales@ideban.test']->id => ['role' => 'leader'],
        ]);

        app(MarkOnboarding::class)->complete($company);
        $company = $company->fresh();
        $settings = $company->settings ?? [];
        $settings['onboarding'] = [
            'departments' => true,
            'teams' => true,
            'invites' => true,
            'schedule' => true,
            'completed' => true,
        ];
        $company->settings = $settings;
        $company->save();
        $this->seedDemoAttendance($company);
        $this->call(DemoWorkSeeder::class);
        $this->call(SuiteSeeder::class);
    }

    private function seedDemoAttendance(Company $company): void
    {
        app(TenantContext::class)->set($company);
        Feature::query()->withoutGlobalScope('company')->updateOrCreate(
            ['company_id' => $company->id, 'key' => 'attendance'],
            ['enabled' => true],
        );

        if (AttendanceDay::query()->exists()) {
            return;
        }

        $clock = app(ClockAttendance::class);
        $reports = app(SubmitDailyReport::class);
        $byEmail = User::query()->whereIn('email', [
            'ceo@ideban.test',
            'developer@ideban.test',
            'devops@ideban.test',
            'sales@ideban.test',
            'hr@ideban.test',
        ])->get()->keyBy('email');

        if ($byEmail->has('ceo@ideban.test')) {
            $clock->checkIn($byEmail['ceo@ideban.test'], 'office', 'شروع روز در دفتر');
        }
        if ($byEmail->has('developer@ideban.test')) {
            $clock->checkIn($byEmail['developer@ideban.test'], 'remote');
            $reports->handle($byEmail['developer@ideban.test'], 'morning', 'امروز روی هستهٔ حضور و گزارش روزانه کار می‌کنم.', null);
        }
        if ($byEmail->has('devops@ideban.test')) {
            $clock->checkIn($byEmail['devops@ideban.test'], 'office');
            $clock->startBreak($byEmail['devops@ideban.test']);
        }
        if ($byEmail->has('sales@ideban.test')) {
            $clock->setStatus($byEmail['sales@ideban.test'], 'mission', 'جلسه با مشتری');
        }
        if ($byEmail->has('hr@ideban.test')) {
            $clock->setStatus($byEmail['hr@ideban.test'], 'leave', 'مرخصی ساعتی');
        }
    }
}
