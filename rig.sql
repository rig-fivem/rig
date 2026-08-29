-- User Accounts

CREATE TABLE IF NOT EXISTS `users` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `unique_id` VARCHAR(255) NOT NULL,
    `username` VARCHAR(255) DEFAULT NULL,
    `name` VARCHAR(255) NOT NULL,
    `vip` INT(1) NOT NULL DEFAULT 1,
    `license` VARCHAR(255) NOT NULL,
    `discord` VARCHAR(255) DEFAULT NULL,
    `tokens` JSON NOT NULL,
    `ip` VARCHAR(255) NOT NULL,
    `banned` TINYINT(1) NOT NULL DEFAULT 0,
    `muted` TINYINT(1) NOT NULL DEFAULT 0,
    `deleted` TINYINT(1) NOT NULL DEFAULT 0,
    `last_login` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`unique_id`),
    KEY `id_idx` (`id`),
    KEY `license_idx` (`license`),
    KEY `banned_idx` (`banned`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_bans` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `unique_id` VARCHAR(255) NOT NULL,
    `banned_by` VARCHAR(255) NOT NULL DEFAULT 'rig',
    `reason` TEXT DEFAULT NULL,
    `expires_at` TIMESTAMP NULL DEFAULT NULL,
    `expired` TINYINT(1) NOT NULL DEFAULT 0,
    `appealed` TINYINT(1) NOT NULL DEFAULT 0,
    `appealed_by` VARCHAR(255) DEFAULT NULL,
    `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `unique_id_idx` (`unique_id`),
    KEY `expired_idx` (`expired`),
    FOREIGN KEY (`unique_id`) REFERENCES `users` (`unique_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_warnings` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `unique_id` VARCHAR(255) NOT NULL,
    `warned_by` VARCHAR(255) NOT NULL DEFAULT 'rig',
    `reason` TEXT DEFAULT NULL,
    `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `unique_id_idx` (`unique_id`),
    FOREIGN KEY (`unique_id`) REFERENCES `users` (`unique_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;