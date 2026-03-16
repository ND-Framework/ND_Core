CREATE TABLE IF NOT EXISTS `nd_money_log` (
    `log_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `character_id` INT(10) NOT NULL,
    `action` VARCHAR(50) DEFAULT NULL,
    `account` ENUM('cash', 'bank') NOT NULL,
    `amount` INT(10) NOT NULL,
    `reason` VARCHAR(255) DEFAULT NULL,
    `trace` TEXT DEFAULT NULL,
    `date_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`log_id`),
    KEY `idx_character_id` (`character_id`),
    CONSTRAINT `fk_moneylog_character` FOREIGN KEY (`character_id`) REFERENCES `nd_characters` (`charid`) ON UPDATE CASCADE ON DELETE CASCADE
);
