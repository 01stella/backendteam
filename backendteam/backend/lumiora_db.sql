CREATE DATABASE IF NOT EXISTS `lumiora_db` 
USE `lumiora_db`;

CREATE TABLE IF NOT EXISTS `bundle_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bundle_id` int NOT NULL,
  `menu_item_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `bundle_id` (`bundle_id`),
  KEY `menu_item_id` (`menu_item_id`),
  CONSTRAINT `bundle_items_ibfk_1` FOREIGN KEY (`bundle_id`) REFERENCES `bundles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bundle_items_ibfk_2` FOREIGN KEY (`menu_item_id`) REFERENCES `menu` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `bundles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `price` int NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `category` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `customer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(255) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `birthday` date DEFAULT NULL,
  `hashed_password` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `modified_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_UNIQUE` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `menu` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `item_name` varchar(100) NOT NULL,
  `description` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `station_code` varchar(10) DEFAULT 'B',
  PRIMARY KEY (`id`),
  KEY `category_menu` (`category_id`),
  CONSTRAINT `category_menu` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `order_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `menu_id` int NOT NULL,
  `quantity` int NOT NULL,
  `ice_level` varchar(20) DEFAULT NULL,
  `sugar_level` varchar(20) DEFAULT NULL,
  `coffee_strength` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'Normal',
  `item_price` decimal(10,2) DEFAULT NULL,
  `item_status` varchar(20) DEFAULT 'pending',
  `notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `menu_id` (`menu_id`),
  CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`menu_id`) REFERENCES `menu` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int DEFAULT NULL,
  `total` decimal(10,2) NOT NULL,
  `order_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'pending',
  `payment_method` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'cashier',
  `payment_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'unpaid',
  `created_at` datetime DEFAULT (now()),
  `modified_at` datetime NOT NULL,
  `fulfillment_type` enum('pickup','delivery') NOT NULL DEFAULT 'pickup',
  `pickup_time` time DEFAULT NULL,
  `delivery_floor` varchar(50) DEFAULT NULL,
  `delivery_room` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `customer_id` (`customer_id`) USING BTREE,
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `stamps` (
  `id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `order_id` int DEFAULT NULL,
  `stamp_change` int NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_id` (`order_id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `stamps_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`),
  CONSTRAINT `stamps_ibfk_2` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


