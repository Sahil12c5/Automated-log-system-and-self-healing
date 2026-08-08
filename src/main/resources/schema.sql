-- ============================================================================
-- Automated Log System & Self-Healing Platform (Phase 1 & Phase 2 Schema)
-- Target RDBMS: MySQL 8.0+
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `autoheal_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `autoheal_db`;

-- Drop existing tables in reverse dependency order for clean migrations
DROP TABLE IF EXISTS `logs`;
DROP TABLE IF EXISTS `auto_healing_rules`;
DROP TABLE IF EXISTS `audit_logs`;
DROP TABLE IF EXISTS `otp_verifications`;
DROP TABLE IF EXISTS `user_domain_scopes`;
DROP TABLE IF EXISTS `domains`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `organizations`;

-- 1. Organizations Table (Multi-Tenant Root)
CREATE TABLE `organizations` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(150) NOT NULL UNIQUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Users Table
CREATE TABLE `users` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `organization_id` BIGINT NOT NULL,
    `full_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `role` ENUM('OWNER', 'MANAGER', 'SENIOR_DEVELOPER', 'DEVELOPER') NOT NULL DEFAULT 'DEVELOPER',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`organization_id`) REFERENCES `organizations`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Domains Table
CREATE TABLE `domains` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `organization_id` BIGINT NOT NULL,
    `domain_name` VARCHAR(255) NOT NULL,
    `api_key` VARCHAR(64) NOT NULL UNIQUE,
    `github_repo` VARCHAR(255) NULL,
    `github_token` VARCHAR(255) NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`organization_id`) REFERENCES `organizations`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_org_domain` (`organization_id`, `domain_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. User Domain Scopes Table
CREATE TABLE `user_domain_scopes` (
    `user_id` BIGINT NOT NULL,
    `domain_id` BIGINT NOT NULL,
    PRIMARY KEY (`user_id`, `domain_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`domain_id`) REFERENCES `domains`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. OTP Verifications Table
CREATE TABLE `otp_verifications` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `email` VARCHAR(150) NOT NULL,
    `otp_code` VARCHAR(10) NOT NULL,
    `expires_at` TIMESTAMP NOT NULL,
    `is_used` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_email_otp` (`email`, `otp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Audit Logs Table
CREATE TABLE `audit_logs` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `organization_id` BIGINT NOT NULL,
    `user_id` BIGINT NULL,
    `action` VARCHAR(100) NOT NULL,
    `details` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`organization_id`) REFERENCES `organizations`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Auto Healing Rules Table (Phase 2)
CREATE TABLE `auto_healing_rules` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `domain_id` BIGINT NOT NULL,
    `error_pattern` VARCHAR(255) NOT NULL,
    `action_type` ENUM('RESTART_SERVICE', 'CLEAR_CACHE', 'RESET_CONNECTION', 'CUSTOM_SCRIPT') NOT NULL,
    `target_script` VARCHAR(255) NOT NULL,
    `is_active` TINYINT(1) DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`domain_id`) REFERENCES `domains`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. Ingested Logs Table (Phase 2)
CREATE TABLE `logs` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `domain_id` BIGINT NOT NULL,
    `log_level` ENUM('INFO', 'WARN', 'ERROR', 'CRITICAL') NOT NULL,
    `message` TEXT NOT NULL,
    `stack_trace` TEXT NULL,
    `status` ENUM('PENDING', 'AUTO_HEALED', 'AI_DIAGNOSED', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    `executed_action` VARCHAR(255) NULL,
    `ai_root_cause` TEXT NULL,
    `ai_remediation_suggestion` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`domain_id`) REFERENCES `domains`(`id`) ON DELETE CASCADE,
    INDEX `idx_domain_created` (`domain_id`, `created_at`),
    INDEX `idx_level_status` (`log_level`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed Data for testing
INSERT INTO `organizations` (`id`, `name`) VALUES (1, 'Acme Cloud Solutions');

-- Default password for sample users: Password@123 (BCrypt hash)
INSERT INTO `users` (`id`, `organization_id`, `full_name`, `email`, `password_hash`, `role`) 
VALUES 
(1, 1, 'Sarah Connor (Owner)', 'owner@acme.com', '$2a$10$w8T0O9dO9c2Z7x9/L4v40uYwJg4jF6Xp1kK1wL.A7D9kQ0P.8q4C2', 'OWNER'),
(2, 1, 'Alex Mercer (Dev)', 'dev@acme.com', '$2a$10$w8T0O9dO9c2Z7x9/L4v40uYwJg4jF6Xp1kK1wL.A7D9kQ0P.8q4C2', 'SENIOR_DEVELOPER');

INSERT INTO `domains` (`id`, `organization_id`, `domain_name`, `api_key`)
VALUES 
(1, 1, 'api.acme-cloud.internal', 'ahl_live_9f82b7c4e1a04d3b8f62c9e710a34b21'),
(2, 1, 'auth.acme-cloud.io', 'ahl_live_4d71e2c90f8341b5a92c8d10e34f67a2');

INSERT INTO `user_domain_scopes` (`user_id`, `domain_id`) VALUES (1, 1), (1, 2), (2, 1);

INSERT INTO `auto_healing_rules` (`id`, `domain_id`, `error_pattern`, `action_type`, `target_script`, `is_active`)
VALUES
(1, 1, 'Connection pool exhausted', 'RESET_CONNECTION', 'scripts/reset-db-pool.sh', 1),
(2, 1, 'OutOfMemoryError: Java heap space', 'RESTART_SERVICE', 'scripts/restart-app-service.sh', 1),
(3, 2, 'RedisCacheException', 'CLEAR_CACHE', 'scripts/flush-redis-cache.sh', 1);

INSERT INTO `logs` (`id`, `domain_id`, `log_level`, `message`, `stack_trace`, `status`, `executed_action`, `created_at`)
VALUES
(1, 1, 'INFO', 'User authentication request processed successfully for user_id=4029', NULL, 'AUTO_HEALED', NULL, NOW() - INTERVAL 15 MINUTE),
(2, 1, 'ERROR', 'Connection pool exhausted: Timeout waiting for idle database connection', 'java.sql.SQLException: Connection pool exhausted\n\tat com.zaxxer.hikari.pool.HikariPool.getConnection(HikariPool.java:213)', 'AUTO_HEALED', 'RESET_CONNECTION: scripts/reset-db-pool.sh', NOW() - INTERVAL 10 MINUTE),
(3, 1, 'CRITICAL', 'Fatal Memory Leak: OutOfMemoryError: Java heap space in Garbage Collector', 'java.lang.OutOfMemoryError: Java heap space\n\tat java.base/java.util.Arrays.copyOf(Arrays.java:3522)', 'AUTO_HEALED', 'RESTART_SERVICE: scripts/restart-app-service.sh', NOW() - INTERVAL 5 MINUTE),
(4, 2, 'ERROR', 'Unhandled NullPointerException in Gateway Token Parsing', 'java.lang.NullPointerException: Cannot invoke getClaims() because token is null\n\tat com.acme.auth.TokenValidator.validate(TokenValidator.java:42)', 'PENDING', NULL, NOW() - INTERVAL 2 MINUTE);

INSERT INTO `audit_logs` (`organization_id`, `user_id`, `action`, `details`) VALUES 
(1, 1, 'ORGANIZATION_CREATED', 'Organization Acme Cloud Solutions registered'),
(1, 1, 'DOMAIN_REGISTERED', 'Domain api.acme-cloud.internal added with API Key'),
(1, 1, 'RULE_CREATED', 'Auto-healing rule created for pattern "Connection pool exhausted"');
