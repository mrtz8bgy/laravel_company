<?php

declare(strict_types=1);

namespace App\Providers;

use App\Core\Models\ActivityLog;
use App\Core\Policies\ActivityLogPolicy;
use App\Modules\Attendance\Models\AttendanceDay;
use App\Modules\Attendance\Models\DailyReport;
use App\Modules\Attendance\Policies\AttendanceDayPolicy;
use App\Modules\Calendar\Models\Event;
use App\Modules\Communication\Models\Announcement;
use App\Modules\Communication\Models\Channel;
use App\Modules\Communication\Models\Message;
use App\Modules\Crm\Models\Account;
use App\Modules\Crm\Models\Deal;
use App\Modules\Documents\Models\Document;
use App\Modules\Finance\Models\Expense;
use App\Modules\Finance\Models\Invoice;
use App\Modules\Marketing\Models\Campaign;
use App\Modules\Operations\Models\Ticket;
use App\Modules\Workflows\Models\Approval;
use App\Modules\Hr\Models\HrProfile;
use App\Modules\Hr\Models\LeaveRequest;
use App\Modules\Hr\Models\MissionRequest;
use App\Modules\Portal\Models\Customer;
use App\Modules\Portal\Models\CustomerOrder;
use App\Modules\Portal\Models\CustomerThread;
use App\Modules\Portal\Models\CustomerTicket;
use App\Modules\Portal\Models\Product;
use App\Modules\Projects\Models\Project;
use App\Modules\Projects\Models\Task;
use App\Modules\Projects\Policies\ProjectPolicy;
use App\Core\Support\ExceptionRendererAssets;
use App\Core\Support\MysqlLocalSetup;
use App\Core\Support\TenantContext;
use App\Models\PersonalAccessToken;
use App\Modules\Access\Models\Permission;
use App\Modules\Access\Models\Role;
use App\Modules\Access\Policies\PermissionPolicy;
use App\Modules\Access\Policies\RolePolicy;
use App\Modules\Identity\Models\User;
use App\Modules\Identity\Policies\UserPolicy;
use App\Modules\Organizations\Models\Company;
use App\Modules\Organizations\Models\Department;
use App\Modules\Organizations\Models\Invitation;
use App\Modules\Organizations\Models\Team;
use App\Modules\Organizations\Policies\CompanyPolicy;
use App\Modules\Organizations\Policies\DepartmentPolicy;
use App\Modules\Organizations\Policies\TeamPolicy;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Database\Eloquent\Relations\Relation;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;
use Laravel\Sanctum\Sanctum;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(TenantContext::class);
    }

    public function boot(): void
    {
        ExceptionRendererAssets::ensure();
        MysqlLocalSetup::ensure();
        Sanctum::usePersonalAccessTokenModel(PersonalAccessToken::class);
        JsonResource::withoutWrapping();

        Relation::enforceMorphMap([
            'user' => User::class,
            'company' => Company::class,
            'department' => Department::class,
            'team' => Team::class,
            'role' => Role::class,
            'invitation' => Invitation::class,
            'attendance_day' => AttendanceDay::class,
            'daily_report' => DailyReport::class,
            'project' => Project::class,
            'task' => Task::class,
            'hr_profile' => HrProfile::class,
            'leave_request' => LeaveRequest::class,
            'mission_request' => MissionRequest::class,
            'channel' => Channel::class,
            'message' => Message::class,
            'announcement' => Announcement::class,
            'event' => Event::class,
            'crm_account' => Account::class,
            'crm_deal' => Deal::class,
            'campaign' => Campaign::class,
            'invoice' => Invoice::class,
            'expense' => Expense::class,
            'ticket' => Ticket::class,
            'approval' => Approval::class,
            'document' => Document::class,
            'customer' => Customer::class,
            'product' => Product::class,
            'customer_order' => CustomerOrder::class,
            'customer_thread' => CustomerThread::class,
            'customer_ticket' => CustomerTicket::class,
        ]);

        Gate::policy(Department::class, DepartmentPolicy::class);
        Gate::policy(Team::class, TeamPolicy::class);
        Gate::policy(Company::class, CompanyPolicy::class);
        Gate::policy(User::class, UserPolicy::class);
        Gate::policy(Role::class, RolePolicy::class);
        Gate::policy(Permission::class, PermissionPolicy::class);
        Gate::policy(ActivityLog::class, ActivityLogPolicy::class);
        Gate::policy(AttendanceDay::class, AttendanceDayPolicy::class);
        Gate::policy(Project::class, ProjectPolicy::class);

        RateLimiter::for('login', function (Request $request) {
            $email = strtolower((string) $request->input('email'));

            return Limit::perMinute(5)->by($email.'|'.$request->ip());
        });

        RateLimiter::for('onboarding', function (Request $request) {
            return Limit::perMinute(3)->by('onboarding|'.$request->ip());
        });

        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute(120)->by($request->user()?->id ?: $request->ip());
        });
    }
}
