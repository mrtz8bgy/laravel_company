<?php

use App\Core\Http\Controllers\HealthController;
use App\Core\Http\Controllers\WorkspaceController;
use App\Modules\Access\Http\Controllers\RoleController;
use App\Modules\Attendance\Http\Controllers\BoardController;
use App\Modules\Attendance\Http\Controllers\ClockController;
use App\Modules\Attendance\Http\Controllers\DailyReportController;
use App\Modules\Attendance\Http\Controllers\WorkLogController;
use App\Modules\Auth\Http\Controllers\AuthController;
use App\Modules\Analytics\Http\Controllers\OverviewController;
use App\Modules\Calendar\Http\Controllers\EventController;
use App\Modules\Communication\Http\Controllers\AnnouncementController;
use App\Modules\Communication\Http\Controllers\ChannelController;
use App\Modules\Crm\Http\Controllers\CrmController;
use App\Modules\Documents\Http\Controllers\DocumentController;
use App\Modules\Finance\Http\Controllers\LedgerController;
use App\Modules\Hr\Http\Controllers\LeaveController;
use App\Modules\Marketing\Http\Controllers\CampaignController;
use App\Modules\Operations\Http\Controllers\TicketController;
use App\Modules\Workflows\Http\Controllers\ApprovalController;
use App\Modules\Hr\Http\Controllers\MissionController;
use App\Modules\Hr\Http\Controllers\ProfileController as HrProfileController;
use App\Modules\Identity\Http\Controllers\UserController;
use App\Modules\Portal\Http\Controllers\CustomerDeskController;
use App\Modules\Portal\Http\Controllers\PortalController;
use App\Modules\Portal\Http\Controllers\PortalRegistrationController;
use App\Modules\Projects\Http\Controllers\ProjectController;
use App\Modules\Projects\Http\Controllers\TaskController;
use App\Modules\Organizations\Http\Controllers\CompanyController;
use App\Modules\Organizations\Http\Controllers\DepartmentController;
use App\Modules\Organizations\Http\Controllers\InvitationController;
use App\Modules\Organizations\Http\Controllers\OnboardingController;
use App\Modules\Organizations\Http\Controllers\PlatformController;
use App\Modules\Organizations\Http\Controllers\TeamController;
use Illuminate\Support\Facades\Route;

Route::get('/health', HealthController::class);

Route::prefix('auth')->group(function (): void {
    Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:login');
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword'])->middleware('throttle:login');
    Route::post('/reset-password', [AuthController::class, 'resetPassword'])->middleware('throttle:login');
    Route::post('/accept-invite', [AuthController::class, 'acceptInvite'])->middleware('throttle:login');
});

Route::post('/onboarding/company', [OnboardingController::class, 'company'])->middleware('throttle:onboarding');

Route::prefix('portal')->group(function (): void {
    Route::get('/companies/{slug}', [PortalRegistrationController::class, 'company'])->middleware('throttle:60,1');
    Route::post('/register', [PortalRegistrationController::class, 'register'])->middleware('throttle:login');
});

Route::middleware('auth:sanctum')->group(function (): void {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::post('/auth/logout-all', [AuthController::class, 'logoutAll']);
    Route::get('/auth/sessions', [AuthController::class, 'sessions']);
    Route::delete('/auth/sessions/{session}', [AuthController::class, 'revokeSession']);
    Route::post('/auth/switch-company', [AuthController::class, 'switchCompany']);
    Route::get('/profile', [WorkspaceController::class, 'profile']);
    Route::patch('/profile', [WorkspaceController::class, 'updateProfile']);
});

Route::middleware(['auth:sanctum', 'tenant'])->group(function (): void {
    Route::get('/dashboard', [WorkspaceController::class, 'dashboard'])->middleware('permission:dashboard.view');
    Route::get('/search', [WorkspaceController::class, 'search']);
    Route::get('/activity-logs', [WorkspaceController::class, 'activity'])->middleware('permission:activity_logs.view');

    Route::get('/company', [CompanyController::class, 'show'])->middleware('permission:company.view');
    Route::patch('/company', [CompanyController::class, 'update'])->middleware('permission:company.update');
    Route::get('/work-schedules', [CompanyController::class, 'schedule'])->middleware('permission:company.view');
    Route::put('/work-schedules', [CompanyController::class, 'updateSchedule'])->middleware('permission:company.settings.manage');
    Route::get('/features', [CompanyController::class, 'features'])->middleware('permission:features.view');
    Route::patch('/features/{key}', [CompanyController::class, 'updateFeature'])->middleware('permission:features.manage');
    Route::get('/settings', [CompanyController::class, 'settings'])->middleware('permission:company.settings.manage');
    Route::put('/settings/{key}', [CompanyController::class, 'updateSetting'])->middleware('permission:company.settings.manage');

    Route::middleware('permission:departments.view')->group(function (): void {
        Route::get('/departments', [DepartmentController::class, 'index']);
        Route::get('/departments/{department}', [DepartmentController::class, 'show']);
    });
    Route::post('/departments', [DepartmentController::class, 'store'])->middleware('permission:departments.create');
    Route::match(['put', 'patch'], '/departments/{department}', [DepartmentController::class, 'update'])->middleware('permission:departments.update');
    Route::delete('/departments/{department}', [DepartmentController::class, 'destroy'])->middleware('permission:departments.delete');

    Route::middleware('permission:teams.view')->group(function (): void {
        Route::get('/teams', [TeamController::class, 'index']);
        Route::get('/teams/{team}', [TeamController::class, 'show']);
    });
    Route::post('/teams', [TeamController::class, 'store'])->middleware('permission:teams.create');
    Route::match(['put', 'patch'], '/teams/{team}', [TeamController::class, 'update'])->middleware('permission:teams.update');
    Route::delete('/teams/{team}', [TeamController::class, 'destroy'])->middleware('permission:teams.delete');
    Route::post('/teams/{team}/members', [TeamController::class, 'addMember'])->middleware('permission:teams.update');
    Route::delete('/teams/{team}/members/{user}', [TeamController::class, 'removeMember'])->middleware('permission:teams.update');

    Route::middleware('permission:users.view')->group(function (): void {
        Route::get('/users', [UserController::class, 'index']);
        Route::get('/users/{user}', [UserController::class, 'show']);
        Route::get('/invitations', [InvitationController::class, 'index']);
    });
    Route::post('/users', [UserController::class, 'store'])->middleware('permission:users.create');
    Route::match(['put', 'patch'], '/users/{user}', [UserController::class, 'update'])->middleware('permission:users.update');
    Route::delete('/users/{user}', [UserController::class, 'destroy'])->middleware('permission:users.delete');
    Route::post('/invitations', [InvitationController::class, 'store'])->middleware('permission:users.invite');
    Route::delete('/invitations/{invitation}', [InvitationController::class, 'destroy'])->middleware('permission:users.invite');

    Route::middleware('permission:roles.view')->group(function (): void {
        Route::get('/roles', [RoleController::class, 'index']);
    });
    Route::get('/permissions', [RoleController::class, 'permissions'])->middleware('permission:permissions.view');
    Route::post('/roles', [RoleController::class, 'store'])->middleware('permission:roles.create');
    Route::match(['put', 'patch'], '/roles/{role}', [RoleController::class, 'update'])->middleware('permission:roles.update');
    Route::delete('/roles/{role}', [RoleController::class, 'destroy'])->middleware('permission:roles.delete');

    Route::post('/onboarding/departments', [OnboardingController::class, 'departments'])->middleware('permission:departments.create');
    Route::post('/onboarding/teams', [OnboardingController::class, 'teams'])->middleware('permission:teams.create');
    Route::post('/onboarding/invites', [OnboardingController::class, 'invites'])->middleware('permission:users.invite');
    Route::post('/onboarding/complete', [OnboardingController::class, 'complete'])->middleware('permission:company.update');

    Route::middleware('feature:attendance')->group(function (): void {
        Route::middleware('permission:attendance.clock')->group(function (): void {
            Route::get('/attendance/today', [ClockController::class, 'today']);
            Route::get('/attendance/me', [ClockController::class, 'history']);
            Route::post('/attendance/check-in', [ClockController::class, 'checkIn'])->middleware('throttle:30,1');
            Route::post('/attendance/check-out', [ClockController::class, 'checkOut'])->middleware('throttle:30,1');
            Route::post('/attendance/break/start', [ClockController::class, 'startBreak'])->middleware('throttle:30,1');
            Route::post('/attendance/break/end', [ClockController::class, 'endBreak'])->middleware('throttle:30,1');
            Route::put('/attendance/status', [ClockController::class, 'status'])->middleware('throttle:30,1');
        });

        Route::get('/attendance/board', [BoardController::class, 'index'])->middleware('permission:attendance.view');
        Route::patch('/attendance/days/{day}', [BoardController::class, 'correct'])->middleware('permission:attendance.correct');
        Route::get('/attendance/people/{user}', [WorkLogController::class, 'show'])->middleware('permission:attendance.view');
        Route::get('/attendance/reports', [DailyReportController::class, 'index'])->middleware('permission:attendance.reports.view');
        Route::post('/attendance/reports', [DailyReportController::class, 'store'])->middleware('permission:attendance.reports.submit');
    });

    Route::middleware('feature:projects')->group(function (): void {
        Route::middleware('permission:projects.view')->group(function (): void {
            Route::get('/projects', [ProjectController::class, 'index']);
            Route::get('/projects/{project}', [ProjectController::class, 'show']);
            Route::get('/projects/{project}/board', [ProjectController::class, 'board']);
        });
        Route::post('/projects', [ProjectController::class, 'store'])->middleware('permission:projects.create');
        Route::match(['put', 'patch'], '/projects/{project}', [ProjectController::class, 'update'])->middleware('permission:projects.update');
        Route::delete('/projects/{project}', [ProjectController::class, 'destroy'])->middleware('permission:projects.delete');
        Route::post('/projects/{project}/members', [ProjectController::class, 'addMember'])->middleware('permission:projects.update');
        Route::delete('/projects/{project}/members/{user}', [ProjectController::class, 'removeMember'])->middleware('permission:projects.update');

        Route::get('/tasks/mine', [TaskController::class, 'mine'])->middleware('permission:tasks.view');
        Route::get('/tasks/people/{user}', [TaskController::class, 'forPerson'])->middleware('permission:tasks.view');
        Route::post('/tasks', [TaskController::class, 'store'])->middleware('permission:tasks.create');
        Route::match(['put', 'patch'], '/tasks/{task}', [TaskController::class, 'update'])->middleware('permission:tasks.update');
        Route::post('/tasks/{task}/move', [TaskController::class, 'move'])->middleware('permission:tasks.update');
        Route::delete('/tasks/{task}', [TaskController::class, 'destroy'])->middleware('permission:tasks.delete');
        Route::post('/tasks/{task}/comments', [TaskController::class, 'comment'])->middleware('permission:tasks.update');
    });

    Route::middleware('feature:hr')->group(function (): void {
        Route::get('/hr/me', [HrProfileController::class, 'me'])->middleware('permission:leave.request');
        Route::get('/hr/people/{user}', [HrProfileController::class, 'show'])->middleware('permission:hr.profile.view');
        Route::match(['put', 'patch'], '/hr/people/{user}', [HrProfileController::class, 'update'])->middleware('permission:hr.profile.update');

        Route::get('/hr/leave', [LeaveController::class, 'index'])->middleware('permission:leave.request');
        Route::post('/hr/leave', [LeaveController::class, 'store'])->middleware('permission:leave.request');
        Route::post('/hr/leave/{leave}/review', [LeaveController::class, 'reviewRequest'])->middleware('permission:leave.review');

        Route::get('/hr/missions', [MissionController::class, 'index'])->middleware('permission:mission.request');
        Route::post('/hr/missions', [MissionController::class, 'store'])->middleware('permission:mission.request');
        Route::post('/hr/missions/{mission}/review', [MissionController::class, 'reviewRequest'])->middleware('permission:mission.review');
    });

    Route::middleware('feature:communication')->group(function (): void {
        Route::get('/channels', [ChannelController::class, 'index'])->middleware('permission:messages.view');
        Route::post('/channels', [ChannelController::class, 'store'])->middleware('permission:announcements.publish');
        Route::get('/channels/{channel}/messages', [ChannelController::class, 'messages'])->middleware('permission:messages.view');
        Route::post('/channels/{channel}/messages', [ChannelController::class, 'send'])->middleware('permission:messages.send');
        Route::get('/announcements', [AnnouncementController::class, 'index'])->middleware('permission:messages.view');
        Route::post('/announcements', [AnnouncementController::class, 'store'])->middleware('permission:announcements.publish');
    });

    Route::middleware('feature:calendar')->group(function (): void {
        Route::get('/events', [EventController::class, 'index'])->middleware('permission:calendar.view');
        Route::get('/events/{event}', [EventController::class, 'show'])->middleware('permission:calendar.view');
        Route::post('/events', [EventController::class, 'store'])->middleware('permission:calendar.manage');
    });

    Route::middleware('feature:crm')->group(function (): void {
        Route::get('/crm/accounts', [CrmController::class, 'accounts'])->middleware('permission:crm.view');
        Route::post('/crm/accounts', [CrmController::class, 'storeAccount'])->middleware('permission:crm.manage');
        Route::get('/crm/contacts', [CrmController::class, 'contacts'])->middleware('permission:crm.view');
        Route::post('/crm/contacts', [CrmController::class, 'storeContact'])->middleware('permission:crm.manage');
        Route::get('/crm/deals', [CrmController::class, 'deals'])->middleware('permission:crm.view');
        Route::post('/crm/deals', [CrmController::class, 'storeDeal'])->middleware('permission:crm.manage');
        Route::patch('/crm/deals/{deal}', [CrmController::class, 'updateDeal'])->middleware('permission:crm.manage');
    });

    Route::middleware('feature:marketing')->group(function (): void {
        Route::get('/campaigns', [CampaignController::class, 'index'])->middleware('permission:marketing.view');
        Route::post('/campaigns', [CampaignController::class, 'store'])->middleware('permission:marketing.manage');
    });
    Route::get('/advertising/campaigns', [CampaignController::class, 'index'])->middleware(['feature:advertising', 'permission:advertising.view']);

    Route::middleware('feature:finance')->group(function (): void {
        Route::get('/finance/invoices', [LedgerController::class, 'invoices'])->middleware('permission:finance.view');
        Route::post('/finance/invoices', [LedgerController::class, 'storeInvoice'])->middleware('permission:finance.manage');
        Route::get('/finance/expenses', [LedgerController::class, 'expenses'])->middleware('permission:finance.view');
        Route::post('/finance/expenses', [LedgerController::class, 'storeExpense'])->middleware('permission:finance.manage');
    });

    Route::middleware('feature:operations')->group(function (): void {
        Route::get('/tickets', [TicketController::class, 'index'])->middleware('permission:tickets.create');
        Route::post('/tickets', [TicketController::class, 'store'])->middleware('permission:tickets.create');
        Route::patch('/tickets/{ticket}', [TicketController::class, 'update'])->middleware('permission:tickets.manage');
        Route::post('/tickets/{ticket}/messages', [TicketController::class, 'reply'])->middleware('permission:tickets.create');
    });

    Route::middleware('feature:workflows')->group(function (): void {
        Route::get('/approvals', [ApprovalController::class, 'index'])->middleware('permission:workflows.request');
        Route::post('/approvals', [ApprovalController::class, 'store'])->middleware('permission:workflows.request');
        Route::post('/approvals/{approval}/review', [ApprovalController::class, 'review'])->middleware('permission:workflows.review');
    });

    Route::middleware('feature:documents')->group(function (): void {
        Route::get('/documents', [DocumentController::class, 'index'])->middleware('permission:documents.view');
        Route::get('/documents/{document}', [DocumentController::class, 'show'])->middleware('permission:documents.view');
        Route::post('/documents', [DocumentController::class, 'store'])->middleware('permission:documents.manage');
    });

    Route::get('/analytics/overview', OverviewController::class)->middleware(['feature:analytics', 'permission:analytics.view']);

    Route::middleware('feature:portal')->prefix('portal/desk')->group(function (): void {
        Route::get('/', [CustomerDeskController::class, 'home']);
        Route::get('/customers', [CustomerDeskController::class, 'customers'])->middleware('permission:customers.view');
        Route::post('/customers/{customer}/review', [CustomerDeskController::class, 'reviewCustomer'])->middleware('permission:customers.review');
        Route::get('/products', [CustomerDeskController::class, 'products'])->middleware('permission:products.view');
        Route::post('/products', [CustomerDeskController::class, 'storeProduct'])->middleware('permission:products.manage');
        Route::patch('/products/{product}', [CustomerDeskController::class, 'updateProduct'])->middleware('permission:products.manage');
        Route::get('/orders', [CustomerDeskController::class, 'orders'])->middleware('permission:customer_orders.view');
        Route::patch('/orders/{order}', [CustomerDeskController::class, 'updateOrder'])->middleware('permission:customer_orders.manage');
        Route::get('/threads', [CustomerDeskController::class, 'threads']);
        Route::get('/threads/{thread}', [CustomerDeskController::class, 'showThread']);
        Route::post('/threads/{thread}/replies', [CustomerDeskController::class, 'reply']);
        Route::get('/tickets', [CustomerDeskController::class, 'tickets']);
        Route::get('/tickets/{ticket}', [CustomerDeskController::class, 'showTicket']);
        Route::post('/tickets/{ticket}/replies', [CustomerDeskController::class, 'replyTicket']);
        Route::patch('/tickets/{ticket}', [CustomerDeskController::class, 'updateTicket']);
    });
});

Route::middleware(['auth:sanctum', 'portal', 'feature:portal'])->prefix('portal')->group(function (): void {
    Route::get('/me', [PortalController::class, 'me']);
    Route::patch('/me', [PortalController::class, 'updateMe']);
    Route::get('/products', [PortalController::class, 'products']);
    Route::get('/orders', [PortalController::class, 'orders']);
    Route::post('/orders', [PortalController::class, 'storeOrder']);
    Route::get('/threads', [PortalController::class, 'threads']);
    Route::post('/threads', [PortalController::class, 'storeThread']);
    Route::get('/threads/{thread}', [PortalController::class, 'showThread']);
    Route::post('/threads/{thread}/replies', [PortalController::class, 'reply']);
    Route::get('/tickets', [PortalController::class, 'tickets']);
    Route::post('/tickets', [PortalController::class, 'storeTicket']);
    Route::get('/tickets/{ticket}', [PortalController::class, 'showTicket']);
    Route::post('/tickets/{ticket}/replies', [PortalController::class, 'replyTicket']);
});

Route::middleware(['auth:sanctum', 'platform'])->prefix('platform')->group(function (): void {
    Route::get('/companies', [PlatformController::class, 'companies']);
    Route::patch('/companies/{company}', [PlatformController::class, 'updateCompany']);
});
