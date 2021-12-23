CREATE TABLE `characters` (
	`license` VARCHAR(200) NOT NULL DEFAULT '0' COLLATE 'utf8mb4_general_ci',
	`character_id` INT(50) NULL DEFAULT NULL,
	`first_name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`last_name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`dob` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`gender` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`twt` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`department` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`cash` INT(11) NULL DEFAULT NULL,
	`bank` INT(11) NULL DEFAULT NULL
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
;