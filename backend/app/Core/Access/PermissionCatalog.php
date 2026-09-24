<?php

declare(strict_types=1);

namespace App\Core\Access;

/**
 * Canonical permission names. Modules added in later phases extend this
 * catalog and run `php artisan permissions:sync`.
 */
final class PermissionCatalog
{
    public const DASHBOARD_VIEW = 'dashboard.view';

    public const COMPANY_VIEW = 'company.view';

    public const COMPANY_UPDATE = 'company.update';

    public const COMPANY_SETTINGS_MANAGE = 'company.settings.manage';

    public const USERS_VIEW = 'users.view';

    public const USERS_CREATE = 'users.create';

    public const USERS_UPDATE = 'users.update';

    public const USERS_DELETE = 'users.delete';

    public const USERS_INVITE = 'users.invite';

    public const DEPARTMENTS_VIEW = 'departments.view';

    public const DEPARTMENTS_CREATE = 'departments.create';

    public const DEPARTMENTS_UPDATE = 'departments.update';

    public const DEPARTMENTS_DELETE = 'departments.delete';

    public const TEAMS_VIEW = 'teams.view';

    public const TEAMS_CREATE = 'teams.create';

    public const TEAMS_UPDATE = 'teams.update';

    public const TEAMS_DELETE = 'teams.delete';

    public const ROLES_VIEW = 'roles.view';

    public const ROLES_CREATE = 'roles.create';

    public const ROLES_UPDATE = 'roles.update';

    public const ROLES_DELETE = 'roles.delete';

    public const PERMISSIONS_VIEW = 'permissions.view';

    public const ACTIVITY_LOGS_VIEW = 'activity_logs.view';

    public const PROFILE_VIEW = 'profile.view';

    public const PROFILE_UPDATE = 'profile.update';

    public const FEATURES_VIEW = 'features.view';

    public const FEATURES_MANAGE = 'features.manage';

    public const ATTENDANCE_CLOCK = 'attendance.clock';

    public const ATTENDANCE_VIEW = 'attendance.view';

    public const ATTENDANCE_CORRECT = 'attendance.correct';

    public const ATTENDANCE_REPORTS_SUBMIT = 'attendance.reports.submit';

    public const ATTENDANCE_REPORTS_VIEW = 'attendance.reports.view';

    public const PROJECTS_VIEW = 'projects.view';

    public const PROJECTS_CREATE = 'projects.create';

    public const PROJECTS_UPDATE = 'projects.update';

    public const PROJECTS_DELETE = 'projects.delete';

    public const TASKS_VIEW = 'tasks.view';

    public const TASKS_CREATE = 'tasks.create';

    public const TASKS_UPDATE = 'tasks.update';

    public const TASKS_ASSIGN = 'tasks.assign';

    public const TASKS_DELETE = 'tasks.delete';

    public const HR_PROFILE_VIEW = 'hr.profile.view';

    public const HR_PROFILE_UPDATE = 'hr.profile.update';

    public const HR_SALARY_VIEW = 'hr.salary.view';

    public const LEAVE_REQUEST = 'leave.request';

    public const LEAVE_REVIEW = 'leave.review';

    public const MISSION_REQUEST = 'mission.request';

    public const MISSION_REVIEW = 'mission.review';

    public const MESSAGES_VIEW = 'messages.view';

    public const MESSAGES_SEND = 'messages.send';

    public const ANNOUNCEMENTS_PUBLISH = 'announcements.publish';

    public const CALENDAR_VIEW = 'calendar.view';

    public const CALENDAR_MANAGE = 'calendar.manage';

    public const CRM_VIEW = 'crm.view';

    public const CRM_MANAGE = 'crm.manage';

    public const MARKETING_VIEW = 'marketing.view';

    public const MARKETING_MANAGE = 'marketing.manage';

    public const ADVERTISING_VIEW = 'advertising.view';

    public const ADVERTISING_MANAGE = 'advertising.manage';

    public const FINANCE_VIEW = 'finance.view';

    public const FINANCE_MANAGE = 'finance.manage';

    public const TICKETS_CREATE = 'tickets.create';

    public const TICKETS_MANAGE = 'tickets.manage';

    public const WORKFLOWS_REQUEST = 'workflows.request';

    public const WORKFLOWS_REVIEW = 'workflows.review';

    public const DOCUMENTS_VIEW = 'documents.view';

    public const DOCUMENTS_MANAGE = 'documents.manage';

    public const ANALYTICS_VIEW = 'analytics.view';

    public const PLATFORM_COMPANIES_VIEW = 'platform.companies.view';

    public const PLATFORM_COMPANIES_MANAGE = 'platform.companies.manage';

    /**
     * @return array<string, array{module: string, description: string}>
     */
    public static function definitions(): array
    {
        return [
            self::DASHBOARD_VIEW => ['module' => 'core', 'description' => 'View the workspace dashboard'],
            self::COMPANY_VIEW => ['module' => 'organizations', 'description' => 'View company profile'],
            self::COMPANY_UPDATE => ['module' => 'organizations', 'description' => 'Update company profile'],
            self::COMPANY_SETTINGS_MANAGE => ['module' => 'organizations', 'description' => 'Manage company settings and work schedule'],
            self::USERS_VIEW => ['module' => 'identity', 'description' => 'View company directory'],
            self::USERS_CREATE => ['module' => 'identity', 'description' => 'Create company members'],
            self::USERS_UPDATE => ['module' => 'identity', 'description' => 'Update company members'],
            self::USERS_DELETE => ['module' => 'identity', 'description' => 'Remove company members'],
            self::USERS_INVITE => ['module' => 'identity', 'description' => 'Invite people to the company'],
            self::DEPARTMENTS_VIEW => ['module' => 'organizations', 'description' => 'View departments'],
            self::DEPARTMENTS_CREATE => ['module' => 'organizations', 'description' => 'Create departments'],
            self::DEPARTMENTS_UPDATE => ['module' => 'organizations', 'description' => 'Update departments'],
            self::DEPARTMENTS_DELETE => ['module' => 'organizations', 'description' => 'Delete departments'],
            self::TEAMS_VIEW => ['module' => 'organizations', 'description' => 'View teams'],
            self::TEAMS_CREATE => ['module' => 'organizations', 'description' => 'Create teams'],
            self::TEAMS_UPDATE => ['module' => 'organizations', 'description' => 'Update teams'],
            self::TEAMS_DELETE => ['module' => 'organizations', 'description' => 'Delete teams'],
            self::ROLES_VIEW => ['module' => 'access', 'description' => 'View roles'],
            self::ROLES_CREATE => ['module' => 'access', 'description' => 'Create roles'],
            self::ROLES_UPDATE => ['module' => 'access', 'description' => 'Update roles and grants'],
            self::ROLES_DELETE => ['module' => 'access', 'description' => 'Delete custom roles'],
            self::PERMISSIONS_VIEW => ['module' => 'access', 'description' => 'View the permission catalog'],
            self::ACTIVITY_LOGS_VIEW => ['module' => 'core', 'description' => 'View the company activity log'],
            self::PROFILE_VIEW => ['module' => 'identity', 'description' => 'View own profile'],
            self::PROFILE_UPDATE => ['module' => 'identity', 'description' => 'Update own profile'],
            self::FEATURES_VIEW => ['module' => 'core', 'description' => 'View feature flags'],
            self::FEATURES_MANAGE => ['module' => 'core', 'description' => 'Manage feature flags'],
            self::ATTENDANCE_CLOCK => ['module' => 'attendance', 'description' => 'Clock in, clock out, and set own work status'],
            self::ATTENDANCE_VIEW => ['module' => 'attendance', 'description' => 'View attendance for people in scope'],
            self::ATTENDANCE_CORRECT => ['module' => 'attendance', 'description' => 'Correct attendance records'],
            self::ATTENDANCE_REPORTS_SUBMIT => ['module' => 'attendance', 'description' => 'Submit own morning check-in and daily report'],
            self::ATTENDANCE_REPORTS_VIEW => ['module' => 'attendance', 'description' => 'Read daily reports in scope'],
            self::PROJECTS_VIEW => ['module' => 'projects', 'description' => 'View visible projects'],
            self::PROJECTS_CREATE => ['module' => 'projects', 'description' => 'Create projects'],
            self::PROJECTS_UPDATE => ['module' => 'projects', 'description' => 'Update projects and columns'],
            self::PROJECTS_DELETE => ['module' => 'projects', 'description' => 'Archive or delete projects'],
            self::TASKS_VIEW => ['module' => 'projects', 'description' => 'View tasks on visible projects'],
            self::TASKS_CREATE => ['module' => 'projects', 'description' => 'Create tasks'],
            self::TASKS_UPDATE => ['module' => 'projects', 'description' => 'Update own or assigned tasks'],
            self::TASKS_ASSIGN => ['module' => 'projects', 'description' => 'Assign and move any visible task'],
            self::TASKS_DELETE => ['module' => 'projects', 'description' => 'Delete tasks'],
            self::HR_PROFILE_VIEW => ['module' => 'hr', 'description' => 'View employee HR profiles'],
            self::HR_PROFILE_UPDATE => ['module' => 'hr', 'description' => 'Update employee HR profiles'],
            self::HR_SALARY_VIEW => ['module' => 'hr', 'description' => 'View salary and national id'],
            self::LEAVE_REQUEST => ['module' => 'hr', 'description' => 'Submit own leave requests'],
            self::LEAVE_REVIEW => ['module' => 'hr', 'description' => 'Review leave requests in scope'],
            self::MISSION_REQUEST => ['module' => 'hr', 'description' => 'Submit own mission requests'],
            self::MISSION_REVIEW => ['module' => 'hr', 'description' => 'Review mission requests in scope'],
            self::MESSAGES_VIEW => ['module' => 'communication', 'description' => 'Read company channels and announcements'],
            self::MESSAGES_SEND => ['module' => 'communication', 'description' => 'Send messages in visible channels'],
            self::ANNOUNCEMENTS_PUBLISH => ['module' => 'communication', 'description' => 'Publish company announcements'],
            self::CALENDAR_VIEW => ['module' => 'calendar', 'description' => 'View visible events'],
            self::CALENDAR_MANAGE => ['module' => 'calendar', 'description' => 'Create and update events'],
            self::CRM_VIEW => ['module' => 'crm', 'description' => 'View accounts, contacts, and deals'],
            self::CRM_MANAGE => ['module' => 'crm', 'description' => 'Manage the sales pipeline'],
            self::MARKETING_VIEW => ['module' => 'marketing', 'description' => 'View campaigns'],
            self::MARKETING_MANAGE => ['module' => 'marketing', 'description' => 'Manage campaigns'],
            self::ADVERTISING_VIEW => ['module' => 'advertising', 'description' => 'View advertising campaigns'],
            self::ADVERTISING_MANAGE => ['module' => 'advertising', 'description' => 'Manage advertising campaigns'],
            self::FINANCE_VIEW => ['module' => 'finance', 'description' => 'View invoices and expenses'],
            self::FINANCE_MANAGE => ['module' => 'finance', 'description' => 'Record invoices and expenses'],
            self::TICKETS_CREATE => ['module' => 'operations', 'description' => 'Open and follow own tickets'],
            self::TICKETS_MANAGE => ['module' => 'operations', 'description' => 'Triage every ticket'],
            self::WORKFLOWS_REQUEST => ['module' => 'workflows', 'description' => 'Submit an approval request'],
            self::WORKFLOWS_REVIEW => ['module' => 'workflows', 'description' => 'Review approval requests'],
            self::DOCUMENTS_VIEW => ['module' => 'documents', 'description' => 'Read visible documents'],
            self::DOCUMENTS_MANAGE => ['module' => 'documents', 'description' => 'Create and edit documents'],
            self::ANALYTICS_VIEW => ['module' => 'analytics', 'description' => 'View permitted company metrics'],
            self::PLATFORM_COMPANIES_VIEW => ['module' => 'platform', 'description' => 'View companies on the platform'],
            self::PLATFORM_COMPANIES_MANAGE => ['module' => 'platform', 'description' => 'Suspend or activate companies'],
        ];
    }

    /**
     * @return list<string>
     */
    public static function companyNames(): array
    {
        return array_values(array_filter(
            array_keys(self::definitions()),
            static fn (string $name): bool => ! str_starts_with($name, 'platform.'),
        ));
    }

    /**
     * @return array<string, array{name: string, description: string, permissions: list<string>}>
     */
    public static function roleTemplates(): array
    {
        $directory = [
            self::DASHBOARD_VIEW,
            self::COMPANY_VIEW,
            self::USERS_VIEW,
            self::DEPARTMENTS_VIEW,
            self::TEAMS_VIEW,
            self::PROFILE_VIEW,
            self::PROFILE_UPDATE,
        ];

        $presence = [
            self::ATTENDANCE_CLOCK,
            self::ATTENDANCE_REPORTS_SUBMIT,
        ];

        $work = [
            self::PROJECTS_VIEW,
            self::TASKS_VIEW,
            self::TASKS_CREATE,
            self::TASKS_UPDATE,
            self::LEAVE_REQUEST,
            self::MISSION_REQUEST,
        ];

        $manageWork = [
            self::PROJECTS_CREATE,
            self::PROJECTS_UPDATE,
            self::TASKS_ASSIGN,
        ];

        $desk = [
            self::MESSAGES_VIEW,
            self::MESSAGES_SEND,
            self::CALENDAR_VIEW,
            self::TICKETS_CREATE,
            self::WORKFLOWS_REQUEST,
            self::DOCUMENTS_VIEW,
        ];

        return [
            'company-owner' => [
                'name' => 'مالک شرکت',
                'description' => 'دسترسی کامل به شرکت',
                'permissions' => self::companyNames(),
            ],
            'ceo' => [
                'name' => 'مدیرعامل',
                'description' => 'مشاهده و مدیریت کل شرکت',
                'permissions' => self::companyNames(),
            ],
            'department-manager' => [
                'name' => 'مدیر واحد',
                'description' => 'مدیریت تیم‌های واحد و مشاهده اعضا',
                'permissions' => [
                    ...$directory,
                    ...$presence,
                    ...$work,
                    ...$manageWork,
                    self::LEAVE_REVIEW,
                    self::MISSION_REVIEW,
                    self::ATTENDANCE_VIEW,
                    self::ATTENDANCE_REPORTS_VIEW,
                    self::USERS_UPDATE,
                    self::TEAMS_CREATE,
                    self::TEAMS_UPDATE,
                    self::TEAMS_DELETE,
                    self::ACTIVITY_LOGS_VIEW,
                    ...$desk,
                    self::CALENDAR_MANAGE,
                    self::ANNOUNCEMENTS_PUBLISH,
                    self::TICKETS_MANAGE,
                    self::WORKFLOWS_REVIEW,
                    self::DOCUMENTS_MANAGE,
                    self::ANALYTICS_VIEW,
                ],
            ],
            'team-leader' => [
                'name' => 'سرپرست تیم',
                'description' => 'مشاهده تیم و همکاران',
                'permissions' => [
                    ...$directory,
                    ...$presence,
                    ...$work,
                    ...$manageWork,
                    self::ATTENDANCE_VIEW,
                    ...$desk,
                    self::CALENDAR_MANAGE,
                ],
            ],
            'employee' => [
                'name' => 'کارمند',
                'description' => 'فضای کاری شخصی و مشاهده ساختار مجاز',
                'permissions' => [
                    ...$directory,
                    ...$presence,
                    ...$work,
                    ...$desk,
                ],
            ],
            'hr' => [
                'name' => 'منابع انسانی',
                'description' => 'مدیریت اعضا و دعوت‌ها',
                'permissions' => [
                    ...$directory,
                    ...$presence,
                    ...$work,
                    self::HR_PROFILE_VIEW,
                    self::HR_PROFILE_UPDATE,
                    self::HR_SALARY_VIEW,
                    self::LEAVE_REVIEW,
                    self::MISSION_REVIEW,
                    self::ATTENDANCE_VIEW,
                    self::ATTENDANCE_CORRECT,
                    self::ATTENDANCE_REPORTS_VIEW,
                    self::USERS_CREATE,
                    self::USERS_UPDATE,
                    self::USERS_INVITE,
                    self::ACTIVITY_LOGS_VIEW,
                    ...$desk,
                    self::DOCUMENTS_MANAGE,
                ],
            ],
            'sales' => [
                'name' => 'فروش',
                'description' => 'دسترسی پایه تا فعال شدن ماژول فروش',
                'permissions' => [
                    ...$directory,
                    ...$presence,
                    ...$work,
                    ...$desk,
                    self::CRM_VIEW,
                    self::CRM_MANAGE,
                ],
            ],
            'marketing' => [
                'name' => 'بازاریابی',
                'description' => 'دسترسی پایه تا فعال شدن ماژول بازاریابی',
                'permissions' => [
                    ...$directory,
                    ...$presence,
                    ...$work,
                    ...$desk,
                    self::MARKETING_VIEW,
                    self::MARKETING_MANAGE,
                    self::ADVERTISING_VIEW,
                    self::ADVERTISING_MANAGE,
                ],
            ],
            'finance' => [
                'name' => 'مالی',
                'description' => 'دفتر مالی شرکت',
                'permissions' => [
                    ...$directory,
                    ...$presence,
                    ...$work,
                    ...$desk,
                    self::FINANCE_VIEW,
                    self::FINANCE_MANAGE,
                    self::ANALYTICS_VIEW,
                ],
            ],
            'client' => [
                'name' => 'مشتری',
                'description' => 'دسترسی محدود به فضای شخصی',
                'permissions' => [
                    self::DASHBOARD_VIEW,
                    self::PROFILE_VIEW,
                    self::PROFILE_UPDATE,
                ],
            ],
        ];
    }
}
