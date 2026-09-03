-- User Tables
-- Users
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

-- Bans
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

-- Warnings
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

-- Group Tables
-- Groups
CREATE TABLE IF NOT EXISTS `groups` (
    `name` VARCHAR(50) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `type` VARCHAR(32) NOT NULL DEFAULT 'group',
    `parent_name` VARCHAR(50) DEFAULT NULL,
    `metadata` JSON NOT NULL,
    PRIMARY KEY (`name`),
    KEY `type_idx` (`type`),
    FOREIGN KEY (`parent_name`) REFERENCES `groups` (`name`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Roles
CREATE TABLE IF NOT EXISTS `group_roles` (
    `group_name` VARCHAR(50) NOT NULL,
    `name` VARCHAR(50) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `grade` INT NOT NULL DEFAULT 0,
    `permissions` JSON NOT NULL,
    PRIMARY KEY (`group_name`, `name`),
    KEY `grade_idx` (`grade`),
    FOREIGN KEY (`group_name`) REFERENCES `groups` (`name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Members
CREATE TABLE IF NOT EXISTS `group_members` (
    `group_name` VARCHAR(50) NOT NULL,
    `unique_id` VARCHAR(255) NOT NULL,
    `role_name` VARCHAR(50) NOT NULL,
    `is_primary` TINYINT(1) NOT NULL DEFAULT 0,
    `metadata` JSON NOT NULL,
    `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`group_name`, `unique_id`),
    FOREIGN KEY (`group_name`) REFERENCES `groups` (`name`) ON DELETE CASCADE,
    FOREIGN KEY (`group_name`, `role_name`) REFERENCES `group_roles` (`group_name`, `name`) ON DELETE CASCADE,
    FOREIGN KEY (`unique_id`) REFERENCES `users` (`unique_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Player Tables
-- Avatars
CREATE TABLE IF NOT EXISTS `avatars` (
    `unique_id` VARCHAR(255) NOT NULL,
    `ped` VARCHAR(255) NOT NULL DEFAULT "mp_m_freemode_01",
    `genetics` JSON NOT NULL DEFAULT (JSON_OBJECT()),
    `barber` JSON NOT NULL DEFAULT (JSON_OBJECT()),
    `clothing` JSON NOT NULL DEFAULT (JSON_OBJECT()),
    `tattoos` JSON NOT NULL DEFAULT (JSON_OBJECT()),
    `has_customised` TINYINT(1) NOT NULL DEFAULT 0,
    `last_played` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`unique_id`),
    FOREIGN KEY (`unique_id`) REFERENCES `users` (`unique_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Spawns
CREATE TABLE IF NOT EXISTS `spawns` (
    `unique_id` VARCHAR(255) NOT NULL,
    `spawn_id` VARCHAR(50) NOT NULL DEFAULT 'last_location',
    `spawn_type` VARCHAR(20) NOT NULL DEFAULT 'last_location',
    `label` VARCHAR(100) DEFAULT NULL,
    `x` FLOAT NOT NULL,
    `y` FLOAT NOT NULL,
    `z` FLOAT NOT NULL,
    `w` FLOAT NOT NULL,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`unique_id`, `spawn_id`),
    KEY `spawn_type_idx` (`spawn_type`),
    FOREIGN KEY (`unique_id`) REFERENCES `users` (`unique_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Statuses
CREATE TABLE IF NOT EXISTS `statuses` (
    `unique_id` VARCHAR(255) NOT NULL,
    `health` FLOAT NOT NULL DEFAULT 200.0,
    `armour` FLOAT NOT NULL DEFAULT 0.0,
    `hunger` FLOAT NOT NULL DEFAULT 100.0,
    `thirst` FLOAT NOT NULL DEFAULT 100.0,
    `hygiene` FLOAT NOT NULL DEFAULT 100.0,
    `fatigue` FLOAT NOT NULL DEFAULT 0.0,
    `stress` FLOAT NOT NULL DEFAULT 0.0,
    `bleeding` FLOAT NOT NULL DEFAULT 0.0,
    `radiation` FLOAT NOT NULL DEFAULT 0.0,
    `infection` FLOAT NOT NULL DEFAULT 0.0,
    `poison` FLOAT NOT NULL DEFAULT 0.0,
    `temperature` FLOAT NOT NULL DEFAULT 37.0,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`unique_id`),
    FOREIGN KEY (`unique_id`) REFERENCES `users` (`unique_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Statuses: Injuries
CREATE TABLE IF NOT EXISTS `injuries` (
    `unique_id` VARCHAR(255) NOT NULL,
    `head` FLOAT NOT NULL DEFAULT 0.0,
    `upper_torso` FLOAT NOT NULL DEFAULT 0.0,
    `lower_torso` FLOAT NOT NULL DEFAULT 0.0,
    `forearm_right` FLOAT NOT NULL DEFAULT 0.0,
    `forearm_left` FLOAT NOT NULL DEFAULT 0.0,
    `hand_right` FLOAT NOT NULL DEFAULT 0.0,
    `hand_left` FLOAT NOT NULL DEFAULT 0.0,
    `thigh_right` FLOAT NOT NULL DEFAULT 0.0,
    `thigh_left` FLOAT NOT NULL DEFAULT 0.0,
    `calf_right` FLOAT NOT NULL DEFAULT 0.0,
    `calf_left` FLOAT NOT NULL DEFAULT 0.0,
    `foot_right` FLOAT NOT NULL DEFAULT 0.0,
    `foot_left` FLOAT NOT NULL DEFAULT 0.0,
    PRIMARY KEY (`unique_id`),
    FOREIGN KEY (`unique_id`) REFERENCES `users` (`unique_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Statuses: Effects
CREATE TABLE IF NOT EXISTS `effects` (
    `unique_id` VARCHAR(255) NOT NULL,
    `effect_id` VARCHAR(255) NOT NULL,
    `effect_type` VARCHAR(20) NOT NULL DEFAULT 'status',
    `effect_name` VARCHAR(100) NOT NULL,
    `duration` INT NOT NULL DEFAULT -1,
    `stacks` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `applied_at` INT NOT NULL,
    `expires_at` INT NULL DEFAULT NULL,
    PRIMARY KEY (`unique_id`, `effect_id`),
    KEY `unique_id_idx` (`unique_id`),
    KEY `expires_at_idx` (`expires_at`),
    FOREIGN KEY (`unique_id`) REFERENCES `users` (`unique_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Inventory Tables
-- Inventories
CREATE TABLE IF NOT EXISTS `inventories` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(255) NOT NULL,
    `owner` VARCHAR(255) NOT NULL,
    `inventory_type` VARCHAR(50) NOT NULL DEFAULT 'player',
    `inventory_subtype` VARCHAR(50) DEFAULT NULL,
    `items` JSON NOT NULL DEFAULT (JSON_OBJECT()),
    `metadata` JSON DEFAULT (JSON_OBJECT()),
    `last_update` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier_unique` (`identifier`),
    KEY `owner_idx` (`owner`),
    KEY `inventory_type_inventory_subtype_idx` (`inventory_type`, `inventory_subtype`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Delimiter; removes player inventories when `user` account is removed.
DELIMITER $$

DROP TRIGGER IF EXISTS trg_users_after_delete;

CREATE TRIGGER trg_users_after_delete
AFTER DELETE ON users
FOR EACH ROW
BEGIN
    DELETE FROM inventories
    WHERE owner = OLD.unique_id
      AND inventory_type = 'player';
END$$

DELIMITER ;