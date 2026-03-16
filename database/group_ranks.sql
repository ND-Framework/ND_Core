CREATE TABLE IF NOT EXISTS `nd_group_ranks` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `group_name` VARCHAR(50) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `weight` INT NOT NULL DEFAULT 1,
    `isBoss` TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    INDEX `idx_group_name` (`group_name`),
    CONSTRAINT `fk_group_ranks_group` FOREIGN KEY (`group_name`) REFERENCES `nd_groups`(`name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
