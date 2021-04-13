-- Adminer 4.8.0 MySQL 5.5.5-10.3.25-MariaDB-0ubuntu0.20.04.1 dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

SET NAMES utf8mb4;

DROP TABLE IF EXISTS `countries`;
CREATE TABLE `countries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `default_tax_percentage` decimal(10,2) NOT NULL,
  `language_id` int(11) NOT NULL,
  `currency_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `countries_ibfk_1` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `countries` (`id`, `name`, `default_tax_percentage`, `language_id`, `currency_id`) VALUES
(1,	'Nederland',	21.00,	1,	1),
(2,	'United States',	5.00,	2,	2),
(3,	'United Kingdom',	20.00,	2,	3);

DROP TABLE IF EXISTS `currencies`;
CREATE TABLE `currencies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `character` varchar(255) NOT NULL,
  `abbreviation` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `currencies` (`id`, `name`, `character`, `abbreviation`) VALUES
(1,	'Euro',	'€',	'EUR'),
(2,	'US Dollar',	'$',	'USD'),
(3,	'Pound Sterling',	'£',	'GBP');

DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tenant_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `contact` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `tax_reverse_charge` tinyint(1) NOT NULL DEFAULT 0,
  `language_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `tenant_id` (`tenant_id`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `customers_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`),
  CONSTRAINT `customers_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `deliveries`;
CREATE TABLE `deliveries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tenant_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `project_id` int(11) DEFAULT NULL,
  `date` date NOT NULL,
  `name` varchar(255) NOT NULL,
  `subtotal` decimal(10,2) DEFAULT NULL,
  `tax_percentage` decimal(10,2) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `invoiceline_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `project_id` (`project_id`),
  KEY `invoiceline_id` (`invoiceline_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `deliveries_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `deliveries_ibfk_3` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`),
  CONSTRAINT `deliveries_ibfk_4` FOREIGN KEY (`invoiceline_id`) REFERENCES `invoicelines` (`id`),
  CONSTRAINT `deliveries_ibfk_5` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `hours`;
CREATE TABLE `hours` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tenant_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `date` date NOT NULL,
  `name` varchar(255) NOT NULL,
  `hours_worked` decimal(5,2) NOT NULL,
  `hourly_fee` decimal(10,2) DEFAULT NULL,
  `subtotal` decimal(10,2) DEFAULT NULL,
  `tax_percentage` decimal(10,2) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `invoiceline_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `project_id` (`project_id`),
  KEY `type` (`type`),
  KEY `datum` (`date`),
  KEY `tenant_id` (`tenant_id`),
  KEY `invoiceline_id` (`invoiceline_id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `hours_ibfk_2` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`),
  CONSTRAINT `hours_ibfk_3` FOREIGN KEY (`type`) REFERENCES `hourtypes` (`id`),
  CONSTRAINT `hours_ibfk_5` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`),
  CONSTRAINT `hours_ibfk_6` FOREIGN KEY (`invoiceline_id`) REFERENCES `invoicelines` (`id`),
  CONSTRAINT `hours_ibfk_7` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `hourtypes`;
CREATE TABLE `hourtypes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tenant_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `hourtypes_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `invoicelines`;
CREATE TABLE `invoicelines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tenant_id` int(11) NOT NULL,
  `invoice_id` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `tax` decimal(10,2) DEFAULT NULL,
  `tax_percentage` decimal(10,2) DEFAULT NULL,
  `total` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `tenant_id` (`tenant_id`),
  KEY `invoice_id` (`invoice_id`),
  CONSTRAINT `invoicelines_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`),
  CONSTRAINT `invoicelines_ibfk_5` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `invoices`;
CREATE TABLE `invoices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tenant_id` int(11) NOT NULL,
  `number` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `date` date DEFAULT NULL,
  `sent` date DEFAULT NULL,
  `paid` date DEFAULT NULL,
  `reminder1` date DEFAULT NULL,
  `reminder2` date DEFAULT NULL,
  `customer_id` int(11) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `tax` decimal(10,2) DEFAULT NULL,
  `total` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tenant_id_number` (`tenant_id`,`number`),
  KEY `customer_id` (`customer_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `invoices_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `invoices_ibfk_2` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `languages`;
CREATE TABLE `languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `code` varchar(2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `languages` (`id`, `name`, `code`) VALUES
(1,	'Nederlands',	'nl'),
(2,	'English',	'en');

DROP TABLE IF EXISTS `offers`;
CREATE TABLE `offers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tenant_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `name` varchar(255) NOT NULL,
  `product_id` int(11) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `approved` tinyint(1) NOT NULL,
  `signed` tinyint(1) NOT NULL,
  `intro_html` text DEFAULT NULL,
  `planning_html` text DEFAULT NULL,
  `betaling_html` text DEFAULT NULL,
  `line1` varchar(255) DEFAULT NULL,
  `amount1` decimal(10,2) DEFAULT NULL,
  `line2` varchar(255) DEFAULT NULL,
  `amount2` decimal(10,2) DEFAULT NULL,
  `line3` varchar(255) DEFAULT NULL,
  `amount3` decimal(10,2) DEFAULT NULL,
  `line4` varchar(255) DEFAULT NULL,
  `amount4` decimal(10,2) DEFAULT NULL,
  `line5` varchar(255) DEFAULT NULL,
  `amount5` decimal(10,2) DEFAULT NULL,
  `line6` varchar(255) DEFAULT NULL,
  `amount6` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  KEY `customer_id` (`customer_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `offers_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `offers_ibfk_3` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `offers_ibfk_4` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tenant_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `products_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `projects`;
CREATE TABLE `projects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tenant_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `default_hourly_fee` decimal(10,2) DEFAULT NULL,
  `active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `projects_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `projects_ibfk_2` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `subscriptionperiods`;
CREATE TABLE `subscriptionperiods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tenant_id` int(11) NOT NULL,
  `from` date NOT NULL,
  `until` date NOT NULL,
  `name` varchar(255) NOT NULL,
  `subscription_id` int(11) NOT NULL,
  `comment` text DEFAULT NULL,
  `invoiceline_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tenant_id` (`tenant_id`),
  KEY `subscription_id` (`subscription_id`),
  KEY `invoiceline_id` (`invoiceline_id`),
  CONSTRAINT `subscriptionperiods_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`),
  CONSTRAINT `subscriptionperiods_ibfk_3` FOREIGN KEY (`subscription_id`) REFERENCES `subscriptions` (`id`),
  CONSTRAINT `subscriptionperiods_ibfk_4` FOREIGN KEY (`invoiceline_id`) REFERENCES `invoicelines` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `subscriptions`;
CREATE TABLE `subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tenant_id` int(11) NOT NULL,
  `fee` decimal(10,2) NOT NULL,
  `tax_percentage` decimal(10,2) DEFAULT NULL,
  `months` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `from` date NOT NULL,
  `canceled` date DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `subscriptiontype_id` int(11) DEFAULT NULL,
  `customer_id` int(11) NOT NULL,
  `referral_customer_id` int(11) DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `project_id` (`project_id`),
  KEY `subscriptiontype_id` (`subscriptiontype_id`),
  KEY `tenant_id` (`tenant_id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `subscriptions_ibfk_4` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`),
  CONSTRAINT `subscriptions_ibfk_6` FOREIGN KEY (`subscriptiontype_id`) REFERENCES `subscriptiontypes` (`id`),
  CONSTRAINT `subscriptions_ibfk_7` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`),
  CONSTRAINT `subscriptions_ibfk_8` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `subscriptiontypes`;
CREATE TABLE `subscriptiontypes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tenant_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `comment` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `subscriptiontypes_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `templates`;
CREATE TABLE `templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `language_id` int(11) NOT NULL,
  `tenant_id` int(11) NOT NULL,
  `invoice_styles` text DEFAULT NULL,
  `invoice_template` text DEFAULT NULL,
  `invoiceline_template` text DEFAULT NULL,
  `invoice_page_number` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tenant_id` (`tenant_id`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `templates_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`),
  CONSTRAINT `templates_ibfk_2` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`),
  CONSTRAINT `templates_ibfk_3` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `tenants`;
CREATE TABLE `tenants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `contact` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `invoice_email` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `bank_account_number` varchar(255) DEFAULT NULL,
  `bank_account_name` varchar(255) DEFAULT NULL,
  `bank_name` varchar(255) DEFAULT NULL,
  `bank_bic` varchar(255) DEFAULT NULL,
  `bank_city` varchar(255) DEFAULT NULL,
  `coc_number` varchar(255) DEFAULT NULL,
  `tax_number` varchar(255) DEFAULT NULL,
  `default_tax_percentage` decimal(10,2) NOT NULL DEFAULT 21.00,
  `default_hourly_fee` decimal(10,2) NOT NULL DEFAULT 75.00,
  `payment_period` int(11) NOT NULL DEFAULT 30,
  `reminder_period` int(11) NOT NULL DEFAULT 14,
  `logo_image` mediumblob DEFAULT NULL,
  `signature_image` mediumblob DEFAULT NULL,
  `hours_active` tinyint(1) NOT NULL DEFAULT 1,
  `subscriptions_active` tinyint(1) NOT NULL DEFAULT 1,
  `country_id` int(11) NOT NULL,
  `currency_id` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `country_id` (`country_id`),
  KEY `currency_id` (`currency_id`),
  CONSTRAINT `tenants_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`),
  CONSTRAINT `tenants_ibfk_2` FOREIGN KEY (`currency_id`) REFERENCES `currencies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tenant_id` int(11) DEFAULT NULL,
  `username` varchar(255) CHARACTER SET utf8 NOT NULL,
  `password` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `created` datetime NOT NULL,
  `superadmin` tinyint(1) NOT NULL DEFAULT 0,
  `name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `tenant_id` (`tenant_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


-- 2021-04-13 20:25:31
