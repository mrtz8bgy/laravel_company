-- =============================================================================
-- ارتقای پنل مشتری — Virtual Company OS
-- این فایل را روی دیتابیس موجود ایمپورت کنید. دادهٔ قبلی را پاک نمی‌کند.
-- جدول‌ها فقط اگر نباشند ساخته می‌شوند. مجوزها، نقش مشتری و قابلیت portal
-- فقط اگر نباشند اضافه می‌شوند. مهاجرت لاراول هم ثبت می‌شود تا
-- php artisan migrate دوباره همین جدول‌ها را نسازد.
--
-- روی دیتابیس خالی نزنید. برای نصب تازه از virtual-company-os-mysql.sql استفاده کنید.
-- فایل‌های PostgreSQL را اینجا ایمپورت نکنید.
-- MySQL 5.7+ / MariaDB 10.2+ / phpMyAdmin. دیتابیس را اول انتخاب کنید.
-- =============================================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';
SET sql_mode = 'NO_ENGINE_SUBSTITUTION';
SET @now = UTC_TIMESTAMP();

CREATE TABLE IF NOT EXISTS `customers` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `status` VARCHAR(16) NOT NULL DEFAULT 'pending',
    `organization_name` VARCHAR(191) NULL,
    `phone` VARCHAR(32) NULL,
    `note` LONGTEXT NULL,
    `review_note` LONGTEXT NULL,
    `reviewer_id` BIGINT UNSIGNED NULL,
    `reviewed_at` DATETIME NULL,
    `created_at` DATETIME NULL,
    `updated_at` DATETIME NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `products` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `sku` VARCHAR(40) NULL,
    `description` LONGTEXT NULL,
    `unit_price` DECIMAL(14,0) NOT NULL DEFAULT 0,
    `currency` VARCHAR(8) NOT NULL DEFAULT 'IRR',
    `stock` INT UNSIGNED NULL,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NULL,
    `updated_at` DATETIME NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `customer_orders` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `customer_id` BIGINT UNSIGNED NOT NULL,
    `number` VARCHAR(32) NOT NULL,
    `status` VARCHAR(16) NOT NULL DEFAULT 'submitted',
    `note` LONGTEXT NULL,
    `staff_note` LONGTEXT NULL,
    `total_amount` DECIMAL(14,0) NOT NULL DEFAULT 0,
    `currency` VARCHAR(8) NOT NULL DEFAULT 'IRR',
    `reviewer_id` BIGINT UNSIGNED NULL,
    `reviewed_at` DATETIME NULL,
    `created_at` DATETIME NULL,
    `updated_at` DATETIME NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `customer_order_items` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `order_id` BIGINT UNSIGNED NOT NULL,
    `product_id` BIGINT UNSIGNED NULL,
    `name` VARCHAR(191) NOT NULL,
    `quantity` INT UNSIGNED NOT NULL,
    `unit_price` DECIMAL(14,0) NOT NULL,
    `line_total` DECIMAL(14,0) NOT NULL,
    `created_at` DATETIME NULL,
    `updated_at` DATETIME NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `customer_threads` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `customer_id` BIGINT UNSIGNED NOT NULL,
    `desk` VARCHAR(16) NOT NULL,
    `subject` VARCHAR(191) NOT NULL,
    `status` VARCHAR(16) NOT NULL DEFAULT 'open',
    `created_at` DATETIME NULL,
    `updated_at` DATETIME NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `customer_thread_messages` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `thread_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `body` LONGTEXT NOT NULL,
    `is_staff` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` DATETIME NULL,
    `updated_at` DATETIME NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `customer_tickets` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `uuid` VARCHAR(191) NOT NULL,
    `customer_id` BIGINT UNSIGNED NOT NULL,
    `number` VARCHAR(32) NOT NULL,
    `desk` VARCHAR(16) NOT NULL,
    `subject` VARCHAR(191) NOT NULL,
    `priority` VARCHAR(16) NOT NULL DEFAULT 'normal',
    `status` VARCHAR(16) NOT NULL DEFAULT 'open',
    `created_at` DATETIME NULL,
    `updated_at` DATETIME NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `customer_ticket_messages` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `company_id` BIGINT UNSIGNED NOT NULL,
    `ticket_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `body` LONGTEXT NOT NULL,
    `is_staff` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` DATETIME NULL,
    `updated_at` DATETIME NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- Indexes. Re-import is safe: an existing index is left alone.
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'customers' AND index_name = 'customers_uuid_unique') = 0, 'CREATE UNIQUE INDEX `customers_uuid_unique` ON `customers` (`uuid`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'customers' AND index_name = 'customers_company_id_user_id_unique') = 0, 'CREATE UNIQUE INDEX `customers_company_id_user_id_unique` ON `customers` (`company_id`, `user_id`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'customers' AND index_name = 'customers_company_id_status_index') = 0, 'CREATE INDEX `customers_company_id_status_index` ON `customers` (`company_id`, `status`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'products' AND index_name = 'products_uuid_unique') = 0, 'CREATE UNIQUE INDEX `products_uuid_unique` ON `products` (`uuid`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'products' AND index_name = 'products_company_id_sku_unique') = 0, 'CREATE UNIQUE INDEX `products_company_id_sku_unique` ON `products` (`company_id`, `sku`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'products' AND index_name = 'products_company_id_is_active_index') = 0, 'CREATE INDEX `products_company_id_is_active_index` ON `products` (`company_id`, `is_active`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'customer_orders' AND index_name = 'customer_orders_uuid_unique') = 0, 'CREATE UNIQUE INDEX `customer_orders_uuid_unique` ON `customer_orders` (`uuid`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'customer_orders' AND index_name = 'customer_orders_company_id_number_unique') = 0, 'CREATE UNIQUE INDEX `customer_orders_company_id_number_unique` ON `customer_orders` (`company_id`, `number`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'customer_orders' AND index_name = 'customer_orders_company_id_status_index') = 0, 'CREATE INDEX `customer_orders_company_id_status_index` ON `customer_orders` (`company_id`, `status`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'customer_orders' AND index_name = 'customer_orders_customer_id_created_at_index') = 0, 'CREATE INDEX `customer_orders_customer_id_created_at_index` ON `customer_orders` (`customer_id`, `created_at`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'customer_threads' AND index_name = 'customer_threads_uuid_unique') = 0, 'CREATE UNIQUE INDEX `customer_threads_uuid_unique` ON `customer_threads` (`uuid`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'customer_threads' AND index_name = 'customer_threads_company_id_desk_status_index') = 0, 'CREATE INDEX `customer_threads_company_id_desk_status_index` ON `customer_threads` (`company_id`, `desk`, `status`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'customer_thread_messages' AND index_name = 'customer_thread_messages_thread_id_id_index') = 0, 'CREATE INDEX `customer_thread_messages_thread_id_id_index` ON `customer_thread_messages` (`thread_id`, `id`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'customer_tickets' AND index_name = 'customer_tickets_uuid_unique') = 0, 'CREATE UNIQUE INDEX `customer_tickets_uuid_unique` ON `customer_tickets` (`uuid`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'customer_tickets' AND index_name = 'customer_tickets_company_id_number_unique') = 0, 'CREATE UNIQUE INDEX `customer_tickets_company_id_number_unique` ON `customer_tickets` (`company_id`, `number`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'customer_tickets' AND index_name = 'customer_tickets_company_id_desk_status_index') = 0, 'CREATE INDEX `customer_tickets_company_id_desk_status_index` ON `customer_tickets` (`company_id`, `desk`, `status`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'customer_ticket_messages' AND index_name = 'customer_ticket_messages_ticket_id_id_index') = 0, 'CREATE INDEX `customer_ticket_messages_ticket_id_id_index` ON `customer_ticket_messages` (`ticket_id`, `id`)', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;

-- Foreign keys. Skipped when the constraint name already exists.
SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customers' AND constraint_name = 'customers_company_id_fk') = 0, 'ALTER TABLE `customers` ADD CONSTRAINT `customers_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customers' AND constraint_name = 'customers_user_id_fk') = 0, 'ALTER TABLE `customers` ADD CONSTRAINT `customers_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customers' AND constraint_name = 'customers_reviewer_id_fk') = 0, 'ALTER TABLE `customers` ADD CONSTRAINT `customers_reviewer_id_fk` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'products' AND constraint_name = 'products_company_id_fk') = 0, 'ALTER TABLE `products` ADD CONSTRAINT `products_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customer_orders' AND constraint_name = 'customer_orders_company_id_fk') = 0, 'ALTER TABLE `customer_orders` ADD CONSTRAINT `customer_orders_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customer_orders' AND constraint_name = 'customer_orders_customer_id_fk') = 0, 'ALTER TABLE `customer_orders` ADD CONSTRAINT `customer_orders_customer_id_fk` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customer_orders' AND constraint_name = 'customer_orders_reviewer_id_fk') = 0, 'ALTER TABLE `customer_orders` ADD CONSTRAINT `customer_orders_reviewer_id_fk` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customer_order_items' AND constraint_name = 'customer_order_items_company_id_fk') = 0, 'ALTER TABLE `customer_order_items` ADD CONSTRAINT `customer_order_items_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customer_order_items' AND constraint_name = 'customer_order_items_order_id_fk') = 0, 'ALTER TABLE `customer_order_items` ADD CONSTRAINT `customer_order_items_order_id_fk` FOREIGN KEY (`order_id`) REFERENCES `customer_orders` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customer_order_items' AND constraint_name = 'customer_order_items_product_id_fk') = 0, 'ALTER TABLE `customer_order_items` ADD CONSTRAINT `customer_order_items_product_id_fk` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customer_threads' AND constraint_name = 'customer_threads_company_id_fk') = 0, 'ALTER TABLE `customer_threads` ADD CONSTRAINT `customer_threads_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customer_threads' AND constraint_name = 'customer_threads_customer_id_fk') = 0, 'ALTER TABLE `customer_threads` ADD CONSTRAINT `customer_threads_customer_id_fk` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customer_thread_messages' AND constraint_name = 'customer_thread_messages_company_id_fk') = 0, 'ALTER TABLE `customer_thread_messages` ADD CONSTRAINT `customer_thread_messages_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customer_thread_messages' AND constraint_name = 'customer_thread_messages_thread_id_fk') = 0, 'ALTER TABLE `customer_thread_messages` ADD CONSTRAINT `customer_thread_messages_thread_id_fk` FOREIGN KEY (`thread_id`) REFERENCES `customer_threads` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customer_thread_messages' AND constraint_name = 'customer_thread_messages_user_id_fk') = 0, 'ALTER TABLE `customer_thread_messages` ADD CONSTRAINT `customer_thread_messages_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customer_tickets' AND constraint_name = 'customer_tickets_company_id_fk') = 0, 'ALTER TABLE `customer_tickets` ADD CONSTRAINT `customer_tickets_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customer_tickets' AND constraint_name = 'customer_tickets_customer_id_fk') = 0, 'ALTER TABLE `customer_tickets` ADD CONSTRAINT `customer_tickets_customer_id_fk` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customer_ticket_messages' AND constraint_name = 'customer_ticket_messages_company_id_fk') = 0, 'ALTER TABLE `customer_ticket_messages` ADD CONSTRAINT `customer_ticket_messages_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customer_ticket_messages' AND constraint_name = 'customer_ticket_messages_ticket_id_fk') = 0, 'ALTER TABLE `customer_ticket_messages` ADD CONSTRAINT `customer_ticket_messages_ticket_id_fk` FOREIGN KEY (`ticket_id`) REFERENCES `customer_tickets` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @sql = IF((SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND table_name = 'customer_ticket_messages' AND constraint_name = 'customer_ticket_messages_user_id_fk') = 0, 'ALTER TABLE `customer_ticket_messages` ADD CONSTRAINT `customer_ticket_messages_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE', 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;

INSERT INTO `permissions` (`name`, `module`, `description`, `created_at`, `updated_at`)
SELECT fresh.name, fresh.module, fresh.description, fresh.created_at, fresh.updated_at
FROM (
    SELECT seed.name, seed.module, seed.description, @now AS created_at, @now AS updated_at
    FROM (
        SELECT 'customers.view' AS name, 'portal' AS module, 'View customer accounts' AS description
        UNION ALL SELECT 'customers.review', 'portal', 'Approve or reject customer registration'
        UNION ALL SELECT 'products.view', 'portal', 'View the product catalog'
        UNION ALL SELECT 'products.manage', 'portal', 'Create and update products'
        UNION ALL SELECT 'customer_orders.view', 'portal', 'View customer orders'
        UNION ALL SELECT 'customer_orders.manage', 'portal', 'Update customer order status'
        UNION ALL SELECT 'customer_messages.view', 'portal', 'Read customer messages for a permitted desk'
        UNION ALL SELECT 'customer_messages.reply', 'portal', 'Reply to customer messages on a permitted desk'
    ) AS seed
    WHERE NOT EXISTS (SELECT 1 FROM `permissions` existing WHERE existing.name = seed.name)
) AS fresh;

INSERT INTO `roles` (`company_id`, `uuid`, `name`, `slug`, `description`, `is_system`, `created_at`, `updated_at`)
SELECT fresh.company_id, fresh.uuid, fresh.name, fresh.slug, fresh.description, fresh.is_system, fresh.created_at, fresh.updated_at
FROM (
    SELECT companies.id AS company_id, UUID() AS uuid, 'مشتری' AS name, 'client' AS slug,
           'صفحه شخصی، سفارش و پیام پس از تأیید مدیر' AS description, 1 AS is_system, @now AS created_at, @now AS updated_at
    FROM `companies`
    WHERE NOT EXISTS (
        SELECT 1 FROM `roles` existing
        WHERE existing.company_id = companies.id AND existing.slug = 'client'
    )
) AS fresh;

INSERT INTO `role_permissions` (`role_id`, `permission_id`)
SELECT pair.role_id, pair.permission_id
FROM (
    SELECT roles.id AS role_id, permissions.id AS permission_id
    FROM `roles`
    INNER JOIN `permissions` ON permissions.name IN ('profile.view', 'profile.update')
    WHERE roles.is_system = 1 AND roles.slug = 'client'
      AND NOT EXISTS (
          SELECT 1 FROM `role_permissions` existing
          WHERE existing.role_id = roles.id AND existing.permission_id = permissions.id
      )
) AS pair;

INSERT INTO `role_permissions` (`role_id`, `permission_id`)
SELECT pair.role_id, pair.permission_id
FROM (
    SELECT roles.id AS role_id, permissions.id AS permission_id
    FROM `roles`
    INNER JOIN `permissions` ON permissions.name IN (
        'customers.view', 'customers.review', 'products.view', 'products.manage',
        'customer_orders.view', 'customer_orders.manage', 'customer_messages.view', 'customer_messages.reply'
    )
    WHERE roles.is_system = 1 AND roles.slug IN ('company-owner', 'ceo', 'department-manager')
      AND NOT EXISTS (
          SELECT 1 FROM `role_permissions` existing
          WHERE existing.role_id = roles.id AND existing.permission_id = permissions.id
      )
) AS pair;

INSERT INTO `role_permissions` (`role_id`, `permission_id`)
SELECT pair.role_id, pair.permission_id
FROM (
    SELECT roles.id AS role_id, permissions.id AS permission_id
    FROM `roles`
    INNER JOIN `permissions` ON permissions.name IN ('customers.view', 'customers.review')
    WHERE roles.is_system = 1 AND roles.slug = 'hr'
      AND NOT EXISTS (
          SELECT 1 FROM `role_permissions` existing
          WHERE existing.role_id = roles.id AND existing.permission_id = permissions.id
      )
) AS pair;

INSERT INTO `role_permissions` (`role_id`, `permission_id`)
SELECT pair.role_id, pair.permission_id
FROM (
    SELECT roles.id AS role_id, permissions.id AS permission_id
    FROM `roles`
    INNER JOIN `permissions` ON permissions.name IN (
        'customers.view', 'products.view', 'customer_orders.view', 'customer_orders.manage',
        'customer_messages.view', 'customer_messages.reply'
    )
    WHERE roles.is_system = 1 AND roles.slug = 'sales'
      AND NOT EXISTS (
          SELECT 1 FROM `role_permissions` existing
          WHERE existing.role_id = roles.id AND existing.permission_id = permissions.id
      )
) AS pair;

INSERT INTO `features` (`company_id`, `key`, `enabled`, `created_at`, `updated_at`)
SELECT fresh.company_id, fresh.feature_key, fresh.enabled, fresh.created_at, fresh.updated_at
FROM (
    SELECT companies.id AS company_id, 'portal' AS feature_key, 1 AS enabled, @now AS created_at, @now AS updated_at
    FROM `companies`
    WHERE NOT EXISTS (
        SELECT 1 FROM `features` existing
        WHERE existing.company_id = companies.id AND existing.`key` = 'portal'
    )
) AS fresh;

UPDATE `features` SET `enabled` = 1, `updated_at` = @now WHERE `key` = 'portal' AND `enabled` = 0;

SET @batch = (SELECT IFNULL(MAX(`batch`), 1) FROM `migrations`);
SET @has_portal = (SELECT COUNT(*) FROM `migrations` WHERE `migration` = '2026_09_25_160000_create_portal_tables');
SET @sql = IF(@has_portal = 0, CONCAT('INSERT INTO `migrations` (`migration`, `batch`) VALUES (''2026_09_25_160000_create_portal_tables'', ', @batch, ')'), 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
SET @has_tickets = (SELECT COUNT(*) FROM `migrations` WHERE `migration` = '2026_09_25_160100_create_customer_ticket_tables');
SET @sql = IF(@has_tickets = 0, CONCAT('INSERT INTO `migrations` (`migration`, `batch`) VALUES (''2026_09_25_160100_create_customer_ticket_tables'', ', @batch, ')'), 'SELECT 1');
PREPARE portal_stmt FROM @sql; EXECUTE portal_stmt; DEALLOCATE PREPARE portal_stmt;
