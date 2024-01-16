CREATE TABLE IF NOT EXISTS `nd_characters` (
    `charid` INT(10) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(200) NOT NULL DEFAULT '0',
    `name` VARCHAR(50) DEFAULT NULL,
    `firstname` VARCHAR(50) DEFAULT NULL,
    `lastname` VARCHAR(50) DEFAULT NULL,
    `dob` VARCHAR(50) DEFAULT NULL,
    `gender` VARCHAR(50) DEFAULT NULL,
    `cash` INT(10) DEFAULT '0',
    `bank` INT(10) DEFAULT '0',
    `phonenumber` VARCHAR(20) DEFAULT NULL,
    `groups` LONGTEXT DEFAULT ('[]'),
    `metadata` LONGTEXT DEFAULT ('[]'),
    `inventory` LONGTEXT DEFAULT ('[]'),
    PRIMARY KEY (`charid`) USING BTREE
);
CREATE TABLE IF NOT EXISTS `nd_vehicles` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `owner` INT(11) DEFAULT NULL,
    `plate` VARCHAR(255) DEFAULT NULL,
    `glovebox` LONGTEXT DEFAULT ('[]'),
    `trunk` LONGTEXT DEFAULT ('[]'),
    `properties` LONGTEXT DEFAULT ('[]'),
    `stored` INT(11) DEFAULT '1',
    `impounded` INT(11) DEFAULT '0',
    `stolen` INT(11) DEFAULT '0',
    `metadata` LONGTEXT DEFAULT ('[]'),
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `owner` (`owner`) USING BTREE,
    CONSTRAINT `vehowner` FOREIGN KEY (`owner`) REFERENCES `nd_characters` (`charid`) ON UPDATE CASCADE ON DELETE CASCADE
);
