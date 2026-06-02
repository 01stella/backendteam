-- --------------------------------------------------------
-- Host:                         43.133.144.212
-- Server version:               8.0.46 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.17.0.7270
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for cafe_db
CREATE DATABASE IF NOT EXISTS `cafe_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `cafe_db`;

-- Dumping structure for table cafe_db.bundles
CREATE TABLE IF NOT EXISTS `bundles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `Type` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table cafe_db.bundles: ~11 rows (approximately)
INSERT INTO `bundles` (`id`, `Type`, `name`, `description`, `price`, `created_at`) VALUES
	(1, 'Duo', 'Twin Brew', '2 cups of Americano', 30000.00, '2026-05-07 06:14:33'),
	(2, 'Duo', 'Signature Pair', 'Aren Latte + Americano', 35000.00, '2026-05-07 06:14:33'),
	(3, 'Duo', 'Nusantara Duo', '2 cups of Aren Latte', 40000.00, '2026-05-07 06:14:33'),
	(4, 'Duo', 'The Classics Duo', '2 cups of Latte', 40000.00, '2026-05-07 06:14:33'),
	(5, 'Duo', 'Double Choc', '2 cups of Chocolate', 45000.00, '2026-05-07 06:14:33'),
	(6, 'Trio', 'Mood Booster', '3 cups of Americano', 45000.00, '2026-05-07 06:14:33'),
	(7, 'Trio', 'Triple Treat', 'Hazelnut, Vanilla, Caramel', 60000.00, '2026-05-07 06:14:33'),
	(8, 'Trio', 'Sweetie Sweet', 'Pandan, Avocado, Coconut', 60000.00, '2026-05-07 06:14:33'),
	(9, 'Trio', 'House Favorites', 'Butterscotch, Matcha, Chocolate', 60000.00, '2026-05-07 06:14:33'),
	(10, 'duo', 'aa', 'dd', 23232.00, '2026-05-07 06:46:49'),
	(12, 'Duo', 'balabal', 'Two premium coffees and two pastries perfect for sharing.', 85000.00, '2026-05-07 06:48:55');

-- Dumping structure for table cafe_db.category
CREATE TABLE IF NOT EXISTS `category` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` enum('latte_series','classics','non_coffee') COLLATE utf8mb4_general_ci NOT NULL,
  UNIQUE KEY `unique_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table cafe_db.category: ~3 rows (approximately)
INSERT INTO `category` (`id`, `name`) VALUES
	(1, 'latte_series'),
	(2, 'non_coffee'),
	(3, 'classics');

-- Dumping structure for table cafe_db.checkout
CREATE TABLE IF NOT EXISTS `checkout` (
  `id` int NOT NULL AUTO_INCREMENT,
  `orders_id` int NOT NULL,
  `payment_status` enum('cancelled','pending','paid','') COLLATE utf8mb4_general_ci NOT NULL,
  `created_at` datetime NOT NULL,
  UNIQUE KEY `unique_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table cafe_db.checkout: ~0 rows (approximately)

-- Dumping structure for table cafe_db.customer
CREATE TABLE IF NOT EXISTS `customer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(25) COLLATE utf8mb4_general_ci NOT NULL,
  `phone` varchar(14) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '0',
  `birthday` date DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `modified_at` datetime NOT NULL DEFAULT (now()),
  `user_id` int DEFAULT NULL,
  UNIQUE KEY `unique_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table cafe_db.customer: ~10 rows (approximately)
INSERT INTO `customer` (`id`, `name`, `phone`, `birthday`, `created_at`, `modified_at`, `user_id`) VALUES
	(1, 'Stella', '0812345678', NULL, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1),
	(2, 'Arjuna', '0812121212', NULL, '0000-00-00 00:00:00', '0000-00-00 00:00:00', NULL),
	(3, 'Budi Santoso', '1313131313', NULL, '0000-00-00 00:00:00', '0000-00-00 00:00:00', NULL),
	(4, 'Nisa', '14141414', NULL, '0000-00-00 00:00:00', '0000-00-00 00:00:00', NULL),
	(6, 'Lilian Okafor', '16161616', NULL, '2026-05-07 06:08:52', '2026-05-07 06:08:52', NULL),
	(7, 'Stella Putri', '17171717', NULL, '2026-05-07 06:10:18', '2026-05-07 06:10:18', NULL),
	(8, 'Ones', '089626105445', NULL, '2026-05-07 13:12:42', '2026-05-07 13:12:43', NULL),
	(9, 'JJ', '8124718924', '1970-01-01', '2026-05-07 06:15:57', '2026-05-07 06:15:57', NULL),
	(10, 'SAM', '12904891294', '1970-01-01', '2026-05-07 06:18:02', '2026-05-07 06:18:02', NULL),
	(11, 'Rafdah Z', '12481289487', '2006-08-31', '2026-05-07 06:18:51', '2026-05-07 06:18:51', NULL),
	(12, 'Alvino W', '0812131415', '2006-09-18', '2026-05-07 06:54:11', '2026-05-07 06:54:11', NULL),
	(13, 'Xeno', '0819181716', '2007-01-01', '2026-05-07 07:09:22', '2026-05-07 07:09:22', NULL);

-- Dumping structure for table cafe_db.menu
CREATE TABLE IF NOT EXISTS `menu` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `item_name` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `image_url` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `price` int NOT NULL,
  `is_Available` tinyint(1) DEFAULT NULL,
  UNIQUE KEY `unique_id` (`id`),
  KEY `category_menu` (`category_id`),
  CONSTRAINT `category_menu` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table cafe_db.menu: ~18 rows (approximately)
INSERT INTO `menu` (`id`, `category_id`, `item_name`, `description`, `image_url`, `price`, `is_Available`) VALUES
	(1, 3, 'Espresso', 'Classic espresso shot', '/assets/espresso.png', 15000, 1),
	(2, 3, 'Americano', 'Classic americano', '/assets/americano.png', 17000, 1),
	(3, 3, 'Cappucino', 'Classic cappucino', '/assets/cappucino.png', 22000, 1),
	(4, 3, 'Caffe Mocha', 'Classic caffe mocha', '/assets/mocha.png', 25000, 1),
	(5, 1, 'Latte', 'Signature latte', '/assets/latte.png', 22000, 1),
	(6, 1, 'Aren Latte', 'Sweet aren latte', '/assets/aren_latte.png', 22000, 1),
	(7, 1, 'Caramel Latte', 'Caramel infused latte', '/assets/caramel_latte.png', 25000, 1),
	(8, 1, 'Hazelnut Latte', 'Hazelnut latte', '/assets/hazelnut_latte.png', 25000, 1),
	(9, 1, 'Vanilla Latte', 'Vanilla latte', '/assets/vanilla_latte.png', 25000, 1),
	(10, 1, 'Butterscotch Latte', 'Butterscotch latte', '/assets/butterscotch.png', 25000, 1),
	(11, 1, 'Buttercream Aren', 'Buttercream aren latte', '/assets/buttercream.png', 25000, 1),
	(12, 1, 'Creamy Aren Latte', 'Creamy aren latte', '/assets/creamy_aren.png', 25000, 1),
	(13, 1, 'Pandan Latte', 'Pandan latte', '/assets/pandan_latte.png', 25000, 1),
	(14, 1, 'Avocado Latte', 'Avocado latte', '/assets/avocado_latte.png', 25000, 1),
	(15, 1, 'Banana Latte', 'Banana latte', '/assets/banana_latte.png', 25000, 1),
	(16, 1, 'Coconut Latte', 'Coconut latte', '/assets/coconut_latte.png', 25000, 1),
	(17, 2, 'Chocolate', 'Iced chocolate', '/assets/chocolate.png', 25000, 1),
	(18, 2, 'Matcha latte', 'Iced matcha latte', '/assets/matcha.png', 25000, 1);

-- Dumping structure for table cafe_db.orders
CREATE TABLE IF NOT EXISTS `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `menu_id` int NOT NULL,
  `quantity` int NOT NULL,
  `ice_level` enum('iced','hot','','') COLLATE utf8mb4_general_ci NOT NULL,
  `sugar_level` enum('less','normal','high') COLLATE utf8mb4_general_ci NOT NULL,
  `total` int NOT NULL,
  `order_status` enum('cancelled','pending','success','') COLLATE utf8mb4_general_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `modified_at` datetime NOT NULL,
  UNIQUE KEY `unique_id` (`id`),
  KEY `customer_orders` (`customer_id`),
  CONSTRAINT `customer_orders` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table cafe_db.orders: ~2 rows (approximately)
INSERT INTO `orders` (`id`, `customer_id`, `menu_id`, `quantity`, `ice_level`, `sugar_level`, `total`, `order_status`, `created_at`, `modified_at`) VALUES
	(1, 1, 5, 2, 'iced', 'normal', 12, 'cancelled', '2026-05-07 06:06:50', '2026-05-07 06:06:50'),
	(2, 1, 5, 2, 'iced', 'normal', 12, 'cancelled', '2026-05-07 06:09:36', '2026-05-07 06:09:36'),
	(3, 1, 5, 2, 'iced', 'normal', 12, 'cancelled', '2026-05-07 06:10:03', '2026-05-07 06:10:03');

-- Dumping structure for table cafe_db.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(25) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(30) COLLATE utf8mb4_general_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `role` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `phone_no` int NOT NULL,
  UNIQUE KEY `unique_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table cafe_db.users: ~3 rows (approximately)
INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `role`, `created_at`, `phone_no`) VALUES
	(1, 'Stella', 'stella.admin@cafe.com', '$2b$10$dummyhashstring123456789', 'admin', '2026-04-30 08:00:00', 0),
	(2, 'System Admin', 'sysadmin@cafe.com', '$2b$10$dummyhashstring987654321', 'admin', '2026-04-30 08:30:00', 0),
	(3, 'Cafe Manager', 'manager@cafe.com', '$2b$10$dummyhashstringabcdefghi', 'admin', '2026-04-30 09:00:00', 0),
	(4, 'Jack Doe', 'jack@gmail.com', 'this should be encrypted instead of plain text', 'customer', '2026-05-07 13:28:09', 0);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
