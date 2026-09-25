-- Virtual Company OS — default company, roles, login accounts, and sample work, HR, and suite data.
-- Password for every account: 123456
-- Change it before any shared or production use.
-- This file contains a fake national id, salary, invoice, and deal amount. Treat it as sensitive.
BEGIN;

-- migrations
INSERT INTO migrations (id, migration, batch) VALUES
    (1, '0001_01_01_000000_create_users_table', 1),
    (2, '0001_01_01_000001_create_cache_table', 1),
    (3, '0001_01_01_000002_create_jobs_table', 1),
    (4, '2026_09_24_204451_create_personal_access_tokens_table', 1),
    (5, '2026_09_25_100000_create_organization_tables', 1),
    (6, '2026_09_25_100100_create_access_tables', 1),
    (7, '2026_09_25_100200_create_foundation_tables', 1),
    (8, '2026_09_25_120000_create_attendance_tables', 1),
    (9, '2026_09_25_130000_create_project_tables', 1),
    (10, '2026_09_25_140000_create_hr_tables', 1),
    (11, '2026_09_25_150000_create_suite_tables', 1);

SELECT setval(pg_get_serial_sequence('migrations', 'id'), COALESCE((SELECT MAX(id) FROM migrations), 1), true);

-- users
INSERT INTO users (id, uuid, name, email, phone, avatar_path, locale, timezone, status, is_platform_admin, email_verified_at, password, last_login_at, last_login_ip, two_factor_secret, two_factor_recovery_codes, two_factor_confirmed_at, remember_token, created_at, updated_at) VALUES
    (1, 'ef3bf85d-6ca0-4e9a-afd4-01fdb5072d69', 'Platform Admin', 'platform@virtual-company.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', true, '2026-09-24 22:19:10', '$2y$12$1GlRys45h0fzAOtpVFEGtOc./bD0RwNUPsK7oiNPu0GNVO1zUGtoK', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (2, '6b3e9445-2e1a-4bf2-ae51-eeb0b1118d46', 'سارا محمدی', 'ceo@ideban.test', '02191000000', NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-24 22:19:10', '$2y$12$1GlRys45h0fzAOtpVFEGtOc./bD0RwNUPsK7oiNPu0GNVO1zUGtoK', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (3, 'ea36ecf0-6bbf-4946-b42a-d3e1982bcd79', 'آرمان کاظمی', 'developer@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-24 22:19:11', '$2y$12$1GlRys45h0fzAOtpVFEGtOc./bD0RwNUPsK7oiNPu0GNVO1zUGtoK', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (4, '9eb27c7c-b99d-483c-88d7-421a05d89822', 'نیلوفر رضایی', 'devops@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-24 22:19:11', '$2y$12$1GlRys45h0fzAOtpVFEGtOc./bD0RwNUPsK7oiNPu0GNVO1zUGtoK', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (5, '6a888cf6-a755-4a74-ada3-d92785ae5675', 'حسین مرادی', 'support@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-24 22:19:11', '$2y$12$1GlRys45h0fzAOtpVFEGtOc./bD0RwNUPsK7oiNPu0GNVO1zUGtoK', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:12', '2026-09-24 22:19:12'),
    (6, 'cb83e5fc-b175-42f3-b825-c33678ce9276', 'مریم حسینی', 'sales@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-24 22:19:12', '$2y$12$1GlRys45h0fzAOtpVFEGtOc./bD0RwNUPsK7oiNPu0GNVO1zUGtoK', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:12', '2026-09-24 22:19:12'),
    (7, '21c11167-7fda-482a-967d-ddafc9da7f79', 'کیان نادری', 'marketing@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-24 22:19:12', '$2y$12$1GlRys45h0fzAOtpVFEGtOc./bD0RwNUPsK7oiNPu0GNVO1zUGtoK', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:12', '2026-09-24 22:19:12'),
    (8, 'aafe04b1-cdaa-4402-a8e5-d91bcf21ebc4', 'لیلا اکبری', 'finance@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-24 22:19:12', '$2y$12$1GlRys45h0fzAOtpVFEGtOc./bD0RwNUPsK7oiNPu0GNVO1zUGtoK', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (9, '46e30c25-6ca2-42f5-b1db-a80031f2aa4e', 'رضا شریفی', 'hr@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-24 22:19:13', '$2y$12$1GlRys45h0fzAOtpVFEGtOc./bD0RwNUPsK7oiNPu0GNVO1zUGtoK', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('users', 'id'), COALESCE((SELECT MAX(id) FROM users), 1), true);

-- permissions
INSERT INTO permissions (id, name, module, description, created_at, updated_at) VALUES
    (1, 'dashboard.view', 'core', 'View the workspace dashboard', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (2, 'company.view', 'organizations', 'View company profile', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (3, 'company.update', 'organizations', 'Update company profile', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (4, 'company.settings.manage', 'organizations', 'Manage company settings and work schedule', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (5, 'users.view', 'identity', 'View company directory', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (6, 'users.create', 'identity', 'Create company members', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (7, 'users.update', 'identity', 'Update company members', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (8, 'users.delete', 'identity', 'Remove company members', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (9, 'users.invite', 'identity', 'Invite people to the company', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (10, 'departments.view', 'organizations', 'View departments', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (11, 'departments.create', 'organizations', 'Create departments', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (12, 'departments.update', 'organizations', 'Update departments', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (13, 'departments.delete', 'organizations', 'Delete departments', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (14, 'teams.view', 'organizations', 'View teams', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (15, 'teams.create', 'organizations', 'Create teams', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (16, 'teams.update', 'organizations', 'Update teams', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (17, 'teams.delete', 'organizations', 'Delete teams', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (18, 'roles.view', 'access', 'View roles', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (19, 'roles.create', 'access', 'Create roles', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (20, 'roles.update', 'access', 'Update roles and grants', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (21, 'roles.delete', 'access', 'Delete custom roles', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (22, 'permissions.view', 'access', 'View the permission catalog', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (23, 'activity_logs.view', 'core', 'View the company activity log', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (24, 'profile.view', 'identity', 'View own profile', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (25, 'profile.update', 'identity', 'Update own profile', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (26, 'features.view', 'core', 'View feature flags', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (27, 'features.manage', 'core', 'Manage feature flags', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (28, 'attendance.clock', 'attendance', 'Clock in, clock out, and set own work status', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (29, 'attendance.view', 'attendance', 'View attendance for people in scope', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (30, 'attendance.correct', 'attendance', 'Correct attendance records', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (31, 'attendance.reports.submit', 'attendance', 'Submit own morning check-in and daily report', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (32, 'attendance.reports.view', 'attendance', 'Read daily reports in scope', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (33, 'projects.view', 'projects', 'View visible projects', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (34, 'projects.create', 'projects', 'Create projects', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (35, 'projects.update', 'projects', 'Update projects and columns', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (36, 'projects.delete', 'projects', 'Archive or delete projects', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (37, 'tasks.view', 'projects', 'View tasks on visible projects', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (38, 'tasks.create', 'projects', 'Create tasks', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (39, 'tasks.update', 'projects', 'Update own or assigned tasks', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (40, 'tasks.assign', 'projects', 'Assign and move any visible task', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (41, 'tasks.delete', 'projects', 'Delete tasks', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (42, 'hr.profile.view', 'hr', 'View employee HR profiles', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (43, 'hr.profile.update', 'hr', 'Update employee HR profiles', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (44, 'hr.salary.view', 'hr', 'View salary and national id', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (45, 'leave.request', 'hr', 'Submit own leave requests', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (46, 'leave.review', 'hr', 'Review leave requests in scope', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (47, 'mission.request', 'hr', 'Submit own mission requests', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (48, 'mission.review', 'hr', 'Review mission requests in scope', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (49, 'messages.view', 'communication', 'Read company channels and announcements', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (50, 'messages.send', 'communication', 'Send messages in visible channels', '2026-09-24 22:19:10', '2026-09-24 22:19:10');

INSERT INTO permissions (id, name, module, description, created_at, updated_at) VALUES
    (51, 'announcements.publish', 'communication', 'Publish company announcements', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (52, 'calendar.view', 'calendar', 'View visible events', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (53, 'calendar.manage', 'calendar', 'Create and update events', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (54, 'crm.view', 'crm', 'View accounts, contacts, and deals', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (55, 'crm.manage', 'crm', 'Manage the sales pipeline', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (56, 'marketing.view', 'marketing', 'View campaigns', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (57, 'marketing.manage', 'marketing', 'Manage campaigns', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (58, 'advertising.view', 'advertising', 'View advertising campaigns', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (59, 'advertising.manage', 'advertising', 'Manage advertising campaigns', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (60, 'finance.view', 'finance', 'View invoices and expenses', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (61, 'finance.manage', 'finance', 'Record invoices and expenses', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (62, 'tickets.create', 'operations', 'Open and follow own tickets', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (63, 'tickets.manage', 'operations', 'Triage every ticket', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (64, 'workflows.request', 'workflows', 'Submit an approval request', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (65, 'workflows.review', 'workflows', 'Review approval requests', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (66, 'documents.view', 'documents', 'Read visible documents', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (67, 'documents.manage', 'documents', 'Create and edit documents', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (68, 'analytics.view', 'analytics', 'View permitted company metrics', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (69, 'platform.companies.view', 'platform', 'View companies on the platform', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (70, 'platform.companies.manage', 'platform', 'Suspend or activate companies', '2026-09-24 22:19:10', '2026-09-24 22:19:10');

SELECT setval(pg_get_serial_sequence('permissions', 'id'), COALESCE((SELECT MAX(id) FROM permissions), 1), true);

-- companies
INSERT INTO companies (id, uuid, name, legal_name, slug, status, timezone, locale, logo_path, plan, user_limit, settings, onboarded_at, created_at, updated_at) VALUES
    (1, 'a3a0c13a-cb5c-4a3a-8761-68dcb55b5a8a', 'شبکه پردازان ایده‌بان الماس', 'شبکه پردازان ایده‌بان الماس', 'ideban-almas', 'active', 'Asia/Tehran', 'fa', NULL, NULL, NULL, '{"onboarding":{"departments":true,"teams":true,"invites":true,"schedule":true,"completed":true}}'::jsonb, '2026-09-24 22:19:13', '2026-09-24 22:19:10', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('companies', 'id'), COALESCE((SELECT MAX(id) FROM companies), 1), true);

-- departments
INSERT INTO departments (id, company_id, uuid, name, slug, code, description, manager_id, parent_id, is_active, sort_order, created_at, updated_at) VALUES
    (1, 1, '80b87840-6664-44a6-b1ed-1ecdc3c60ad9', 'مدیریت', 'management', 'MGT', NULL, 2, NULL, true, 0, '2026-09-24 22:19:11', '2026-09-24 22:19:13'),
    (2, 1, '5ad47401-fc43-4515-804e-88306f57f474', 'توسعه نرم‌افزار', 'software', 'DEV', NULL, 3, NULL, true, 1, '2026-09-24 22:19:11', '2026-09-24 22:19:13'),
    (3, 1, 'ceb9cfe5-b42a-4e2c-9740-94421778788f', 'دوآپس', 'devops', 'OPSINF', NULL, NULL, NULL, true, 2, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (4, 1, '59d75c51-c176-4a21-b177-4600ee5ec2ab', 'عملیات و پشتیبانی', 'operations', 'OPS', NULL, NULL, NULL, true, 3, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (5, 1, 'a90db179-13c3-4ca1-b083-acf01ea3dc79', 'فروش', 'sales', 'SAL', NULL, 6, NULL, true, 4, '2026-09-24 22:19:11', '2026-09-24 22:19:13'),
    (6, 1, 'b69d893f-f178-4757-af63-7f52983d379f', 'بازاریابی', 'marketing', 'MKT', NULL, NULL, NULL, true, 5, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (7, 1, 'b0d5dc80-bb4d-49fb-84f5-50f7720b0374', 'تبلیغات', 'advertising', 'ADV', NULL, NULL, NULL, true, 6, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (8, 1, 'e6c0068b-6703-42e8-ae7d-69af5ccdca5f', 'مالی', 'finance', 'FIN', NULL, 8, NULL, true, 7, '2026-09-24 22:19:11', '2026-09-24 22:19:13'),
    (9, 1, 'd97beb97-92ee-46e1-9246-3d7b5b57e70f', 'منابع انسانی', 'hr', 'HR', NULL, 9, NULL, true, 8, '2026-09-24 22:19:11', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('departments', 'id'), COALESCE((SELECT MAX(id) FROM departments), 1), true);

-- company_user
INSERT INTO company_user (id, company_id, user_id, department_id, job_title, employee_code, status, is_owner, joined_at, created_at, updated_at) VALUES
    (1, 1, 2, NULL, 'مدیرعامل', NULL, 'active', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (2, 1, 3, 2, 'توسعه‌دهنده', 'DEV-01', 'active', false, '2026-09-24 22:19:11', '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (3, 1, 4, 3, 'مهندس دوآپس', 'OPS-01', 'active', false, '2026-09-24 22:19:11', '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (4, 1, 5, 4, 'کارشناس پشتیبانی', 'SUP-01', 'active', false, '2026-09-24 22:19:12', '2026-09-24 22:19:12', '2026-09-24 22:19:12'),
    (5, 1, 6, 5, 'مدیر فروش', 'SAL-01', 'active', false, '2026-09-24 22:19:12', '2026-09-24 22:19:12', '2026-09-24 22:19:12'),
    (6, 1, 7, 6, 'کارشناس بازاریابی', 'MKT-01', 'active', false, '2026-09-24 22:19:12', '2026-09-24 22:19:12', '2026-09-24 22:19:12'),
    (7, 1, 8, 8, 'مدیر مالی', 'FIN-01', 'active', false, '2026-09-24 22:19:13', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (8, 1, 9, 9, 'کارشناس منابع انسانی', 'HR-01', 'active', false, '2026-09-24 22:19:13', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('company_user', 'id'), COALESCE((SELECT MAX(id) FROM company_user), 1), true);

-- teams
INSERT INTO teams (id, company_id, department_id, uuid, name, slug, description, leader_id, is_active, created_at, updated_at) VALUES
    (1, 1, 2, '97b453c8-b424-4ea2-b646-d24a437935c8', 'تیم محصول', 'product', 'توسعه محصول‌های نرم‌افزاری شرکت', 3, true, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 1, 3, '47b7de3b-67f3-47bc-bb75-ebfefc608360', 'تیم زیرساخت', 'infrastructure', NULL, 4, true, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (3, 1, 5, '1e1f2cde-7e74-48e3-b3e4-8615d40a9a1d', 'میز فروش', 'sales-desk', NULL, 6, true, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('teams', 'id'), COALESCE((SELECT MAX(id) FROM teams), 1), true);

-- team_user
INSERT INTO team_user (id, team_id, user_id, role, created_at, updated_at) VALUES
    (1, 1, 3, 'leader', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 2, 4, 'leader', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (3, 3, 6, 'leader', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('team_user', 'id'), COALESCE((SELECT MAX(id) FROM team_user), 1), true);

-- roles
INSERT INTO roles (id, company_id, uuid, name, slug, description, is_system, created_at, updated_at) VALUES
    (1, 1, 'ecd79d96-bf22-4add-878f-48d4d3cfbb72', 'مالک شرکت', 'company-owner', 'دسترسی کامل به شرکت', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (2, 1, 'eb26c3f8-3b2b-4434-8448-e965fc981233', 'مدیرعامل', 'ceo', 'مشاهده و مدیریت کل شرکت', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (3, 1, '0810f14a-d7a0-4a8e-a651-040fd8d66c2c', 'مدیر واحد', 'department-manager', 'مدیریت تیم‌های واحد و مشاهده اعضا', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (4, 1, 'ff8231b5-c944-48bf-9042-24c720d4e762', 'سرپرست تیم', 'team-leader', 'مشاهده تیم و همکاران', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (5, 1, 'c4347c8a-c259-46e9-8f40-9ecfe23a2c14', 'کارمند', 'employee', 'فضای کاری شخصی و مشاهده ساختار مجاز', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (6, 1, 'fcfaf5b1-21c4-4481-abc5-efbf1e4309d1', 'منابع انسانی', 'hr', 'مدیریت اعضا و دعوت‌ها', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (7, 1, 'c11ed07d-d9c1-4b58-8dfe-ed55671b5c7d', 'فروش', 'sales', 'دسترسی پایه تا فعال شدن ماژول فروش', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (8, 1, '3073f75b-1179-457a-abda-710196a57daf', 'بازاریابی', 'marketing', 'دسترسی پایه تا فعال شدن ماژول بازاریابی', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (9, 1, '74ec9860-31ec-4acd-86b7-70747401641b', 'مالی', 'finance', 'دفتر مالی شرکت', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (10, 1, '67c4a3b5-dc5f-4c2b-8e24-8e89c09b22e5', 'مشتری', 'client', 'دسترسی محدود به فضای شخصی', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11');

SELECT setval(pg_get_serial_sequence('roles', 'id'), COALESCE((SELECT MAX(id) FROM roles), 1), true);

-- role_permissions
INSERT INTO role_permissions (role_id, permission_id) VALUES
    (1, 1),
    (1, 2),
    (1, 3),
    (1, 4),
    (1, 5),
    (1, 6),
    (1, 7),
    (1, 8),
    (1, 9),
    (1, 10),
    (1, 11),
    (1, 12),
    (1, 13),
    (1, 14),
    (1, 15),
    (1, 16),
    (1, 17),
    (1, 18),
    (1, 19),
    (1, 20),
    (1, 21),
    (1, 22),
    (1, 23),
    (1, 24),
    (1, 25),
    (1, 26),
    (1, 27),
    (1, 28),
    (1, 29),
    (1, 30),
    (1, 31),
    (1, 32),
    (1, 33),
    (1, 34),
    (1, 35),
    (1, 36),
    (1, 37),
    (1, 38),
    (1, 39),
    (1, 40),
    (1, 41),
    (1, 42),
    (1, 43),
    (1, 44),
    (1, 45),
    (1, 46),
    (1, 47),
    (1, 48),
    (1, 49),
    (1, 50);

INSERT INTO role_permissions (role_id, permission_id) VALUES
    (1, 51),
    (1, 52),
    (1, 53),
    (1, 54),
    (1, 55),
    (1, 56),
    (1, 57),
    (1, 58),
    (1, 59),
    (1, 60),
    (1, 61),
    (1, 62),
    (1, 63),
    (1, 64),
    (1, 65),
    (1, 66),
    (1, 67),
    (1, 68),
    (2, 1),
    (2, 2),
    (2, 3),
    (2, 4),
    (2, 5),
    (2, 6),
    (2, 7),
    (2, 8),
    (2, 9),
    (2, 10),
    (2, 11),
    (2, 12),
    (2, 13),
    (2, 14),
    (2, 15),
    (2, 16),
    (2, 17),
    (2, 18),
    (2, 19),
    (2, 20),
    (2, 21),
    (2, 22),
    (2, 23),
    (2, 24),
    (2, 25),
    (2, 26),
    (2, 27),
    (2, 28),
    (2, 29),
    (2, 30),
    (2, 31),
    (2, 32);

INSERT INTO role_permissions (role_id, permission_id) VALUES
    (2, 33),
    (2, 34),
    (2, 35),
    (2, 36),
    (2, 37),
    (2, 38),
    (2, 39),
    (2, 40),
    (2, 41),
    (2, 42),
    (2, 43),
    (2, 44),
    (2, 45),
    (2, 46),
    (2, 47),
    (2, 48),
    (2, 49),
    (2, 50),
    (2, 51),
    (2, 52),
    (2, 53),
    (2, 54),
    (2, 55),
    (2, 56),
    (2, 57),
    (2, 58),
    (2, 59),
    (2, 60),
    (2, 61),
    (2, 62),
    (2, 63),
    (2, 64),
    (2, 65),
    (2, 66),
    (2, 67),
    (2, 68),
    (3, 1),
    (3, 2),
    (3, 5),
    (3, 10),
    (3, 14),
    (3, 24),
    (3, 25),
    (3, 28),
    (3, 31),
    (3, 33),
    (3, 37),
    (3, 38),
    (3, 39),
    (3, 45);

INSERT INTO role_permissions (role_id, permission_id) VALUES
    (3, 47),
    (3, 34),
    (3, 35),
    (3, 40),
    (3, 46),
    (3, 48),
    (3, 29),
    (3, 32),
    (3, 7),
    (3, 15),
    (3, 16),
    (3, 17),
    (3, 23),
    (3, 49),
    (3, 50),
    (3, 52),
    (3, 62),
    (3, 64),
    (3, 66),
    (3, 53),
    (3, 51),
    (3, 63),
    (3, 65),
    (3, 67),
    (3, 68),
    (4, 1),
    (4, 2),
    (4, 5),
    (4, 10),
    (4, 14),
    (4, 24),
    (4, 25),
    (4, 28),
    (4, 31),
    (4, 33),
    (4, 37),
    (4, 38),
    (4, 39),
    (4, 45),
    (4, 47),
    (4, 34),
    (4, 35),
    (4, 40),
    (4, 29),
    (4, 49),
    (4, 50),
    (4, 52),
    (4, 62),
    (4, 64),
    (4, 66);

INSERT INTO role_permissions (role_id, permission_id) VALUES
    (4, 53),
    (5, 1),
    (5, 2),
    (5, 5),
    (5, 10),
    (5, 14),
    (5, 24),
    (5, 25),
    (5, 28),
    (5, 31),
    (5, 33),
    (5, 37),
    (5, 38),
    (5, 39),
    (5, 45),
    (5, 47),
    (5, 49),
    (5, 50),
    (5, 52),
    (5, 62),
    (5, 64),
    (5, 66),
    (6, 1),
    (6, 2),
    (6, 5),
    (6, 10),
    (6, 14),
    (6, 24),
    (6, 25),
    (6, 28),
    (6, 31),
    (6, 33),
    (6, 37),
    (6, 38),
    (6, 39),
    (6, 45),
    (6, 47),
    (6, 42),
    (6, 43),
    (6, 44),
    (6, 46),
    (6, 48),
    (6, 29),
    (6, 30),
    (6, 32),
    (6, 6),
    (6, 7),
    (6, 9),
    (6, 23),
    (6, 49);

INSERT INTO role_permissions (role_id, permission_id) VALUES
    (6, 50),
    (6, 52),
    (6, 62),
    (6, 64),
    (6, 66),
    (6, 67),
    (7, 1),
    (7, 2),
    (7, 5),
    (7, 10),
    (7, 14),
    (7, 24),
    (7, 25),
    (7, 28),
    (7, 31),
    (7, 33),
    (7, 37),
    (7, 38),
    (7, 39),
    (7, 45),
    (7, 47),
    (7, 49),
    (7, 50),
    (7, 52),
    (7, 62),
    (7, 64),
    (7, 66),
    (7, 54),
    (7, 55),
    (8, 1),
    (8, 2),
    (8, 5),
    (8, 10),
    (8, 14),
    (8, 24),
    (8, 25),
    (8, 28),
    (8, 31),
    (8, 33),
    (8, 37),
    (8, 38),
    (8, 39),
    (8, 45),
    (8, 47),
    (8, 49),
    (8, 50),
    (8, 52),
    (8, 62),
    (8, 64),
    (8, 66);

INSERT INTO role_permissions (role_id, permission_id) VALUES
    (8, 56),
    (8, 57),
    (8, 58),
    (8, 59),
    (9, 1),
    (9, 2),
    (9, 5),
    (9, 10),
    (9, 14),
    (9, 24),
    (9, 25),
    (9, 28),
    (9, 31),
    (9, 33),
    (9, 37),
    (9, 38),
    (9, 39),
    (9, 45),
    (9, 47),
    (9, 49),
    (9, 50),
    (9, 52),
    (9, 62),
    (9, 64),
    (9, 66),
    (9, 60),
    (9, 61),
    (9, 68),
    (10, 1),
    (10, 24),
    (10, 25);

-- user_roles
INSERT INTO user_roles (id, company_id, user_id, role_id, created_at, updated_at) VALUES
    (1, 1, 2, 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (2, 1, 3, 4, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (3, 1, 4, 5, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (4, 1, 5, 5, '2026-09-24 22:19:12', '2026-09-24 22:19:12'),
    (5, 1, 6, 3, '2026-09-24 22:19:12', '2026-09-24 22:19:12'),
    (6, 1, 6, 7, '2026-09-24 22:19:12', '2026-09-24 22:19:12'),
    (7, 1, 7, 8, '2026-09-24 22:19:12', '2026-09-24 22:19:12'),
    (8, 1, 8, 3, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (9, 1, 8, 9, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (10, 1, 9, 6, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('user_roles', 'id'), COALESCE((SELECT MAX(id) FROM user_roles), 1), true);

-- work_schedules
INSERT INTO work_schedules (id, company_id, weekday, is_working_day, start_time, end_time, break_minutes, grace_minutes, created_at, updated_at) VALUES
    (1, 1, 0, true, '09:00', '17:00', 60, 15, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (2, 1, 1, true, '09:00', '17:00', 60, 15, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (3, 1, 2, true, '09:00', '17:00', 60, 15, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (4, 1, 3, true, '09:00', '17:00', 60, 15, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (5, 1, 4, true, '09:00', '17:00', 60, 15, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (6, 1, 5, false, '09:00', '17:00', 60, 15, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (7, 1, 6, true, '09:00', '17:00', 60, 15, '2026-09-24 22:19:11', '2026-09-24 22:19:11');

SELECT setval(pg_get_serial_sequence('work_schedules', 'id'), COALESCE((SELECT MAX(id) FROM work_schedules), 1), true);

-- features
INSERT INTO features (id, company_id, key, enabled, created_at, updated_at) VALUES
    (1, 1, 'foundation', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (2, 1, 'attendance', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (3, 1, 'projects', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (4, 1, 'hr', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (5, 1, 'communication', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (6, 1, 'calendar', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (7, 1, 'crm', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (8, 1, 'marketing', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (9, 1, 'advertising', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (10, 1, 'finance', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (11, 1, 'operations', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (12, 1, 'workflows', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (13, 1, 'documents', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (14, 1, 'analytics', true, '2026-09-24 22:19:11', '2026-09-24 22:19:11');

SELECT setval(pg_get_serial_sequence('features', 'id'), COALESCE((SELECT MAX(id) FROM features), 1), true);

-- projects
INSERT INTO projects (id, company_id, uuid, name, slug, code, description, status, visibility, department_id, owner_id, start_date, due_date, created_at, updated_at) VALUES
    (1, 1, '5609b00e-3a6b-4473-83c2-3570f1c740d1', 'فروشگاه', 'shop', 'SHOP', 'فروش آنلاین و هماهنگی کاتالوگ', 'active', 'company', 5, 2, NULL, '2026-10-24 00:00:00', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 1, '717fb2e6-f4f1-447e-b2a1-acb7bbfe84a2', 'دفتر مجازی', 'virtual-office', 'VOFFICE', 'حضور، وظیفه و گزارش روزانهٔ شرکت مجازی', 'active', 'company', 2, 2, NULL, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('projects', 'id'), COALESCE((SELECT MAX(id) FROM projects), 1), true);

-- project_members
INSERT INTO project_members (id, company_id, project_id, user_id, role, created_at, updated_at) VALUES
    (1, 1, 1, 2, 'manager', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 1, 2, 2, 'manager', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (3, 1, 1, 6, 'member', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (4, 1, 1, 7, 'member', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (5, 1, 2, 3, 'manager', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (6, 1, 2, 4, 'member', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('project_members', 'id'), COALESCE((SELECT MAX(id) FROM project_members), 1), true);

-- kanban_columns
INSERT INTO kanban_columns (id, company_id, project_id, uuid, name, sort_order, is_done, created_at, updated_at) VALUES
    (1, 1, 1, 'ca93fd8c-2be3-48d4-b7df-edeba25d6586', 'صف انتظار', 0, false, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 1, 1, 'd4369705-4014-4008-a38d-b42fca09715d', 'در حال انجام', 1, false, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (3, 1, 1, 'b30121a2-1b0b-45f3-89de-ad1e4f9508f8', 'بازبینی', 2, false, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (4, 1, 1, 'db32feb9-e04c-467d-a5ac-8462592be58b', 'انجام شد', 3, true, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (5, 1, 2, '4b8ce55e-2bd1-46df-9c4e-bc2d2e5d56c5', 'صف انتظار', 0, false, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (6, 1, 2, 'eb584862-d5b1-4e1e-83b5-c10e24012a1c', 'در حال انجام', 1, false, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (7, 1, 2, '2d2d2fb5-4c72-4f8f-8168-62ce3835ef39', 'بازبینی', 2, false, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (8, 1, 2, '7c41c657-8a8e-4566-b60a-e731c782ce57', 'انجام شد', 3, true, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('kanban_columns', 'id'), COALESCE((SELECT MAX(id) FROM kanban_columns), 1), true);

-- tasks
INSERT INTO tasks (id, company_id, project_id, column_id, uuid, title, description, priority, assignee_id, reporter_id, due_date, sort_order, completed_at, created_at, updated_at) VALUES
    (1, 1, 1, 1, '7be05441-bac9-4e0e-a300-a4a521fe81a3', 'آماده‌سازی کاتالوگ پاییز', NULL, 'high', 6, 2, '2026-09-25 00:00:00', 1, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 1, 2, 5, '469ce747-9cfc-495e-9e64-19cecb8ca9e4', 'برد کانبان دفتر مجازی', NULL, 'high', 3, 2, '2026-09-25 00:00:00', 1, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (3, 1, 2, 5, 'f9568f21-46e0-45db-8304-1bed8180ae52', 'پایدارسازی سرویس حضور', NULL, 'normal', 4, 2, '2026-09-25 00:00:00', 2, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('tasks', 'id'), COALESCE((SELECT MAX(id) FROM tasks), 1), true);

-- hr_profiles
INSERT INTO hr_profiles (id, company_id, user_id, hire_date, employment_type, national_id, emergency_name, emergency_phone, salary_amount, salary_currency, notes, created_at, updated_at) VALUES
    (1, 1, 3, '2024-03-01 00:00:00', 'full_time', '0087654321', 'خانواده کاظمی', '09120000000', 850000000, 'IRR', NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('hr_profiles', 'id'), COALESCE((SELECT MAX(id) FROM hr_profiles), 1), true);

-- leave_requests
INSERT INTO leave_requests (id, company_id, uuid, user_id, type, starts_on, ends_on, reason, status, reviewer_id, reviewed_at, review_note, created_at, updated_at) VALUES
    (1, 1, '9f8f935e-2962-48b2-9aa4-a23deea9d918', 4, 'annual', '2026-09-25 00:00:00', '2026-09-25 00:00:00', 'مرخصی استحقاقی نمونه', 'pending', NULL, NULL, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('leave_requests', 'id'), COALESCE((SELECT MAX(id) FROM leave_requests), 1), true);

-- mission_requests
INSERT INTO mission_requests (id, company_id, uuid, user_id, destination, starts_on, ends_on, purpose, status, reviewer_id, reviewed_at, review_note, created_at, updated_at) VALUES
    (1, 1, 'eec73131-3b5b-4da7-95ca-4db25ccd6cb2', 6, 'دفتر مشتری، تهران', '2026-09-25 00:00:00', '2026-09-25 00:00:00', 'جلسه معرفی فروشگاه', 'pending', NULL, NULL, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('mission_requests', 'id'), COALESCE((SELECT MAX(id) FROM mission_requests), 1), true);

-- channels
INSERT INTO channels (id, company_id, uuid, name, slug, kind, created_at, updated_at) VALUES
    (1, 1, '806941ef-0192-485d-ac35-fe668abdcf47', 'عمومی', 'general', 'company', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('channels', 'id'), COALESCE((SELECT MAX(id) FROM channels), 1), true);

-- messages
INSERT INTO messages (id, company_id, channel_id, user_id, uuid, body, created_at, updated_at) VALUES
    (1, 1, 1, 2, '3550fc6e-18df-4dac-8920-334102a3c26e', 'صبح بخیر. اولویت امروز: فروشگاه و دفتر مجازی.', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('messages', 'id'), COALESCE((SELECT MAX(id) FROM messages), 1), true);

-- announcements
INSERT INTO announcements (id, company_id, uuid, title, body, author_id, created_at, updated_at) VALUES
    (1, 1, '8f8ab1c9-f193-4232-a2eb-dc488ee27605', 'شروع هفته', 'جلسهٔ هماهنگی ساعت ۱۰ در تقویم شرکت است.', 2, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('announcements', 'id'), COALESCE((SELECT MAX(id) FROM announcements), 1), true);

-- events
INSERT INTO events (id, company_id, uuid, title, location, starts_at, ends_at, visibility, owner_id, created_at, updated_at) VALUES
    (1, 1, '292186cd-3365-4c7f-a5e5-ef11e74267db', 'هماهنگی هفتگی', 'اتاق مجازی', '2026-09-25 10:00:00', '2026-09-25 11:00:00', 'company', 2, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('events', 'id'), COALESCE((SELECT MAX(id) FROM events), 1), true);

-- crm_accounts
INSERT INTO crm_accounts (id, company_id, uuid, name, status, created_at, updated_at) VALUES
    (1, 1, '4e77b519-4cc0-47ab-b355-d41e4cd8dac9', 'خانهٔ کتاب', 'active', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('crm_accounts', 'id'), COALESCE((SELECT MAX(id) FROM crm_accounts), 1), true);

-- crm_contacts
INSERT INTO crm_contacts (id, company_id, uuid, account_id, name, email, phone, created_at, updated_at) VALUES
    (1, 1, '89c06b26-a782-42fc-b38f-34281992830d', 1, 'نگار سلیمانی', 'negar@example.test', '02144000000', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('crm_contacts', 'id'), COALESCE((SELECT MAX(id) FROM crm_contacts), 1), true);

-- crm_deals
INSERT INTO crm_deals (id, company_id, uuid, account_id, title, stage, amount, currency, owner_id, created_at, updated_at) VALUES
    (1, 1, 'cd8f238e-31a1-4cf5-9c96-c93572d8f919', 1, 'قرارداد فروشگاه', 'proposal', 240000000, 'IRR', 6, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('crm_deals', 'id'), COALESCE((SELECT MAX(id) FROM crm_deals), 1), true);

-- campaigns
INSERT INTO campaigns (id, company_id, uuid, name, channel, status, budget_amount, currency, starts_on, ends_on, created_at, updated_at) VALUES
    (1, 1, 'ecfd7896-5098-471b-9766-1cb32088ba3c', 'کمپین پاییز', 'social', 'active', 80000000, 'IRR', '2026-09-24 00:00:00', '2026-10-24 00:00:00', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 1, 'f826f3f6-2aae-4d72-b46c-fbd5d6fc8381', 'تبلیغ جستجو', 'ads', 'draft', 45000000, 'IRR', NULL, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('campaigns', 'id'), COALESCE((SELECT MAX(id) FROM campaigns), 1), true);

-- invoices
INSERT INTO invoices (id, company_id, uuid, number, party_name, amount, currency, status, issued_on, due_on, created_at, updated_at) VALUES
    (1, 1, 'ae3c5f60-11ec-4cf7-9f61-dfad19352135', 'INV-1405-001', 'خانهٔ کتاب', 120000000, 'IRR', 'sent', '2026-09-24 00:00:00', '2026-10-08 00:00:00', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('invoices', 'id'), COALESCE((SELECT MAX(id) FROM invoices), 1), true);

-- expenses
INSERT INTO expenses (id, company_id, uuid, category, amount, currency, status, spent_on, note, created_at, updated_at) VALUES
    (1, 1, '4560a00d-bd60-459b-8ce5-c509199b310a', 'زیرساخت', 18000000, 'IRR', 'recorded', '2026-09-24 00:00:00', 'هزینهٔ نمونه', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('expenses', 'id'), COALESCE((SELECT MAX(id) FROM expenses), 1), true);

-- tickets
INSERT INTO tickets (id, company_id, uuid, subject, body, status, priority, requester_id, assignee_id, created_at, updated_at) VALUES
    (1, 1, '3a3d3b1a-5d29-4aa7-8803-90cf4e1382c1', 'دسترسی گزارش روزانه', 'همکار جدید صفحهٔ حضور را نمی‌بیند.', 'open', 'high', 5, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('tickets', 'id'), COALESCE((SELECT MAX(id) FROM tickets), 1), true);

-- approvals
INSERT INTO approvals (id, company_id, uuid, title, kind, status, requester_id, reviewer_id, note, review_note, reviewed_at, created_at, updated_at) VALUES
    (1, 1, '3d595d0c-5d88-431b-aacf-45be47c9d533', 'خرید دامنهٔ فروشگاه', 'purchase', 'pending', 3, NULL, 'تمدید یک‌ساله', NULL, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('approvals', 'id'), COALESCE((SELECT MAX(id) FROM approvals), 1), true);

-- documents
INSERT INTO documents (id, company_id, uuid, title, body, visibility, author_id, created_at, updated_at) VALUES
    (1, 1, 'cb341d83-5553-4dba-9fd0-0f23fa8a838e', 'راهنمای دفتر مجازی', 'ورود، وظیفهٔ امروز، گزارش روزانه و مرخصی از همین سامانه انجام می‌شود.', 'company', 2, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

SELECT setval(pg_get_serial_sequence('documents', 'id'), COALESCE((SELECT MAX(id) FROM documents), 1), true);

COMMIT;
