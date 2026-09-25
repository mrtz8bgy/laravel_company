-- Virtual Company OS — default company, roles, login accounts, sample projects, and HR.
-- Password for every account: 123456
-- Change it before any shared or production use.
-- hr_profiles in this file contains a fake national id and salary. Treat the file as sensitive.
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
    (11, '2026_09_25_150000_create_suite_tables', 1),
    (12, '2026_09_25_160000_create_portal_tables', 1),
    (13, '2026_09_25_160100_create_customer_ticket_tables', 1);

SELECT setval(pg_get_serial_sequence('migrations', 'id'), COALESCE((SELECT MAX(id) FROM migrations), 1), true);

-- users
INSERT INTO users (id, uuid, name, email, phone, avatar_path, locale, timezone, status, is_platform_admin, email_verified_at, password, last_login_at, last_login_ip, two_factor_secret, two_factor_recovery_codes, two_factor_confirmed_at, remember_token, created_at, updated_at) VALUES
    (1, 'f96ac4e4-9294-4bdc-aa00-f2d0ed41e075', 'Platform Admin', 'platform@virtual-company.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', true, '2026-09-25 21:32:45', '$2y$12$1OZcSHlrMPfq9oPAPd8Ep.winQ952Kqw0V6DrGBBX/kldqAv.JfvK', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (2, '9bcf9819-6fc6-4ca6-a81d-e8fe8bf2931e', 'سارا محمدی', 'ceo@ideban.test', '02191000000', NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-25 21:32:45', '$2y$12$Z79wckD7mNCk8X72kZQ3uuYuj/0/mqSAaiPTMupw4gv.XwG8pRoFu', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (3, '8a67473f-5894-459c-97b3-72a7401b716d', 'آرمان کاظمی', 'developer@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-25 21:32:46', '$2y$12$rfwNqj7fLvt8tAUaRSI9YOoz4M8HsFVjtsykg62nWBqY/7WCCJZpe', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (4, '6caba140-1e39-431a-be6a-b5febe15c777', 'نیلوفر رضایی', 'devops@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-25 21:32:46', '$2y$12$egnkKMaMdnbnIGLfkG3UJO5kTXYx4rpmDiF6Pc1iwF2/PXtkYeZ6K', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (5, '798df375-b455-4c43-89a8-7570f22c6da8', 'حسین مرادی', 'support@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-25 21:32:46', '$2y$12$qHH3q/bR9krvjH2mOBll1.UqZqAk629.qaQPEu4kLPnkf2EL8uysy', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-25 21:32:47', '2026-09-25 21:32:47'),
    (6, '9af7b002-8ba4-4e2b-a615-2f330a8af3b5', 'مریم حسینی', 'sales@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-25 21:32:47', '$2y$12$XG6qurts7uHnyBgcF8uPtONKMD.Md5S9CAfdwKBc49eb0.5Ge7ELG', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-25 21:32:47', '2026-09-25 21:32:47'),
    (7, '9a3579b8-381f-4c81-b2b0-585e21c2ce59', 'کیان نادری', 'marketing@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-25 21:32:47', '$2y$12$0dmcfD9XzyKBXQVaHowh7eXqGzyquNF8iJlHkJlGdePty/UdqJAKK', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-25 21:32:47', '2026-09-25 21:32:47'),
    (8, '863262b3-1242-4ac2-a51f-2eb98d8088fa', 'لیلا اکبری', 'finance@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-25 21:32:47', '$2y$12$xamzd.6hyYbXJCuoCCFiKebvmms.vNg4SJnD2rySPiQG9.JV6q2ve', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-25 21:32:47', '2026-09-25 21:32:47'),
    (9, '8129e41e-e936-47e9-92f9-94edce593188', 'رضا شریفی', 'hr@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-25 21:32:47', '$2y$12$z6qHomNkW4SbXfLvg7fMteo96.DQTU7g4CF8cmDgt0Ph7sFZRlK2m', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (10, '5d845fac-b56f-408f-89b0-06e64fd0b4f8', 'نگار احمدی', 'customer@ideban.test', '09120001111', NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-25 21:32:50', '$2y$12$/BKmjKz290xb15WLrDSYH.sHOyPq1rMOpJtoTJ0J.8EqODAklA49C', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-25 21:32:51', '2026-09-25 21:32:51'),
    (11, 'd55d9540-5820-4ce7-aab0-531afd547260', 'پارسا نعمتی', 'pending@ideban.test', '09120002222', NULL, 'fa', 'Asia/Tehran', 'active', false, '2026-09-25 21:32:51', '$2y$12$NZyj5R9sGsH/T2.xgxfchOOvK6c13J6Xq/fm4SL6HaKvT7qXY0gKe', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-25 21:32:51', '2026-09-25 21:32:51');

SELECT setval(pg_get_serial_sequence('users', 'id'), COALESCE((SELECT MAX(id) FROM users), 1), true);

-- permissions
INSERT INTO permissions (id, name, module, description, created_at, updated_at) VALUES
    (1, 'dashboard.view', 'core', 'View the workspace dashboard', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (2, 'company.view', 'organizations', 'View company profile', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (3, 'company.update', 'organizations', 'Update company profile', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (4, 'company.settings.manage', 'organizations', 'Manage company settings and work schedule', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (5, 'users.view', 'identity', 'View company directory', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (6, 'users.create', 'identity', 'Create company members', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (7, 'users.update', 'identity', 'Update company members', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (8, 'users.delete', 'identity', 'Remove company members', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (9, 'users.invite', 'identity', 'Invite people to the company', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (10, 'departments.view', 'organizations', 'View departments', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (11, 'departments.create', 'organizations', 'Create departments', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (12, 'departments.update', 'organizations', 'Update departments', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (13, 'departments.delete', 'organizations', 'Delete departments', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (14, 'teams.view', 'organizations', 'View teams', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (15, 'teams.create', 'organizations', 'Create teams', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (16, 'teams.update', 'organizations', 'Update teams', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (17, 'teams.delete', 'organizations', 'Delete teams', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (18, 'roles.view', 'access', 'View roles', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (19, 'roles.create', 'access', 'Create roles', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (20, 'roles.update', 'access', 'Update roles and grants', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (21, 'roles.delete', 'access', 'Delete custom roles', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (22, 'permissions.view', 'access', 'View the permission catalog', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (23, 'activity_logs.view', 'core', 'View the company activity log', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (24, 'profile.view', 'identity', 'View own profile', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (25, 'profile.update', 'identity', 'Update own profile', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (26, 'features.view', 'core', 'View feature flags', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (27, 'features.manage', 'core', 'Manage feature flags', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (28, 'attendance.clock', 'attendance', 'Clock in, clock out, and set own work status', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (29, 'attendance.view', 'attendance', 'View attendance for people in scope', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (30, 'attendance.correct', 'attendance', 'Correct attendance records', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (31, 'attendance.reports.submit', 'attendance', 'Submit own morning check-in and daily report', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (32, 'attendance.reports.view', 'attendance', 'Read daily reports in scope', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (33, 'projects.view', 'projects', 'View visible projects', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (34, 'projects.create', 'projects', 'Create projects', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (35, 'projects.update', 'projects', 'Update projects and columns', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (36, 'projects.delete', 'projects', 'Archive or delete projects', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (37, 'tasks.view', 'projects', 'View tasks on visible projects', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (38, 'tasks.create', 'projects', 'Create tasks', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (39, 'tasks.update', 'projects', 'Update own or assigned tasks', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (40, 'tasks.assign', 'projects', 'Assign and move any visible task', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (41, 'tasks.delete', 'projects', 'Delete tasks', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (42, 'hr.profile.view', 'hr', 'View employee HR profiles', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (43, 'hr.profile.update', 'hr', 'Update employee HR profiles', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (44, 'hr.salary.view', 'hr', 'View salary and national id', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (45, 'leave.request', 'hr', 'Submit own leave requests', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (46, 'leave.review', 'hr', 'Review leave requests in scope', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (47, 'mission.request', 'hr', 'Submit own mission requests', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (48, 'mission.review', 'hr', 'Review mission requests in scope', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (49, 'messages.view', 'communication', 'Read company channels and announcements', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (50, 'messages.send', 'communication', 'Send messages in visible channels', '2026-09-25 21:32:45', '2026-09-25 21:32:45');

INSERT INTO permissions (id, name, module, description, created_at, updated_at) VALUES
    (51, 'announcements.publish', 'communication', 'Publish company announcements', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (52, 'calendar.view', 'calendar', 'View visible events', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (53, 'calendar.manage', 'calendar', 'Create and update events', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (54, 'crm.view', 'crm', 'View accounts, contacts, and deals', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (55, 'crm.manage', 'crm', 'Manage the sales pipeline', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (56, 'marketing.view', 'marketing', 'View campaigns', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (57, 'marketing.manage', 'marketing', 'Manage campaigns', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (58, 'advertising.view', 'advertising', 'View advertising campaigns', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (59, 'advertising.manage', 'advertising', 'Manage advertising campaigns', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (60, 'finance.view', 'finance', 'View invoices and expenses', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (61, 'finance.manage', 'finance', 'Record invoices and expenses', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (62, 'tickets.create', 'operations', 'Open and follow own tickets', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (63, 'tickets.manage', 'operations', 'Triage every ticket', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (64, 'workflows.request', 'workflows', 'Submit an approval request', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (65, 'workflows.review', 'workflows', 'Review approval requests', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (66, 'documents.view', 'documents', 'Read visible documents', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (67, 'documents.manage', 'documents', 'Create and edit documents', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (68, 'analytics.view', 'analytics', 'View permitted company metrics', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (69, 'platform.companies.view', 'platform', 'View companies on the platform', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (70, 'platform.companies.manage', 'platform', 'Suspend or activate companies', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (71, 'customers.view', 'portal', 'View customer accounts', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (72, 'customers.review', 'portal', 'Approve or reject customer registration', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (73, 'products.view', 'portal', 'View the product catalog', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (74, 'products.manage', 'portal', 'Create and update products', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (75, 'customer_orders.view', 'portal', 'View customer orders', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (76, 'customer_orders.manage', 'portal', 'Update customer order status', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (77, 'customer_messages.view', 'portal', 'Read customer messages for a permitted desk', '2026-09-25 21:32:45', '2026-09-25 21:32:45'),
    (78, 'customer_messages.reply', 'portal', 'Reply to customer messages on a permitted desk', '2026-09-25 21:32:45', '2026-09-25 21:32:45');

SELECT setval(pg_get_serial_sequence('permissions', 'id'), COALESCE((SELECT MAX(id) FROM permissions), 1), true);

-- companies
INSERT INTO companies (id, uuid, name, legal_name, slug, status, timezone, locale, logo_path, plan, user_limit, settings, onboarded_at, created_at, updated_at) VALUES
    (1, '803a48ab-f04e-42a2-8ee9-c7b58a9eceb3', 'شبکه پردازان ایده‌بان الماس', 'شبکه پردازان ایده‌بان الماس', 'ideban-almas', 'active', 'Asia/Tehran', 'fa', NULL, NULL, NULL, '{"onboarding":{"departments":true,"teams":true,"invites":true,"schedule":true,"completed":true},"calendar":"jalali"}'::jsonb, '2026-09-25 21:32:48', '2026-09-25 21:32:45', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('companies', 'id'), COALESCE((SELECT MAX(id) FROM companies), 1), true);

-- departments
INSERT INTO departments (id, company_id, uuid, name, slug, code, description, manager_id, parent_id, is_active, sort_order, created_at, updated_at) VALUES
    (1, 1, '105ea40e-4412-448a-bd95-a31a78727d1c', 'مدیریت', 'management', 'MGT', NULL, 2, NULL, true, 0, '2026-09-25 21:32:46', '2026-09-25 21:32:48'),
    (2, 1, 'bba0ce69-176d-4d5a-a51b-e441e0c182ba', 'توسعه نرم‌افزار', 'software', 'DEV', NULL, 3, NULL, true, 1, '2026-09-25 21:32:46', '2026-09-25 21:32:48'),
    (3, 1, 'c138ccf8-72b8-4c70-91ab-a0b54ff170f8', 'دوآپس', 'devops', 'OPSINF', NULL, NULL, NULL, true, 2, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (4, 1, '33f82ff0-3e26-4954-8821-04fc2adb411d', 'عملیات و پشتیبانی', 'operations', 'OPS', NULL, NULL, NULL, true, 3, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (5, 1, 'cb0d9b1e-5019-4136-91e7-d5b1ceaee6d3', 'فروش', 'sales', 'SAL', NULL, 6, NULL, true, 4, '2026-09-25 21:32:46', '2026-09-25 21:32:48'),
    (6, 1, 'e5068ac6-052e-4cbc-8b41-373143934f27', 'بازاریابی', 'marketing', 'MKT', NULL, NULL, NULL, true, 5, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (7, 1, 'd8752d7f-8235-4112-a3a6-c24d4619889b', 'تبلیغات', 'advertising', 'ADV', NULL, NULL, NULL, true, 6, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (8, 1, 'b3245ee3-005f-4c73-8946-59dcb67972e3', 'مالی', 'finance', 'FIN', NULL, 8, NULL, true, 7, '2026-09-25 21:32:46', '2026-09-25 21:32:48'),
    (9, 1, 'b0d80a1f-0ebf-4a9c-ade0-ceefa487382e', 'منابع انسانی', 'hr', 'HR', NULL, 9, NULL, true, 8, '2026-09-25 21:32:46', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('departments', 'id'), COALESCE((SELECT MAX(id) FROM departments), 1), true);

-- company_user
INSERT INTO company_user (id, company_id, user_id, department_id, job_title, employee_code, status, is_owner, joined_at, created_at, updated_at) VALUES
    (1, 1, 2, NULL, 'مدیرعامل', NULL, 'active', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (2, 1, 3, 2, 'توسعه‌دهنده', 'DEV-01', 'active', false, '2026-09-25 21:32:46', '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (3, 1, 4, 3, 'مهندس دوآپس', 'OPS-01', 'active', false, '2026-09-25 21:32:46', '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (4, 1, 5, 4, 'کارشناس پشتیبانی', 'SUP-01', 'active', false, '2026-09-25 21:32:47', '2026-09-25 21:32:47', '2026-09-25 21:32:47'),
    (5, 1, 6, 5, 'مدیر فروش', 'SAL-01', 'active', false, '2026-09-25 21:32:47', '2026-09-25 21:32:47', '2026-09-25 21:32:47'),
    (6, 1, 7, 6, 'کارشناس بازاریابی', 'MKT-01', 'active', false, '2026-09-25 21:32:47', '2026-09-25 21:32:47', '2026-09-25 21:32:47'),
    (7, 1, 8, 8, 'مدیر مالی', 'FIN-01', 'active', false, '2026-09-25 21:32:47', '2026-09-25 21:32:47', '2026-09-25 21:32:47'),
    (8, 1, 9, 9, 'کارشناس منابع انسانی', 'HR-01', 'active', false, '2026-09-25 21:32:48', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (9, 1, 10, NULL, 'مشتری', NULL, 'active', false, '2026-09-25 21:32:51', '2026-09-25 21:32:51', '2026-09-25 21:32:51'),
    (10, 1, 11, NULL, 'مشتری', NULL, 'pending', false, '2026-09-25 21:32:51', '2026-09-25 21:32:51', '2026-09-25 21:32:51');

SELECT setval(pg_get_serial_sequence('company_user', 'id'), COALESCE((SELECT MAX(id) FROM company_user), 1), true);

-- teams
INSERT INTO teams (id, company_id, department_id, uuid, name, slug, description, leader_id, is_active, created_at, updated_at) VALUES
    (1, 1, 2, 'e31ab1d1-ba89-4e88-85ca-aab9845f77c4', 'تیم محصول', 'product', 'توسعه محصول‌های نرم‌افزاری شرکت', 3, true, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (2, 1, 3, '0cc8ff4c-fbcb-4401-adff-8d7f4d246407', 'تیم زیرساخت', 'infrastructure', NULL, 4, true, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (3, 1, 5, '7525ddcb-d131-419c-97c7-b6d8f64c78ca', 'میز فروش', 'sales-desk', NULL, 6, true, '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('teams', 'id'), COALESCE((SELECT MAX(id) FROM teams), 1), true);

-- team_user
INSERT INTO team_user (id, team_id, user_id, role, created_at, updated_at) VALUES
    (1, 1, 3, 'leader', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (2, 2, 4, 'leader', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (3, 3, 6, 'leader', '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('team_user', 'id'), COALESCE((SELECT MAX(id) FROM team_user), 1), true);

-- roles
INSERT INTO roles (id, company_id, uuid, name, slug, description, is_system, created_at, updated_at) VALUES
    (1, 1, 'ddde21b7-338b-4e44-8b5e-d402a3eaac79', 'مالک شرکت', 'company-owner', 'دسترسی کامل به شرکت', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (2, 1, 'ad1c6b3f-4fd0-4db2-a541-31905e2bb558', 'مدیرعامل', 'ceo', 'مشاهده و مدیریت کل شرکت', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (3, 1, 'f7957cbf-fc1b-40eb-b9fa-abb1c62e6de1', 'مدیر واحد', 'department-manager', 'مدیریت تیم‌های واحد و مشاهده اعضا', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (4, 1, 'e2660d26-4469-488e-959b-04e541afb6af', 'سرپرست تیم', 'team-leader', 'مشاهده تیم و همکاران', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (5, 1, 'c0584d29-ae35-4dd5-8873-39f67e3a2f5c', 'کارمند', 'employee', 'فضای کاری شخصی و مشاهده ساختار مجاز', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (6, 1, '1aff5eb3-86c2-4e9f-8933-ca96bd71e2ca', 'منابع انسانی', 'hr', 'مدیریت اعضا و دعوت‌ها', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (7, 1, 'a1c2732d-ea0e-44eb-93fc-7512874a2bc8', 'فروش', 'sales', 'دسترسی پایه تا فعال شدن ماژول فروش', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (8, 1, 'bb9e26ec-2d1b-4cb2-a8f5-aa1b76ac83a0', 'بازاریابی', 'marketing', 'دسترسی پایه تا فعال شدن ماژول بازاریابی', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (9, 1, '8ec33ebc-4807-4b9e-a4d4-fa0d0de502fc', 'مالی', 'finance', 'دفتر مالی شرکت', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (10, 1, '4a011fc8-36fa-48d4-9e7c-40b2a448a678', 'مشتری', 'client', 'صفحه شخصی، سفارش و پیام پس از تأیید مدیر', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46');

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
    (1, 71),
    (1, 72),
    (1, 73),
    (1, 74),
    (1, 75),
    (1, 76),
    (1, 77),
    (1, 78),
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
    (2, 24);

INSERT INTO role_permissions (role_id, permission_id) VALUES
    (2, 25),
    (2, 26),
    (2, 27),
    (2, 28),
    (2, 29),
    (2, 30),
    (2, 31),
    (2, 32),
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
    (2, 71),
    (2, 72),
    (2, 73),
    (2, 74),
    (2, 75),
    (2, 76);

INSERT INTO role_permissions (role_id, permission_id) VALUES
    (2, 77),
    (2, 78),
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
    (3, 45),
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
    (3, 71),
    (3, 72),
    (3, 73),
    (3, 74),
    (3, 75),
    (3, 76),
    (3, 77),
    (3, 78),
    (4, 1);

INSERT INTO role_permissions (role_id, permission_id) VALUES
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
    (4, 66),
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
    (6, 10);

INSERT INTO role_permissions (role_id, permission_id) VALUES
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
    (6, 71),
    (6, 72),
    (6, 49),
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
    (7, 52);

INSERT INTO role_permissions (role_id, permission_id) VALUES
    (7, 62),
    (7, 64),
    (7, 66),
    (7, 54),
    (7, 55),
    (7, 71),
    (7, 73),
    (7, 75),
    (7, 76),
    (7, 77),
    (7, 78),
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
    (8, 66),
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
    (9, 45);

INSERT INTO role_permissions (role_id, permission_id) VALUES
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
    (10, 24),
    (10, 25);

-- user_roles
INSERT INTO user_roles (id, company_id, user_id, role_id, created_at, updated_at) VALUES
    (1, 1, 2, 1, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (2, 1, 3, 4, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (3, 1, 4, 5, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (4, 1, 5, 5, '2026-09-25 21:32:47', '2026-09-25 21:32:47'),
    (5, 1, 6, 3, '2026-09-25 21:32:47', '2026-09-25 21:32:47'),
    (6, 1, 6, 7, '2026-09-25 21:32:47', '2026-09-25 21:32:47'),
    (7, 1, 7, 8, '2026-09-25 21:32:47', '2026-09-25 21:32:47'),
    (8, 1, 8, 3, '2026-09-25 21:32:47', '2026-09-25 21:32:47'),
    (9, 1, 8, 9, '2026-09-25 21:32:47', '2026-09-25 21:32:47'),
    (10, 1, 9, 6, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (11, 1, 10, 10, '2026-09-25 21:32:51', '2026-09-25 21:32:51'),
    (12, 1, 11, 10, '2026-09-25 21:32:51', '2026-09-25 21:32:51');

SELECT setval(pg_get_serial_sequence('user_roles', 'id'), COALESCE((SELECT MAX(id) FROM user_roles), 1), true);

-- work_schedules
INSERT INTO work_schedules (id, company_id, weekday, is_working_day, start_time, end_time, break_minutes, grace_minutes, created_at, updated_at) VALUES
    (1, 1, 0, true, '09:00', '17:00', 60, 15, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (2, 1, 1, true, '09:00', '17:00', 60, 15, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (3, 1, 2, true, '09:00', '17:00', 60, 15, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (4, 1, 3, true, '09:00', '17:00', 60, 15, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (5, 1, 4, true, '09:00', '17:00', 60, 15, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (6, 1, 5, false, '09:00', '17:00', 60, 15, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (7, 1, 6, true, '09:00', '17:00', 60, 15, '2026-09-25 21:32:46', '2026-09-25 21:32:46');

SELECT setval(pg_get_serial_sequence('work_schedules', 'id'), COALESCE((SELECT MAX(id) FROM work_schedules), 1), true);

-- features
INSERT INTO features (id, company_id, key, enabled, created_at, updated_at) VALUES
    (1, 1, 'foundation', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (2, 1, 'attendance', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (3, 1, 'projects', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (4, 1, 'hr', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (5, 1, 'communication', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (6, 1, 'calendar', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (7, 1, 'crm', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (8, 1, 'marketing', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (9, 1, 'advertising', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (10, 1, 'finance', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (11, 1, 'operations', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (12, 1, 'workflows', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (13, 1, 'documents', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (14, 1, 'analytics', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46'),
    (15, 1, 'portal', true, '2026-09-25 21:32:46', '2026-09-25 21:32:46');

SELECT setval(pg_get_serial_sequence('features', 'id'), COALESCE((SELECT MAX(id) FROM features), 1), true);

-- projects
INSERT INTO projects (id, company_id, uuid, name, slug, code, description, status, visibility, department_id, owner_id, start_date, due_date, created_at, updated_at) VALUES
    (1, 1, 'e3b8f2d8-b203-424b-a9fd-4d1b7bcac121', 'فروشگاه', 'shop', 'SHOP', 'فروش آنلاین و هماهنگی کاتالوگ', 'active', 'company', 5, 2, NULL, '2026-10-25 00:00:00', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (2, 1, 'dc33ce45-bdfb-42f6-ba0a-4adb0c292347', 'دفتر مجازی', 'virtual-office', 'VOFFICE', 'حضور، وظیفه و گزارش روزانهٔ شرکت مجازی', 'active', 'company', 2, 2, NULL, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('projects', 'id'), COALESCE((SELECT MAX(id) FROM projects), 1), true);

-- project_members
INSERT INTO project_members (id, company_id, project_id, user_id, role, created_at, updated_at) VALUES
    (1, 1, 1, 2, 'manager', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (2, 1, 2, 2, 'manager', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (3, 1, 1, 6, 'member', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (4, 1, 1, 7, 'member', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (5, 1, 2, 3, 'manager', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (6, 1, 2, 4, 'member', '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('project_members', 'id'), COALESCE((SELECT MAX(id) FROM project_members), 1), true);

-- kanban_columns
INSERT INTO kanban_columns (id, company_id, project_id, uuid, name, sort_order, is_done, created_at, updated_at) VALUES
    (1, 1, 1, 'c6e72e8e-ab0f-44e6-b3e4-56ec26b71a0d', 'صف انتظار', 0, false, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (2, 1, 1, '66ca5915-df7e-4d53-a576-49a11fae096f', 'در حال انجام', 1, false, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (3, 1, 1, '54443d02-cf93-488b-a89f-3415c9d5a428', 'بازبینی', 2, false, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (4, 1, 1, '4204e6d2-4f7d-46af-8aff-ec9d8a84399a', 'انجام شد', 3, true, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (5, 1, 2, 'e8dbf12e-a490-42b1-bef1-ecffde847605', 'صف انتظار', 0, false, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (6, 1, 2, 'b2ea1d77-cd02-441b-b6f3-25993c5f3fa5', 'در حال انجام', 1, false, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (7, 1, 2, '365edaa3-9f78-4fbb-a864-3bf85001549c', 'بازبینی', 2, false, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (8, 1, 2, 'b7587d93-f5bb-48b2-9e39-c967cfe122ba', 'انجام شد', 3, true, '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('kanban_columns', 'id'), COALESCE((SELECT MAX(id) FROM kanban_columns), 1), true);

-- tasks
INSERT INTO tasks (id, company_id, project_id, column_id, uuid, title, description, priority, assignee_id, reporter_id, due_date, sort_order, completed_at, created_at, updated_at) VALUES
    (1, 1, 1, 1, '95fe1efb-459c-4a9f-9955-fbc7f4a31cca', 'آماده‌سازی کاتالوگ پاییز', NULL, 'high', 6, 2, '2026-09-26 00:00:00', 1, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (2, 1, 2, 5, '9d54b460-f4b3-4ba1-b0e4-04277d59600d', 'برد کانبان دفتر مجازی', NULL, 'high', 3, 2, '2026-09-26 00:00:00', 1, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (3, 1, 2, 5, 'cc00f4d1-1e52-4dc9-86e2-ca0269b2b22b', 'پایدارسازی سرویس حضور', NULL, 'normal', 4, 2, '2026-09-26 00:00:00', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (4, 1, 2, 5, '924434c2-a9a7-43ce-a7bc-5d62855e3ab2', 'جمع‌بندی گزارش کار هفته', 'گزارش ساعت و تأخیر هفته را برای مدیرعامل جمع کنید.', 'high', 3, 2, '2026-09-28 00:00:00', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (5, 1, 2, 8, 'f55580e2-afa4-483c-abaf-3681bfbbfda8', 'بستن گزارش روزانه پنجشنبه', 'گزارش روزانه ثبت و تحویل شد.', 'normal', 3, 2, '2026-09-23 00:00:00', 1, '2026-09-25 00:00:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (6, 1, 2, 5, '8815008f-2dc0-4812-a724-cb6ff9ffcf18', 'بررسی تأخیر ورود', 'ساعت ورود دو روز اخیر را با مدیر هماهنگ کنید.', 'high', 4, 2, '2026-09-24 00:00:00', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (7, 1, 2, 5, 'cc9b9d08-38b4-4b24-8667-630888c40af4', 'پاسخ تیکت‌های باز صبح', 'تیکت‌های بدون پاسخ را تا پایان شیفت ببندید.', 'normal', 5, 2, '2026-09-27 00:00:00', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (8, 1, 1, 1, 'c58e44b7-cabe-4f2b-9f18-f43eed601473', 'پیگیری پیش‌فاکتور مشتری', 'پیش‌فاکتور را برای مشتری ارسال کنید.', 'high', 6, 2, '2026-09-29 00:00:00', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (9, 1, 1, 1, 'fb2261e6-0dc8-4fe9-97f7-e380459d2cff', 'به‌روزرسانی متن کمپین', 'متن کمپین پاییز را با فروش هماهنگ کنید.', 'normal', 7, 2, '2026-09-30 00:00:00', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (10, 1, 1, 1, 'c12f2f39-2a08-4903-a241-0014a4065ef3', 'ثبت هزینهٔ جلسه مشتری', 'هزینه را در مالی ثبت کنید. مبلغ نمونه است.', 'normal', 8, 2, '2026-09-27 00:00:00', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (11, 1, 2, 5, '09933204-813f-403a-9ea2-bd2463916eb4', 'تکمیل پروندهٔ حضور ماه', 'مرخصی و مأموریت‌های باز را بررسی کنید.', 'normal', 9, 2, '2026-10-01 00:00:00', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50');

SELECT setval(pg_get_serial_sequence('tasks', 'id'), COALESCE((SELECT MAX(id) FROM tasks), 1), true);

-- hr_profiles
INSERT INTO hr_profiles (id, company_id, user_id, hire_date, employment_type, national_id, emergency_name, emergency_phone, salary_amount, salary_currency, notes, created_at, updated_at) VALUES
    (1, 1, 3, '2024-03-01 00:00:00', 'full_time', '0087654321', 'خانواده کاظمی', '09120000000', 850000000, 'IRR', NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('hr_profiles', 'id'), COALESCE((SELECT MAX(id) FROM hr_profiles), 1), true);

-- leave_requests
INSERT INTO leave_requests (id, company_id, uuid, user_id, type, starts_on, ends_on, reason, status, reviewer_id, reviewed_at, review_note, created_at, updated_at) VALUES
    (1, 1, '0fdabe07-3d50-4f53-ab4f-d78e184e9ac1', 4, 'annual', '2026-09-26 00:00:00', '2026-09-26 00:00:00', 'مرخصی استحقاقی نمونه', 'pending', NULL, NULL, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('leave_requests', 'id'), COALESCE((SELECT MAX(id) FROM leave_requests), 1), true);

-- mission_requests
INSERT INTO mission_requests (id, company_id, uuid, user_id, destination, starts_on, ends_on, purpose, status, reviewer_id, reviewed_at, review_note, created_at, updated_at) VALUES
    (1, 1, '02bb25da-5792-4597-850a-a46c35ec30e0', 6, 'دفتر مشتری، تهران', '2026-09-26 00:00:00', '2026-09-26 00:00:00', 'جلسه معرفی فروشگاه', 'pending', NULL, NULL, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('mission_requests', 'id'), COALESCE((SELECT MAX(id) FROM mission_requests), 1), true);

-- channels
INSERT INTO channels (id, company_id, uuid, name, slug, kind, created_at, updated_at) VALUES
    (1, 1, 'eec84ad6-0692-45c4-99a8-7490b1c528b5', 'عمومی', 'general', 'company', '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('channels', 'id'), COALESCE((SELECT MAX(id) FROM channels), 1), true);

-- messages
INSERT INTO messages (id, company_id, channel_id, user_id, uuid, body, created_at, updated_at) VALUES
    (1, 1, 1, 2, '2de00e41-37fd-4d14-b4d0-9d814fbe7795', 'صبح بخیر. اولویت امروز: فروشگاه و دفتر مجازی.', '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('messages', 'id'), COALESCE((SELECT MAX(id) FROM messages), 1), true);

-- announcements
INSERT INTO announcements (id, company_id, uuid, title, body, author_id, created_at, updated_at) VALUES
    (1, 1, '9e391ce9-062a-4d24-aa28-635244be265a', 'شروع هفته', 'جلسهٔ هماهنگی ساعت ۱۰ در تقویم شرکت است.', 2, '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('announcements', 'id'), COALESCE((SELECT MAX(id) FROM announcements), 1), true);

-- events
INSERT INTO events (id, company_id, uuid, title, location, starts_at, ends_at, visibility, owner_id, created_at, updated_at) VALUES
    (1, 1, 'aec1b4b4-f84a-4560-840e-e74feeaa6e81', 'هماهنگی هفتگی', 'اتاق مجازی', '2026-09-26 10:00:00', '2026-09-26 11:00:00', 'company', 2, '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('events', 'id'), COALESCE((SELECT MAX(id) FROM events), 1), true);

-- crm_accounts
INSERT INTO crm_accounts (id, company_id, uuid, name, status, created_at, updated_at) VALUES
    (1, 1, '7b9af106-b66d-4b6e-8fb5-842f52ba2941', 'خانهٔ کتاب', 'active', '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('crm_accounts', 'id'), COALESCE((SELECT MAX(id) FROM crm_accounts), 1), true);

-- crm_contacts
INSERT INTO crm_contacts (id, company_id, uuid, account_id, name, email, phone, created_at, updated_at) VALUES
    (1, 1, '1b22bea2-455f-4556-9b18-6b258ca3c9f4', 1, 'نگار سلیمانی', 'negar@example.test', '02144000000', '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('crm_contacts', 'id'), COALESCE((SELECT MAX(id) FROM crm_contacts), 1), true);

-- crm_deals
INSERT INTO crm_deals (id, company_id, uuid, account_id, title, stage, amount, currency, owner_id, created_at, updated_at) VALUES
    (1, 1, '2984c02e-8a96-4cf7-8f93-5176ea5f8093', 1, 'قرارداد فروشگاه', 'proposal', 240000000, 'IRR', 6, '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('crm_deals', 'id'), COALESCE((SELECT MAX(id) FROM crm_deals), 1), true);

-- campaigns
INSERT INTO campaigns (id, company_id, uuid, name, channel, status, budget_amount, currency, starts_on, ends_on, created_at, updated_at) VALUES
    (1, 1, '8cbdaae5-5c39-43ed-a8e9-8ae61f66c8ce', 'کمپین پاییز', 'social', 'active', 80000000, 'IRR', '2026-09-25 00:00:00', '2026-10-25 00:00:00', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (2, 1, '87df7eb3-4194-48bd-9508-1eeab23ca0a0', 'تبلیغ جستجو', 'ads', 'draft', 45000000, 'IRR', NULL, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('campaigns', 'id'), COALESCE((SELECT MAX(id) FROM campaigns), 1), true);

-- invoices
INSERT INTO invoices (id, company_id, uuid, number, party_name, amount, currency, status, issued_on, due_on, created_at, updated_at) VALUES
    (1, 1, '1f52037d-9e7a-49a3-9965-efe51d575517', 'INV-1405-001', 'خانهٔ کتاب', 120000000, 'IRR', 'sent', '2026-09-25 00:00:00', '2026-10-09 00:00:00', '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('invoices', 'id'), COALESCE((SELECT MAX(id) FROM invoices), 1), true);

-- expenses
INSERT INTO expenses (id, company_id, uuid, category, amount, currency, status, spent_on, note, created_at, updated_at) VALUES
    (1, 1, 'a9b3d69e-4f70-4796-aa2d-d6f184c5c484', 'زیرساخت', 18000000, 'IRR', 'recorded', '2026-09-25 00:00:00', 'هزینهٔ نمونه', '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('expenses', 'id'), COALESCE((SELECT MAX(id) FROM expenses), 1), true);

-- tickets
INSERT INTO tickets (id, company_id, uuid, subject, body, status, priority, requester_id, assignee_id, created_at, updated_at) VALUES
    (1, 1, '372d6b55-8adc-4603-8122-952a24c4d3e4', 'دسترسی گزارش روزانه', 'همکار جدید صفحهٔ حضور را نمی‌بیند.', 'open', 'high', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('tickets', 'id'), COALESCE((SELECT MAX(id) FROM tickets), 1), true);

-- approvals
INSERT INTO approvals (id, company_id, uuid, title, kind, status, requester_id, reviewer_id, note, review_note, reviewed_at, created_at, updated_at) VALUES
    (1, 1, '66678025-ddef-4cd1-a315-c8590f1e2660', 'خرید دامنهٔ فروشگاه', 'purchase', 'pending', 3, NULL, 'تمدید یک‌ساله', NULL, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('approvals', 'id'), COALESCE((SELECT MAX(id) FROM approvals), 1), true);

-- documents
INSERT INTO documents (id, company_id, uuid, title, body, visibility, author_id, created_at, updated_at) VALUES
    (1, 1, 'db234210-208a-40fb-97b4-9b4f67234e4a', 'راهنمای دفتر مجازی', 'ورود، وظیفهٔ امروز، گزارش روزانه و مرخصی از همین سامانه انجام می‌شود.', 'company', 2, '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('documents', 'id'), COALESCE((SELECT MAX(id) FROM documents), 1), true);

-- customers
INSERT INTO customers (id, company_id, uuid, user_id, status, organization_name, phone, note, review_note, reviewer_id, reviewed_at, created_at, updated_at) VALUES
    (1, 1, '209f6b8c-6905-439a-b0df-4c3c8248b175', 10, 'active', 'آتیه‌سازان نمونه', '09120001111', NULL, 'مشتری نمونه تأیید شد.', 2, '2026-09-25 21:32:51', '2026-09-25 21:32:51', '2026-09-25 21:32:51'),
    (2, 1, '6c5c00ab-d082-45a0-8378-8cd6cffcb7ba', 11, 'pending', 'بازرگانی در انتظار', '09120002222', NULL, NULL, NULL, NULL, '2026-09-25 21:32:51', '2026-09-25 21:32:51');

SELECT setval(pg_get_serial_sequence('customers', 'id'), COALESCE((SELECT MAX(id) FROM customers), 1), true);

-- products
INSERT INTO products (id, company_id, uuid, name, sku, description, unit_price, currency, stock, is_active, created_at, updated_at) VALUES
    (1, 1, 'ea9e4d20-c5ef-466b-af5c-ad0ff4374da0', 'بسته راه‌اندازی شبکه', 'NET-SETUP', 'طراحی و راه‌اندازی شبکه دفتر.', 185000000, 'IRR', 11, true, '2026-09-25 21:32:50', '2026-09-25 21:32:51'),
    (2, 1, '7cae438d-95e6-4d0f-aa95-37ed1d36fc75', 'پشتیبانی سالانه', 'SUP-YEAR', 'پشتیبانی نرم‌افزار و شبکه برای یک سال.', 96000000, 'IRR', NULL, true, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (3, 1, '864ff431-2888-4494-ac42-84d98cb40616', 'مشاوره حضوری', 'CON-VISIT', 'یک جلسه مشاوره در تهران.', 25000000, 'IRR', 40, true, '2026-09-25 21:32:50', '2026-09-25 21:32:50');

SELECT setval(pg_get_serial_sequence('products', 'id'), COALESCE((SELECT MAX(id) FROM products), 1), true);

-- customer_orders
INSERT INTO customer_orders (id, company_id, uuid, customer_id, number, status, note, staff_note, total_amount, currency, reviewer_id, reviewed_at, created_at, updated_at) VALUES
    (1, 1, '7aa0fc4e-0b65-4189-80f8-0522f9899a11', 1, 'ORD-0001', 'submitted', 'راه‌اندازی دفتر و پشتیبانی سال اول.', NULL, 281000000, 'IRR', NULL, NULL, '2026-09-25 21:32:51', '2026-09-25 21:32:51');

SELECT setval(pg_get_serial_sequence('customer_orders', 'id'), COALESCE((SELECT MAX(id) FROM customer_orders), 1), true);

-- customer_order_items
INSERT INTO customer_order_items (id, company_id, order_id, product_id, name, quantity, unit_price, line_total, created_at, updated_at) VALUES
    (1, 1, 1, 1, 'بسته راه‌اندازی شبکه', 1, 185000000, 185000000, '2026-09-25 21:32:51', '2026-09-25 21:32:51'),
    (2, 1, 1, 2, 'پشتیبانی سالانه', 1, 96000000, 96000000, '2026-09-25 21:32:51', '2026-09-25 21:32:51');

SELECT setval(pg_get_serial_sequence('customer_order_items', 'id'), COALESCE((SELECT MAX(id) FROM customer_order_items), 1), true);

-- customer_threads
INSERT INTO customer_threads (id, company_id, uuid, customer_id, desk, subject, status, created_at, updated_at) VALUES
    (1, 1, '75fc0b49-6de0-41fe-82f1-416585be0c1d', 1, 'sales', 'هماهنگی تحویل سفارش', 'open', '2026-09-25 21:32:51', '2026-09-25 21:32:51'),
    (2, 1, '5dc2add9-293b-42ad-a6c4-7673d072f4ad', 1, 'support', 'سؤال درباره پشتیبانی', 'open', '2026-09-25 21:32:51', '2026-09-25 21:32:51');

SELECT setval(pg_get_serial_sequence('customer_threads', 'id'), COALESCE((SELECT MAX(id) FROM customer_threads), 1), true);

-- customer_thread_messages
INSERT INTO customer_thread_messages (id, company_id, thread_id, user_id, body, is_staff, created_at, updated_at) VALUES
    (1, 1, 1, 10, 'لطفاً زمان نصب را با واحد فروش هماهنگ کنید.', false, '2026-09-25 21:32:51', '2026-09-25 21:32:51'),
    (2, 1, 2, 10, 'ساعت پاسخ‌گویی پشتیبانی را اعلام کنید.', false, '2026-09-25 21:32:51', '2026-09-25 21:32:51');

SELECT setval(pg_get_serial_sequence('customer_thread_messages', 'id'), COALESCE((SELECT MAX(id) FROM customer_thread_messages), 1), true);

-- customer_tickets
INSERT INTO customer_tickets (id, company_id, uuid, customer_id, number, desk, subject, priority, status, created_at, updated_at) VALUES
    (1, 1, '2e72c866-3abe-448d-80ee-a9b600e45520', 1, 'TKT-0001', 'support', 'درخواست پیگیری نصب', 'high', 'open', '2026-09-25 21:32:51', '2026-09-25 21:32:51'),
    (2, 1, '6bac438d-510e-44f2-a4af-69adee2b9ad5', 1, 'TKT-0002', 'management', 'درخواست جلسه با مدیریت', 'normal', 'open', '2026-09-25 21:32:51', '2026-09-25 21:32:51');

SELECT setval(pg_get_serial_sequence('customer_tickets', 'id'), COALESCE((SELECT MAX(id) FROM customer_tickets), 1), true);

-- customer_ticket_messages
INSERT INTO customer_ticket_messages (id, company_id, ticket_id, user_id, body, is_staff, created_at, updated_at) VALUES
    (1, 1, 1, 10, 'لطفاً این مورد را به صورت تیکت پیگیری کنید.', false, '2026-09-25 21:32:51', '2026-09-25 21:32:51'),
    (2, 1, 2, 10, 'برای تمدید قرارداد یک جلسه کوتاه می‌خواهیم.', false, '2026-09-25 21:32:51', '2026-09-25 21:32:51');

SELECT setval(pg_get_serial_sequence('customer_ticket_messages', 'id'), COALESCE((SELECT MAX(id) FROM customer_ticket_messages), 1), true);

-- attendance_days
INSERT INTO attendance_days (id, company_id, uuid, user_id, work_date, location, day_status, check_in_at, check_out_at, late_minutes, worked_minutes, break_minutes, expected_minutes, excused, note, created_at, updated_at) VALUES
    (1, 1, '7cdc115c-a967-4ac9-8835-b396d78bd836', 2, '2026-09-26 00:00:00', 'office', 'open', '2026-09-25 21:32:48', NULL, 0, 0, 0, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (2, 1, '973a593f-0aaf-4e47-a72f-86f604555f59', 3, '2026-09-26 00:00:00', 'remote', 'open', '2026-09-25 21:32:48', NULL, 0, 0, 0, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (3, 1, '00c20ace-42d6-4a04-aa4e-95c48f468575', 4, '2026-09-26 00:00:00', 'office', 'open', '2026-09-25 21:32:48', NULL, 0, 0, 0, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (4, 1, '4ba81535-0529-4119-a977-0215a2db1f7c', 6, '2026-09-26 00:00:00', 'office', 'marked', NULL, NULL, 0, 0, 0, 420, true, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (5, 1, 'dd28586a-793c-4f9d-a833-68a440c59aa2', 9, '2026-09-26 00:00:00', 'office', 'marked', NULL, NULL, 0, 0, 0, 420, true, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (6, 1, '4e6e5173-5dc4-4a2a-a43a-7a17ac24f3c0', 2, '2026-09-05 00:00:00', 'office', 'closed', '2026-09-05 05:20:00', '2026-09-05 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (7, 1, '2d1e2622-d3d7-4928-9237-1f2f069c87c3', 3, '2026-09-05 00:00:00', 'remote', 'closed', '2026-09-05 05:58:00', '2026-09-05 13:50:00', 13, 417, 55, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (8, 1, '5bb2426e-f892-4d50-871f-2923275c4b86', 4, '2026-09-05 00:00:00', 'office', 'closed', '2026-09-05 05:34:00', '2026-09-05 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (9, 1, '3c3cf863-b05d-4267-a5b5-89ca5f2ac84b', 5, '2026-09-05 00:00:00', 'office', 'closed', '2026-09-05 05:58:00', '2026-09-05 13:35:00', 13, 397, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (10, 1, '7badb763-cbb6-4f0d-8577-9a387b5f1ea1', 6, '2026-09-05 00:00:00', 'office', 'closed', '2026-09-05 05:30:00', '2026-09-05 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (11, 1, 'd5ccdbcb-854f-4aba-8e14-94303b98705f', 7, '2026-09-05 00:00:00', 'office', 'closed', '2026-09-05 05:42:00', '2026-09-05 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (12, 1, '79f214ed-03f2-47fc-9ca7-39a18e20bd55', 8, '2026-09-05 00:00:00', 'office', 'closed', '2026-09-05 05:25:00', '2026-09-05 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (13, 1, 'b323d774-3dfc-4056-8e0d-25e076e74322', 9, '2026-09-05 00:00:00', 'office', 'closed', '2026-09-05 05:31:00', '2026-09-05 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (14, 1, 'f9a27b60-36ff-4203-9384-eb6e0764955e', 2, '2026-09-06 00:00:00', 'office', 'closed', '2026-09-06 05:20:00', '2026-09-06 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (15, 1, 'de80e815-d16e-4304-bf0d-236890653ee9', 3, '2026-09-06 00:00:00', 'remote', 'closed', '2026-09-06 05:36:00', '2026-09-06 13:50:00', 0, 439, 55, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (16, 1, '1b5e4125-3a6d-4bd0-ab83-68587578ea64', 4, '2026-09-06 00:00:00', 'office', 'closed', '2026-09-06 05:34:00', '2026-09-06 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (17, 1, '8d3a0698-f6ad-4b6f-b004-fb9aabfdff48', 5, '2026-09-06 00:00:00', 'office', 'closed', '2026-09-06 05:38:00', '2026-09-06 13:35:00', 0, 417, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (18, 1, '1a576c47-88f0-4a8f-9244-f1e1006c6460', 6, '2026-09-06 00:00:00', 'office', 'closed', '2026-09-06 05:30:00', '2026-09-06 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (19, 1, '8888f748-fa34-4f94-8791-bf1ee3393c35', 7, '2026-09-06 00:00:00', 'office', 'closed', '2026-09-06 05:42:00', '2026-09-06 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (20, 1, 'df4fb429-aee1-452d-a9e8-3808ff5ac325', 8, '2026-09-06 00:00:00', 'office', 'closed', '2026-09-06 05:25:00', '2026-09-06 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (21, 1, '30541103-b462-42a3-bf52-b51706240451', 9, '2026-09-06 00:00:00', 'office', 'closed', '2026-09-06 05:31:00', '2026-09-06 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (22, 1, '190552cd-d9a8-442a-b8db-95ef414a70f9', 2, '2026-09-07 00:00:00', 'office', 'closed', '2026-09-07 05:20:00', '2026-09-07 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (23, 1, 'ac0fb9f5-e92e-460f-a11b-4851e926f046', 3, '2026-09-07 00:00:00', 'remote', 'closed', '2026-09-07 05:36:00', '2026-09-07 13:50:00', 0, 439, 55, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (24, 1, 'b23f6c18-cb7c-486f-aaea-6fd29c1ee384', 4, '2026-09-07 00:00:00', 'office', 'closed', '2026-09-07 05:34:00', '2026-09-07 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (25, 1, '713e4846-ed25-4d59-a5ae-2610131b9f9a', 5, '2026-09-07 00:00:00', 'office', 'closed', '2026-09-07 05:38:00', '2026-09-07 13:35:00', 0, 417, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (26, 1, 'd50e24bd-e217-4ed4-8570-d9ee5c155837', 6, '2026-09-07 00:00:00', 'office', 'closed', '2026-09-07 05:30:00', '2026-09-07 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (27, 1, '70da02e1-d779-4205-ad52-bfdc3a87ac22', 7, '2026-09-07 00:00:00', 'office', 'closed', '2026-09-07 05:42:00', '2026-09-07 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (28, 1, 'eeb1e981-cde7-4ce4-bcc1-a9d1903f279f', 8, '2026-09-07 00:00:00', 'office', 'closed', '2026-09-07 05:25:00', '2026-09-07 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (29, 1, '4ad74ba7-e7c1-4291-9d3b-20092a13085b', 9, '2026-09-07 00:00:00', 'office', 'closed', '2026-09-07 05:31:00', '2026-09-07 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (30, 1, 'ddb1679a-1c88-4e56-b300-16143f2c2785', 2, '2026-09-08 00:00:00', 'office', 'closed', '2026-09-08 05:20:00', '2026-09-08 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (31, 1, '441231e8-f852-4bfe-9223-8afe0ee6e177', 3, '2026-09-08 00:00:00', 'remote', 'closed', '2026-09-08 05:36:00', '2026-09-08 13:50:00', 0, 439, 55, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (32, 1, 'dd71beaf-ec43-4911-9bc3-d2f7a105275e', 4, '2026-09-08 00:00:00', 'office', 'closed', '2026-09-08 05:34:00', '2026-09-08 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (33, 1, 'f854f054-fefe-403a-894d-ef0f72ff7a12', 5, '2026-09-08 00:00:00', 'office', 'closed', '2026-09-08 05:38:00', '2026-09-08 13:35:00', 0, 417, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (34, 1, '3da43e43-9c00-40c6-b13c-435911b618cd', 6, '2026-09-08 00:00:00', 'office', 'marked', NULL, NULL, 0, 0, 0, 420, true, 'مأموریت مشتری', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (35, 1, '6c476a30-d1be-4216-8949-89b5c39c87da', 7, '2026-09-08 00:00:00', 'office', 'closed', '2026-09-08 05:42:00', '2026-09-08 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (36, 1, '4a044525-a756-4f6b-b273-e8cbd0bb0a88', 8, '2026-09-08 00:00:00', 'office', 'closed', '2026-09-08 05:25:00', '2026-09-08 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (37, 1, '9267552d-60e9-4fba-9637-8ce217e4fb72', 9, '2026-09-08 00:00:00', 'office', 'closed', '2026-09-08 05:31:00', '2026-09-08 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (38, 1, 'fc4252bb-97aa-46e4-85e6-4de3b56faeb4', 2, '2026-09-09 00:00:00', 'office', 'closed', '2026-09-09 05:20:00', '2026-09-09 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (39, 1, '65f90618-db71-4261-be8f-5e0d32370af7', 3, '2026-09-09 00:00:00', 'remote', 'closed', '2026-09-09 05:36:00', '2026-09-09 13:50:00', 0, 439, 55, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (40, 1, '243c98a9-42cb-49ee-8cd6-f53aae025b01', 4, '2026-09-09 00:00:00', 'office', 'closed', '2026-09-09 05:34:00', '2026-09-09 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (41, 1, '1c1b1293-ef8f-430e-b30f-61be5b8a75ff', 5, '2026-09-09 00:00:00', 'office', 'closed', '2026-09-09 05:58:00', '2026-09-09 13:35:00', 13, 397, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (42, 1, '64072567-f043-4db1-86fe-ce9b201df501', 6, '2026-09-09 00:00:00', 'office', 'closed', '2026-09-09 05:30:00', '2026-09-09 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (43, 1, '5e8b8120-2fb9-43ca-ad5b-5c021f5a99b7', 7, '2026-09-09 00:00:00', 'office', 'closed', '2026-09-09 05:42:00', '2026-09-09 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (44, 1, 'f4a88605-6821-4611-b3ee-6a7f37deb5c6', 8, '2026-09-09 00:00:00', 'office', 'closed', '2026-09-09 05:25:00', '2026-09-09 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (45, 1, '4c5da49f-d83b-40b2-88b1-ccb3326288f3', 9, '2026-09-09 00:00:00', 'office', 'closed', '2026-09-09 05:31:00', '2026-09-09 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (46, 1, '09124fd3-2d83-4da1-a780-45bb73aa6733', 2, '2026-09-10 00:00:00', 'office', 'closed', '2026-09-10 05:20:00', '2026-09-10 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (47, 1, '2300ee75-8965-4859-be99-f53c51d551df', 3, '2026-09-10 00:00:00', 'remote', 'closed', '2026-09-10 05:58:00', '2026-09-10 13:50:00', 13, 417, 55, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (48, 1, '71535e2a-5ba7-42db-b345-f749d088f10b', 4, '2026-09-10 00:00:00', 'office', 'closed', '2026-09-10 05:34:00', '2026-09-10 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (49, 1, '13791488-01b6-4b82-8e70-2406a960ef3e', 5, '2026-09-10 00:00:00', 'office', 'closed', '2026-09-10 05:38:00', '2026-09-10 13:35:00', 0, 417, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (50, 1, 'acd67bc5-9994-409b-b072-ef816731f424', 6, '2026-09-10 00:00:00', 'office', 'closed', '2026-09-10 05:30:00', '2026-09-10 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49');

INSERT INTO attendance_days (id, company_id, uuid, user_id, work_date, location, day_status, check_in_at, check_out_at, late_minutes, worked_minutes, break_minutes, expected_minutes, excused, note, created_at, updated_at) VALUES
    (51, 1, '185566a0-06d8-43d4-8b2b-006ee809f0d4', 7, '2026-09-10 00:00:00', 'office', 'closed', '2026-09-10 05:42:00', '2026-09-10 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (52, 1, '8693876d-4348-4f4c-8173-204857f2141c', 8, '2026-09-10 00:00:00', 'office', 'closed', '2026-09-10 05:25:00', '2026-09-10 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (53, 1, 'b8fdaa5c-82df-4046-b06e-dc18bc542729', 9, '2026-09-10 00:00:00', 'office', 'closed', '2026-09-10 05:31:00', '2026-09-10 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (54, 1, 'a413491c-804b-46fb-9376-442fdd634882', 2, '2026-09-12 00:00:00', 'office', 'closed', '2026-09-12 05:20:00', '2026-09-12 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (55, 1, '9cfc4538-f41d-4f51-91e6-f75c85805603', 3, '2026-09-12 00:00:00', 'remote', 'closed', '2026-09-12 05:36:00', '2026-09-12 13:50:00', 0, 439, 55, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (56, 1, 'a0bf56eb-1977-4136-86a2-47cdf0af40c1', 4, '2026-09-12 00:00:00', 'office', 'closed', '2026-09-12 05:34:00', '2026-09-12 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (57, 1, '37a9d15f-a54d-4d4c-9b5d-a03f3d3533ef', 5, '2026-09-12 00:00:00', 'office', 'closed', '2026-09-12 05:38:00', '2026-09-12 13:35:00', 0, 417, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (58, 1, '21e71c9f-4452-4d08-89d6-8a6456422fb2', 6, '2026-09-12 00:00:00', 'office', 'closed', '2026-09-12 05:30:00', '2026-09-12 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (59, 1, '62deb7c7-733b-425f-bcd4-e31cebc709c7', 7, '2026-09-12 00:00:00', 'office', 'closed', '2026-09-12 05:42:00', '2026-09-12 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (60, 1, 'f778706b-e16f-4f20-a4f7-d29a1458f68b', 8, '2026-09-12 00:00:00', 'office', 'closed', '2026-09-12 05:25:00', '2026-09-12 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (61, 1, '51a7cb8e-18d1-49be-9957-7e9422046c73', 9, '2026-09-12 00:00:00', 'office', 'closed', '2026-09-12 05:31:00', '2026-09-12 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (62, 1, '109bc261-ee50-4046-880d-df6716ca7270', 2, '2026-09-13 00:00:00', 'office', 'closed', '2026-09-13 05:20:00', '2026-09-13 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (63, 1, '8def2a1c-5dce-480b-a1d5-c5cf0edd733d', 3, '2026-09-13 00:00:00', 'remote', 'closed', '2026-09-13 05:36:00', '2026-09-13 13:50:00', 0, 439, 55, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (64, 1, '3a7cc60b-0009-4aae-b0ce-bb718e6fac91', 4, '2026-09-13 00:00:00', 'office', 'marked', NULL, NULL, 0, 0, 0, 420, true, 'مرخصی استحقاقی', '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (65, 1, 'c14b470c-8619-40c3-9efa-e0a4c2491f17', 5, '2026-09-13 00:00:00', 'office', 'closed', '2026-09-13 05:38:00', '2026-09-13 13:35:00', 0, 417, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (66, 1, '632383db-be8f-445b-842a-ea17e91fb21a', 6, '2026-09-13 00:00:00', 'office', 'closed', '2026-09-13 05:30:00', '2026-09-13 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (67, 1, '9498093f-f1cd-4ee1-a58d-7217daaaf7d4', 7, '2026-09-13 00:00:00', 'office', 'closed', '2026-09-13 05:42:00', '2026-09-13 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (68, 1, 'f980910a-6975-4488-bfb3-3252e9f21b30', 8, '2026-09-13 00:00:00', 'office', 'closed', '2026-09-13 05:25:00', '2026-09-13 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (69, 1, '211fb8c7-4bb0-404f-8a69-27ae7d6d82c1', 9, '2026-09-13 00:00:00', 'office', 'closed', '2026-09-13 05:31:00', '2026-09-13 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (70, 1, '6bfcca60-d9a9-460b-a90a-15eb95508098', 2, '2026-09-14 00:00:00', 'office', 'closed', '2026-09-14 05:20:00', '2026-09-14 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (71, 1, '14ff7a66-af4f-4e61-8026-6c004d56b302', 3, '2026-09-14 00:00:00', 'remote', 'closed', '2026-09-14 05:36:00', '2026-09-14 13:50:00', 0, 439, 55, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (72, 1, '6859d012-d82d-447b-8c8e-b630ddbe232d', 4, '2026-09-14 00:00:00', 'office', 'closed', '2026-09-14 05:34:00', '2026-09-14 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (73, 1, 'e9a844d7-b8cf-4ecf-9ac0-279790135770', 5, '2026-09-14 00:00:00', 'office', 'closed', '2026-09-14 05:58:00', '2026-09-14 13:35:00', 13, 397, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (74, 1, 'c4d18b32-959d-41ce-9351-ddcef68da8f2', 6, '2026-09-14 00:00:00', 'office', 'closed', '2026-09-14 05:30:00', '2026-09-14 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (75, 1, '17969e2f-aed6-4164-ade4-941fd4b5acf0', 7, '2026-09-14 00:00:00', 'office', 'closed', '2026-09-14 05:42:00', '2026-09-14 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (76, 1, '033c4b83-272c-4c3c-8c95-1d8ae133b53a', 8, '2026-09-14 00:00:00', 'office', 'closed', '2026-09-14 05:25:00', '2026-09-14 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (77, 1, '86c3106d-a536-4e00-9f82-3879f98edf09', 9, '2026-09-14 00:00:00', 'office', 'closed', '2026-09-14 05:31:00', '2026-09-14 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (78, 1, '874b6239-cc9f-4c14-a919-ff59129dd011', 2, '2026-09-15 00:00:00', 'office', 'closed', '2026-09-15 05:20:00', '2026-09-15 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (79, 1, 'c8706d78-bf58-46e5-9eb3-a54753036648', 3, '2026-09-15 00:00:00', 'remote', 'closed', '2026-09-15 05:36:00', '2026-09-15 13:50:00', 0, 439, 55, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (80, 1, '7da9adc7-2971-49c2-b12d-afe902127767', 4, '2026-09-15 00:00:00', 'office', 'closed', '2026-09-15 05:34:00', '2026-09-15 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (81, 1, '2019e906-8929-4c88-86fd-05408cba27e5', 5, '2026-09-15 00:00:00', 'office', 'closed', '2026-09-15 05:38:00', '2026-09-15 13:35:00', 0, 417, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (82, 1, '8e0bba5f-74d0-46ea-932c-7a50a3ac8c05', 6, '2026-09-15 00:00:00', 'office', 'closed', '2026-09-15 05:30:00', '2026-09-15 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (83, 1, '53c40f5a-7f91-483d-b7b6-2fbb8d01d6ef', 7, '2026-09-15 00:00:00', 'office', 'closed', '2026-09-15 05:42:00', '2026-09-15 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (84, 1, '4f589231-752b-4283-b831-c5017f02590e', 8, '2026-09-15 00:00:00', 'office', 'closed', '2026-09-15 05:25:00', '2026-09-15 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (85, 1, '6fa85ea0-6d23-4ff4-b6f6-0caf1259ddd0', 9, '2026-09-15 00:00:00', 'office', 'closed', '2026-09-15 05:31:00', '2026-09-15 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (86, 1, '398c78f7-8b49-48c3-bbf6-7d5b0adeed6f', 2, '2026-09-16 00:00:00', 'office', 'closed', '2026-09-16 05:20:00', '2026-09-16 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (87, 1, 'f07cedd3-f3e3-454c-af1a-cef6f7cf6d21', 3, '2026-09-16 00:00:00', 'remote', 'closed', '2026-09-16 05:58:00', '2026-09-16 13:50:00', 13, 417, 55, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (88, 1, 'e92c1d7a-a9f7-450e-83e4-0d81dfc2c3fc', 4, '2026-09-16 00:00:00', 'office', 'closed', '2026-09-16 05:34:00', '2026-09-16 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (89, 1, '75b9fcf1-e9ac-4350-a427-e28dc2a89464', 5, '2026-09-16 00:00:00', 'office', 'closed', '2026-09-16 05:38:00', '2026-09-16 13:35:00', 0, 417, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (90, 1, 'e84e0a89-2807-448d-9a1a-a59ad6c4bc54', 6, '2026-09-16 00:00:00', 'office', 'closed', '2026-09-16 05:30:00', '2026-09-16 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (91, 1, '4ec2ae85-f505-445e-a1b4-abc4df03c5a0', 7, '2026-09-16 00:00:00', 'office', 'closed', '2026-09-16 05:42:00', '2026-09-16 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (92, 1, '7cdf9fb5-73be-4eae-b5de-46d45e3f15d7', 8, '2026-09-16 00:00:00', 'office', 'closed', '2026-09-16 05:25:00', '2026-09-16 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (93, 1, '2243228e-e80e-4423-b96f-2724e2edf409', 9, '2026-09-16 00:00:00', 'office', 'closed', '2026-09-16 05:31:00', '2026-09-16 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (94, 1, 'c2fac6b7-486e-4218-a3f6-e097634ba2d2', 2, '2026-09-17 00:00:00', 'office', 'closed', '2026-09-17 05:20:00', '2026-09-17 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (95, 1, '84a8a32d-8150-4547-a267-35d27d45a87e', 3, '2026-09-17 00:00:00', 'remote', 'closed', '2026-09-17 05:36:00', '2026-09-17 13:50:00', 0, 439, 55, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (96, 1, '492b712b-28ff-4b65-a7cb-345a9173ca1a', 4, '2026-09-17 00:00:00', 'office', 'closed', '2026-09-17 05:34:00', '2026-09-17 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (97, 1, 'a5bec0ab-c9cb-4af1-9b22-c631c5333a74', 5, '2026-09-17 00:00:00', 'office', 'closed', '2026-09-17 05:38:00', '2026-09-17 13:35:00', 0, 417, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (98, 1, '4c537379-f7ad-4359-878a-307ef01f0d24', 6, '2026-09-17 00:00:00', 'office', 'closed', '2026-09-17 05:30:00', '2026-09-17 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (99, 1, 'a1e496cb-a5c7-4c38-be75-ce0af1d65416', 7, '2026-09-17 00:00:00', 'office', 'marked', NULL, NULL, 0, 0, 0, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (100, 1, 'fe5878d3-bebc-4520-b512-306de34352de', 8, '2026-09-17 00:00:00', 'office', 'closed', '2026-09-17 05:25:00', '2026-09-17 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49');

INSERT INTO attendance_days (id, company_id, uuid, user_id, work_date, location, day_status, check_in_at, check_out_at, late_minutes, worked_minutes, break_minutes, expected_minutes, excused, note, created_at, updated_at) VALUES
    (101, 1, 'a92ed3d2-4a77-4c05-90b0-72f3d40e41a1', 9, '2026-09-17 00:00:00', 'office', 'closed', '2026-09-17 05:31:00', '2026-09-17 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (102, 1, 'c2117323-5a77-4c4b-ba63-3759b6874927', 2, '2026-09-19 00:00:00', 'office', 'closed', '2026-09-19 05:20:00', '2026-09-19 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:50'),
    (103, 1, '91d9e337-7035-4804-822a-3af328d0b1ea', 3, '2026-09-19 00:00:00', 'remote', 'closed', '2026-09-19 05:36:00', '2026-09-19 13:50:00', 0, 439, 55, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (104, 1, 'd499589c-7e8f-4a64-a3da-eabeb24d0637', 4, '2026-09-19 00:00:00', 'office', 'closed', '2026-09-19 05:34:00', '2026-09-19 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (105, 1, '52231481-ccd4-44bc-962f-71707e11fb13', 5, '2026-09-19 00:00:00', 'office', 'closed', '2026-09-19 05:58:00', '2026-09-19 13:35:00', 13, 397, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (106, 1, 'e656c595-52e0-4e4a-90f6-c6006ef3502d', 6, '2026-09-19 00:00:00', 'office', 'closed', '2026-09-19 05:30:00', '2026-09-19 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (107, 1, 'bdf15e52-e47d-41c2-acca-f40ea8bcb94e', 7, '2026-09-19 00:00:00', 'office', 'closed', '2026-09-19 05:42:00', '2026-09-19 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (108, 1, '81619ba2-bdae-4cd4-bc1c-0df95140cc43', 8, '2026-09-19 00:00:00', 'office', 'closed', '2026-09-19 05:25:00', '2026-09-19 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (109, 1, '58ae31f4-5a4e-46bd-82fe-dac572d15f1b', 9, '2026-09-19 00:00:00', 'office', 'closed', '2026-09-19 05:31:00', '2026-09-19 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (110, 1, 'da7563f7-6541-4576-adc5-f52b2541a6ff', 2, '2026-09-20 00:00:00', 'office', 'closed', '2026-09-20 05:20:00', '2026-09-20 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (111, 1, '53e70397-7a00-487a-bfe6-f40fce856fea', 3, '2026-09-20 00:00:00', 'remote', 'closed', '2026-09-20 05:36:00', '2026-09-20 13:50:00', 0, 439, 55, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (112, 1, 'a29eda42-2b57-4775-9389-ed925c9f8067', 4, '2026-09-20 00:00:00', 'office', 'closed', '2026-09-20 05:34:00', '2026-09-20 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (113, 1, '60a63610-948f-424a-9f83-723811d97b3e', 5, '2026-09-20 00:00:00', 'office', 'closed', '2026-09-20 05:38:00', '2026-09-20 13:35:00', 0, 417, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (114, 1, 'ebae3e30-4c14-4d9e-994e-b792d873186a', 6, '2026-09-20 00:00:00', 'office', 'closed', '2026-09-20 05:30:00', '2026-09-20 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (115, 1, '865474ee-e473-4eef-a15f-6c31c229c4dc', 7, '2026-09-20 00:00:00', 'office', 'closed', '2026-09-20 05:42:00', '2026-09-20 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (116, 1, '28232be5-7535-47fd-9101-e907c1ad38ba', 8, '2026-09-20 00:00:00', 'office', 'closed', '2026-09-20 05:25:00', '2026-09-20 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (117, 1, 'f45c7788-1026-4932-92c1-4f5f01141a5f', 9, '2026-09-20 00:00:00', 'office', 'closed', '2026-09-20 05:31:00', '2026-09-20 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (118, 1, '454a865b-5de3-4087-8b1e-32af437637a6', 2, '2026-09-21 00:00:00', 'office', 'closed', '2026-09-21 05:20:00', '2026-09-21 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (119, 1, '963fb77f-63af-42ca-b96c-52b07a5c1b26', 3, '2026-09-21 00:00:00', 'remote', 'closed', '2026-09-21 05:36:00', '2026-09-21 13:50:00', 0, 439, 55, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (120, 1, '59c0d78f-29fe-4e77-b41a-ca13029ce4b3', 4, '2026-09-21 00:00:00', 'office', 'closed', '2026-09-21 05:34:00', '2026-09-21 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (121, 1, '931042d3-ad7a-437c-8e57-189d2025f3b7', 5, '2026-09-21 00:00:00', 'office', 'closed', '2026-09-21 05:38:00', '2026-09-21 13:35:00', 0, 417, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (122, 1, '5718408c-7593-4fc8-bfbd-af59d69040da', 6, '2026-09-21 00:00:00', 'office', 'closed', '2026-09-21 05:30:00', '2026-09-21 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (123, 1, 'bc93483c-7d94-4b55-86de-735e7d164e02', 7, '2026-09-21 00:00:00', 'office', 'closed', '2026-09-21 05:42:00', '2026-09-21 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (124, 1, '0fe7e5ce-66c7-480f-839a-01e9c2cf74c3', 8, '2026-09-21 00:00:00', 'office', 'closed', '2026-09-21 05:25:00', '2026-09-21 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (125, 1, '66afd478-7b42-495a-acab-9b220b63e327', 9, '2026-09-21 00:00:00', 'office', 'closed', '2026-09-21 05:31:00', '2026-09-21 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (126, 1, '15637656-7295-44ec-8a83-264d1ac0a551', 2, '2026-09-22 00:00:00', 'office', 'closed', '2026-09-22 05:20:00', '2026-09-22 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (127, 1, 'a237e9ca-f0ce-4158-bb73-04317cd600d0', 3, '2026-09-22 00:00:00', 'remote', 'closed', '2026-09-22 05:58:00', '2026-09-22 13:50:00', 13, 417, 55, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (128, 1, '834985b2-81b0-41ac-91d4-5271751f1785', 4, '2026-09-22 00:00:00', 'office', 'closed', '2026-09-22 05:34:00', '2026-09-22 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (129, 1, 'fa36db13-2408-4e52-9a7f-9a9131253fa3', 5, '2026-09-22 00:00:00', 'office', 'closed', '2026-09-22 05:38:00', '2026-09-22 13:35:00', 0, 417, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (130, 1, 'f0224183-ca4c-466a-8e03-f5c5169bdee8', 6, '2026-09-22 00:00:00', 'office', 'closed', '2026-09-22 05:30:00', '2026-09-22 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (131, 1, 'aa776a3b-a81c-4862-bada-f305dd231ee9', 7, '2026-09-22 00:00:00', 'office', 'closed', '2026-09-22 05:42:00', '2026-09-22 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (132, 1, 'd3de0597-b1a2-439e-9af3-e0a1a256a1b6', 8, '2026-09-22 00:00:00', 'office', 'closed', '2026-09-22 05:25:00', '2026-09-22 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (133, 1, 'fbfd2313-0f6b-4926-bcfe-5b9b0f2d7dd5', 9, '2026-09-22 00:00:00', 'office', 'closed', '2026-09-22 05:31:00', '2026-09-22 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (134, 1, 'f95ef3d0-ffc6-4aab-a8a4-2c7f7457b4cc', 2, '2026-09-23 00:00:00', 'office', 'closed', '2026-09-23 05:20:00', '2026-09-23 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (135, 1, '49c9c9bf-2ec9-440d-9489-46107fe6b660', 3, '2026-09-23 00:00:00', 'remote', 'closed', '2026-09-23 05:36:00', '2026-09-23 13:50:00', 0, 439, 55, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (136, 1, '29e03a76-0098-4d26-8679-3967dc5d18bb', 4, '2026-09-23 00:00:00', 'office', 'closed', '2026-09-23 05:34:00', '2026-09-23 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (137, 1, 'd595bcdc-cd21-42e9-b824-f547005940bc', 5, '2026-09-23 00:00:00', 'office', 'closed', '2026-09-23 05:58:00', '2026-09-23 13:35:00', 13, 397, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (138, 1, '875143d8-4ce1-45c7-9ef8-9258ccca6ec3', 6, '2026-09-23 00:00:00', 'office', 'closed', '2026-09-23 05:30:00', '2026-09-23 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (139, 1, 'b9a2aa2f-fe7c-4398-b1c6-ca79bf206853', 7, '2026-09-23 00:00:00', 'office', 'closed', '2026-09-23 05:42:00', '2026-09-23 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (140, 1, '5d4a31de-9390-4ec8-a729-b232be2d3164', 8, '2026-09-23 00:00:00', 'office', 'closed', '2026-09-23 05:25:00', '2026-09-23 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (141, 1, 'a4f3b6c0-1340-4801-9496-ab2fd8815b9a', 9, '2026-09-23 00:00:00', 'office', 'closed', '2026-09-23 05:31:00', '2026-09-23 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (142, 1, 'e6a881fa-0fa2-47de-b27e-beeea05ca6d4', 2, '2026-09-24 00:00:00', 'office', 'closed', '2026-09-24 05:20:00', '2026-09-24 13:40:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (143, 1, 'ee16e4f5-5201-447c-9da8-29f35821448a', 3, '2026-09-24 00:00:00', 'remote', 'closed', '2026-09-24 05:36:00', '2026-09-24 13:50:00', 0, 439, 55, 420, false, 'اصلاح ساعت توسط مدیر', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (144, 1, '7ae64f1c-a35f-4c04-b8de-c6c79b7147c4', 4, '2026-09-24 00:00:00', 'office', 'closed', '2026-09-24 05:34:00', '2026-09-24 13:30:00', 0, 416, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (145, 1, '78331b3d-f10e-4454-a881-bcb1a228f4a1', 5, '2026-09-24 00:00:00', 'office', 'closed', '2026-09-24 05:38:00', '2026-09-24 13:35:00', 0, 417, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (146, 1, 'a8fbee64-d654-4e00-b690-3140ed564006', 6, '2026-09-24 00:00:00', 'office', 'closed', '2026-09-24 05:30:00', '2026-09-24 13:10:00', 0, 415, 45, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (147, 1, '2acd7d32-ef1e-407e-b30a-c0ec44bc752a', 7, '2026-09-24 00:00:00', 'office', 'closed', '2026-09-24 05:42:00', '2026-09-24 13:30:00', 0, 408, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (148, 1, '5b557f7b-f6b5-4479-b73a-76bbeb7cfc10', 8, '2026-09-24 00:00:00', 'office', 'closed', '2026-09-24 05:25:00', '2026-09-24 13:45:00', 0, 440, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (149, 1, '97e9fd77-897e-4d51-993d-cab9de9829a2', 9, '2026-09-24 00:00:00', 'office', 'closed', '2026-09-24 05:31:00', '2026-09-24 13:30:00', 0, 419, 60, 420, false, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50');

SELECT setval(pg_get_serial_sequence('attendance_days', 'id'), COALESCE((SELECT MAX(id) FROM attendance_days), 1), true);

-- attendance_events
INSERT INTO attendance_events (id, company_id, uuid, attendance_day_id, user_id, type, occurred_at, location, status, note, source, actor_id, ip, created_at, updated_at) VALUES
    (1, 1, '9ffee65f-24d7-45f8-9633-a5779d4888ab', 1, 2, 'check_in', '2026-09-25 21:32:48', 'office', NULL, 'شروع روز در دفتر', 'self', 2, '127.0.0.1', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (2, 1, 'e0b7316b-aa9b-476c-bee3-3f96623f909d', 2, 3, 'check_in', '2026-09-25 21:32:48', 'remote', NULL, NULL, 'self', 3, '127.0.0.1', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (3, 1, '64c959d1-ce9a-4a44-a040-c0bf1201c739', 3, 4, 'check_in', '2026-09-25 21:32:48', 'office', NULL, NULL, 'self', 4, '127.0.0.1', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (4, 1, 'f8662cd2-de26-4d9b-8934-82763091f4f8', 3, 4, 'break_start', '2026-09-25 21:32:48', 'office', 'break', NULL, 'self', 4, '127.0.0.1', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (5, 1, 'f687be7a-4d22-4bde-9e43-fb16459fdaa5', 4, 6, 'status', '2026-09-25 21:32:48', 'office', 'mission', 'جلسه با مشتری', 'self', 6, '127.0.0.1', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (6, 1, '8266c692-9b97-43a2-827a-85d79e60ba01', 5, 9, 'status', '2026-09-25 21:32:48', 'office', 'leave', 'مرخصی ساعتی', 'self', 9, '127.0.0.1', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (7, 1, 'd28ecb40-a378-41c8-8e3a-f08620a3a569', 6, 2, 'check_in', '2026-09-05 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (8, 1, '8fd96701-a60d-4a26-820a-1a78268de345', 6, 2, 'break_start', '2026-09-05 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (9, 1, 'd1ec1368-83ca-4ac1-91c0-e141f2873c66', 6, 2, 'break_end', '2026-09-05 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (10, 1, '1867859d-7519-4de4-bf5e-2b7c318f8454', 6, 2, 'check_out', '2026-09-05 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (11, 1, '9ef87030-4e5c-4f37-8b11-00abe318898c', 7, 3, 'check_in', '2026-09-05 05:58:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (12, 1, '41a94462-312c-4de4-833c-5e87c347a21b', 7, 3, 'break_start', '2026-09-05 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (13, 1, '71046386-5ed4-42a7-bfcf-fae0fec5e256', 7, 3, 'break_end', '2026-09-05 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (14, 1, '681647d1-a0f3-42b4-9a97-073f966acb70', 7, 3, 'check_out', '2026-09-05 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (15, 1, '24a61475-6a02-4853-8ded-4cf1734d027b', 8, 4, 'check_in', '2026-09-05 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (16, 1, '803f5edc-b82a-4291-9c46-78722d643b5d', 8, 4, 'break_start', '2026-09-05 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (17, 1, '37ee358b-c1e0-40fe-9728-cec943e96bf0', 8, 4, 'break_end', '2026-09-05 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (18, 1, '9f5e03c2-d051-4bda-9a39-85c550fe22ca', 8, 4, 'check_out', '2026-09-05 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (19, 1, '55f338eb-6ef3-4e6d-96c6-a45c3ecffbd1', 9, 5, 'check_in', '2026-09-05 05:58:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (20, 1, '4346b1bb-02ad-41e8-8b70-6deee064d532', 9, 5, 'break_start', '2026-09-05 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (21, 1, 'bbbb4197-29dc-42cd-bebc-a0625c56ee76', 9, 5, 'break_end', '2026-09-05 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (22, 1, 'd1722a0f-016f-4cce-b2e9-4937f088a1b9', 9, 5, 'check_out', '2026-09-05 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (23, 1, 'ff9993b0-48fc-4246-ac92-38fd5b67fd3f', 10, 6, 'check_in', '2026-09-05 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (24, 1, 'b7f79beb-fda6-49b7-a900-b0f6b10f6695', 10, 6, 'break_start', '2026-09-05 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (25, 1, '5c5f3f78-673b-4e35-bd75-00616ff791e1', 10, 6, 'break_end', '2026-09-05 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (26, 1, 'fb86ddfd-a80c-4b4b-8a45-f56acb5f641b', 10, 6, 'check_out', '2026-09-05 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (27, 1, 'fc5e10a1-f5da-44f1-acab-cf15895a9fb3', 11, 7, 'check_in', '2026-09-05 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (28, 1, '0640ee2e-2f70-4124-ad21-c4c8aafdd099', 11, 7, 'break_start', '2026-09-05 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (29, 1, '08bd762c-2240-45f7-9ea7-31beec96e2b0', 11, 7, 'break_end', '2026-09-05 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (30, 1, '9a5776b3-50b9-44b9-8667-f57b112c1bae', 11, 7, 'check_out', '2026-09-05 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (31, 1, 'ddce0a46-e946-4fde-82b3-d77d3e015624', 12, 8, 'check_in', '2026-09-05 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (32, 1, '2630fbd0-e711-4021-b970-3e771c8ad5d0', 12, 8, 'break_start', '2026-09-05 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (33, 1, '321a7053-a488-4383-be1a-5ac410d24c8a', 12, 8, 'break_end', '2026-09-05 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (34, 1, '2c97616d-67f0-4a7d-9cf5-ce8140efe058', 12, 8, 'check_out', '2026-09-05 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (35, 1, '7063c262-34d2-4e22-8cab-fd69aedf7d53', 13, 9, 'check_in', '2026-09-05 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (36, 1, '4a553610-4903-401c-94c3-cba0fb79fc70', 13, 9, 'break_start', '2026-09-05 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (37, 1, 'dd4f8d96-96d6-4faa-96f5-5a7398479475', 13, 9, 'break_end', '2026-09-05 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (38, 1, '4001c6fe-f5a7-4979-9487-e977174fc17e', 13, 9, 'check_out', '2026-09-05 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (39, 1, '53c69d0d-71fc-48c6-9d54-a3a93a1b349c', 14, 2, 'check_in', '2026-09-06 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (40, 1, '079b15fb-18fe-4858-af8c-4055c27e057b', 14, 2, 'break_start', '2026-09-06 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (41, 1, '81654632-7bdb-4f01-bfb5-19a90ad48238', 14, 2, 'break_end', '2026-09-06 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (42, 1, 'f4d39061-9514-427a-ad0c-892b865503df', 14, 2, 'check_out', '2026-09-06 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (43, 1, '11f959df-8265-4b96-96b3-9eb3308d7360', 15, 3, 'check_in', '2026-09-06 05:36:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (44, 1, 'f449084d-f52d-48aa-8162-33fbc88dd9a0', 15, 3, 'break_start', '2026-09-06 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (45, 1, '1ed914fe-9435-47b8-ad73-550e05993ff6', 15, 3, 'break_end', '2026-09-06 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (46, 1, '3530896f-9e36-4095-8639-35808b5f8732', 15, 3, 'check_out', '2026-09-06 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (47, 1, '724d1309-5990-4d24-a4bc-0d878bf2e446', 16, 4, 'check_in', '2026-09-06 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (48, 1, '8086edad-af35-4044-9fdc-e1636f53de27', 16, 4, 'break_start', '2026-09-06 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (49, 1, 'f6f54d84-1740-42d0-bfc5-59b38f3447d8', 16, 4, 'break_end', '2026-09-06 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (50, 1, '920d64c4-33fd-4d03-a39b-69c72bc4a26d', 16, 4, 'check_out', '2026-09-06 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48');

INSERT INTO attendance_events (id, company_id, uuid, attendance_day_id, user_id, type, occurred_at, location, status, note, source, actor_id, ip, created_at, updated_at) VALUES
    (51, 1, '075bd55a-2316-4f53-974c-f4d7b97a9956', 17, 5, 'check_in', '2026-09-06 05:38:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (52, 1, '07066eb7-d21f-43fd-aa44-121c0c036eac', 17, 5, 'break_start', '2026-09-06 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (53, 1, 'a76b5d5d-0c31-40c1-9a3a-2e02746c3186', 17, 5, 'break_end', '2026-09-06 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (54, 1, '6d2a1048-4f49-44b4-a17c-e69e94b938c3', 17, 5, 'check_out', '2026-09-06 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (55, 1, '464579f7-b1b6-4b4c-980c-1263b9cf3404', 18, 6, 'check_in', '2026-09-06 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (56, 1, '4e204649-89ed-4fea-99a6-977cc843a1d2', 18, 6, 'break_start', '2026-09-06 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (57, 1, '7292032a-340e-4d53-ad44-98284f1a9939', 18, 6, 'break_end', '2026-09-06 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (58, 1, '1e4bdab2-e348-4cdd-a76a-f5ac1c587365', 18, 6, 'check_out', '2026-09-06 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (59, 1, '9738fdad-9084-49db-a7dc-10bb7340e1c2', 19, 7, 'check_in', '2026-09-06 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (60, 1, '6a60b6de-80f3-4168-ab7c-522244ad1504', 19, 7, 'break_start', '2026-09-06 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (61, 1, 'de91a9dc-edd0-4c35-b76b-1372a03bad64', 19, 7, 'break_end', '2026-09-06 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (62, 1, '0338d63a-f691-4e58-bcb7-de050c6d7e2a', 19, 7, 'check_out', '2026-09-06 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (63, 1, 'a1866d6f-c919-4c68-a270-ea8fb166f2af', 20, 8, 'check_in', '2026-09-06 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (64, 1, '74a04fe4-705e-4100-b78f-5e0c83193fcb', 20, 8, 'break_start', '2026-09-06 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (65, 1, 'cc0847f3-f521-4ec9-b7b2-2b1ccd3f93ec', 20, 8, 'break_end', '2026-09-06 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (66, 1, 'fa481deb-2492-4811-801f-017c768bd17d', 20, 8, 'check_out', '2026-09-06 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (67, 1, 'af19a86e-4a05-45b6-b11d-fb0e482642e4', 21, 9, 'check_in', '2026-09-06 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (68, 1, 'ddd343bb-cfe1-488b-9a7d-0ae9d3b8da25', 21, 9, 'break_start', '2026-09-06 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (69, 1, '24695a58-1026-45fa-afad-493780e39a12', 21, 9, 'break_end', '2026-09-06 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (70, 1, 'abd346f4-be1e-4294-9131-f28a47cdb065', 21, 9, 'check_out', '2026-09-06 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (71, 1, 'cd601f5d-4d11-44ae-8f0d-832cdcbbddc7', 22, 2, 'check_in', '2026-09-07 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (72, 1, '19041869-2394-49be-a15d-2acccddd53f0', 22, 2, 'break_start', '2026-09-07 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (73, 1, '36817171-cd62-4645-a0ee-9e895b4f8380', 22, 2, 'break_end', '2026-09-07 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (74, 1, '1292a9a7-9258-4809-81ba-507f89824ba1', 22, 2, 'check_out', '2026-09-07 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (75, 1, '2d3c00bf-f091-4df7-be67-4e038af25abe', 23, 3, 'check_in', '2026-09-07 05:36:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (76, 1, 'abd6ca2c-9111-46cf-b26b-185567cc65ca', 23, 3, 'break_start', '2026-09-07 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (77, 1, 'da8ee5a1-ae46-4db4-98ed-3827522e2b97', 23, 3, 'break_end', '2026-09-07 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (78, 1, 'dbba7a7d-5c89-4713-aaad-efa367e19df2', 23, 3, 'check_out', '2026-09-07 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (79, 1, '1faa723f-c662-459b-828b-6c25b0385c71', 24, 4, 'check_in', '2026-09-07 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (80, 1, 'b41e894c-3a90-40ec-9b01-bc048018e41b', 24, 4, 'break_start', '2026-09-07 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (81, 1, 'cee25674-1716-4d0c-9980-9bf5214b84f1', 24, 4, 'break_end', '2026-09-07 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (82, 1, '14d99da3-21a0-42fb-b005-c3b595599744', 24, 4, 'check_out', '2026-09-07 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (83, 1, 'b9865aaa-6a81-4f45-82c9-92d879922338', 25, 5, 'check_in', '2026-09-07 05:38:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (84, 1, '97097c51-3241-411e-86b9-45705d86f3a3', 25, 5, 'break_start', '2026-09-07 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (85, 1, '63a49668-3f33-49a7-8059-d0a687fd0cfb', 25, 5, 'break_end', '2026-09-07 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (86, 1, 'e3671d02-4552-438d-b8d2-1977a708153c', 25, 5, 'check_out', '2026-09-07 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (87, 1, 'c95a64d0-c0ee-4062-86a2-0242c4ae05d3', 26, 6, 'check_in', '2026-09-07 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (88, 1, '7f095421-3a96-4d6c-ba13-9b42aac5e546', 26, 6, 'break_start', '2026-09-07 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (89, 1, '053e1bdb-38a8-4b16-9e74-b183fdbf8a74', 26, 6, 'break_end', '2026-09-07 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (90, 1, '537db7fa-c69f-4a8a-aae2-3469d8c71503', 26, 6, 'check_out', '2026-09-07 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (91, 1, '90f11699-b006-4ff7-acf6-2e73df198885', 27, 7, 'check_in', '2026-09-07 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (92, 1, 'c098534b-7fe5-421d-ab6f-4f35a648f242', 27, 7, 'break_start', '2026-09-07 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (93, 1, '6f88a7b5-37eb-4cf7-93db-7abb63865bb9', 27, 7, 'break_end', '2026-09-07 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (94, 1, 'a55d793b-47cb-4623-88ff-e1f68d54813b', 27, 7, 'check_out', '2026-09-07 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (95, 1, '9fadee70-a6d6-428b-8884-ad2f112d6f10', 28, 8, 'check_in', '2026-09-07 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (96, 1, '55f09897-dbf7-4087-82dd-6e543f3461ef', 28, 8, 'break_start', '2026-09-07 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (97, 1, '8c7f19ef-2a89-4a99-8f7d-fe9fde6995d1', 28, 8, 'break_end', '2026-09-07 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (98, 1, 'cae348a2-8e05-42bf-a2d4-541c2cf75b87', 28, 8, 'check_out', '2026-09-07 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (99, 1, '41cccb32-e9c7-47dd-9f84-efedc88a55dc', 29, 9, 'check_in', '2026-09-07 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (100, 1, '0649d7f6-d1c1-46fb-8b7c-a20a29bd7d2b', 29, 9, 'break_start', '2026-09-07 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48');

INSERT INTO attendance_events (id, company_id, uuid, attendance_day_id, user_id, type, occurred_at, location, status, note, source, actor_id, ip, created_at, updated_at) VALUES
    (101, 1, '8d525f85-85a4-416f-a392-f641d517d616', 29, 9, 'break_end', '2026-09-07 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (102, 1, '792eed05-d859-49a7-bfe1-c5eeb8863d6b', 29, 9, 'check_out', '2026-09-07 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (103, 1, '9a15caca-6159-4af3-b98e-a632b24d5ab5', 30, 2, 'check_in', '2026-09-08 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (104, 1, 'fbd2e022-2bfe-43b8-9b01-4d80137837c2', 30, 2, 'break_start', '2026-09-08 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (105, 1, 'f90c338d-a8ad-4b25-9bf4-98f936c29468', 30, 2, 'break_end', '2026-09-08 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (106, 1, '6ae61c97-fb80-4e7f-9b1c-0238088b2009', 30, 2, 'check_out', '2026-09-08 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (107, 1, '2d8b1393-2a93-44c2-9bb6-3bc406d8bcd4', 31, 3, 'check_in', '2026-09-08 05:36:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (108, 1, '6143e785-5bea-4d5f-b331-d5da290d1960', 31, 3, 'break_start', '2026-09-08 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (109, 1, 'c4bc0adf-3c79-4bd5-9074-e08d1f578826', 31, 3, 'break_end', '2026-09-08 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (110, 1, 'c9e6ac05-485e-4af7-8a34-25e5cce2324d', 31, 3, 'check_out', '2026-09-08 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (111, 1, 'f5d4825f-aa19-4151-9a79-db52f2b3a4d4', 32, 4, 'check_in', '2026-09-08 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (112, 1, '3f54ec90-6a63-41dd-bcfd-d9a52f5261c8', 32, 4, 'break_start', '2026-09-08 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (113, 1, '3ab65ae3-024b-4eaa-bf77-c38b070d3281', 32, 4, 'break_end', '2026-09-08 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (114, 1, '865d6700-85bc-45ed-8018-417a65b7cd42', 32, 4, 'check_out', '2026-09-08 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (115, 1, '98dfdc2b-87dc-47df-8642-984f9e69c883', 33, 5, 'check_in', '2026-09-08 05:38:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (116, 1, 'be5cf05a-d991-481e-9809-35658985bc5f', 33, 5, 'break_start', '2026-09-08 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (117, 1, 'a3f9d7f4-257b-46e2-a8e5-ea7ff06d7847', 33, 5, 'break_end', '2026-09-08 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (118, 1, 'bccd00fd-eaeb-4092-80b0-cf542217bd57', 33, 5, 'check_out', '2026-09-08 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (119, 1, 'b6e0b7d2-a3e0-4bc6-8bcf-9e4554459ded', 35, 7, 'check_in', '2026-09-08 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (120, 1, '7e1a05d3-0e42-476d-8d31-a507be1f80ba', 35, 7, 'break_start', '2026-09-08 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (121, 1, '1787c2da-1f2c-4eb8-a356-91707d4c71a7', 35, 7, 'break_end', '2026-09-08 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (122, 1, '84c02d8e-0530-4cb6-b0fa-dba62aaee178', 35, 7, 'check_out', '2026-09-08 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (123, 1, '728f6b39-256c-4752-a20f-abfec26d2c57', 36, 8, 'check_in', '2026-09-08 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (124, 1, 'ef2d8f9f-fc00-4bea-a32e-1e2d6363afbb', 36, 8, 'break_start', '2026-09-08 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (125, 1, 'e8d70f45-a6b4-4019-91e2-13ea2b829fe0', 36, 8, 'break_end', '2026-09-08 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (126, 1, '29bc48e7-f5c3-4a8f-ae38-6981027b6ffc', 36, 8, 'check_out', '2026-09-08 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (127, 1, '6108958a-bc29-49cf-a50f-0c1100889994', 37, 9, 'check_in', '2026-09-08 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (128, 1, 'c7300e06-ec7d-4c93-b028-9b13a55bcbbc', 37, 9, 'break_start', '2026-09-08 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (129, 1, 'f56e2093-1d8e-4332-932a-f5f83960d070', 37, 9, 'break_end', '2026-09-08 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (130, 1, 'e1c1782a-c12e-4d0d-b0e4-d9f803bbcb83', 37, 9, 'check_out', '2026-09-08 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (131, 1, '376bb2bc-4a3f-492e-ad08-cde6e266e911', 38, 2, 'check_in', '2026-09-09 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (132, 1, '35922ab2-54ba-484a-ad3f-423487a28a72', 38, 2, 'break_start', '2026-09-09 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (133, 1, '2a345ccb-4e79-497f-a7cf-196b60ba45c3', 38, 2, 'break_end', '2026-09-09 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (134, 1, 'c3fa67f9-c2cd-427a-b1ad-10d4ebb6423a', 38, 2, 'check_out', '2026-09-09 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (135, 1, 'bdd02e84-5b59-4261-9878-c33d8ab64ff1', 39, 3, 'check_in', '2026-09-09 05:36:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (136, 1, '190cce0f-6f05-478b-aac6-2d8d69dcf953', 39, 3, 'break_start', '2026-09-09 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (137, 1, 'e9fe0305-bed2-4a91-a63b-4a2a1f60ccc0', 39, 3, 'break_end', '2026-09-09 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (138, 1, 'f273f242-fe58-4c32-996e-11e15162ac3c', 39, 3, 'check_out', '2026-09-09 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (139, 1, 'a800000c-40ba-4660-a135-d1b15eb30387', 40, 4, 'check_in', '2026-09-09 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (140, 1, 'fa13abaf-46d5-4abb-b8ff-5cb1b8a87766', 40, 4, 'break_start', '2026-09-09 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (141, 1, '31dd356f-0cad-42b9-8d5d-1d07e9545262', 40, 4, 'break_end', '2026-09-09 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (142, 1, '21d6b1ba-2238-43d1-80e3-c9e3cf0b18e0', 40, 4, 'check_out', '2026-09-09 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (143, 1, '99e57c55-1a3b-473a-9e85-2a511e563b28', 41, 5, 'check_in', '2026-09-09 05:58:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (144, 1, '876f52de-30a6-4628-8b8b-e96b626aed7a', 41, 5, 'break_start', '2026-09-09 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (145, 1, '635a20fd-a394-47ba-b32f-3233a5f51832', 41, 5, 'break_end', '2026-09-09 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (146, 1, '1bcfba87-a72e-4d1a-8f3c-783d3c9c8072', 41, 5, 'check_out', '2026-09-09 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (147, 1, '7bd478f7-d458-4c4b-a69b-e52575cd18ef', 42, 6, 'check_in', '2026-09-09 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (148, 1, '2ec7f724-cf7c-4d0e-8b89-b45d01a52121', 42, 6, 'break_start', '2026-09-09 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (149, 1, '68ac4d0e-ca87-4911-b4af-2a1d7554e202', 42, 6, 'break_end', '2026-09-09 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (150, 1, '477ebe0c-339c-45bf-a963-bdc9d64ae410', 42, 6, 'check_out', '2026-09-09 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48');

INSERT INTO attendance_events (id, company_id, uuid, attendance_day_id, user_id, type, occurred_at, location, status, note, source, actor_id, ip, created_at, updated_at) VALUES
    (151, 1, '9ca03ac0-dc0c-4beb-a9da-7b55ac4f4ad4', 43, 7, 'check_in', '2026-09-09 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (152, 1, '29354ba3-ac05-42a5-ba11-d26323aa5ba1', 43, 7, 'break_start', '2026-09-09 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (153, 1, 'b2d32f75-1b30-4575-85d4-bd75be093a81', 43, 7, 'break_end', '2026-09-09 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (154, 1, 'a12d1cd2-c077-4c2e-a300-ff71051eec94', 43, 7, 'check_out', '2026-09-09 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (155, 1, 'ca9eb73e-26f9-4cc4-9129-817219e095a6', 44, 8, 'check_in', '2026-09-09 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (156, 1, 'c45c5997-787b-46b1-bbf2-9ca4779a1e11', 44, 8, 'break_start', '2026-09-09 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (157, 1, '7daff90b-ad68-4842-aa2c-ba6a06ca7a2e', 44, 8, 'break_end', '2026-09-09 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (158, 1, '0ec9c190-1031-43b1-a8ac-1905ab85697b', 44, 8, 'check_out', '2026-09-09 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (159, 1, 'ee03227d-c5a1-4dd2-b882-6b0550181c05', 45, 9, 'check_in', '2026-09-09 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (160, 1, '051c73aa-51ff-45ac-b31f-cc90a688a9db', 45, 9, 'break_start', '2026-09-09 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (161, 1, 'f16c786a-d1de-4a9d-a539-32e7e4be05c6', 45, 9, 'break_end', '2026-09-09 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (162, 1, 'd7766059-3dac-4e6b-8d25-41de39aed2c7', 45, 9, 'check_out', '2026-09-09 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (163, 1, '921513de-a656-4aea-9f20-cc894638a66b', 46, 2, 'check_in', '2026-09-10 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (164, 1, '7c41b92c-837a-40e2-9b56-7dbcdffe48f1', 46, 2, 'break_start', '2026-09-10 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (165, 1, '2c3de53b-9f72-45fa-93e8-545173254ce8', 46, 2, 'break_end', '2026-09-10 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (166, 1, '4ca94daf-a83f-4504-baba-84f12d50d51c', 46, 2, 'check_out', '2026-09-10 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (167, 1, 'd734bdf2-9ff1-423c-a429-f67608a93770', 47, 3, 'check_in', '2026-09-10 05:58:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (168, 1, 'ef359b75-d244-46a4-967b-9f0153ad094a', 47, 3, 'break_start', '2026-09-10 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (169, 1, '9219e5d8-87ee-445a-92ff-f49bc804e761', 47, 3, 'break_end', '2026-09-10 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (170, 1, '8b675625-2983-443f-8301-86a903813e0f', 47, 3, 'check_out', '2026-09-10 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (171, 1, 'a05722a9-aba8-4152-90bb-121dcd78ad0d', 48, 4, 'check_in', '2026-09-10 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (172, 1, '35814817-ebdd-4ca3-a1fe-1682fd95f8f8', 48, 4, 'break_start', '2026-09-10 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (173, 1, '6f2fe451-ce9e-471f-8c84-239a853ba4f2', 48, 4, 'break_end', '2026-09-10 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (174, 1, '1bfc7f13-0ad2-482c-97e2-516dbb55a577', 48, 4, 'check_out', '2026-09-10 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (175, 1, 'dbfb34cb-4045-453c-aebc-9337aad54c5a', 49, 5, 'check_in', '2026-09-10 05:38:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (176, 1, '2abb52bb-05fc-48f1-83f7-90fd6ead9e3f', 49, 5, 'break_start', '2026-09-10 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (177, 1, '54c294da-f64c-467c-a656-b34f964fcde1', 49, 5, 'break_end', '2026-09-10 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (178, 1, 'e3d7640a-2b66-4a1e-b061-99fdbb6c29ed', 49, 5, 'check_out', '2026-09-10 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (179, 1, '80b500b8-7254-4da1-828b-4965410d4f5f', 50, 6, 'check_in', '2026-09-10 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (180, 1, '6836ea7a-f713-4cc2-8522-7cff4a0f8191', 50, 6, 'break_start', '2026-09-10 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (181, 1, '3453f880-2b98-4dcd-a7aa-28ffd5acd515', 50, 6, 'break_end', '2026-09-10 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (182, 1, 'dc8a5f7d-7423-42e2-a866-c2ee598afab2', 50, 6, 'check_out', '2026-09-10 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (183, 1, '89fc55ae-a5f2-4f35-8d63-1ede37a75e2a', 51, 7, 'check_in', '2026-09-10 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (184, 1, '26fa55b6-804f-4f1c-bb8c-8f26948c5d98', 51, 7, 'break_start', '2026-09-10 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (185, 1, 'a1250fd5-657c-4fad-9e82-1923c656a3a4', 51, 7, 'break_end', '2026-09-10 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (186, 1, '6e638e41-387b-4c63-a4c1-4ea9c885611d', 51, 7, 'check_out', '2026-09-10 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (187, 1, 'd2b0c1f6-ad53-4c76-b539-04ff7fe2066e', 52, 8, 'check_in', '2026-09-10 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (188, 1, 'db2501d1-02ab-49a6-91c9-5d3586cc8e87', 52, 8, 'break_start', '2026-09-10 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (189, 1, '319c411e-db8a-45ac-904c-0cc73c2b73ed', 52, 8, 'break_end', '2026-09-10 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (190, 1, 'ff4e519e-7825-4539-bb99-2eea83773fc6', 52, 8, 'check_out', '2026-09-10 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (191, 1, '4337b489-7112-47a6-9245-7512468d0a24', 53, 9, 'check_in', '2026-09-10 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (192, 1, '75d6fe20-c93e-4d39-acc9-4a71ef3cc90b', 53, 9, 'break_start', '2026-09-10 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (193, 1, '12412ee2-fbb6-4a85-89e8-931a12db92f8', 53, 9, 'break_end', '2026-09-10 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (194, 1, '7d3b8dde-7256-436e-ac04-1741c8e937ab', 53, 9, 'check_out', '2026-09-10 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (195, 1, '1b037626-7eda-4879-ad42-b2eb76fe4669', 54, 2, 'check_in', '2026-09-12 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (196, 1, '5dcd177c-da41-4703-a122-b16f9f186a78', 54, 2, 'break_start', '2026-09-12 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (197, 1, 'd8a03bf6-7c77-4748-a993-d6523172caa8', 54, 2, 'break_end', '2026-09-12 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (198, 1, '502c8635-ecfc-4014-a861-55f69c2624a9', 54, 2, 'check_out', '2026-09-12 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (199, 1, 'e91769d1-950e-4a47-80b6-04d83fcd1dae', 55, 3, 'check_in', '2026-09-12 05:36:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (200, 1, '486608fe-29f9-49e7-9390-67f3a92c9b65', 55, 3, 'break_start', '2026-09-12 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49');

INSERT INTO attendance_events (id, company_id, uuid, attendance_day_id, user_id, type, occurred_at, location, status, note, source, actor_id, ip, created_at, updated_at) VALUES
    (201, 1, '75c02d16-1bfc-4ec0-a131-6aa4074c53df', 55, 3, 'break_end', '2026-09-12 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (202, 1, 'db7ac3f3-8855-486c-8cdb-c7e568532628', 55, 3, 'check_out', '2026-09-12 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (203, 1, '794cac62-75e8-4bb4-98bf-cbb67135adf4', 56, 4, 'check_in', '2026-09-12 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (204, 1, '3c020833-3c74-45fb-875d-7e0c359865bc', 56, 4, 'break_start', '2026-09-12 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (205, 1, 'fdde4c1f-45d6-4345-88b5-5090b5dd01dd', 56, 4, 'break_end', '2026-09-12 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (206, 1, '9fcd579d-fd8a-4089-8f7c-7a75c1840a5a', 56, 4, 'check_out', '2026-09-12 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (207, 1, '1a44e2ae-c332-4192-b227-d0df3d8592fb', 57, 5, 'check_in', '2026-09-12 05:38:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (208, 1, '116bb7b2-0cd2-484e-80d9-07f9a313fb3a', 57, 5, 'break_start', '2026-09-12 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (209, 1, '126a4efb-cd98-4f6c-9ffb-fde103a95b44', 57, 5, 'break_end', '2026-09-12 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (210, 1, 'b2049230-d9ba-4041-94fd-67a92da0a67c', 57, 5, 'check_out', '2026-09-12 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (211, 1, 'e3d1c9d2-d3fc-46ac-82c1-e21f7d3fe149', 58, 6, 'check_in', '2026-09-12 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (212, 1, '003ae050-6223-4a15-b00c-1e10ca81b108', 58, 6, 'break_start', '2026-09-12 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (213, 1, 'f0c74571-6f89-437c-960e-b590888abfc0', 58, 6, 'break_end', '2026-09-12 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (214, 1, 'b0e61731-f58a-4b67-8ddf-caf493603e20', 58, 6, 'check_out', '2026-09-12 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (215, 1, 'd1b18c0a-863e-4904-9aa3-3fd168d91d29', 59, 7, 'check_in', '2026-09-12 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (216, 1, '64bf9fcb-20f8-4cb8-8619-fcaf6de828f0', 59, 7, 'break_start', '2026-09-12 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (217, 1, '74f2d621-29d6-4543-977c-d3060275d997', 59, 7, 'break_end', '2026-09-12 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (218, 1, '5fc1353d-70f6-490b-b49e-9f0a44d8357c', 59, 7, 'check_out', '2026-09-12 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (219, 1, 'b0ef4575-7297-4c53-afbc-9b96b67a03a8', 60, 8, 'check_in', '2026-09-12 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (220, 1, '844a960a-5241-4134-b2cc-8eeba5d6e6d4', 60, 8, 'break_start', '2026-09-12 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (221, 1, '2971101f-a59b-4a39-842d-0e7160c7a304', 60, 8, 'break_end', '2026-09-12 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (222, 1, '6e23a104-d861-4573-a18d-7de6ea0a0d2e', 60, 8, 'check_out', '2026-09-12 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (223, 1, '87f82d44-a004-46e0-b2f2-3ecc942e4f24', 61, 9, 'check_in', '2026-09-12 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (224, 1, '4b458c3c-5b87-4cb9-bb81-14dc6859b392', 61, 9, 'break_start', '2026-09-12 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (225, 1, '03a6ea44-6342-4792-b41d-e696c8d192cd', 61, 9, 'break_end', '2026-09-12 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (226, 1, '6355a438-35e9-4ef4-aae3-9661840828d4', 61, 9, 'check_out', '2026-09-12 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (227, 1, 'e0d5d2bd-71f3-48af-850b-628bf39dc5cb', 62, 2, 'check_in', '2026-09-13 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (228, 1, 'cb71342b-7ea4-4f0e-8d07-4bb3ad341b74', 62, 2, 'break_start', '2026-09-13 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (229, 1, '366e278a-c12d-4e30-8c03-1f9f4d879e78', 62, 2, 'break_end', '2026-09-13 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (230, 1, '08376ce3-b0d7-47f1-8ebe-f9b4a8faca8e', 62, 2, 'check_out', '2026-09-13 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (231, 1, 'c8e3a4fb-5322-4caf-b3b7-257bb31a2a1b', 63, 3, 'check_in', '2026-09-13 05:36:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (232, 1, '19c864f1-4ae8-4edb-85f0-6424f4fe8f86', 63, 3, 'break_start', '2026-09-13 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (233, 1, 'f5a37284-3f74-4889-9eb1-73a126f835cf', 63, 3, 'break_end', '2026-09-13 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (234, 1, '6ae687dc-cbba-4458-a45c-ab90a4b278ad', 63, 3, 'check_out', '2026-09-13 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (235, 1, '6c3733ce-1b74-451d-b44b-c7f3a4b1e392', 65, 5, 'check_in', '2026-09-13 05:38:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (236, 1, '3e09d07d-4d78-4dc8-b69f-1883224bbdde', 65, 5, 'break_start', '2026-09-13 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (237, 1, '323e5ded-bbf6-440d-9f9f-1eb80e4664f0', 65, 5, 'break_end', '2026-09-13 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (238, 1, '994cf294-9aa9-4fcc-be54-534b511ac7cb', 65, 5, 'check_out', '2026-09-13 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (239, 1, 'b7a25a94-268d-4ba0-88da-3cefd6789550', 66, 6, 'check_in', '2026-09-13 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (240, 1, '560eea5a-3c56-448d-9f8a-07eeefbab52a', 66, 6, 'break_start', '2026-09-13 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (241, 1, 'c7294e42-3221-453c-a384-f3bf94d4853d', 66, 6, 'break_end', '2026-09-13 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (242, 1, '1c972133-f1e6-4aa1-b168-3da36f576f76', 66, 6, 'check_out', '2026-09-13 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (243, 1, '3dd64b87-94e6-4c32-84ec-d85e4c78ba1d', 67, 7, 'check_in', '2026-09-13 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (244, 1, '20e15ee6-91e9-4829-960e-e19cb588c77e', 67, 7, 'break_start', '2026-09-13 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (245, 1, '7c094627-46e0-4990-a857-c0974be286ae', 67, 7, 'break_end', '2026-09-13 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (246, 1, '1f8c8ddc-3402-45ed-a1c1-4c3c3651fb01', 67, 7, 'check_out', '2026-09-13 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (247, 1, '5e04030a-6c62-4a88-a62c-ba2375450fe9', 68, 8, 'check_in', '2026-09-13 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (248, 1, 'ae888548-15a8-4eeb-860d-b45d52c3e8c4', 68, 8, 'break_start', '2026-09-13 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (249, 1, '304aeb8d-bdb0-471b-bc96-64e2642d2663', 68, 8, 'break_end', '2026-09-13 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (250, 1, '4d62715c-85d9-4502-a72e-aa7b25c39453', 68, 8, 'check_out', '2026-09-13 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49');

INSERT INTO attendance_events (id, company_id, uuid, attendance_day_id, user_id, type, occurred_at, location, status, note, source, actor_id, ip, created_at, updated_at) VALUES
    (251, 1, '67db9dfd-928b-4a48-bc2d-1f682bc486f3', 69, 9, 'check_in', '2026-09-13 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (252, 1, '152664f5-5606-4cb7-b8a4-cb1687aa4a72', 69, 9, 'break_start', '2026-09-13 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (253, 1, 'c979bfef-0622-4ac5-9204-b9c7e6a1a5fb', 69, 9, 'break_end', '2026-09-13 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (254, 1, '546a5b5e-6b31-457a-ab00-39707f485177', 69, 9, 'check_out', '2026-09-13 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (255, 1, 'de3b5218-5f8f-4b7e-ae13-808cc04f1e1a', 70, 2, 'check_in', '2026-09-14 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (256, 1, '5346dfc5-d5f9-48a8-820c-734d3f437b29', 70, 2, 'break_start', '2026-09-14 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (257, 1, '0b1675ba-7f7b-4037-8304-7aae1ac179e1', 70, 2, 'break_end', '2026-09-14 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (258, 1, '61bbaa43-e881-4205-9767-716daccd9f95', 70, 2, 'check_out', '2026-09-14 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (259, 1, '0d77f9bf-d851-49ba-8d6a-324ff6d7306c', 71, 3, 'check_in', '2026-09-14 05:36:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (260, 1, '8e0182ed-7913-4334-b512-547900f48d9f', 71, 3, 'break_start', '2026-09-14 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (261, 1, 'c346a47f-2de5-4e33-9902-45378f489cd3', 71, 3, 'break_end', '2026-09-14 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (262, 1, 'd0ae6ee6-58ff-4c27-b030-1267db193e4a', 71, 3, 'check_out', '2026-09-14 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (263, 1, 'e3ff24e2-05a2-43d1-9c92-a31d40e14e2f', 72, 4, 'check_in', '2026-09-14 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (264, 1, '10f4c340-9dd3-4e14-bad6-4a01ce0a1c95', 72, 4, 'break_start', '2026-09-14 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (265, 1, '737d1c9a-62af-463f-a14a-1a0f01a315b2', 72, 4, 'break_end', '2026-09-14 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (266, 1, 'ad5f6e46-8cec-4430-b5d9-675ef993bfca', 72, 4, 'check_out', '2026-09-14 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (267, 1, 'ecedcb05-936c-4078-bde5-cfdf5640a2c3', 73, 5, 'check_in', '2026-09-14 05:58:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (268, 1, 'bc70273e-f48b-43b2-b2c0-eaf0c3ee5be7', 73, 5, 'break_start', '2026-09-14 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (269, 1, '2e2decf3-b775-4118-ad84-8da132ae867e', 73, 5, 'break_end', '2026-09-14 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (270, 1, '0069a8b2-af34-4540-ae1d-b354b571d624', 73, 5, 'check_out', '2026-09-14 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (271, 1, 'b54eefe4-7fd8-4e48-8687-feb75b8bf8bd', 74, 6, 'check_in', '2026-09-14 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (272, 1, '9cb965de-43be-4357-ad4f-b38abb16e2cd', 74, 6, 'break_start', '2026-09-14 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (273, 1, '9ee26a22-61e9-4310-97ae-30512e28e182', 74, 6, 'break_end', '2026-09-14 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (274, 1, '056ab361-d077-4314-a239-57b93e4a4f01', 74, 6, 'check_out', '2026-09-14 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (275, 1, '95406f90-cd52-4fe6-9ff9-8bd8d564a295', 75, 7, 'check_in', '2026-09-14 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (276, 1, 'e5bf225a-f2e8-4afc-aa9f-f2053ba38aca', 75, 7, 'break_start', '2026-09-14 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (277, 1, '3f8edca2-d920-47b1-9b03-bcba1a835911', 75, 7, 'break_end', '2026-09-14 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (278, 1, 'd0e4709a-5b43-40cc-b620-5dbbb51308c9', 75, 7, 'check_out', '2026-09-14 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (279, 1, '0a311155-9541-4126-bfd7-aee3d65ba7e8', 76, 8, 'check_in', '2026-09-14 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (280, 1, 'f29c1ac3-affc-4eb6-8007-7dba3aa0929b', 76, 8, 'break_start', '2026-09-14 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (281, 1, '5309d51e-041a-4b20-9398-c46bb3cdcc7c', 76, 8, 'break_end', '2026-09-14 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (282, 1, '8dacd78d-b28f-4874-9aae-045b4bc9cb9d', 76, 8, 'check_out', '2026-09-14 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (283, 1, 'a536c81d-5708-48ff-96b1-283ab44b920a', 77, 9, 'check_in', '2026-09-14 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (284, 1, '09ddc766-a685-4433-a74c-ab7e1895cece', 77, 9, 'break_start', '2026-09-14 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (285, 1, 'cd9ddcc1-787d-40d8-8347-ac8b91850760', 77, 9, 'break_end', '2026-09-14 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (286, 1, 'ff947afe-c737-464e-9ee3-9b833cec66ad', 77, 9, 'check_out', '2026-09-14 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (287, 1, '8af12dd7-e80e-429b-b3a6-c3bc1ae4e117', 78, 2, 'check_in', '2026-09-15 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (288, 1, '7178421d-b889-44fc-97d6-381c3757ad2c', 78, 2, 'break_start', '2026-09-15 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (289, 1, '8037f86b-3186-4237-a075-b16496b909fc', 78, 2, 'break_end', '2026-09-15 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (290, 1, 'a761c596-deb0-4421-a370-f78ae01141e8', 78, 2, 'check_out', '2026-09-15 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (291, 1, 'c77dc6b8-61f3-4f2c-a7be-3a15c909a006', 79, 3, 'check_in', '2026-09-15 05:36:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (292, 1, 'b96e22d0-ad97-4288-b87a-09814ec63be8', 79, 3, 'break_start', '2026-09-15 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (293, 1, '3352ec79-8a10-4490-91b3-08e256b8239c', 79, 3, 'break_end', '2026-09-15 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (294, 1, 'a32ee8be-be4d-4368-a2ee-dc13bb642a40', 79, 3, 'check_out', '2026-09-15 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (295, 1, 'a0fa63b7-881b-445a-b677-d2153029e491', 80, 4, 'check_in', '2026-09-15 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (296, 1, 'badca79c-1f22-4614-bf50-81360f886976', 80, 4, 'break_start', '2026-09-15 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (297, 1, 'd8d6b27b-10e3-42a3-889f-7e69aa95772d', 80, 4, 'break_end', '2026-09-15 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (298, 1, '9b84c3d5-8127-4b41-9f23-0d9f45285aa3', 80, 4, 'check_out', '2026-09-15 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (299, 1, '8bf6cfda-5ae8-424f-8113-2360eb98f182', 81, 5, 'check_in', '2026-09-15 05:38:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (300, 1, 'c4155c5e-ac24-4aa7-8f1c-5f9b717df502', 81, 5, 'break_start', '2026-09-15 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49');

INSERT INTO attendance_events (id, company_id, uuid, attendance_day_id, user_id, type, occurred_at, location, status, note, source, actor_id, ip, created_at, updated_at) VALUES
    (301, 1, '0f28fb12-def1-4a23-8d45-16ec0dcc98ac', 81, 5, 'break_end', '2026-09-15 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (302, 1, 'a6ebda65-efb1-46de-99ef-6f8d58a07d1e', 81, 5, 'check_out', '2026-09-15 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (303, 1, 'c6c1decc-fc92-43fa-bd15-53e136225449', 82, 6, 'check_in', '2026-09-15 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (304, 1, '8053138b-12ed-41ae-99d3-ab1a12cc28e0', 82, 6, 'break_start', '2026-09-15 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (305, 1, '90a5dd0a-7e24-4690-8501-6e1cf53c4846', 82, 6, 'break_end', '2026-09-15 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (306, 1, 'f23625bd-669a-4fbb-9fb1-dfe21ad7c231', 82, 6, 'check_out', '2026-09-15 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (307, 1, 'bfdc6d86-bc25-4ceb-9571-bb2259a48740', 83, 7, 'check_in', '2026-09-15 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (308, 1, '728c9641-ee9e-4342-a754-c6517b3f1524', 83, 7, 'break_start', '2026-09-15 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (309, 1, 'a92ed84f-cbd7-4d24-b81e-ac9a6208da1a', 83, 7, 'break_end', '2026-09-15 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (310, 1, '358118c0-af23-4480-a889-66c68f1f5277', 83, 7, 'check_out', '2026-09-15 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (311, 1, 'a43a97ea-3fdd-40cd-9451-262cc6fd34ec', 84, 8, 'check_in', '2026-09-15 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (312, 1, '891c9d4a-521f-4b8a-8467-669cb550cf4d', 84, 8, 'break_start', '2026-09-15 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (313, 1, '6901dad9-19bf-49b7-8eb7-7c0c975eff6c', 84, 8, 'break_end', '2026-09-15 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (314, 1, '52dbdacd-df10-4475-881a-e3598eb7eaa2', 84, 8, 'check_out', '2026-09-15 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (315, 1, 'f2d3711b-05ff-4df4-b935-f6ecb8bcc38d', 85, 9, 'check_in', '2026-09-15 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (316, 1, '9c51fc0a-bc23-4167-b905-c5c0f7afafd0', 85, 9, 'break_start', '2026-09-15 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (317, 1, '9c9d5416-e761-4796-b798-3277056d6e8a', 85, 9, 'break_end', '2026-09-15 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (318, 1, '3f6e4beb-9f0f-466c-a461-7c24f0396a0d', 85, 9, 'check_out', '2026-09-15 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (319, 1, 'cabbbd75-c324-46b1-b0b4-58d87fada33a', 86, 2, 'check_in', '2026-09-16 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (320, 1, '46e95c77-7aa3-48ab-a7f9-af88daf6d1a4', 86, 2, 'break_start', '2026-09-16 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (321, 1, '6101fc14-1d43-4f02-88b7-4f642ab78a0c', 86, 2, 'break_end', '2026-09-16 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (322, 1, 'ade6a928-b742-44e8-8a54-d88442f6fed5', 86, 2, 'check_out', '2026-09-16 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (323, 1, '8af37fb7-c8a8-4a0d-9c91-9da87bd4fa10', 87, 3, 'check_in', '2026-09-16 05:58:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (324, 1, '581b739c-f22b-4c33-8122-bb45cffc3f0a', 87, 3, 'break_start', '2026-09-16 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (325, 1, 'f35a3ed4-65e3-4b16-be2f-ab4db453c1fd', 87, 3, 'break_end', '2026-09-16 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (326, 1, '49ee857a-4a73-47d0-bb08-d02c9e56dca0', 87, 3, 'check_out', '2026-09-16 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (327, 1, '7da1f0f1-6fd9-46b3-8a50-82815eeda4e3', 88, 4, 'check_in', '2026-09-16 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (328, 1, '555548e2-8e35-41a7-b730-ae145eb173b7', 88, 4, 'break_start', '2026-09-16 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (329, 1, 'ca0df0c5-5088-4346-bf92-4f92edc4b676', 88, 4, 'break_end', '2026-09-16 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (330, 1, '11501db5-dedf-4066-a3b2-bdd77e1caffe', 88, 4, 'check_out', '2026-09-16 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (331, 1, 'a57e21a9-7f56-45ec-b799-2f2e7061d7b9', 89, 5, 'check_in', '2026-09-16 05:38:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (332, 1, 'c1581838-9c1f-44b8-8535-03405380ff6a', 89, 5, 'break_start', '2026-09-16 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (333, 1, 'c8ab3ba6-a418-4b1e-a960-fa3a269e3344', 89, 5, 'break_end', '2026-09-16 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (334, 1, '76ecf459-5905-42f2-97f1-5f10fa95ea47', 89, 5, 'check_out', '2026-09-16 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (335, 1, '3f07782a-a601-4d64-bf6d-797134370b1b', 90, 6, 'check_in', '2026-09-16 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (336, 1, '8ff039e1-8abf-4872-945c-fe74b5f65751', 90, 6, 'break_start', '2026-09-16 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (337, 1, '38e08e2d-4a7e-4d69-895c-0efa3f3cfa5d', 90, 6, 'break_end', '2026-09-16 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (338, 1, '63f00f53-6382-49f5-934c-16bcd1b189bf', 90, 6, 'check_out', '2026-09-16 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (339, 1, 'b1de409c-a1a6-4a67-ad4e-613d61f2210d', 91, 7, 'check_in', '2026-09-16 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (340, 1, '36fe05d7-cbb8-4b88-8c0f-04f59583bd52', 91, 7, 'break_start', '2026-09-16 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (341, 1, '0772e075-d2a6-49e0-92fc-4fa71978c632', 91, 7, 'break_end', '2026-09-16 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (342, 1, 'ebba9f51-8549-4e01-934b-259bc108752c', 91, 7, 'check_out', '2026-09-16 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (343, 1, '9b81a407-224c-477f-bfbd-4d72d2a05a0b', 92, 8, 'check_in', '2026-09-16 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (344, 1, '1e745d66-a469-46a2-9cdb-5c5f7a2c9e28', 92, 8, 'break_start', '2026-09-16 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (345, 1, '7e571688-d1de-4f84-ba2c-8e957c8fdd7c', 92, 8, 'break_end', '2026-09-16 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (346, 1, '7f4d9ca3-aae2-41e5-95e8-be7054f314ec', 92, 8, 'check_out', '2026-09-16 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (347, 1, '8b1165a1-59a5-4a20-b232-a5c19860ac8b', 93, 9, 'check_in', '2026-09-16 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (348, 1, '955e44ce-0414-4223-8dcf-24f34fdbcfca', 93, 9, 'break_start', '2026-09-16 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (349, 1, 'b0388fb1-67b0-4a6c-87e2-4e8244d93b57', 93, 9, 'break_end', '2026-09-16 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (350, 1, '96ccccda-2bb3-4451-b855-5d9133726749', 93, 9, 'check_out', '2026-09-16 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49');

INSERT INTO attendance_events (id, company_id, uuid, attendance_day_id, user_id, type, occurred_at, location, status, note, source, actor_id, ip, created_at, updated_at) VALUES
    (351, 1, '3aa2315a-2bd3-49d7-ae2e-eb04daaa7ef7', 94, 2, 'check_in', '2026-09-17 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (352, 1, '6054229e-1f22-4654-b3cb-f3f6fb7398bd', 94, 2, 'break_start', '2026-09-17 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (353, 1, '941e2bdd-db24-4291-861d-44322c4c50fa', 94, 2, 'break_end', '2026-09-17 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (354, 1, 'b2d5a96c-8521-4171-b289-5e9f5adcd395', 94, 2, 'check_out', '2026-09-17 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (355, 1, '552c96ad-e18e-4d36-8cbe-7081021a1259', 95, 3, 'check_in', '2026-09-17 05:36:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (356, 1, '4fea3e4b-6b19-4ecf-a152-e5134ff480ec', 95, 3, 'break_start', '2026-09-17 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (357, 1, 'c32ed2b3-3807-49ff-9afd-8a69a2e4786d', 95, 3, 'break_end', '2026-09-17 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (358, 1, '7cee2ff9-4f7c-40fb-b8ac-0df07b6afe21', 95, 3, 'check_out', '2026-09-17 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (359, 1, '7ec8d24c-b3f0-45b6-8db9-24ac26d41cc8', 96, 4, 'check_in', '2026-09-17 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (360, 1, 'f9cee65b-a132-495b-ad70-da7221065357', 96, 4, 'break_start', '2026-09-17 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (361, 1, 'c3e6bf3c-4b66-466e-9d56-15493837b682', 96, 4, 'break_end', '2026-09-17 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (362, 1, '29457b5f-82f6-4924-ae0d-1ddc9c472264', 96, 4, 'check_out', '2026-09-17 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (363, 1, '0b61607a-074b-4bdc-a263-a1e979049fe5', 97, 5, 'check_in', '2026-09-17 05:38:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (364, 1, '909c7e88-5166-40fb-9645-e1d8443da3ab', 97, 5, 'break_start', '2026-09-17 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (365, 1, '3cf4a187-35d5-4039-a30d-e92a23ff79db', 97, 5, 'break_end', '2026-09-17 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (366, 1, 'e8fec31e-3462-4f02-bd2d-d17d70cde7d1', 97, 5, 'check_out', '2026-09-17 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (367, 1, '217e6d9e-deed-4c34-8fe4-cc6a5294dbc0', 98, 6, 'check_in', '2026-09-17 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (368, 1, 'ddbe39b8-8dea-475e-b9de-7c4d033afe29', 98, 6, 'break_start', '2026-09-17 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (369, 1, 'b19df343-33fd-41b9-a66e-83248eca85a8', 98, 6, 'break_end', '2026-09-17 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (370, 1, '818abd27-c2e3-4c06-926e-1fcae193b15e', 98, 6, 'check_out', '2026-09-17 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (371, 1, 'eb78d274-173c-45e6-a037-67cdd1eace51', 100, 8, 'check_in', '2026-09-17 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (372, 1, '513d6058-3594-4b49-a528-81850f7317af', 100, 8, 'break_start', '2026-09-17 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (373, 1, 'dae7414a-5cf7-4f9e-b8d6-e526a834fb71', 100, 8, 'break_end', '2026-09-17 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (374, 1, '18962581-cfbf-4e02-bf04-9c479ea2dd65', 100, 8, 'check_out', '2026-09-17 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (375, 1, '4201b592-9a0e-45f9-bbe3-39e75cf8f8fe', 101, 9, 'check_in', '2026-09-17 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (376, 1, 'c9314e73-75f9-47b3-af93-938488fa0f87', 101, 9, 'break_start', '2026-09-17 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (377, 1, '835966a8-de1e-4379-852e-d0265030bf30', 101, 9, 'break_end', '2026-09-17 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (378, 1, '29be3097-f747-4e65-83a1-72adaf78a79b', 101, 9, 'check_out', '2026-09-17 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (379, 1, '99172946-08a0-4a65-9f24-8d4fbaccc540', 102, 2, 'check_in', '2026-09-19 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (380, 1, 'c0efe12b-ce77-4c74-8112-56c01ae9d950', 102, 2, 'break_start', '2026-09-19 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (381, 1, '24aea12b-3018-4028-90ea-fe22e44421a8', 102, 2, 'break_end', '2026-09-19 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:49', '2026-09-25 21:32:49'),
    (382, 1, 'a2259a22-b929-4db7-8269-390986eeaf85', 102, 2, 'check_out', '2026-09-19 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (383, 1, 'f418ccf1-7539-48f1-9ca0-b03d7ea2d172', 103, 3, 'check_in', '2026-09-19 05:36:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (384, 1, '1ec5a84f-6179-468e-9baa-60412c39ee93', 103, 3, 'break_start', '2026-09-19 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (385, 1, 'fae6ee42-5044-4230-b623-1e561d9459f8', 103, 3, 'break_end', '2026-09-19 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (386, 1, '56632291-7618-44d8-ac5d-fb8f196f070b', 103, 3, 'check_out', '2026-09-19 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (387, 1, 'efbe6bef-1f45-4637-a747-af081a8d5ac0', 104, 4, 'check_in', '2026-09-19 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (388, 1, 'f64f0d91-5ce8-45d4-9c3b-2c6b4e966743', 104, 4, 'break_start', '2026-09-19 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (389, 1, 'd98ca418-b5be-4f60-b423-488f65f95a8d', 104, 4, 'break_end', '2026-09-19 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (390, 1, '8a75a08b-6b6e-4ab6-9085-28fb19cce4ce', 104, 4, 'check_out', '2026-09-19 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (391, 1, 'f5b9d1ba-0665-49ae-9398-f4749582a809', 105, 5, 'check_in', '2026-09-19 05:58:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (392, 1, '31c7ca07-c727-435a-b489-517d0d1bed8f', 105, 5, 'break_start', '2026-09-19 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (393, 1, '5643777d-0a7e-44bd-ad12-5b8d598b6a7d', 105, 5, 'break_end', '2026-09-19 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (394, 1, '9031c0ad-fe5e-4dd6-8873-7a3f8139e05f', 105, 5, 'check_out', '2026-09-19 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (395, 1, '688bd272-67d4-4d54-bf2e-a75769bf0854', 106, 6, 'check_in', '2026-09-19 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (396, 1, '49ffbe13-789b-4066-bdd2-63c10ab56699', 106, 6, 'break_start', '2026-09-19 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (397, 1, '9aa1c4c5-87c2-4f6d-8506-10398cbf75aa', 106, 6, 'break_end', '2026-09-19 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (398, 1, '262bf1f0-f246-44b2-8d9f-19283b5f0a7e', 106, 6, 'check_out', '2026-09-19 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (399, 1, '45f1e69d-65d2-42c9-8a28-611aa30e9566', 107, 7, 'check_in', '2026-09-19 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (400, 1, '939f4eb8-8f7d-416c-bcaa-48dd59a9c3a7', 107, 7, 'break_start', '2026-09-19 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50');

INSERT INTO attendance_events (id, company_id, uuid, attendance_day_id, user_id, type, occurred_at, location, status, note, source, actor_id, ip, created_at, updated_at) VALUES
    (401, 1, 'db753e8a-5b9d-4f54-b1eb-1ac1cfea95e7', 107, 7, 'break_end', '2026-09-19 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (402, 1, 'ffdbad46-4ff8-4c71-8e0a-8fad74a794a6', 107, 7, 'check_out', '2026-09-19 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (403, 1, 'cedc3e1a-2935-4ce4-8607-970c62266e34', 108, 8, 'check_in', '2026-09-19 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (404, 1, 'b8191eb6-02cc-494c-a885-c1965c743744', 108, 8, 'break_start', '2026-09-19 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (405, 1, '7688ca5b-7a5c-4104-bb6d-5211d9cb26b9', 108, 8, 'break_end', '2026-09-19 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (406, 1, 'a8dbe2a0-789c-4325-9bea-fbda7dbaa645', 108, 8, 'check_out', '2026-09-19 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (407, 1, 'e453173b-5e5f-42f5-a8de-9ed5ec9bad02', 109, 9, 'check_in', '2026-09-19 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (408, 1, '96ca8a21-f3ae-4305-b665-eb1bc8100a94', 109, 9, 'break_start', '2026-09-19 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (409, 1, '2e604de1-4a2c-4439-8491-cce52d4bdb6f', 109, 9, 'break_end', '2026-09-19 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (410, 1, 'f0cc8b58-aabd-4df5-b490-e7bd4b689421', 109, 9, 'check_out', '2026-09-19 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (411, 1, '834da41a-4ce4-4c86-b283-cf09e7947617', 110, 2, 'check_in', '2026-09-20 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (412, 1, '0914edbe-f92b-4b19-bde7-e607cc5abc83', 110, 2, 'break_start', '2026-09-20 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (413, 1, '047b137f-cb2e-4abd-aeb8-3f9be9770717', 110, 2, 'break_end', '2026-09-20 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (414, 1, '6f8bb5c9-9eaf-407a-a83f-abb7eefb129c', 110, 2, 'check_out', '2026-09-20 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (415, 1, '6a9d54de-fae0-45a3-aad7-dcb2a93cb3a6', 111, 3, 'check_in', '2026-09-20 05:36:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (416, 1, '7bae9dff-1fdb-4bba-8da8-fbc5bf3d6e7b', 111, 3, 'break_start', '2026-09-20 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (417, 1, '16e9a713-ff49-447f-905c-9d039f802e34', 111, 3, 'break_end', '2026-09-20 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (418, 1, '473b781c-38f3-413b-ae83-508efa3d78e5', 111, 3, 'check_out', '2026-09-20 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (419, 1, '74ba2294-9ea1-439e-8ba5-f35354009371', 112, 4, 'check_in', '2026-09-20 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (420, 1, 'a1f4bebe-966f-47ff-be02-016584879e60', 112, 4, 'break_start', '2026-09-20 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (421, 1, 'd69fc672-e40d-4fc3-92a8-e1a57223818b', 112, 4, 'break_end', '2026-09-20 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (422, 1, 'c7fa16c0-6371-46b5-acdf-8dc38aca6861', 112, 4, 'check_out', '2026-09-20 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (423, 1, '8d3fdea0-8008-4680-bc0d-5a3c640c951a', 113, 5, 'check_in', '2026-09-20 05:38:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (424, 1, '8a668cb2-4d2c-4d32-ba2b-90264c4b2f9d', 113, 5, 'break_start', '2026-09-20 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (425, 1, '7d179f95-96b9-4c2d-9f84-b08392e91efd', 113, 5, 'break_end', '2026-09-20 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (426, 1, '1728a334-c83b-4729-999e-7c2b4ddd7003', 113, 5, 'check_out', '2026-09-20 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (427, 1, '6149387c-d9dc-4742-a10e-a62b06e31a57', 114, 6, 'check_in', '2026-09-20 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (428, 1, '553ce7a7-9613-4943-8df1-efe535b1c855', 114, 6, 'break_start', '2026-09-20 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (429, 1, '2129f7ed-1eb7-4dd4-a177-c4715eebadd7', 114, 6, 'break_end', '2026-09-20 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (430, 1, 'd77b6d08-a4ed-4beb-a796-9b5e211a5352', 114, 6, 'check_out', '2026-09-20 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (431, 1, '98259133-a342-4aa7-84ff-11886b50ab3e', 115, 7, 'check_in', '2026-09-20 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (432, 1, 'c4a7d21d-8b6f-4c47-882b-87808c61e0dc', 115, 7, 'break_start', '2026-09-20 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (433, 1, 'ee104c3e-2a63-4a6a-9294-29a535afaa82', 115, 7, 'break_end', '2026-09-20 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (434, 1, 'a575438e-11c4-4157-ab6d-74156ac13af9', 115, 7, 'check_out', '2026-09-20 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (435, 1, 'a658e159-e740-40a1-a1b9-97981c7a84c8', 116, 8, 'check_in', '2026-09-20 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (436, 1, 'ab194a2c-f957-4980-9592-74aafde4fa44', 116, 8, 'break_start', '2026-09-20 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (437, 1, 'dd82ae4f-a2ad-4233-9a2b-875464707de9', 116, 8, 'break_end', '2026-09-20 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (438, 1, '96a5424d-1570-4c2c-8653-8db717535b1b', 116, 8, 'check_out', '2026-09-20 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (439, 1, 'dea9ab2a-d8b0-4cf8-b612-112628eebebf', 117, 9, 'check_in', '2026-09-20 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (440, 1, 'e25f303f-6d2f-41ea-9c3c-e5af231b19cb', 117, 9, 'break_start', '2026-09-20 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (441, 1, '0e25dfb4-1a11-45db-993b-8f6fc9f559e7', 117, 9, 'break_end', '2026-09-20 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (442, 1, 'b933edd0-31f3-4253-8b04-304db9df873c', 117, 9, 'check_out', '2026-09-20 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (443, 1, '55b7f425-e194-4c18-924c-5e899be71d42', 118, 2, 'check_in', '2026-09-21 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (444, 1, '35af4856-17d9-44a9-96ea-935d6d46c0be', 118, 2, 'break_start', '2026-09-21 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (445, 1, '1a29ed6f-2ef5-4358-a06a-bd138a516250', 118, 2, 'break_end', '2026-09-21 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (446, 1, '564e5e4f-9aaa-464c-8d3b-c5478157bc09', 118, 2, 'check_out', '2026-09-21 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (447, 1, '86f46c5f-0539-4f4f-b872-0db523497ee7', 119, 3, 'check_in', '2026-09-21 05:36:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (448, 1, '332fa5cb-3932-451c-a93c-aa2a931d3ab7', 119, 3, 'break_start', '2026-09-21 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (449, 1, 'ed1b5ba0-adeb-489a-9fa0-fec411eedec6', 119, 3, 'break_end', '2026-09-21 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (450, 1, '9346d123-4984-4ecb-bd29-4c4b1eff59b8', 119, 3, 'check_out', '2026-09-21 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50');

INSERT INTO attendance_events (id, company_id, uuid, attendance_day_id, user_id, type, occurred_at, location, status, note, source, actor_id, ip, created_at, updated_at) VALUES
    (451, 1, '3e20ed68-95e3-4fb1-aa19-b980665c5ed2', 120, 4, 'check_in', '2026-09-21 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (452, 1, 'd09fa5d1-93b6-4fda-9485-5d1bd66389a1', 120, 4, 'break_start', '2026-09-21 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (453, 1, '85c89ba8-bcbb-4cf6-a53b-3a99873a805d', 120, 4, 'break_end', '2026-09-21 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (454, 1, '74b14d0a-c32c-4f7e-99ed-92fd31923cfe', 120, 4, 'check_out', '2026-09-21 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (455, 1, '8de521fc-a76c-498b-8167-fcf44422ff8c', 121, 5, 'check_in', '2026-09-21 05:38:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (456, 1, '286bcf6c-947f-49b8-8293-f67758b91b14', 121, 5, 'break_start', '2026-09-21 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (457, 1, '1135bdd3-9a36-405f-b362-be9745d1dd86', 121, 5, 'break_end', '2026-09-21 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (458, 1, '036450c2-7eb8-4f72-8c36-98e77f9630a4', 121, 5, 'check_out', '2026-09-21 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (459, 1, '159cf40c-497e-460a-a408-4201381c1de1', 122, 6, 'check_in', '2026-09-21 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (460, 1, 'edee9b18-f63f-4267-82b8-4d2fbbdbe044', 122, 6, 'break_start', '2026-09-21 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (461, 1, 'ec0e3a7c-5501-4f42-9227-d8b6da8449d7', 122, 6, 'break_end', '2026-09-21 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (462, 1, '9fbfb5b4-e4b0-4b42-b2c6-4c87851b2178', 122, 6, 'check_out', '2026-09-21 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (463, 1, '97455f92-c2a0-4497-a890-a7a97f94d904', 123, 7, 'check_in', '2026-09-21 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (464, 1, '447236f5-6437-4a1f-ae1a-9d5c880bd23e', 123, 7, 'break_start', '2026-09-21 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (465, 1, '0324e82e-d916-42c4-9302-05b698ec9e51', 123, 7, 'break_end', '2026-09-21 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (466, 1, 'c4da27fa-4d22-4cc3-8bf1-14adc017be40', 123, 7, 'check_out', '2026-09-21 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (467, 1, 'd5c1f190-a437-4f19-a510-9984ebd14284', 124, 8, 'check_in', '2026-09-21 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (468, 1, '0f6fc606-5724-48f7-bdf5-eb039d57b7f9', 124, 8, 'break_start', '2026-09-21 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (469, 1, '97bfad6a-1c39-4e90-a43b-7ab1c4169f17', 124, 8, 'break_end', '2026-09-21 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (470, 1, '34cf9ca8-242b-4b11-81b1-920b8d9c18c4', 124, 8, 'check_out', '2026-09-21 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (471, 1, '511a65fa-3539-44bd-94f7-84e8083e8e39', 125, 9, 'check_in', '2026-09-21 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (472, 1, 'b703c226-e8be-4140-8c31-80d56f6d2f3f', 125, 9, 'break_start', '2026-09-21 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (473, 1, '0af9c3f7-f9f0-42ae-8316-8b883c7df606', 125, 9, 'break_end', '2026-09-21 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (474, 1, 'c08b531b-b0ec-4770-9b7f-6572da5cdc4f', 125, 9, 'check_out', '2026-09-21 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (475, 1, 'fb74b466-129e-4d4e-add7-85de83985ec3', 126, 2, 'check_in', '2026-09-22 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (476, 1, '7cd783d8-044d-49b9-a8b5-291a4252cc64', 126, 2, 'break_start', '2026-09-22 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (477, 1, 'e5ed49cb-3308-41b6-a454-2d9190585ec0', 126, 2, 'break_end', '2026-09-22 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (478, 1, 'fc760593-72a5-4c61-a053-1581dcb663bf', 126, 2, 'check_out', '2026-09-22 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (479, 1, '96567fb3-9391-414f-ad9c-865f874c373b', 127, 3, 'check_in', '2026-09-22 05:58:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (480, 1, 'ffce5501-9f2e-456a-9881-4bb6ea5a3522', 127, 3, 'break_start', '2026-09-22 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (481, 1, 'c9422498-56f0-40ad-bce6-316b7636bad3', 127, 3, 'break_end', '2026-09-22 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (482, 1, 'be1e99ca-f283-4ed3-bdd1-486961098df7', 127, 3, 'check_out', '2026-09-22 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (483, 1, '383da774-d936-40cf-aeb5-4d26936fe575', 128, 4, 'check_in', '2026-09-22 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (484, 1, 'c839b0b1-afcc-4b93-b99a-fe495acd6b75', 128, 4, 'break_start', '2026-09-22 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (485, 1, '665115d4-cd3a-4ac1-aec0-51f5de4ba4d3', 128, 4, 'break_end', '2026-09-22 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (486, 1, 'cb763e40-fb12-4c72-b64a-40011c2e4f03', 128, 4, 'check_out', '2026-09-22 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (487, 1, 'c6a40872-01e5-4ebc-93db-6ad8c46a28c9', 129, 5, 'check_in', '2026-09-22 05:38:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (488, 1, '0dde008e-9dcc-4121-9217-a43ce15952f7', 129, 5, 'break_start', '2026-09-22 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (489, 1, '4eb5ac51-8422-49b9-86a9-f7db19cbf22e', 129, 5, 'break_end', '2026-09-22 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (490, 1, '934d581d-d4ba-4874-9954-bea27a7a9d3e', 129, 5, 'check_out', '2026-09-22 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (491, 1, '1a0f4735-7184-4a2a-998a-1073c91b6690', 130, 6, 'check_in', '2026-09-22 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (492, 1, '6ad9a825-c9d3-4717-92d0-149556e80262', 130, 6, 'break_start', '2026-09-22 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (493, 1, 'a876e3c2-c827-40bd-820f-4a3d1e9e1153', 130, 6, 'break_end', '2026-09-22 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (494, 1, 'da6deebc-1de2-4438-ac97-c3a19d0fc37d', 130, 6, 'check_out', '2026-09-22 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (495, 1, '25fb83c5-037f-4373-85f7-79865ea981f0', 131, 7, 'check_in', '2026-09-22 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (496, 1, 'bd162c4e-b23f-4750-a35b-629acdbbb14d', 131, 7, 'break_start', '2026-09-22 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (497, 1, '9701fe5e-7e7e-48ad-8feb-0c9464a3b41e', 131, 7, 'break_end', '2026-09-22 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (498, 1, 'e0ea5098-9800-4997-805c-069ca09e86be', 131, 7, 'check_out', '2026-09-22 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (499, 1, '87129520-f6c3-4f55-aa68-f0542d816f36', 132, 8, 'check_in', '2026-09-22 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (500, 1, 'fdf15973-40e4-41c5-945c-1591c5bd7bd0', 132, 8, 'break_start', '2026-09-22 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50');

INSERT INTO attendance_events (id, company_id, uuid, attendance_day_id, user_id, type, occurred_at, location, status, note, source, actor_id, ip, created_at, updated_at) VALUES
    (501, 1, 'fc2c9e63-976c-4571-91f2-9a5e732bad5c', 132, 8, 'break_end', '2026-09-22 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (502, 1, 'c0d1e604-6d98-462f-a31b-24eba1f8e9e1', 132, 8, 'check_out', '2026-09-22 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (503, 1, '635f1589-84f9-4238-83eb-24b510480983', 133, 9, 'check_in', '2026-09-22 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (504, 1, '3ef9dd64-a7b5-4c11-9736-9dc34703a5b8', 133, 9, 'break_start', '2026-09-22 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (505, 1, 'a8d8f652-3de6-4fb5-8ab4-575ef220848f', 133, 9, 'break_end', '2026-09-22 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (506, 1, '9a9acfb8-1846-437f-84e9-c9abb492525e', 133, 9, 'check_out', '2026-09-22 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (507, 1, '55aef971-ff14-414f-9c78-671c10f7b901', 134, 2, 'check_in', '2026-09-23 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (508, 1, 'aa34ff20-103a-43ce-bea3-eace3198a509', 134, 2, 'break_start', '2026-09-23 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (509, 1, 'ce3be52b-95f5-4821-b53e-603835aa5dc2', 134, 2, 'break_end', '2026-09-23 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (510, 1, 'b89a1f0b-bec3-4f4d-9f4c-607cd8b23349', 134, 2, 'check_out', '2026-09-23 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (511, 1, 'd68b5b2d-a282-4fcc-a61e-2a444381ff51', 135, 3, 'check_in', '2026-09-23 05:36:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (512, 1, 'e5f4e284-dbad-40c6-8496-39edd132334f', 135, 3, 'break_start', '2026-09-23 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (513, 1, '3228c07b-5b49-4d2e-adff-0da47b0f9629', 135, 3, 'break_end', '2026-09-23 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (514, 1, '4ddc4c52-fee6-4d2b-883b-8a88f5542940', 135, 3, 'check_out', '2026-09-23 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (515, 1, '711d1bd7-efe7-43dc-a0b0-12e9d0a20879', 136, 4, 'check_in', '2026-09-23 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (516, 1, 'fe4393a8-e0c8-40a8-8511-5b72db810376', 136, 4, 'break_start', '2026-09-23 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (517, 1, 'b6d77568-f6c3-4a22-8312-d0ba74edaead', 136, 4, 'break_end', '2026-09-23 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (518, 1, '11efb746-c7cf-478d-9ece-6d400e6859e4', 136, 4, 'check_out', '2026-09-23 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (519, 1, '9d060a04-d10e-4ae0-a276-2d160169ce84', 137, 5, 'check_in', '2026-09-23 05:58:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (520, 1, 'f1e5cf42-d7bf-4356-8d73-73da1065b76e', 137, 5, 'break_start', '2026-09-23 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (521, 1, '56c2b082-0eb6-4838-8a4d-ed2ffaec1eba', 137, 5, 'break_end', '2026-09-23 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (522, 1, '74e21099-6235-45e2-8db7-7594b8b6d689', 137, 5, 'check_out', '2026-09-23 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (523, 1, '6ef5d27a-2374-4701-b310-9401e44b48a7', 138, 6, 'check_in', '2026-09-23 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (524, 1, '968aaefd-bd86-48fe-979c-4163c36dd50d', 138, 6, 'break_start', '2026-09-23 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (525, 1, 'fcb80aec-9882-4213-b704-2ce3fa0eff3a', 138, 6, 'break_end', '2026-09-23 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (526, 1, 'adc3f62d-04f2-4625-87fe-3e6d5da4b58f', 138, 6, 'check_out', '2026-09-23 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (527, 1, '12be3b1b-f655-4f4a-a72c-ea7753bcbc8a', 139, 7, 'check_in', '2026-09-23 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (528, 1, 'ad923f7f-1bd9-462a-b9fb-5ffbb9b19e2c', 139, 7, 'break_start', '2026-09-23 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (529, 1, 'd1c023fe-f83b-4390-ad59-51a795357a70', 139, 7, 'break_end', '2026-09-23 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (530, 1, '70db209e-1e68-4015-b79a-82cf459eef6e', 139, 7, 'check_out', '2026-09-23 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (531, 1, 'f0172093-86d7-47d0-9e2a-52a86a0b4d26', 140, 8, 'check_in', '2026-09-23 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (532, 1, '80b054aa-2918-453b-a605-fa13f3dd9f6e', 140, 8, 'break_start', '2026-09-23 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (533, 1, 'e2cdc466-a27d-4885-a72d-dfbd0951fe42', 140, 8, 'break_end', '2026-09-23 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (534, 1, '4219b4ab-b3c0-4492-9b9e-e56f243ad895', 140, 8, 'check_out', '2026-09-23 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (535, 1, 'a6303c59-64bd-4dd1-90e1-ca6299feb387', 141, 9, 'check_in', '2026-09-23 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (536, 1, '80099680-a039-4fd6-9114-aff1cb0e0a2b', 141, 9, 'break_start', '2026-09-23 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (537, 1, 'fd0ed1b5-c05a-42af-8985-9a4dec60d135', 141, 9, 'break_end', '2026-09-23 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (538, 1, 'c0e000c9-5bd9-42ec-bd01-ca020e7a5abc', 141, 9, 'check_out', '2026-09-23 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (539, 1, 'd9ecadc3-ac47-4898-b1f2-06ad93fbcc9c', 142, 2, 'check_in', '2026-09-24 05:20:00', 'office', NULL, NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (540, 1, '80019dda-c2de-47fa-b420-4187e585ddc0', 142, 2, 'break_start', '2026-09-24 09:30:00', 'office', 'break', NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (541, 1, '82345399-c789-4fe2-bca0-8905268cb7bc', 142, 2, 'break_end', '2026-09-24 10:30:00', 'office', 'office', NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (542, 1, '4085ca9c-a3ef-4331-a7a7-9f5455f95146', 142, 2, 'check_out', '2026-09-24 13:40:00', 'office', 'off', NULL, 'self', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (543, 1, '43cc5b68-2ba7-479e-b771-f3467f15d178', 143, 3, 'check_in', '2026-09-24 05:36:00', 'remote', NULL, NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (544, 1, '8c2c96b2-f178-4acc-b188-29d344c439c3', 143, 3, 'break_start', '2026-09-24 09:30:00', 'remote', 'break', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (545, 1, 'f18f8c4a-c54d-4ff5-b193-a576b2b8677b', 143, 3, 'break_end', '2026-09-24 10:25:00', 'remote', 'remote', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (546, 1, 'c2541b81-e794-4365-bac6-1d5cf46b1c1b', 143, 3, 'check_out', '2026-09-24 13:50:00', 'remote', 'off', NULL, 'self', 3, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (547, 1, '03122351-4574-4c4c-9422-7d11dd50d328', 143, 3, 'correction', '2026-09-24 13:50:00', 'remote', NULL, 'اصلاح ساعت توسط مدیر', 'correction', 2, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (548, 1, 'bb1387c4-4262-40e5-bc3e-343524aa1a20', 144, 4, 'check_in', '2026-09-24 05:34:00', 'office', NULL, NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (549, 1, '02c329e8-0cd3-4029-ba16-1e3ac14ec566', 144, 4, 'break_start', '2026-09-24 09:30:00', 'office', 'break', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (550, 1, 'f31467a5-a9ad-43d2-be21-cd3d3f6f2459', 144, 4, 'break_end', '2026-09-24 10:30:00', 'office', 'office', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50');

INSERT INTO attendance_events (id, company_id, uuid, attendance_day_id, user_id, type, occurred_at, location, status, note, source, actor_id, ip, created_at, updated_at) VALUES
    (551, 1, '87efa664-e474-4c2b-98df-73f76c9545f8', 144, 4, 'check_out', '2026-09-24 13:30:00', 'office', 'off', NULL, 'self', 4, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (552, 1, '9f5c4a45-453a-4bc1-9eed-23c703f0b527', 145, 5, 'check_in', '2026-09-24 05:38:00', 'office', NULL, NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (553, 1, '569ef124-e510-4974-8b9f-8ad75dfa1a1a', 145, 5, 'break_start', '2026-09-24 09:30:00', 'office', 'break', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (554, 1, 'a89aab06-3229-4404-8016-35715e57246c', 145, 5, 'break_end', '2026-09-24 10:30:00', 'office', 'office', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (555, 1, 'a3872127-5fdb-44d5-b62f-5845215d7c0e', 145, 5, 'check_out', '2026-09-24 13:35:00', 'office', 'off', NULL, 'self', 5, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (556, 1, '28e4ce03-4284-4212-ace3-914d05ee97f4', 146, 6, 'check_in', '2026-09-24 05:30:00', 'office', NULL, NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (557, 1, '95a70043-c583-4215-b792-48503c302aea', 146, 6, 'break_start', '2026-09-24 09:30:00', 'office', 'break', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (558, 1, '022efbb4-a3c1-4039-908e-dfb35b87bc17', 146, 6, 'break_end', '2026-09-24 10:15:00', 'office', 'office', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (559, 1, '2a284716-921f-491e-a7ce-9f791cf72efb', 146, 6, 'check_out', '2026-09-24 13:10:00', 'office', 'off', NULL, 'self', 6, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (560, 1, 'cd6fcd8b-f24e-4385-8048-dfe12773b82b', 147, 7, 'check_in', '2026-09-24 05:42:00', 'office', NULL, NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (561, 1, 'e92b4c6e-4c18-4ae4-9a23-24c7ebda5b54', 147, 7, 'break_start', '2026-09-24 09:30:00', 'office', 'break', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (562, 1, 'ca829ae7-8658-491d-8ef1-0870892babfd', 147, 7, 'break_end', '2026-09-24 10:30:00', 'office', 'office', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (563, 1, '7da3d2af-8514-4095-998d-84044c13da89', 147, 7, 'check_out', '2026-09-24 13:30:00', 'office', 'off', NULL, 'self', 7, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (564, 1, '61ff6eee-7eb9-4fd8-b84a-1c2da3e4bb9b', 148, 8, 'check_in', '2026-09-24 05:25:00', 'office', NULL, NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (565, 1, '2d7ad521-4ecf-4133-a1dc-5b4c7e70dab2', 148, 8, 'break_start', '2026-09-24 09:30:00', 'office', 'break', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (566, 1, '1b6ba609-0347-48cc-b6dc-bd3087e5e2e5', 148, 8, 'break_end', '2026-09-24 10:30:00', 'office', 'office', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (567, 1, '0c2211d0-8603-4d5c-a71d-ce8400314bef', 148, 8, 'check_out', '2026-09-24 13:45:00', 'office', 'off', NULL, 'self', 8, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (568, 1, 'dabbe029-221c-4f95-977a-897f70ad00cc', 149, 9, 'check_in', '2026-09-24 05:31:00', 'office', NULL, NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (569, 1, 'd34b01af-3c0e-4150-b40e-aba1d5cad527', 149, 9, 'break_start', '2026-09-24 09:30:00', 'office', 'break', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (570, 1, '9376801f-1d4f-43a9-9ecc-0ceb760bc1e4', 149, 9, 'break_end', '2026-09-24 10:30:00', 'office', 'office', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (571, 1, '930b58d2-b571-46ee-9619-9317d91e88a7', 149, 9, 'check_out', '2026-09-24 13:30:00', 'office', 'off', NULL, 'self', 9, NULL, '2026-09-25 21:32:50', '2026-09-25 21:32:50');

SELECT setval(pg_get_serial_sequence('attendance_events', 'id'), COALESCE((SELECT MAX(id) FROM attendance_events), 1), true);

-- work_presences
INSERT INTO work_presences (id, company_id, user_id, status, resume_status, note, since, created_at, updated_at) VALUES
    (1, 1, 2, 'office', NULL, 'شروع روز در دفتر', '2026-09-25 21:32:48', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (2, 1, 3, 'remote', NULL, NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (3, 1, 4, 'break', 'office', NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (4, 1, 6, 'mission', 'office', 'جلسه با مشتری', '2026-09-25 21:32:48', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (5, 1, 9, 'leave', 'office', 'مرخصی ساعتی', '2026-09-25 21:32:48', '2026-09-25 21:32:48', '2026-09-25 21:32:48');

SELECT setval(pg_get_serial_sequence('work_presences', 'id'), COALESCE((SELECT MAX(id) FROM work_presences), 1), true);

-- daily_reports
INSERT INTO daily_reports (id, company_id, uuid, user_id, work_date, kind, body, blockers, submitted_at, created_at, updated_at) VALUES
    (1, 1, '0e640a53-e769-419e-8664-3c69ab076db7', 3, '2026-09-26 00:00:00', 'morning', 'امروز روی هستهٔ حضور و گزارش روزانه کار می‌کنم.', NULL, '2026-09-25 21:32:48', '2026-09-25 21:32:48', '2026-09-25 21:32:48'),
    (2, 1, 'efb6bfd4-ac76-48c5-9516-60c106eed8fa', 2, '2026-09-21 00:00:00', 'morning', 'سارا محمدی — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.', NULL, '2026-09-21 05:40:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (3, 1, '66a924d5-f88f-4cd4-ae61-23a3d9a81482', 2, '2026-09-21 00:00:00', 'daily', 'سارا محمدی — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.', NULL, '2026-09-21 13:25:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (4, 1, '7d9c0186-5a11-4780-9924-a9eb9939c4d3', 3, '2026-09-21 00:00:00', 'morning', 'آرمان کاظمی — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.', NULL, '2026-09-21 05:56:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (5, 1, '3584939a-105c-4a52-89c5-494bb2523809', 3, '2026-09-21 00:00:00', 'daily', 'آرمان کاظمی — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.', NULL, '2026-09-21 13:35:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (6, 1, 'd99ac3ad-b62d-46a8-87fb-084ea15ef04a', 5, '2026-09-21 00:00:00', 'morning', 'حسین مرادی — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.', NULL, '2026-09-21 05:58:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (7, 1, 'c5e838ce-3107-4462-841c-7672a875332e', 5, '2026-09-21 00:00:00', 'daily', 'حسین مرادی — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.', NULL, '2026-09-21 13:20:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (8, 1, 'd7fa1ac4-1a50-464c-8ab0-8332c3d8a7fd', 9, '2026-09-21 00:00:00', 'morning', 'رضا شریفی — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.', NULL, '2026-09-21 05:51:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (9, 1, '82420f58-287d-46c3-899d-83f159467f1f', 9, '2026-09-21 00:00:00', 'daily', 'رضا شریفی — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.', NULL, '2026-09-21 13:15:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (10, 1, '17fea181-2190-46b2-9534-d6f2882d68ba', 2, '2026-09-22 00:00:00', 'morning', 'سارا محمدی — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.', NULL, '2026-09-22 05:40:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (11, 1, '53845933-52ea-4a6f-92f3-bba23427f93d', 2, '2026-09-22 00:00:00', 'daily', 'سارا محمدی — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.', NULL, '2026-09-22 13:25:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (12, 1, 'aa0f7720-ba5f-4498-b166-9e3bcaf895af', 3, '2026-09-22 00:00:00', 'morning', 'آرمان کاظمی — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.', NULL, '2026-09-22 06:18:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (13, 1, 'fe88e2d9-eb51-4bdd-bcbb-91b1390cab2c', 3, '2026-09-22 00:00:00', 'daily', 'آرمان کاظمی — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.', NULL, '2026-09-22 13:35:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (14, 1, 'b191b4bc-4ac9-4a9f-9f98-a7e9a7639656', 5, '2026-09-22 00:00:00', 'morning', 'حسین مرادی — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.', NULL, '2026-09-22 05:58:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (15, 1, '9fcb3518-87eb-4db8-b7b5-80940cbb1cf5', 5, '2026-09-22 00:00:00', 'daily', 'حسین مرادی — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.', NULL, '2026-09-22 13:20:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (16, 1, '25e036e1-fd8d-4000-a06b-f31b1e1e4c1d', 9, '2026-09-22 00:00:00', 'morning', 'رضا شریفی — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.', NULL, '2026-09-22 05:51:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (17, 1, '8aa31569-0828-46e4-8f08-439341900c52', 9, '2026-09-22 00:00:00', 'daily', 'رضا شریفی — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.', NULL, '2026-09-22 13:15:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (18, 1, '3aa4063d-0b0c-4d6b-83b7-74cdae054152', 2, '2026-09-23 00:00:00', 'morning', 'سارا محمدی — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.', NULL, '2026-09-23 05:40:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (19, 1, '30dc73b5-c0db-4411-8487-5cf7af52d990', 2, '2026-09-23 00:00:00', 'daily', 'سارا محمدی — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.', NULL, '2026-09-23 13:25:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (20, 1, '6d6ff842-aa4c-4893-89f4-71ac8a2bcabc', 3, '2026-09-23 00:00:00', 'morning', 'آرمان کاظمی — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.', NULL, '2026-09-23 05:56:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (21, 1, 'b6cd6409-7768-411c-bf0a-138215e08e23', 3, '2026-09-23 00:00:00', 'daily', 'آرمان کاظمی — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.', NULL, '2026-09-23 13:35:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (22, 1, '3c04ef51-7dbf-47c1-aa6f-f9459b3e3b26', 5, '2026-09-23 00:00:00', 'morning', 'حسین مرادی — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.', NULL, '2026-09-23 06:18:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (23, 1, 'b1202bdc-11db-460b-88bd-0b5f004fdeb9', 5, '2026-09-23 00:00:00', 'daily', 'حسین مرادی — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.', NULL, '2026-09-23 13:20:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (24, 1, 'faf2f2b3-c34c-4188-8689-0fa379e25618', 9, '2026-09-23 00:00:00', 'morning', 'رضا شریفی — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.', NULL, '2026-09-23 05:51:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (25, 1, 'edfd0379-9f32-4610-b1d8-a24c4da3f5d6', 9, '2026-09-23 00:00:00', 'daily', 'رضا شریفی — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.', NULL, '2026-09-23 13:15:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (26, 1, '2e228312-83d5-4428-8b8d-95f1fafce4ba', 2, '2026-09-24 00:00:00', 'morning', 'سارا محمدی — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.', NULL, '2026-09-24 05:40:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (27, 1, 'b0e39e39-b3cd-4e3b-855d-052d95b70896', 2, '2026-09-24 00:00:00', 'daily', 'سارا محمدی — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.', NULL, '2026-09-24 13:25:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (28, 1, 'a46b9568-f006-4fc7-95b0-df2295f9b710', 3, '2026-09-24 00:00:00', 'morning', 'آرمان کاظمی — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.', NULL, '2026-09-24 05:56:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (29, 1, '5cd5103c-4081-4c13-ae4c-9d5d91610d87', 3, '2026-09-24 00:00:00', 'daily', 'آرمان کاظمی — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.', NULL, '2026-09-24 13:35:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (30, 1, '225ff7c9-4f5e-43e3-ba58-5634eac60223', 5, '2026-09-24 00:00:00', 'morning', 'حسین مرادی — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.', NULL, '2026-09-24 05:58:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (31, 1, '581cc474-090e-4250-a8a4-f015d08dbb59', 5, '2026-09-24 00:00:00', 'daily', 'حسین مرادی — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.', NULL, '2026-09-24 13:20:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (32, 1, '7845902d-d3da-4849-a7d1-e8c910fbb3d8', 9, '2026-09-24 00:00:00', 'morning', 'رضا شریفی — برنامهٔ امروز: وظایف باز، هماهنگی با تیم و ثبت گزارش پایان روز.', NULL, '2026-09-24 05:51:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50'),
    (33, 1, 'b3b290b8-3ec9-4bc0-b494-54bc19e93ef6', 9, '2026-09-24 00:00:00', 'daily', 'رضا شریفی — کارهای امروز انجام شد. ساعت ورود و خروج در گزارش کار ثبت است.', NULL, '2026-09-24 13:15:00', '2026-09-25 21:32:50', '2026-09-25 21:32:50');

SELECT setval(pg_get_serial_sequence('daily_reports', 'id'), COALESCE((SELECT MAX(id) FROM daily_reports), 1), true);

COMMIT;
