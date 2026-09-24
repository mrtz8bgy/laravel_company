<?php

namespace Database\Seeders;

use App\Core\Support\TenantContext;
use App\Modules\Hr\Models\HrProfile;
use App\Modules\Hr\Models\LeaveRequest;
use App\Modules\Hr\Models\MissionRequest;
use App\Modules\Identity\Models\User;
use App\Modules\Organizations\Models\Company;
use App\Modules\Organizations\Models\Department;
use App\Modules\Projects\Actions\CreateProject;
use App\Modules\Projects\Models\Project;
use App\Modules\Projects\Models\ProjectMember;
use App\Modules\Projects\Models\Task;
use Illuminate\Database\Seeder;

class DemoWorkSeeder extends Seeder
{
    public function run(): void
    {
        $company = Company::query()->where('slug', 'ideban-almas')->first();
        if (! $company) {
            return;
        }

        app(TenantContext::class)->set($company);
        if (Project::query()->where('slug', 'shop')->exists()) {
            return;
        }

        $byEmail = User::query()->whereIn('email', [
            'ceo@ideban.test',
            'developer@ideban.test',
            'devops@ideban.test',
            'sales@ideban.test',
            'marketing@ideban.test',
            'hr@ideban.test',
        ])->get()->keyBy('email');

        if (! $byEmail->has('ceo@ideban.test') || ! $byEmail->has('developer@ideban.test')) {
            return;
        }

        $salesDept = Department::query()->where('slug', 'sales')->first();
        $software = Department::query()->where('slug', 'software')->first();
        $today = now($company->timezone ?: 'Asia/Tehran')->toDateString();

        $shop = app(CreateProject::class)->handle($byEmail['ceo@ideban.test'], [
            'name' => 'فروشگاه',
            'slug' => 'shop',
            'code' => 'SHOP',
            'description' => 'فروش آنلاین و هماهنگی کاتالوگ',
            'visibility' => 'company',
            'department_id' => $salesDept?->id,
            'due_date' => now()->addMonth()->toDateString(),
        ]);
        $office = app(CreateProject::class)->handle($byEmail['ceo@ideban.test'], [
            'name' => 'دفتر مجازی',
            'slug' => 'virtual-office',
            'code' => 'VOFFICE',
            'description' => 'حضور، وظیفه و گزارش روزانهٔ شرکت مجازی',
            'visibility' => 'company',
            'department_id' => $software?->id,
        ]);

        $this->member($shop, $byEmail['sales@ideban.test'] ?? null, 'member');
        $this->member($shop, $byEmail['marketing@ideban.test'] ?? null, 'member');
        $this->member($office, $byEmail['developer@ideban.test'], 'manager');
        $this->member($office, $byEmail['devops@ideban.test'] ?? null, 'member');

        $this->task($shop, 'آماده‌سازی کاتالوگ پاییز', 'high', $byEmail['sales@ideban.test'] ?? null, $today);
        $this->task($office, 'برد کانبان دفتر مجازی', 'high', $byEmail['developer@ideban.test'], $today);
        $this->task($office, 'پایدارسازی سرویس حضور', 'normal', $byEmail['devops@ideban.test'] ?? null, $today);

        if ($byEmail->has('developer@ideban.test')) {
            HrProfile::query()->create([
                'user_id' => $byEmail['developer@ideban.test']->id,
                'hire_date' => '2024-03-01',
                'employment_type' => 'full_time',
                'national_id' => '0087654321',
                'emergency_name' => 'خانواده کاظمی',
                'emergency_phone' => '09120000000',
                'salary_amount' => 850000000,
                'salary_currency' => 'IRR',
            ]);
        }

        if ($byEmail->has('devops@ideban.test')) {
            LeaveRequest::query()->create([
                'user_id' => $byEmail['devops@ideban.test']->id,
                'type' => 'annual',
                'starts_on' => $today,
                'ends_on' => $today,
                'reason' => 'مرخصی استحقاقی نمونه',
                'status' => 'pending',
            ]);
        }

        if ($byEmail->has('sales@ideban.test')) {
            MissionRequest::query()->create([
                'user_id' => $byEmail['sales@ideban.test']->id,
                'destination' => 'دفتر مشتری، تهران',
                'starts_on' => $today,
                'ends_on' => $today,
                'purpose' => 'جلسه معرفی فروشگاه',
                'status' => 'pending',
            ]);
        }
    }

    private function member(Project $project, ?User $user, string $role): void
    {
        if (! $user) {
            return;
        }

        ProjectMember::query()->updateOrCreate(
            ['project_id' => $project->id, 'user_id' => $user->id],
            ['role' => $role],
        );
    }

    private function task(Project $project, string $title, string $priority, ?User $assignee, string $due): void
    {
        $column = $project->columns()->orderBy('sort_order')->first();
        if (! $column) {
            return;
        }

        Task::query()->create([
            'project_id' => $project->id,
            'column_id' => $column->id,
            'title' => $title,
            'priority' => $priority,
            'assignee_id' => $assignee?->id,
            'reporter_id' => $project->owner_id,
            'due_date' => $due,
            'sort_order' => (int) Task::query()->where('column_id', $column->id)->max('sort_order') + 1,
        ]);
    }
}
