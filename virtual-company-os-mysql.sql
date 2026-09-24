-- =============================================================================
-- سامانه شرکت مجازی / Virtual Company OS
-- این فایل برای MySQL و MariaDB است، از جمله phpMyAdmin و mysqli.
-- فایل‌های PostgreSQL را در این دیتابیس ایمپورت نکنید.
-- یک دیتابیس خالی بسازید، همان را انتخاب کنید، سپس این فایل را Import کنید.
-- جدول‌های همین برنامه را پاک و دوباره می‌سازد. روی دیتابیس برنامهٔ دیگر نزنید.
-- MySQL 5.7+ or MariaDB 10.2+. Not for PostgreSQL.
--
-- Company: شبکه پردازان ایده‌بان الماس  |  slug: ideban-almas
-- Password for every account: ChangeMe!2026
-- Change that password before any shared or production use.
--
-- Accounts:
-- platform@virtual-company.test  |  Platform Admin  |  -  |  platform admin, no company membership
-- ceo@ideban.test  |  سارا محمدی  |  مدیرعامل  |  مالک شرکت
-- developer@ideban.test  |  آرمان کاظمی  |  توسعه‌دهنده  |  سرپرست تیم
-- devops@ideban.test  |  نیلوفر رضایی  |  مهندس دوآپس  |  کارمند
-- support@ideban.test  |  حسین مرادی  |  کارشناس پشتیبانی  |  کارمند
-- sales@ideban.test  |  مریم حسینی  |  مدیر فروش  |  مدیر واحد + فروش
-- marketing@ideban.test  |  کیان نادری  |  کارشناس بازاریابی  |  بازاریابی
-- finance@ideban.test  |  لیلا اکبری  |  مدیر مالی  |  مدیر واحد + مالی
-- hr@ideban.test  |  رضا شریفی  |  کارشناس منابع انسانی  |  منابع انسانی
--
-- After import, point Laravel at this database and generate APP_KEY:
-- DB_CONNECTION=mysql
-- DB_HOST=127.0.0.1
-- DB_PORT=3306
-- DB_DATABASE=your_database_name
-- DB_USERNAME=your_database_user
-- DB_PASSWORD=your_database_password
-- php artisan key:generate
-- Do not also run migrate --seed on this same database.
-- This file contains a fake national id, salary, invoice, and deal amount.
-- =============================================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';
SET sql_mode = 'NO_ENGINE_SUBSTITUTION';
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;

DROP TABLE IF EXISTS `activity_logs`;
DROP TABLE IF EXISTS `announcements`;
DROP TABLE IF EXISTS `approvals`;
DROP TABLE IF EXISTS `attendance_days`;
DROP TABLE IF EXISTS `attendance_events`;
DROP TABLE IF EXISTS `cache`;
DROP TABLE IF EXISTS `cache_locks`;
DROP TABLE IF EXISTS `campaigns`;
DROP TABLE IF EXISTS `channel_members`;
DROP TABLE IF EXISTS `channels`;
DROP TABLE IF EXISTS `companies`;
DROP TABLE IF EXISTS `company_user`;
DROP TABLE IF EXISTS `crm_accounts`;
DROP TABLE IF EXISTS `crm_contacts`;
DROP TABLE IF EXISTS `crm_deals`;
DROP TABLE IF EXISTS `daily_reports`;
DROP TABLE IF EXISTS `departments`;
DROP TABLE IF EXISTS `documents`;
DROP TABLE IF EXISTS `events`;
DROP TABLE IF EXISTS `expenses`;
DROP TABLE IF EXISTS `failed_jobs`;
DROP TABLE IF EXISTS `features`;
DROP TABLE IF EXISTS `hr_profiles`;
DROP TABLE IF EXISTS `invitations`;
DROP TABLE IF EXISTS `invoices`;
DROP TABLE IF EXISTS `job_batches`;
DROP TABLE IF EXISTS `jobs`;
DROP TABLE IF EXISTS `kanban_columns`;
DROP TABLE IF EXISTS `leave_requests`;
DROP TABLE IF EXISTS `login_sessions`;
DROP TABLE IF EXISTS `messages`;
DROP TABLE IF EXISTS `migrations`;
DROP TABLE IF EXISTS `mission_requests`;
DROP TABLE IF EXISTS `password_reset_tokens`;
DROP TABLE IF EXISTS `permissions`;
DROP TABLE IF EXISTS `personal_access_tokens`;
DROP TABLE IF EXISTS `project_members`;
DROP TABLE IF EXISTS `projects`;
DROP TABLE IF EXISTS `role_permissions`;
DROP TABLE IF EXISTS `roles`;
DROP TABLE IF EXISTS `sessions`;
DROP TABLE IF EXISTS `settings`;
DROP TABLE IF EXISTS `task_comments`;
DROP TABLE IF EXISTS `tasks`;
DROP TABLE IF EXISTS `team_user`;
DROP TABLE IF EXISTS `teams`;
DROP TABLE IF EXISTS `ticket_messages`;
DROP TABLE IF EXISTS `tickets`;
DROP TABLE IF EXISTS `user_permissions`;
DROP TABLE IF EXISTS `user_roles`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `work_presences`;
DROP TABLE IF EXISTS `work_schedules`;

CREATE TABLE `activity_logs` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED,
    `user_id` BIGINT UNSIGNED,
    `action` VARCHAR(191) NOT NULL,
    `entity_type` VARCHAR(191),
    `entity_id` BIGINT UNSIGNED,
    `entity_uuid` VARCHAR(191),
    `description` VARCHAR(191),
    `old_values` JSON,
    `new_values` JSON,
    `ip` VARCHAR(191),
    `user_agent` LONGTEXT,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `announcements` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `body` LONGTEXT NOT NULL,
    `author_id` BIGINT UNSIGNED,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `approvals` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `kind` VARCHAR(191) NOT NULL DEFAULT 'general',
    `status` VARCHAR(191) NOT NULL DEFAULT 'pending',
    `requester_id` BIGINT UNSIGNED NOT NULL,
    `reviewer_id` BIGINT UNSIGNED,
    `note` LONGTEXT,
    `review_note` LONGTEXT,
    `reviewed_at` DATETIME,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `attendance_days` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `work_date` DATE NOT NULL,
    `location` VARCHAR(191) NOT NULL DEFAULT 'office',
    `day_status` VARCHAR(191) NOT NULL DEFAULT 'marked',
    `check_in_at` DATETIME,
    `check_out_at` DATETIME,
    `late_minutes` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `worked_minutes` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `break_minutes` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `expected_minutes` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `excused` TINYINT(1) NOT NULL DEFAULT 0,
    `note` LONGTEXT,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `attendance_events` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `attendance_day_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `type` VARCHAR(191) NOT NULL,
    `occurred_at` DATETIME NOT NULL,
    `location` VARCHAR(191),
    `status` VARCHAR(191),
    `note` LONGTEXT,
    `source` VARCHAR(191) NOT NULL DEFAULT 'self',
    `actor_id` BIGINT UNSIGNED,
    `ip` VARCHAR(191),
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `cache` (
    `key` VARCHAR(191) NOT NULL,
    `value` LONGTEXT NOT NULL,
    `expiration` BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `cache_locks` (
    `key` VARCHAR(191) NOT NULL,
    `owner` VARCHAR(191) NOT NULL,
    `expiration` BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `campaigns` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `channel` VARCHAR(191) NOT NULL DEFAULT 'social',
    `status` VARCHAR(191) NOT NULL DEFAULT 'draft',
    `budget_amount` DECIMAL(14,0),
    `currency` VARCHAR(191) NOT NULL DEFAULT 'IRR',
    `starts_on` DATE,
    `ends_on` DATE,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `channel_members` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `channel_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `channels` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `slug` VARCHAR(191) NOT NULL,
    `kind` VARCHAR(191) NOT NULL DEFAULT 'company',
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `companies` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `legal_name` VARCHAR(191),
    `slug` VARCHAR(191) NOT NULL,
    `status` VARCHAR(191) NOT NULL DEFAULT 'active',
    `timezone` VARCHAR(191) NOT NULL DEFAULT 'Asia/Tehran',
    `locale` VARCHAR(191) NOT NULL DEFAULT 'fa',
    `logo_path` VARCHAR(191),
    `plan` VARCHAR(191),
    `user_limit` BIGINT UNSIGNED,
    `settings` JSON,
    `onboarded_at` DATETIME,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `company_user` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `department_id` BIGINT UNSIGNED,
    `job_title` VARCHAR(191),
    `employee_code` VARCHAR(191),
    `status` VARCHAR(191) NOT NULL DEFAULT 'active',
    `is_owner` TINYINT(1) NOT NULL DEFAULT 0,
    `joined_at` DATETIME,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `crm_accounts` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `status` VARCHAR(191) NOT NULL DEFAULT 'active',
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `crm_contacts` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `account_id` BIGINT UNSIGNED,
    `name` VARCHAR(191) NOT NULL,
    `email` VARCHAR(191),
    `phone` VARCHAR(191),
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `crm_deals` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `account_id` BIGINT UNSIGNED,
    `title` VARCHAR(191) NOT NULL,
    `stage` VARCHAR(191) NOT NULL DEFAULT 'lead',
    `amount` DECIMAL(14,0) NOT NULL DEFAULT 0,
    `currency` VARCHAR(191) NOT NULL DEFAULT 'IRR',
    `owner_id` BIGINT UNSIGNED,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `daily_reports` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `work_date` DATE NOT NULL,
    `kind` VARCHAR(191) NOT NULL,
    `body` LONGTEXT NOT NULL,
    `blockers` LONGTEXT,
    `submitted_at` DATETIME NOT NULL,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `departments` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `slug` VARCHAR(191) NOT NULL,
    `code` VARCHAR(191),
    `description` LONGTEXT,
    `manager_id` BIGINT UNSIGNED,
    `parent_id` BIGINT UNSIGNED,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `sort_order` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `documents` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `body` LONGTEXT NOT NULL,
    `visibility` VARCHAR(191) NOT NULL DEFAULT 'company',
    `author_id` BIGINT UNSIGNED,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `events` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `location` VARCHAR(191),
    `starts_at` DATETIME NOT NULL,
    `ends_at` DATETIME NOT NULL,
    `visibility` VARCHAR(191) NOT NULL DEFAULT 'company',
    `owner_id` BIGINT UNSIGNED,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `expenses` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `category` VARCHAR(191) NOT NULL,
    `amount` DECIMAL(14,0) NOT NULL,
    `currency` VARCHAR(191) NOT NULL DEFAULT 'IRR',
    `status` VARCHAR(191) NOT NULL DEFAULT 'recorded',
    `spent_on` DATE,
    `note` VARCHAR(191),
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `failed_jobs` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid` VARCHAR(191) NOT NULL,
    `connection` VARCHAR(191) NOT NULL,
    `queue` VARCHAR(191) NOT NULL,
    `payload` LONGTEXT NOT NULL,
    `exception` LONGTEXT NOT NULL,
    `failed_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `features` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `key` VARCHAR(191) NOT NULL,
    `enabled` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `hr_profiles` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `hire_date` DATE,
    `employment_type` VARCHAR(191),
    `national_id` VARCHAR(191),
    `emergency_name` VARCHAR(191),
    `emergency_phone` VARCHAR(191),
    `salary_amount` DECIMAL(14,0),
    `salary_currency` VARCHAR(191) NOT NULL DEFAULT 'IRR',
    `notes` LONGTEXT,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `invitations` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `email` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191),
    `role_id` BIGINT UNSIGNED,
    `department_id` BIGINT UNSIGNED,
    `team_id` BIGINT UNSIGNED,
    `token` VARCHAR(191) NOT NULL,
    `invited_by` BIGINT UNSIGNED,
    `expires_at` DATETIME NOT NULL,
    `accepted_at` DATETIME,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `invoices` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `number` VARCHAR(191) NOT NULL,
    `party_name` VARCHAR(191) NOT NULL,
    `amount` DECIMAL(14,0) NOT NULL,
    `currency` VARCHAR(191) NOT NULL DEFAULT 'IRR',
    `status` VARCHAR(191) NOT NULL DEFAULT 'draft',
    `issued_on` DATE,
    `due_on` DATE,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `job_batches` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `total_jobs` BIGINT UNSIGNED NOT NULL,
    `pending_jobs` BIGINT UNSIGNED NOT NULL,
    `failed_jobs` BIGINT UNSIGNED NOT NULL,
    `failed_job_ids` LONGTEXT NOT NULL,
    `options` LONGTEXT,
    `cancelled_at` BIGINT UNSIGNED,
    `created_at` BIGINT UNSIGNED NOT NULL,
    `finished_at` BIGINT UNSIGNED,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `jobs` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `queue` VARCHAR(191) NOT NULL,
    `payload` LONGTEXT NOT NULL,
    `attempts` BIGINT UNSIGNED NOT NULL,
    `reserved_at` BIGINT UNSIGNED,
    `available_at` BIGINT UNSIGNED NOT NULL,
    `created_at` BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `kanban_columns` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `project_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `sort_order` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `is_done` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `leave_requests` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `type` VARCHAR(191) NOT NULL,
    `starts_on` DATE NOT NULL,
    `ends_on` DATE NOT NULL,
    `reason` LONGTEXT NOT NULL,
    `status` VARCHAR(191) NOT NULL DEFAULT 'pending',
    `reviewer_id` BIGINT UNSIGNED,
    `reviewed_at` DATETIME,
    `review_note` LONGTEXT,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `login_sessions` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid` VARCHAR(191) NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `company_id` BIGINT UNSIGNED,
    `token_id` BIGINT UNSIGNED,
    `ip` VARCHAR(191),
    `user_agent` LONGTEXT,
    `device` VARCHAR(191),
    `logged_in_at` DATETIME NOT NULL,
    `logged_out_at` DATETIME,
    `last_activity_at` DATETIME,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `messages` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `channel_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `body` LONGTEXT NOT NULL,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `migrations` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `migration` VARCHAR(191) NOT NULL,
    `batch` BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `mission_requests` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `destination` VARCHAR(191) NOT NULL,
    `starts_on` DATE NOT NULL,
    `ends_on` DATE NOT NULL,
    `purpose` LONGTEXT NOT NULL,
    `status` VARCHAR(191) NOT NULL DEFAULT 'pending',
    `reviewer_id` BIGINT UNSIGNED,
    `reviewed_at` DATETIME,
    `review_note` LONGTEXT,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `password_reset_tokens` (
    `email` VARCHAR(191) NOT NULL,
    `token` VARCHAR(191) NOT NULL,
    `created_at` DATETIME,
    PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `permissions` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(191) NOT NULL,
    `module` VARCHAR(191) NOT NULL,
    `description` VARCHAR(191),
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `personal_access_tokens` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `tokenable_type` VARCHAR(191) NOT NULL,
    `tokenable_id` BIGINT UNSIGNED NOT NULL,
    `name` LONGTEXT NOT NULL,
    `token` VARCHAR(191) NOT NULL,
    `abilities` JSON,
    `last_used_at` DATETIME,
    `expires_at` DATETIME,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    `company_id` BIGINT UNSIGNED,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `project_members` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `project_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `role` VARCHAR(191) NOT NULL DEFAULT 'member',
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `projects` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `slug` VARCHAR(191) NOT NULL,
    `code` VARCHAR(191),
    `description` LONGTEXT,
    `status` VARCHAR(191) NOT NULL DEFAULT 'active',
    `visibility` VARCHAR(191) NOT NULL DEFAULT 'company',
    `department_id` BIGINT UNSIGNED,
    `owner_id` BIGINT UNSIGNED,
    `start_date` DATE,
    `due_date` DATE,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `role_permissions` (
    `role_id` BIGINT UNSIGNED NOT NULL,
    `permission_id` BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (`role_id`, `permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `roles` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `slug` VARCHAR(191) NOT NULL,
    `description` VARCHAR(191),
    `is_system` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `sessions` (
    `id` VARCHAR(191) NOT NULL,
    `user_id` BIGINT UNSIGNED,
    `ip_address` VARCHAR(191),
    `user_agent` LONGTEXT,
    `payload` LONGTEXT NOT NULL,
    `last_activity` BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `settings` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `key` VARCHAR(191) NOT NULL,
    `value` JSON,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `task_comments` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `task_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED,
    `uuid` VARCHAR(191) NOT NULL,
    `body` LONGTEXT NOT NULL,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `tasks` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `project_id` BIGINT UNSIGNED NOT NULL,
    `column_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `description` LONGTEXT,
    `priority` VARCHAR(191) NOT NULL DEFAULT 'normal',
    `assignee_id` BIGINT UNSIGNED,
    `reporter_id` BIGINT UNSIGNED,
    `due_date` DATE,
    `sort_order` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `completed_at` DATETIME,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `team_user` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `team_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `role` VARCHAR(191) NOT NULL DEFAULT 'member',
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `teams` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `department_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `slug` VARCHAR(191) NOT NULL,
    `description` LONGTEXT,
    `leader_id` BIGINT UNSIGNED,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `ticket_messages` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `ticket_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED,
    `uuid` VARCHAR(191) NOT NULL,
    `body` LONGTEXT NOT NULL,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `tickets` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `subject` VARCHAR(191) NOT NULL,
    `body` LONGTEXT NOT NULL,
    `status` VARCHAR(191) NOT NULL DEFAULT 'open',
    `priority` VARCHAR(191) NOT NULL DEFAULT 'normal',
    `requester_id` BIGINT UNSIGNED NOT NULL,
    `assignee_id` BIGINT UNSIGNED,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `user_permissions` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `permission_id` BIGINT UNSIGNED NOT NULL,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `user_roles` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `role_id` BIGINT UNSIGNED NOT NULL,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `users` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `email` VARCHAR(191) NOT NULL,
    `phone` VARCHAR(191),
    `avatar_path` VARCHAR(191),
    `locale` VARCHAR(191) NOT NULL DEFAULT 'fa',
    `timezone` VARCHAR(191),
    `status` VARCHAR(191) NOT NULL DEFAULT 'active',
    `is_platform_admin` TINYINT(1) NOT NULL DEFAULT 0,
    `email_verified_at` DATETIME,
    `password` VARCHAR(191) NOT NULL,
    `last_login_at` DATETIME,
    `last_login_ip` VARCHAR(191),
    `two_factor_secret` LONGTEXT,
    `two_factor_recovery_codes` LONGTEXT,
    `two_factor_confirmed_at` DATETIME,
    `remember_token` VARCHAR(191),
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `work_presences` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `status` VARCHAR(191) NOT NULL DEFAULT 'off',
    `resume_status` VARCHAR(191),
    `note` LONGTEXT,
    `since` DATETIME,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE `work_schedules` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `weekday` BIGINT UNSIGNED NOT NULL,
    `is_working_day` TINYINT(1) NOT NULL DEFAULT 1,
    `start_time` TIME NOT NULL DEFAULT '09:00:00',
    `end_time` TIME NOT NULL DEFAULT '17:00:00',
    `break_minutes` BIGINT UNSIGNED NOT NULL DEFAULT 60,
    `grace_minutes` BIGINT UNSIGNED NOT NULL DEFAULT 15,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- migrations (11)
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
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

ALTER TABLE `migrations` AUTO_INCREMENT = 12;

-- users (9)
INSERT INTO `users` (`id`, `uuid`, `name`, `email`, `phone`, `avatar_path`, `locale`, `timezone`, `status`, `is_platform_admin`, `email_verified_at`, `password`, `last_login_at`, `last_login_ip`, `two_factor_secret`, `two_factor_recovery_codes`, `two_factor_confirmed_at`, `remember_token`, `created_at`, `updated_at`) VALUES
    (1, 'ef3bf85d-6ca0-4e9a-afd4-01fdb5072d69', 'Platform Admin', 'platform@virtual-company.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', 1, '2026-09-24 22:19:10', '$2y$12$y7xwfSkcD3HgY6chymbMOubf5J86w7AkYCsZdjZDsCL0aqDH16T9q', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (2, '6b3e9445-2e1a-4bf2-ae51-eeb0b1118d46', 'سارا محمدی', 'ceo@ideban.test', '02191000000', NULL, 'fa', 'Asia/Tehran', 'active', 0, '2026-09-24 22:19:10', '$2y$12$BrW8VdGtxtmPR0oqnndTceAn/l2tGzY4Oqv5nlL6CrvHWLUa7M5OS', '2026-09-24 22:19:44', '127.0.0.1', NULL, NULL, NULL, NULL, '2026-09-24 22:19:11', '2026-09-24 22:19:44'),
    (3, 'ea36ecf0-6bbf-4946-b42a-d3e1982bcd79', 'آرمان کاظمی', 'developer@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', 0, '2026-09-24 22:19:11', '$2y$12$/qkVQByClbtrWOeACHgIMOjEodXW.caaYIM8n.zO2ryfpntyiqftK', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (4, '9eb27c7c-b99d-483c-88d7-421a05d89822', 'نیلوفر رضایی', 'devops@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', 0, '2026-09-24 22:19:11', '$2y$12$AqhcUjtsc5I4gcPQpyvwd.r8YQsloiXdLakX5Lf/bGaXpYSCBq0Xy', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (5, '6a888cf6-a755-4a74-ada3-d92785ae5675', 'حسین مرادی', 'support@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', 0, '2026-09-24 22:19:11', '$2y$12$6uIeHlhfngDkXtqg5GYvC.dFVfPq.k7yHncEGH8ksSR9W99OuzI9i', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:12', '2026-09-24 22:19:12'),
    (6, 'cb83e5fc-b175-42f3-b825-c33678ce9276', 'مریم حسینی', 'sales@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', 0, '2026-09-24 22:19:12', '$2y$12$OIp6jfxPPDLCdmnFmuKIT.s2q7HPyUaw2Dh6WLJd0SSS3WiMb0P16', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:12', '2026-09-24 22:19:12'),
    (7, '21c11167-7fda-482a-967d-ddafc9da7f79', 'کیان نادری', 'marketing@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', 0, '2026-09-24 22:19:12', '$2y$12$1OsMplC/X3stsi0pDbGfqui9Uoo2MDjo3.J4sxKY9cVxgZLRWJEkW', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:12', '2026-09-24 22:19:12'),
    (8, 'aafe04b1-cdaa-4402-a8e5-d91bcf21ebc4', 'لیلا اکبری', 'finance@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', 0, '2026-09-24 22:19:12', '$2y$12$Zchmvg.ZWbKcC5LmJpqAp.VmXxWi/YxNggCFLoS23azX1UnbZzjaa', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (9, '46e30c25-6ca2-42f5-b1db-a80031f2aa4e', 'رضا شریفی', 'hr@ideban.test', NULL, NULL, 'fa', 'Asia/Tehran', 'active', 0, '2026-09-24 22:19:13', '$2y$12$4XAfDeE9lRFVQagecc1AOesOl4YOUYClyd1PS7HJiSL6DbrG0CkPy', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `users` AUTO_INCREMENT = 10;

-- permissions (70)
INSERT INTO `permissions` (`id`, `name`, `module`, `description`, `created_at`, `updated_at`) VALUES
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
    (40, 'tasks.assign', 'projects', 'Assign and move any visible task', '2026-09-24 22:19:10', '2026-09-24 22:19:10');

INSERT INTO `permissions` (`id`, `name`, `module`, `description`, `created_at`, `updated_at`) VALUES
    (41, 'tasks.delete', 'projects', 'Delete tasks', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (42, 'hr.profile.view', 'hr', 'View employee HR profiles', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (43, 'hr.profile.update', 'hr', 'Update employee HR profiles', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (44, 'hr.salary.view', 'hr', 'View salary and national id', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (45, 'leave.request', 'hr', 'Submit own leave requests', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (46, 'leave.review', 'hr', 'Review leave requests in scope', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (47, 'mission.request', 'hr', 'Submit own mission requests', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (48, 'mission.review', 'hr', 'Review mission requests in scope', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (49, 'messages.view', 'communication', 'Read company channels and announcements', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
    (50, 'messages.send', 'communication', 'Send messages in visible channels', '2026-09-24 22:19:10', '2026-09-24 22:19:10'),
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

ALTER TABLE `permissions` AUTO_INCREMENT = 71;

-- companies (1)
INSERT INTO `companies` (`id`, `uuid`, `name`, `legal_name`, `slug`, `status`, `timezone`, `locale`, `logo_path`, `plan`, `user_limit`, `settings`, `onboarded_at`, `created_at`, `updated_at`) VALUES
    (1, 'a3a0c13a-cb5c-4a3a-8761-68dcb55b5a8a', 'شبکه پردازان ایده‌بان الماس', 'شبکه پردازان ایده‌بان الماس', 'ideban-almas', 'active', 'Asia/Tehran', 'fa', NULL, NULL, NULL, '{"onboarding":{"departments":true,"teams":true,"invites":true,"schedule":true,"completed":true}}', '2026-09-24 22:19:13', '2026-09-24 22:19:10', '2026-09-24 22:19:13');

ALTER TABLE `companies` AUTO_INCREMENT = 2;

-- departments (9)
INSERT INTO `departments` (`id`, `company_id`, `uuid`, `name`, `slug`, `code`, `description`, `manager_id`, `parent_id`, `is_active`, `sort_order`, `created_at`, `updated_at`) VALUES
    (1, 1, '80b87840-6664-44a6-b1ed-1ecdc3c60ad9', 'مدیریت', 'management', 'MGT', NULL, 2, NULL, 1, 0, '2026-09-24 22:19:11', '2026-09-24 22:19:13'),
    (2, 1, '5ad47401-fc43-4515-804e-88306f57f474', 'توسعه نرم‌افزار', 'software', 'DEV', NULL, 3, NULL, 1, 1, '2026-09-24 22:19:11', '2026-09-24 22:19:13'),
    (3, 1, 'ceb9cfe5-b42a-4e2c-9740-94421778788f', 'دوآپس', 'devops', 'OPSINF', NULL, NULL, NULL, 1, 2, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (4, 1, '59d75c51-c176-4a21-b177-4600ee5ec2ab', 'عملیات و پشتیبانی', 'operations', 'OPS', NULL, NULL, NULL, 1, 3, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (5, 1, 'a90db179-13c3-4ca1-b083-acf01ea3dc79', 'فروش', 'sales', 'SAL', NULL, 6, NULL, 1, 4, '2026-09-24 22:19:11', '2026-09-24 22:19:13'),
    (6, 1, 'b69d893f-f178-4757-af63-7f52983d379f', 'بازاریابی', 'marketing', 'MKT', NULL, NULL, NULL, 1, 5, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (7, 1, 'b0d5dc80-bb4d-49fb-84f5-50f7720b0374', 'تبلیغات', 'advertising', 'ADV', NULL, NULL, NULL, 1, 6, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (8, 1, 'e6c0068b-6703-42e8-ae7d-69af5ccdca5f', 'مالی', 'finance', 'FIN', NULL, 8, NULL, 1, 7, '2026-09-24 22:19:11', '2026-09-24 22:19:13'),
    (9, 1, 'd97beb97-92ee-46e1-9246-3d7b5b57e70f', 'منابع انسانی', 'hr', 'HR', NULL, 9, NULL, 1, 8, '2026-09-24 22:19:11', '2026-09-24 22:19:13');

ALTER TABLE `departments` AUTO_INCREMENT = 10;

-- company_user (8)
INSERT INTO `company_user` (`id`, `company_id`, `user_id`, `department_id`, `job_title`, `employee_code`, `status`, `is_owner`, `joined_at`, `created_at`, `updated_at`) VALUES
    (1, 1, 2, NULL, 'مدیرعامل', NULL, 'active', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (2, 1, 3, 2, 'توسعه‌دهنده', 'DEV-01', 'active', 0, '2026-09-24 22:19:11', '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (3, 1, 4, 3, 'مهندس دوآپس', 'OPS-01', 'active', 0, '2026-09-24 22:19:11', '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (4, 1, 5, 4, 'کارشناس پشتیبانی', 'SUP-01', 'active', 0, '2026-09-24 22:19:12', '2026-09-24 22:19:12', '2026-09-24 22:19:12'),
    (5, 1, 6, 5, 'مدیر فروش', 'SAL-01', 'active', 0, '2026-09-24 22:19:12', '2026-09-24 22:19:12', '2026-09-24 22:19:12'),
    (6, 1, 7, 6, 'کارشناس بازاریابی', 'MKT-01', 'active', 0, '2026-09-24 22:19:12', '2026-09-24 22:19:12', '2026-09-24 22:19:12'),
    (7, 1, 8, 8, 'مدیر مالی', 'FIN-01', 'active', 0, '2026-09-24 22:19:13', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (8, 1, 9, 9, 'کارشناس منابع انسانی', 'HR-01', 'active', 0, '2026-09-24 22:19:13', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `company_user` AUTO_INCREMENT = 9;

-- teams (3)
INSERT INTO `teams` (`id`, `company_id`, `department_id`, `uuid`, `name`, `slug`, `description`, `leader_id`, `is_active`, `created_at`, `updated_at`) VALUES
    (1, 1, 2, '97b453c8-b424-4ea2-b646-d24a437935c8', 'تیم محصول', 'product', 'توسعه محصول‌های نرم‌افزاری شرکت', 3, 1, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 1, 3, '47b7de3b-67f3-47bc-bb75-ebfefc608360', 'تیم زیرساخت', 'infrastructure', NULL, 4, 1, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (3, 1, 5, '1e1f2cde-7e74-48e3-b3e4-8615d40a9a1d', 'میز فروش', 'sales-desk', NULL, 6, 1, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `teams` AUTO_INCREMENT = 4;

-- team_user (3)
INSERT INTO `team_user` (`id`, `team_id`, `user_id`, `role`, `created_at`, `updated_at`) VALUES
    (1, 1, 3, 'leader', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 2, 4, 'leader', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (3, 3, 6, 'leader', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `team_user` AUTO_INCREMENT = 4;

-- roles (10)
INSERT INTO `roles` (`id`, `company_id`, `uuid`, `name`, `slug`, `description`, `is_system`, `created_at`, `updated_at`) VALUES
    (1, 1, 'ecd79d96-bf22-4add-878f-48d4d3cfbb72', 'مالک شرکت', 'company-owner', 'دسترسی کامل به شرکت', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (2, 1, 'eb26c3f8-3b2b-4434-8448-e965fc981233', 'مدیرعامل', 'ceo', 'مشاهده و مدیریت کل شرکت', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (3, 1, '0810f14a-d7a0-4a8e-a651-040fd8d66c2c', 'مدیر واحد', 'department-manager', 'مدیریت تیم‌های واحد و مشاهده اعضا', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (4, 1, 'ff8231b5-c944-48bf-9042-24c720d4e762', 'سرپرست تیم', 'team-leader', 'مشاهده تیم و همکاران', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (5, 1, 'c4347c8a-c259-46e9-8f40-9ecfe23a2c14', 'کارمند', 'employee', 'فضای کاری شخصی و مشاهده ساختار مجاز', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (6, 1, 'fcfaf5b1-21c4-4481-abc5-efbf1e4309d1', 'منابع انسانی', 'hr', 'مدیریت اعضا و دعوت‌ها', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (7, 1, 'c11ed07d-d9c1-4b58-8dfe-ed55671b5c7d', 'فروش', 'sales', 'دسترسی پایه تا فعال شدن ماژول فروش', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (8, 1, '3073f75b-1179-457a-abda-710196a57daf', 'بازاریابی', 'marketing', 'دسترسی پایه تا فعال شدن ماژول بازاریابی', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (9, 1, '74ec9860-31ec-4acd-86b7-70747401641b', 'مالی', 'finance', 'دفتر مالی شرکت', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (10, 1, '67c4a3b5-dc5f-4c2b-8e24-8e89c09b22e5', 'مشتری', 'client', 'دسترسی محدود به فضای شخصی', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11');

ALTER TABLE `roles` AUTO_INCREMENT = 11;

-- role_permissions (331)
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
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
    (1, 40);

INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
    (1, 41),
    (1, 42),
    (1, 43),
    (1, 44),
    (1, 45),
    (1, 46),
    (1, 47),
    (1, 48),
    (1, 49),
    (1, 50),
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
    (2, 12);

INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
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
    (2, 52);

INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
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
    (3, 15);

INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
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

INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
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
    (6, 44);

INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
    (6, 46),
    (6, 48),
    (6, 29),
    (6, 30),
    (6, 32),
    (6, 6),
    (6, 7),
    (6, 9),
    (6, 23),
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
    (7, 52),
    (7, 62),
    (7, 64),
    (7, 66),
    (7, 54),
    (7, 55),
    (8, 1);

INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
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
    (9, 45),
    (9, 47),
    (9, 49);

INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
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

-- user_roles (10)
INSERT INTO `user_roles` (`id`, `company_id`, `user_id`, `role_id`, `created_at`, `updated_at`) VALUES
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

ALTER TABLE `user_roles` AUTO_INCREMENT = 11;

-- work_schedules (7)
INSERT INTO `work_schedules` (`id`, `company_id`, `weekday`, `is_working_day`, `start_time`, `end_time`, `break_minutes`, `grace_minutes`, `created_at`, `updated_at`) VALUES
    (1, 1, 0, 1, '09:00:00', '17:00:00', 60, 15, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (2, 1, 1, 1, '09:00:00', '17:00:00', 60, 15, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (3, 1, 2, 1, '09:00:00', '17:00:00', 60, 15, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (4, 1, 3, 1, '09:00:00', '17:00:00', 60, 15, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (5, 1, 4, 1, '09:00:00', '17:00:00', 60, 15, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (6, 1, 5, 0, '09:00:00', '17:00:00', 60, 15, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (7, 1, 6, 1, '09:00:00', '17:00:00', 60, 15, '2026-09-24 22:19:11', '2026-09-24 22:19:11');

ALTER TABLE `work_schedules` AUTO_INCREMENT = 8;

-- features (14)
INSERT INTO `features` (`id`, `company_id`, `key`, `enabled`, `created_at`, `updated_at`) VALUES
    (1, 1, 'foundation', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (2, 1, 'attendance', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (3, 1, 'projects', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (4, 1, 'hr', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (5, 1, 'communication', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (6, 1, 'calendar', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (7, 1, 'crm', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (8, 1, 'marketing', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (9, 1, 'advertising', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (10, 1, 'finance', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (11, 1, 'operations', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (12, 1, 'workflows', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (13, 1, 'documents', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11'),
    (14, 1, 'analytics', 1, '2026-09-24 22:19:11', '2026-09-24 22:19:11');

ALTER TABLE `features` AUTO_INCREMENT = 15;

-- projects (2)
INSERT INTO `projects` (`id`, `company_id`, `uuid`, `name`, `slug`, `code`, `description`, `status`, `visibility`, `department_id`, `owner_id`, `start_date`, `due_date`, `created_at`, `updated_at`) VALUES
    (1, 1, '5609b00e-3a6b-4473-83c2-3570f1c740d1', 'فروشگاه', 'shop', 'SHOP', 'فروش آنلاین و هماهنگی کاتالوگ', 'active', 'company', 5, 2, NULL, '2026-10-24 00:00:00', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 1, '717fb2e6-f4f1-447e-b2a1-acb7bbfe84a2', 'دفتر مجازی', 'virtual-office', 'VOFFICE', 'حضور، وظیفه و گزارش روزانهٔ شرکت مجازی', 'active', 'company', 2, 2, NULL, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `projects` AUTO_INCREMENT = 3;

-- project_members (6)
INSERT INTO `project_members` (`id`, `company_id`, `project_id`, `user_id`, `role`, `created_at`, `updated_at`) VALUES
    (1, 1, 1, 2, 'manager', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 1, 2, 2, 'manager', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (3, 1, 1, 6, 'member', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (4, 1, 1, 7, 'member', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (5, 1, 2, 3, 'manager', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (6, 1, 2, 4, 'member', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `project_members` AUTO_INCREMENT = 7;

-- kanban_columns (8)
INSERT INTO `kanban_columns` (`id`, `company_id`, `project_id`, `uuid`, `name`, `sort_order`, `is_done`, `created_at`, `updated_at`) VALUES
    (1, 1, 1, 'ca93fd8c-2be3-48d4-b7df-edeba25d6586', 'صف انتظار', 0, 0, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 1, 1, 'd4369705-4014-4008-a38d-b42fca09715d', 'در حال انجام', 1, 0, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (3, 1, 1, 'b30121a2-1b0b-45f3-89de-ad1e4f9508f8', 'بازبینی', 2, 0, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (4, 1, 1, 'db32feb9-e04c-467d-a5ac-8462592be58b', 'انجام شد', 3, 1, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (5, 1, 2, '4b8ce55e-2bd1-46df-9c4e-bc2d2e5d56c5', 'صف انتظار', 0, 0, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (6, 1, 2, 'eb584862-d5b1-4e1e-83b5-c10e24012a1c', 'در حال انجام', 1, 0, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (7, 1, 2, '2d2d2fb5-4c72-4f8f-8168-62ce3835ef39', 'بازبینی', 2, 0, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (8, 1, 2, '7c41c657-8a8e-4566-b60a-e731c782ce57', 'انجام شد', 3, 1, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `kanban_columns` AUTO_INCREMENT = 9;

-- tasks (3)
INSERT INTO `tasks` (`id`, `company_id`, `project_id`, `column_id`, `uuid`, `title`, `description`, `priority`, `assignee_id`, `reporter_id`, `due_date`, `sort_order`, `completed_at`, `created_at`, `updated_at`) VALUES
    (1, 1, 1, 1, '7be05441-bac9-4e0e-a300-a4a521fe81a3', 'آماده‌سازی کاتالوگ پاییز', NULL, 'high', 6, 2, '2026-09-25 00:00:00', 1, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 1, 2, 5, '469ce747-9cfc-495e-9e64-19cecb8ca9e4', 'برد کانبان دفتر مجازی', NULL, 'high', 3, 2, '2026-09-25 00:00:00', 1, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (3, 1, 2, 5, 'f9568f21-46e0-45db-8304-1bed8180ae52', 'پایدارسازی سرویس حضور', NULL, 'normal', 4, 2, '2026-09-25 00:00:00', 2, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `tasks` AUTO_INCREMENT = 4;

-- hr_profiles (1)
INSERT INTO `hr_profiles` (`id`, `company_id`, `user_id`, `hire_date`, `employment_type`, `national_id`, `emergency_name`, `emergency_phone`, `salary_amount`, `salary_currency`, `notes`, `created_at`, `updated_at`) VALUES
    (1, 1, 3, '2024-03-01 00:00:00', 'full_time', '0087654321', 'خانواده کاظمی', '09120000000', 850000000, 'IRR', NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `hr_profiles` AUTO_INCREMENT = 2;

-- leave_requests (1)
INSERT INTO `leave_requests` (`id`, `company_id`, `uuid`, `user_id`, `type`, `starts_on`, `ends_on`, `reason`, `status`, `reviewer_id`, `reviewed_at`, `review_note`, `created_at`, `updated_at`) VALUES
    (1, 1, '9f8f935e-2962-48b2-9aa4-a23deea9d918', 4, 'annual', '2026-09-25 00:00:00', '2026-09-25 00:00:00', 'مرخصی استحقاقی نمونه', 'pending', NULL, NULL, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `leave_requests` AUTO_INCREMENT = 2;

-- mission_requests (1)
INSERT INTO `mission_requests` (`id`, `company_id`, `uuid`, `user_id`, `destination`, `starts_on`, `ends_on`, `purpose`, `status`, `reviewer_id`, `reviewed_at`, `review_note`, `created_at`, `updated_at`) VALUES
    (1, 1, 'eec73131-3b5b-4da7-95ca-4db25ccd6cb2', 6, 'دفتر مشتری، تهران', '2026-09-25 00:00:00', '2026-09-25 00:00:00', 'جلسه معرفی فروشگاه', 'pending', NULL, NULL, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `mission_requests` AUTO_INCREMENT = 2;

-- channels (1)
INSERT INTO `channels` (`id`, `company_id`, `uuid`, `name`, `slug`, `kind`, `created_at`, `updated_at`) VALUES
    (1, 1, '806941ef-0192-485d-ac35-fe668abdcf47', 'عمومی', 'general', 'company', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `channels` AUTO_INCREMENT = 2;

-- messages (1)
INSERT INTO `messages` (`id`, `company_id`, `channel_id`, `user_id`, `uuid`, `body`, `created_at`, `updated_at`) VALUES
    (1, 1, 1, 2, '3550fc6e-18df-4dac-8920-334102a3c26e', 'صبح بخیر. اولویت امروز: فروشگاه و دفتر مجازی.', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `messages` AUTO_INCREMENT = 2;

-- announcements (1)
INSERT INTO `announcements` (`id`, `company_id`, `uuid`, `title`, `body`, `author_id`, `created_at`, `updated_at`) VALUES
    (1, 1, '8f8ab1c9-f193-4232-a2eb-dc488ee27605', 'شروع هفته', 'جلسهٔ هماهنگی ساعت ۱۰ در تقویم شرکت است.', 2, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `announcements` AUTO_INCREMENT = 2;

-- events (1)
INSERT INTO `events` (`id`, `company_id`, `uuid`, `title`, `location`, `starts_at`, `ends_at`, `visibility`, `owner_id`, `created_at`, `updated_at`) VALUES
    (1, 1, '292186cd-3365-4c7f-a5e5-ef11e74267db', 'هماهنگی هفتگی', 'اتاق مجازی', '2026-09-25 10:00:00', '2026-09-25 11:00:00', 'company', 2, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `events` AUTO_INCREMENT = 2;

-- crm_accounts (1)
INSERT INTO `crm_accounts` (`id`, `company_id`, `uuid`, `name`, `status`, `created_at`, `updated_at`) VALUES
    (1, 1, '4e77b519-4cc0-47ab-b355-d41e4cd8dac9', 'خانهٔ کتاب', 'active', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `crm_accounts` AUTO_INCREMENT = 2;

-- crm_contacts (1)
INSERT INTO `crm_contacts` (`id`, `company_id`, `uuid`, `account_id`, `name`, `email`, `phone`, `created_at`, `updated_at`) VALUES
    (1, 1, '89c06b26-a782-42fc-b38f-34281992830d', 1, 'نگار سلیمانی', 'negar@example.test', '02144000000', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `crm_contacts` AUTO_INCREMENT = 2;

-- crm_deals (1)
INSERT INTO `crm_deals` (`id`, `company_id`, `uuid`, `account_id`, `title`, `stage`, `amount`, `currency`, `owner_id`, `created_at`, `updated_at`) VALUES
    (1, 1, 'cd8f238e-31a1-4cf5-9c96-c93572d8f919', 1, 'قرارداد فروشگاه', 'proposal', 240000000, 'IRR', 6, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `crm_deals` AUTO_INCREMENT = 2;

-- campaigns (2)
INSERT INTO `campaigns` (`id`, `company_id`, `uuid`, `name`, `channel`, `status`, `budget_amount`, `currency`, `starts_on`, `ends_on`, `created_at`, `updated_at`) VALUES
    (1, 1, 'ecfd7896-5098-471b-9766-1cb32088ba3c', 'کمپین پاییز', 'social', 'active', 80000000, 'IRR', '2026-09-24 00:00:00', '2026-10-24 00:00:00', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 1, 'f826f3f6-2aae-4d72-b46c-fbd5d6fc8381', 'تبلیغ جستجو', 'ads', 'draft', 45000000, 'IRR', NULL, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `campaigns` AUTO_INCREMENT = 3;

-- invoices (1)
INSERT INTO `invoices` (`id`, `company_id`, `uuid`, `number`, `party_name`, `amount`, `currency`, `status`, `issued_on`, `due_on`, `created_at`, `updated_at`) VALUES
    (1, 1, 'ae3c5f60-11ec-4cf7-9f61-dfad19352135', 'INV-1405-001', 'خانهٔ کتاب', 120000000, 'IRR', 'sent', '2026-09-24 00:00:00', '2026-10-08 00:00:00', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `invoices` AUTO_INCREMENT = 2;

-- expenses (1)
INSERT INTO `expenses` (`id`, `company_id`, `uuid`, `category`, `amount`, `currency`, `status`, `spent_on`, `note`, `created_at`, `updated_at`) VALUES
    (1, 1, '4560a00d-bd60-459b-8ce5-c509199b310a', 'زیرساخت', 18000000, 'IRR', 'recorded', '2026-09-24 00:00:00', 'هزینهٔ نمونه', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `expenses` AUTO_INCREMENT = 2;

-- tickets (1)
INSERT INTO `tickets` (`id`, `company_id`, `uuid`, `subject`, `body`, `status`, `priority`, `requester_id`, `assignee_id`, `created_at`, `updated_at`) VALUES
    (1, 1, '3a3d3b1a-5d29-4aa7-8803-90cf4e1382c1', 'دسترسی گزارش روزانه', 'همکار جدید صفحهٔ حضور را نمی‌بیند.', 'open', 'high', 5, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `tickets` AUTO_INCREMENT = 2;

-- approvals (1)
INSERT INTO `approvals` (`id`, `company_id`, `uuid`, `title`, `kind`, `status`, `requester_id`, `reviewer_id`, `note`, `review_note`, `reviewed_at`, `created_at`, `updated_at`) VALUES
    (1, 1, '3d595d0c-5d88-431b-aacf-45be47c9d533', 'خرید دامنهٔ فروشگاه', 'purchase', 'pending', 3, NULL, 'تمدید یک‌ساله', NULL, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `approvals` AUTO_INCREMENT = 2;

-- documents (1)
INSERT INTO `documents` (`id`, `company_id`, `uuid`, `title`, `body`, `visibility`, `author_id`, `created_at`, `updated_at`) VALUES
    (1, 1, 'cb341d83-5553-4dba-9fd0-0f23fa8a838e', 'راهنمای دفتر مجازی', 'ورود، وظیفهٔ امروز، گزارش روزانه و مرخصی از همین سامانه انجام می‌شود.', 'company', 2, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `documents` AUTO_INCREMENT = 2;

-- attendance_days (5)
INSERT INTO `attendance_days` (`id`, `company_id`, `uuid`, `user_id`, `work_date`, `location`, `day_status`, `check_in_at`, `check_out_at`, `late_minutes`, `worked_minutes`, `break_minutes`, `expected_minutes`, `excused`, `note`, `created_at`, `updated_at`) VALUES
    (1, 1, '1f1846ff-6254-476b-acd3-5013efad366f', 2, '2026-09-25 00:00:00', 'office', 'open', '2026-09-24 22:19:13', NULL, 0, 0, 0, 0, 0, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 1, 'd35f1a66-cc7d-4f67-be6a-6b6599d9d4ae', 3, '2026-09-25 00:00:00', 'remote', 'open', '2026-09-24 22:19:13', NULL, 0, 0, 0, 0, 0, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (3, 1, '14fedc35-6f04-4250-94b3-2047501ef2e7', 4, '2026-09-25 00:00:00', 'office', 'open', '2026-09-24 22:19:13', NULL, 0, 0, 0, 0, 0, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (4, 1, 'b637a4e0-1721-499f-8533-016244314366', 6, '2026-09-25 00:00:00', 'office', 'marked', NULL, NULL, 0, 0, 0, 0, 1, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (5, 1, 'ccaf2470-9301-428a-9d4e-b0ddef89d43a', 9, '2026-09-25 00:00:00', 'office', 'marked', NULL, NULL, 0, 0, 0, 0, 1, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `attendance_days` AUTO_INCREMENT = 6;

-- attendance_events (6)
INSERT INTO `attendance_events` (`id`, `company_id`, `uuid`, `attendance_day_id`, `user_id`, `type`, `occurred_at`, `location`, `status`, `note`, `source`, `actor_id`, `ip`, `created_at`, `updated_at`) VALUES
    (1, 1, '1fb5ce03-3a32-408d-9aee-02a7d994b31d', 1, 2, 'check_in', '2026-09-24 22:19:13', 'office', NULL, 'شروع روز در دفتر', 'self', 2, '127.0.0.1', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 1, '3ffc4f6e-db6d-4faf-beb8-1c300b7d00ce', 2, 3, 'check_in', '2026-09-24 22:19:13', 'remote', NULL, NULL, 'self', 3, '127.0.0.1', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (3, 1, 'ab37911b-8c9f-4957-8316-1ce1b92675ad', 3, 4, 'check_in', '2026-09-24 22:19:13', 'office', NULL, NULL, 'self', 4, '127.0.0.1', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (4, 1, '25009995-71c2-4b93-b74c-0836cfdf94c3', 3, 4, 'break_start', '2026-09-24 22:19:13', 'office', 'break', NULL, 'self', 4, '127.0.0.1', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (5, 1, '6164ab0c-a7c6-44de-bef7-0093065e3bed', 4, 6, 'status', '2026-09-24 22:19:13', 'office', 'mission', 'جلسه با مشتری', 'self', 6, '127.0.0.1', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (6, 1, '863ae0ed-512c-44fe-86ea-ab6dbe5cc428', 5, 9, 'status', '2026-09-24 22:19:13', 'office', 'leave', 'مرخصی ساعتی', 'self', 9, '127.0.0.1', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `attendance_events` AUTO_INCREMENT = 7;

-- work_presences (5)
INSERT INTO `work_presences` (`id`, `company_id`, `user_id`, `status`, `resume_status`, `note`, `since`, `created_at`, `updated_at`) VALUES
    (1, 1, 2, 'office', NULL, 'شروع روز در دفتر', '2026-09-24 22:19:13', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (2, 1, 3, 'remote', NULL, NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (3, 1, 4, 'break', 'office', NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (4, 1, 6, 'mission', 'office', 'جلسه با مشتری', '2026-09-24 22:19:13', '2026-09-24 22:19:13', '2026-09-24 22:19:13'),
    (5, 1, 9, 'leave', 'office', 'مرخصی ساعتی', '2026-09-24 22:19:13', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `work_presences` AUTO_INCREMENT = 6;

-- daily_reports (1)
INSERT INTO `daily_reports` (`id`, `company_id`, `uuid`, `user_id`, `work_date`, `kind`, `body`, `blockers`, `submitted_at`, `created_at`, `updated_at`) VALUES
    (1, 1, 'ff48ac63-cd84-485c-9f91-7612a4360b9a', 3, '2026-09-25 00:00:00', 'morning', 'امروز روی هستهٔ حضور و گزارش روزانه کار می‌کنم.', NULL, '2026-09-24 22:19:13', '2026-09-24 22:19:13', '2026-09-24 22:19:13');

ALTER TABLE `daily_reports` AUTO_INCREMENT = 2;

-- activity_logs (18)
INSERT INTO `activity_logs` (`id`, `company_id`, `user_id`, `action`, `entity_type`, `entity_id`, `entity_uuid`, `description`, `old_values`, `new_values`, `ip`, `user_agent`, `created_at`) VALUES
    (1, 1, 2, 'CREATE', 'company', 1, 'a3a0c13a-cb5c-4a3a-8761-68dcb55b5a8a', 'Company provisioned', NULL, '{"name":"\\u0634\\u0628\\u06a9\\u0647 \\u067e\\u0631\\u062f\\u0627\\u0632\\u0627\\u0646 \\u0627\\u06cc\\u062f\\u0647\\u200c\\u0628\\u0627\\u0646 \\u0627\\u0644\\u0645\\u0627\\u0633","slug":"ideban-almas"}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:11'),
    (2, 1, NULL, 'CREATE', 'user', 3, 'ea36ecf0-6bbf-4946-b42a-d3e1982bcd79', 'Member added', NULL, '{"email":"developer@ideban.test","roles":["team-leader"]}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:11'),
    (3, 1, NULL, 'CREATE', 'user', 4, '9eb27c7c-b99d-483c-88d7-421a05d89822', 'Member added', NULL, '{"email":"devops@ideban.test","roles":["employee"]}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:11'),
    (4, 1, NULL, 'CREATE', 'user', 5, '6a888cf6-a755-4a74-ada3-d92785ae5675', 'Member added', NULL, '{"email":"support@ideban.test","roles":["employee"]}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:12'),
    (5, 1, NULL, 'CREATE', 'user', 6, 'cb83e5fc-b175-42f3-b825-c33678ce9276', 'Member added', NULL, '{"email":"sales@ideban.test","roles":["sales","department-manager"]}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:12'),
    (6, 1, NULL, 'CREATE', 'user', 7, '21c11167-7fda-482a-967d-ddafc9da7f79', 'Member added', NULL, '{"email":"marketing@ideban.test","roles":["marketing"]}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:12'),
    (7, 1, NULL, 'CREATE', 'user', 8, 'aafe04b1-cdaa-4402-a8e5-d91bcf21ebc4', 'Member added', NULL, '{"email":"finance@ideban.test","roles":["finance","department-manager"]}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:13'),
    (8, 1, NULL, 'CREATE', 'user', 9, '46e30c25-6ca2-42f5-b1db-a80031f2aa4e', 'Member added', NULL, '{"email":"hr@ideban.test","roles":["hr"]}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:13'),
    (9, 1, NULL, 'CLOCK_IN', 'attendance_day', 1, '1f1846ff-6254-476b-acd3-5013efad366f', NULL, NULL, '{"location":"office","work_date":"2026-09-25"}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:13'),
    (10, 1, NULL, 'CLOCK_IN', 'attendance_day', 2, 'd35f1a66-cc7d-4f67-be6a-6b6599d9d4ae', NULL, NULL, '{"location":"remote","work_date":"2026-09-25"}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:13'),
    (11, 1, NULL, 'REPORT', 'daily_report', 1, 'ff48ac63-cd84-485c-9f91-7612a4360b9a', NULL, NULL, '{"kind":"morning","work_date":"2026-09-25"}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:13'),
    (12, 1, NULL, 'CLOCK_IN', 'attendance_day', 3, '14fedc35-6f04-4250-94b3-2047501ef2e7', NULL, NULL, '{"location":"office","work_date":"2026-09-25"}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:13'),
    (13, 1, NULL, 'BREAK_START', 'attendance_day', 3, '14fedc35-6f04-4250-94b3-2047501ef2e7', NULL, NULL, '{"work_date":"2026-09-25"}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:13'),
    (14, 1, NULL, 'STATUS', 'attendance_day', 4, 'b637a4e0-1721-499f-8533-016244314366', NULL, NULL, '{"status":"mission"}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:13'),
    (15, 1, NULL, 'STATUS', 'attendance_day', 5, 'ccaf2470-9301-428a-9d4e-b0ddef89d43a', NULL, NULL, '{"status":"leave"}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:13'),
    (16, 1, NULL, 'CREATE', 'project', 1, '5609b00e-3a6b-4473-83c2-3570f1c740d1', NULL, NULL, '{"name":"\\u0641\\u0631\\u0648\\u0634\\u06af\\u0627\\u0647","visibility":"company"}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:13'),
    (17, 1, NULL, 'CREATE', 'project', 2, '717fb2e6-f4f1-447e-b2a1-acb7bbfe84a2', NULL, NULL, '{"name":"\\u062f\\u0641\\u062a\\u0631 \\u0645\\u062c\\u0627\\u0632\\u06cc","visibility":"company"}', '127.0.0.1', 'Symfony', '2026-09-24 22:19:13'),
    (18, 1, 2, 'LOGIN', 'user', 2, '6b3e9445-2e1a-4bf2-ae51-eeb0b1118d46', NULL, NULL, '{"company_uuid":"a3a0c13a-cb5c-4a3a-8761-68dcb55b5a8a","device":"Browser \\/ Unknown"}', '127.0.0.1', 'curl/8.14.1', '2026-09-24 22:19:44');

ALTER TABLE `activity_logs` AUTO_INCREMENT = 19;

-- indexes
CREATE UNIQUE INDEX `users_uuid_unique` ON `users` (`uuid`);
CREATE UNIQUE INDEX `users_email_unique` ON `users` (`email`);
CREATE INDEX `users_status_index` ON `users` (`status`);
CREATE INDEX `users_is_platform_admin_index` ON `users` (`is_platform_admin`);
CREATE INDEX `sessions_user_id_index` ON `sessions` (`user_id`);
CREATE INDEX `sessions_last_activity_index` ON `sessions` (`last_activity`);
CREATE INDEX `cache_expiration_index` ON `cache` (`expiration`);
CREATE INDEX `cache_locks_expiration_index` ON `cache_locks` (`expiration`);
CREATE INDEX `jobs_queue_index` ON `jobs` (`queue`);
CREATE INDEX `failed_jobs_connection_queue_failed_at_index` ON `failed_jobs` (`connection`, `queue`, `failed_at`);
CREATE UNIQUE INDEX `failed_jobs_uuid_unique` ON `failed_jobs` (`uuid`);
CREATE UNIQUE INDEX `companies_uuid_unique` ON `companies` (`uuid`);
CREATE UNIQUE INDEX `companies_slug_unique` ON `companies` (`slug`);
CREATE INDEX `companies_status_index` ON `companies` (`status`);
CREATE UNIQUE INDEX `departments_company_id_slug_unique` ON `departments` (`company_id`, `slug`);
CREATE UNIQUE INDEX `departments_company_id_code_unique` ON `departments` (`company_id`, `code`);
CREATE UNIQUE INDEX `departments_uuid_unique` ON `departments` (`uuid`);
CREATE UNIQUE INDEX `company_user_company_id_employee_code_unique` ON `company_user` (`company_id`, `employee_code`);
CREATE UNIQUE INDEX `company_user_company_id_user_id_unique` ON `company_user` (`company_id`, `user_id`);
CREATE INDEX `company_user_status_index` ON `company_user` (`status`);
CREATE UNIQUE INDEX `teams_company_id_slug_unique` ON `teams` (`company_id`, `slug`);
CREATE UNIQUE INDEX `teams_uuid_unique` ON `teams` (`uuid`);
CREATE UNIQUE INDEX `team_user_team_id_user_id_unique` ON `team_user` (`team_id`, `user_id`);
CREATE UNIQUE INDEX `permissions_name_unique` ON `permissions` (`name`);
CREATE INDEX `permissions_module_index` ON `permissions` (`module`);
CREATE UNIQUE INDEX `roles_company_id_slug_unique` ON `roles` (`company_id`, `slug`);
CREATE UNIQUE INDEX `roles_uuid_unique` ON `roles` (`uuid`);
CREATE UNIQUE INDEX `user_roles_company_id_user_id_role_id_unique` ON `user_roles` (`company_id`, `user_id`, `role_id`);
CREATE UNIQUE INDEX `user_permissions_unique` ON `user_permissions` (`company_id`, `user_id`, `permission_id`);
CREATE INDEX `personal_access_tokens_expires_at_index` ON `personal_access_tokens` (`expires_at`);
CREATE UNIQUE INDEX `personal_access_tokens_token_unique` ON `personal_access_tokens` (`token`);
CREATE INDEX `personal_access_tokens_tokenable_type_tokenable_id_index` ON `personal_access_tokens` (`tokenable_type`, `tokenable_id`);
CREATE UNIQUE INDEX `work_schedules_company_id_weekday_unique` ON `work_schedules` (`company_id`, `weekday`);
CREATE INDEX `activity_logs_company_id_created_at_index` ON `activity_logs` (`company_id`, `created_at`);
CREATE INDEX `activity_logs_action_index` ON `activity_logs` (`action`);
CREATE INDEX `activity_logs_created_at_index` ON `activity_logs` (`created_at`);
CREATE INDEX `invitations_company_id_email_index` ON `invitations` (`company_id`, `email`);
CREATE UNIQUE INDEX `invitations_uuid_unique` ON `invitations` (`uuid`);
CREATE UNIQUE INDEX `invitations_token_unique` ON `invitations` (`token`);
CREATE INDEX `login_sessions_user_id_logged_out_at_index` ON `login_sessions` (`user_id`, `logged_out_at`);
CREATE UNIQUE INDEX `login_sessions_uuid_unique` ON `login_sessions` (`uuid`);
CREATE UNIQUE INDEX `settings_company_id_key_unique` ON `settings` (`company_id`, `key`);
CREATE UNIQUE INDEX `features_company_id_key_unique` ON `features` (`company_id`, `key`);
CREATE UNIQUE INDEX `attendance_days_company_id_user_id_work_date_unique` ON `attendance_days` (`company_id`, `user_id`, `work_date`);
CREATE INDEX `attendance_days_company_id_work_date_index` ON `attendance_days` (`company_id`, `work_date`);
CREATE UNIQUE INDEX `attendance_days_uuid_unique` ON `attendance_days` (`uuid`);
CREATE INDEX `attendance_events_company_id_user_id_occurred_at_index` ON `attendance_events` (`company_id`, `user_id`, `occurred_at`);
CREATE UNIQUE INDEX `attendance_events_uuid_unique` ON `attendance_events` (`uuid`);
CREATE UNIQUE INDEX `work_presences_company_id_user_id_unique` ON `work_presences` (`company_id`, `user_id`);
CREATE UNIQUE INDEX `daily_reports_company_id_user_id_work_date_kind_unique` ON `daily_reports` (`company_id`, `user_id`, `work_date`, `kind`);
CREATE UNIQUE INDEX `daily_reports_uuid_unique` ON `daily_reports` (`uuid`);
CREATE UNIQUE INDEX `projects_company_id_slug_unique` ON `projects` (`company_id`, `slug`);
CREATE UNIQUE INDEX `projects_uuid_unique` ON `projects` (`uuid`);
CREATE INDEX `projects_status_index` ON `projects` (`status`);
CREATE UNIQUE INDEX `project_members_project_id_user_id_unique` ON `project_members` (`project_id`, `user_id`);
CREATE UNIQUE INDEX `kanban_columns_uuid_unique` ON `kanban_columns` (`uuid`);
CREATE INDEX `tasks_company_id_assignee_id_due_date_index` ON `tasks` (`company_id`, `assignee_id`, `due_date`);
CREATE UNIQUE INDEX `tasks_uuid_unique` ON `tasks` (`uuid`);
CREATE UNIQUE INDEX `task_comments_uuid_unique` ON `task_comments` (`uuid`);
CREATE UNIQUE INDEX `hr_profiles_company_id_user_id_unique` ON `hr_profiles` (`company_id`, `user_id`);
CREATE INDEX `leave_requests_company_id_user_id_status_index` ON `leave_requests` (`company_id`, `user_id`, `status`);
CREATE UNIQUE INDEX `leave_requests_uuid_unique` ON `leave_requests` (`uuid`);
CREATE INDEX `leave_requests_status_index` ON `leave_requests` (`status`);
CREATE INDEX `mission_requests_company_id_user_id_status_index` ON `mission_requests` (`company_id`, `user_id`, `status`);
CREATE UNIQUE INDEX `mission_requests_uuid_unique` ON `mission_requests` (`uuid`);
CREATE INDEX `mission_requests_status_index` ON `mission_requests` (`status`);
CREATE UNIQUE INDEX `channels_company_id_slug_unique` ON `channels` (`company_id`, `slug`);
CREATE UNIQUE INDEX `channels_uuid_unique` ON `channels` (`uuid`);
CREATE UNIQUE INDEX `channel_members_channel_id_user_id_unique` ON `channel_members` (`channel_id`, `user_id`);
CREATE INDEX `messages_channel_id_id_index` ON `messages` (`channel_id`, `id`);
CREATE UNIQUE INDEX `messages_uuid_unique` ON `messages` (`uuid`);
CREATE UNIQUE INDEX `announcements_uuid_unique` ON `announcements` (`uuid`);
CREATE INDEX `events_company_id_starts_at_index` ON `events` (`company_id`, `starts_at`);
CREATE UNIQUE INDEX `events_uuid_unique` ON `events` (`uuid`);
CREATE UNIQUE INDEX `crm_accounts_uuid_unique` ON `crm_accounts` (`uuid`);
CREATE UNIQUE INDEX `crm_contacts_uuid_unique` ON `crm_contacts` (`uuid`);
CREATE UNIQUE INDEX `crm_deals_uuid_unique` ON `crm_deals` (`uuid`);
CREATE UNIQUE INDEX `campaigns_uuid_unique` ON `campaigns` (`uuid`);
CREATE UNIQUE INDEX `invoices_company_id_number_unique` ON `invoices` (`company_id`, `number`);
CREATE UNIQUE INDEX `invoices_uuid_unique` ON `invoices` (`uuid`);
CREATE UNIQUE INDEX `expenses_uuid_unique` ON `expenses` (`uuid`);
CREATE INDEX `tickets_company_id_status_index` ON `tickets` (`company_id`, `status`);
CREATE UNIQUE INDEX `tickets_uuid_unique` ON `tickets` (`uuid`);
CREATE UNIQUE INDEX `ticket_messages_uuid_unique` ON `ticket_messages` (`uuid`);
CREATE UNIQUE INDEX `approvals_uuid_unique` ON `approvals` (`uuid`);
CREATE UNIQUE INDEX `documents_uuid_unique` ON `documents` (`uuid`);

-- foreign keys
ALTER TABLE `activity_logs` ADD CONSTRAINT `activity_logs_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `activity_logs` ADD CONSTRAINT `activity_logs_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE SET NULL;
ALTER TABLE `announcements` ADD CONSTRAINT `announcements_author_id_fk` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `announcements` ADD CONSTRAINT `announcements_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `approvals` ADD CONSTRAINT `approvals_reviewer_id_fk` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `approvals` ADD CONSTRAINT `approvals_requester_id_fk` FOREIGN KEY (`requester_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `approvals` ADD CONSTRAINT `approvals_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `attendance_days` ADD CONSTRAINT `attendance_days_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `attendance_days` ADD CONSTRAINT `attendance_days_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `attendance_events` ADD CONSTRAINT `attendance_events_actor_id_fk` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `attendance_events` ADD CONSTRAINT `attendance_events_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `attendance_events` ADD CONSTRAINT `attendance_events_attendance_day_id_fk` FOREIGN KEY (`attendance_day_id`) REFERENCES `attendance_days` (`id`) ON DELETE CASCADE;
ALTER TABLE `attendance_events` ADD CONSTRAINT `attendance_events_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `campaigns` ADD CONSTRAINT `campaigns_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `channel_members` ADD CONSTRAINT `channel_members_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `channel_members` ADD CONSTRAINT `channel_members_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE;
ALTER TABLE `channel_members` ADD CONSTRAINT `channel_members_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `channels` ADD CONSTRAINT `channels_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `company_user` ADD CONSTRAINT `company_user_department_id_fk` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL;
ALTER TABLE `company_user` ADD CONSTRAINT `company_user_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `company_user` ADD CONSTRAINT `company_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `crm_accounts` ADD CONSTRAINT `crm_accounts_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `crm_contacts` ADD CONSTRAINT `crm_contacts_account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `crm_accounts` (`id`) ON DELETE SET NULL;
ALTER TABLE `crm_contacts` ADD CONSTRAINT `crm_contacts_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `crm_deals` ADD CONSTRAINT `crm_deals_owner_id_fk` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `crm_deals` ADD CONSTRAINT `crm_deals_account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `crm_accounts` (`id`) ON DELETE SET NULL;
ALTER TABLE `crm_deals` ADD CONSTRAINT `crm_deals_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `daily_reports` ADD CONSTRAINT `daily_reports_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `daily_reports` ADD CONSTRAINT `daily_reports_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `departments` ADD CONSTRAINT `departments_parent_id_fk` FOREIGN KEY (`parent_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL;
ALTER TABLE `departments` ADD CONSTRAINT `departments_manager_id_fk` FOREIGN KEY (`manager_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `departments` ADD CONSTRAINT `departments_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `documents` ADD CONSTRAINT `documents_author_id_fk` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `documents` ADD CONSTRAINT `documents_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `events` ADD CONSTRAINT `events_owner_id_fk` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `events` ADD CONSTRAINT `events_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `expenses` ADD CONSTRAINT `expenses_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `features` ADD CONSTRAINT `features_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `hr_profiles` ADD CONSTRAINT `hr_profiles_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `hr_profiles` ADD CONSTRAINT `hr_profiles_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `invitations` ADD CONSTRAINT `invitations_invited_by_fk` FOREIGN KEY (`invited_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `invitations` ADD CONSTRAINT `invitations_team_id_fk` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE SET NULL;
ALTER TABLE `invitations` ADD CONSTRAINT `invitations_department_id_fk` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL;
ALTER TABLE `invitations` ADD CONSTRAINT `invitations_role_id_fk` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE SET NULL;
ALTER TABLE `invitations` ADD CONSTRAINT `invitations_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `invoices` ADD CONSTRAINT `invoices_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `kanban_columns` ADD CONSTRAINT `kanban_columns_project_id_fk` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE;
ALTER TABLE `kanban_columns` ADD CONSTRAINT `kanban_columns_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `leave_requests` ADD CONSTRAINT `leave_requests_reviewer_id_fk` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `leave_requests` ADD CONSTRAINT `leave_requests_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `leave_requests` ADD CONSTRAINT `leave_requests_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `login_sessions` ADD CONSTRAINT `login_sessions_token_id_fk` FOREIGN KEY (`token_id`) REFERENCES `personal_access_tokens` (`id`) ON DELETE SET NULL;
ALTER TABLE `login_sessions` ADD CONSTRAINT `login_sessions_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE SET NULL;
ALTER TABLE `login_sessions` ADD CONSTRAINT `login_sessions_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `messages` ADD CONSTRAINT `messages_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `messages` ADD CONSTRAINT `messages_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE;
ALTER TABLE `messages` ADD CONSTRAINT `messages_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `mission_requests` ADD CONSTRAINT `mission_requests_reviewer_id_fk` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `mission_requests` ADD CONSTRAINT `mission_requests_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `mission_requests` ADD CONSTRAINT `mission_requests_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `personal_access_tokens` ADD CONSTRAINT `personal_access_tokens_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE SET NULL;
ALTER TABLE `project_members` ADD CONSTRAINT `project_members_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `project_members` ADD CONSTRAINT `project_members_project_id_fk` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE;
ALTER TABLE `project_members` ADD CONSTRAINT `project_members_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `projects` ADD CONSTRAINT `projects_owner_id_fk` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `projects` ADD CONSTRAINT `projects_department_id_fk` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL;
ALTER TABLE `projects` ADD CONSTRAINT `projects_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `role_permissions` ADD CONSTRAINT `role_permissions_permission_id_fk` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE;
ALTER TABLE `role_permissions` ADD CONSTRAINT `role_permissions_role_id_fk` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;
ALTER TABLE `roles` ADD CONSTRAINT `roles_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `settings` ADD CONSTRAINT `settings_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `task_comments` ADD CONSTRAINT `task_comments_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `task_comments` ADD CONSTRAINT `task_comments_task_id_fk` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`) ON DELETE CASCADE;
ALTER TABLE `task_comments` ADD CONSTRAINT `task_comments_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `tasks` ADD CONSTRAINT `tasks_reporter_id_fk` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `tasks` ADD CONSTRAINT `tasks_assignee_id_fk` FOREIGN KEY (`assignee_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `tasks` ADD CONSTRAINT `tasks_column_id_fk` FOREIGN KEY (`column_id`) REFERENCES `kanban_columns` (`id`) ON DELETE CASCADE;
ALTER TABLE `tasks` ADD CONSTRAINT `tasks_project_id_fk` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE;
ALTER TABLE `tasks` ADD CONSTRAINT `tasks_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `team_user` ADD CONSTRAINT `team_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `team_user` ADD CONSTRAINT `team_user_team_id_fk` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE;
ALTER TABLE `teams` ADD CONSTRAINT `teams_leader_id_fk` FOREIGN KEY (`leader_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `teams` ADD CONSTRAINT `teams_department_id_fk` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE;
ALTER TABLE `teams` ADD CONSTRAINT `teams_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `ticket_messages` ADD CONSTRAINT `ticket_messages_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `ticket_messages` ADD CONSTRAINT `ticket_messages_ticket_id_fk` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE;
ALTER TABLE `ticket_messages` ADD CONSTRAINT `ticket_messages_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `tickets` ADD CONSTRAINT `tickets_assignee_id_fk` FOREIGN KEY (`assignee_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
ALTER TABLE `tickets` ADD CONSTRAINT `tickets_requester_id_fk` FOREIGN KEY (`requester_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `tickets` ADD CONSTRAINT `tickets_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `user_permissions` ADD CONSTRAINT `user_permissions_permission_id_fk` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE;
ALTER TABLE `user_permissions` ADD CONSTRAINT `user_permissions_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `user_permissions` ADD CONSTRAINT `user_permissions_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `user_roles` ADD CONSTRAINT `user_roles_role_id_fk` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;
ALTER TABLE `user_roles` ADD CONSTRAINT `user_roles_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `user_roles` ADD CONSTRAINT `user_roles_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `work_presences` ADD CONSTRAINT `work_presences_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
ALTER TABLE `work_presences` ADD CONSTRAINT `work_presences_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
ALTER TABLE `work_schedules` ADD CONSTRAINT `work_schedules_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;

SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;

-- Login check. Password for every row is ChangeMe!2026
SELECT `email`, `name`, `is_platform_admin` FROM `users` ORDER BY `id`;
