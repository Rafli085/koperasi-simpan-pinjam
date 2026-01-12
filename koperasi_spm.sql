-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jan 12, 2026 at 02:26 PM
-- Server version: 8.4.3
-- PHP Version: 8.3.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `koperasi_spm`
--

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `nomor_anggota` varchar(20) DEFAULT NULL,
  `nama` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('anggota','admin_keuangan','ketua') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `tanggal_bergabung` date DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `nomor_anggota`, `nama`, `password`, `role`, `created_at`, `tanggal_bergabung`, `is_active`) VALUES
(1, 'anggota1', 'PMS-20-01-0001', 'Budi Santoso', '123456', 'anggota', '2025-12-18 03:15:41', '2020-01-01', 1),
(2, 'admin', 'PMS-18-01-0001', 'Admin Keuangan', 'admin123', 'admin_keuangan', '2025-12-18 03:15:41', NULL, 1),
(3, 'ketua', 'PMS-18-01-0002', 'Ketua Koperasi', 'ketua123', 'ketua', '2025-12-18 03:15:41', NULL, 1),
(4, 'Mario', 'PMS-22-01-0001', 'Mario', '123123', 'anggota', '2025-12-18 06:26:30', '2022-01-01', 1),
(5, 'elen', NULL, 'elen', '123', 'anggota', '2025-12-27 03:04:33', NULL, 1);

--
-- Triggers `users`
--
DELIMITER $$
CREATE TRIGGER `generate_nomor_anggota_pms` BEFORE INSERT ON `users` FOR EACH ROW BEGIN 
    DECLARE tahun VARCHAR(2);
    DECLARE bulan VARCHAR(2);
    DECLARE urutan INT;
    
    SET tahun = RIGHT(YEAR(NOW()), 2);
    SET bulan = LPAD(MONTH(NOW()), 2, '0');
    
    IF NEW.nomor_anggota IS NULL THEN
        SELECT COALESCE(MAX(CAST(RIGHT(nomor_anggota, 4) AS UNSIGNED)), 0) + 1 
        INTO urutan
        FROM users 
        WHERE nomor_anggota LIKE CONCAT('PMS-', tahun, '-', bulan, '-%');
        
        SET NEW.nomor_anggota = CONCAT('PMS-', tahun, '-', bulan, '-', LPAD(urutan, 4, '0'));
    END IF;
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `username_2` (`username`),
  ADD UNIQUE KEY `nomor_anggota` (`nomor_anggota`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
