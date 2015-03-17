--
-- To reload the database:
-- $ mysql -u root -p < ngx_hawk_dm.sql
--
set session storage_engine = "InnoDB";

set session time_zone = "+0:00";

drop database if exists ngx_hawk;

create database ngx_hawk default character set utf8 default collate utf8_general_ci;

grant all privileges on ngx_hawk.* TO 'ngx_hawk'@'localhost' identified by 'FIXME';

use ngx_hawk;

-- Services
CREATE TABLE `services` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `version` varchar(16) NOT NULL,
  `host` varchar(255) NOT NULL,
  `port` int(11),
  PRIMARY KEY (`id`),
  UNIQUE KEY (`name`, `version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Clients
CREATE TABLE `clients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hawk_id` varchar(100) NOT NULL,
  `secret_key` text NOT NULL,
  `salt` varchar(12) NOT NULL,
  `algorithm` varchar(10) NOT NULL DEFAULT 'sha256',
  PRIMARY KEY (`id`),
  UNIQUE KEY (`hawk_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Permissions
CREATE TABLE `permissions` (
  `client_id` int(11) NOT NULL,
  `service_id` int(11) NOT NULL,
  `beg_eff_date` date,
  `end_eff_date` date,
  `locked` varchar(1) NOT NULL DEFAULT 'N',
  CONSTRAINT `permissions_fk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `permissions_fk_2` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE RESTRICT,
  PRIMARY KEY (`client_id`, `service_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Service nonce storage
CREATE TABLE `nonces` (
  `hawk_id` varchar(100) NOT NULL,
  `nonce` varchar(40) NOT NULL,
  `artifacts` text,
  `created` timestamp NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`hawk_id`, `nonce`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

