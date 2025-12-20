-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 20, 2025 at 04:42 AM
-- Server version: 8.4.3
-- PHP Version: 8.1.32

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
-- Table structure for table `cicilan`
--

CREATE TABLE `cicilan` (
  `id` int NOT NULL,
  `pinjaman_id` int NOT NULL,
  `jumlah` decimal(15,2) NOT NULL,
  `tanggal` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `detail_hp`
--

CREATE TABLE `detail_hp` (
  `id` int NOT NULL,
  `pinjaman_id` int NOT NULL,
  `merk_hp` varchar(100) NOT NULL,
  `model_hp` varchar(100) NOT NULL,
  `harga_hp` decimal(15,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `limit_pinjaman`
--

CREATE TABLE `limit_pinjaman` (
  `id` int NOT NULL,
  `produk_id` int NOT NULL,
  `masa_anggota_min_tahun` int NOT NULL,
  `limit_maksimal` decimal(15,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `limit_pinjaman`
--

INSERT INTO `limit_pinjaman` (`id`, `produk_id`, `masa_anggota_min_tahun`, `limit_maksimal`) VALUES
(1, 1, 5, 20000000.00),
(2, 1, 3, 10000000.00),
(3, 1, 1, 5000000.00),
(4, 2, 0, 2000000.00),
(5, 3, 5, 20000000.00),
(6, 3, 3, 10000000.00),
(7, 3, 1, 5000000.00);

-- --------------------------------------------------------

--
-- Table structure for table `pengajuan_pinjaman`
--

CREATE TABLE `pengajuan_pinjaman` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `produk_id` int NOT NULL,
  `jumlah` decimal(15,2) NOT NULL,
  `tenor` int NOT NULL,
  `keperluan` text,
  `status` enum('pending','diproses_admin','menunggu_approval','disetujui','ditolak') DEFAULT 'pending',
  `catatan_admin` text,
  `catatan_ketua` text,
  `tanggal_pengajuan` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `tanggal_diproses` datetime DEFAULT NULL,
  `tanggal_approval` datetime DEFAULT NULL,
  `diproses_oleh` int DEFAULT NULL,
  `disetujui_oleh` int DEFAULT NULL,
  `merk_hp` varchar(100) DEFAULT NULL,
  `model_hp` varchar(100) DEFAULT NULL,
  `harga_hp` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pinjaman`
--

CREATE TABLE `pinjaman` (
  `id` int NOT NULL,
  `pengajuan_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  `produk_id` int DEFAULT NULL,
  `jenis_produk` enum('pinjaman_tunai','pinjaman_flexi','jual_hp') DEFAULT 'pinjaman_tunai',
  `jumlah` decimal(15,2) NOT NULL,
  `tenor` int NOT NULL,
  `bunga_persen` decimal(5,2) DEFAULT '12.00',
  `bunga_per` enum('tahun','bulan') DEFAULT 'tahun',
  `status` enum('menunggu','aktif','lunas','ditolak') DEFAULT 'menunggu',
  `tanggal` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `tanggal_approval` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `pinjaman`
--

INSERT INTO `pinjaman` (`id`, `pengajuan_id`, `user_id`, `produk_id`, `jenis_produk`, `jumlah`, `tenor`, `bunga_persen`, `bunga_per`, `status`, `tanggal`, `tanggal_approval`) VALUES
(1, NULL, 1, NULL, 'pinjaman_tunai', 1000000.00, 6, 12.00, 'tahun', 'aktif', '2025-12-19 03:09:16', NULL),
(2, NULL, 4, NULL, 'pinjaman_tunai', 1000000.00, 6, 12.00, 'tahun', 'aktif', '2025-12-19 04:05:02', '2025-12-19 11:05:11'),
(3, NULL, 1, NULL, 'pinjaman_tunai', 100000.00, 2, 12.00, 'tahun', 'aktif', '2025-12-19 04:35:50', '2025-12-20 11:13:32');

-- --------------------------------------------------------

--
-- Table structure for table `produk_koperasi`
--

CREATE TABLE `produk_koperasi` (
  `id` int NOT NULL,
  `nama_produk` varchar(100) NOT NULL,
  `jenis` enum('pinjaman_tunai','pinjaman_flexi','jual_hp') NOT NULL,
  `bunga_persen` decimal(5,2) NOT NULL,
  `bunga_per` enum('tahun','bulan') NOT NULL DEFAULT 'tahun',
  `tenor_min` int DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `produk_koperasi`
--

INSERT INTO `produk_koperasi` (`id`, `nama_produk`, `jenis`, `bunga_persen`, `bunga_per`, `tenor_min`, `is_active`) VALUES
(1, 'Pinjaman Tunai', 'pinjaman_tunai', 12.00, 'tahun', 10, 1),
(2, 'Pinjaman Flexi', 'pinjaman_flexi', 5.00, 'bulan', NULL, 1),
(3, 'Jual HP', 'jual_hp', 12.00, 'tahun', 10, 1);

-- --------------------------------------------------------

--
-- Table structure for table `simpanan`
--

CREATE TABLE `simpanan` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `jumlah` decimal(15,2) NOT NULL,
  `tanggal` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `simpanan`
--

INSERT INTO `simpanan` (`id`, `user_id`, `jumlah`, `tanggal`) VALUES
(1, 4, 200000.00, '2025-12-18 06:46:17'),
(2, 1, 1000000.00, '2025-12-18 06:46:25');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `username` varchar(50) NOT NULL,
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

INSERT INTO `users` (`id`, `username`, `nama`, `password`, `role`, `created_at`, `tanggal_bergabung`, `is_active`) VALUES
(1, 'anggota1', 'Budi Santoso', '123456', 'anggota', '2025-12-18 03:15:41', '2020-01-01', 1),
(2, 'admin', 'Admin Keuangan', 'admin123', 'admin_keuangan', '2025-12-18 03:15:41', NULL, 1),
(3, 'ketua', 'Ketua Koperasi', 'ketua123', 'ketua', '2025-12-18 03:15:41', NULL, 1),
(4, 'Mario', 'Mario', '123123', 'anggota', '2025-12-18 06:26:30', '2022-01-01', 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cicilan`
--
ALTER TABLE `cicilan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pinjaman_id` (`pinjaman_id`);

--
-- Indexes for table `detail_hp`
--
ALTER TABLE `detail_hp`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pinjaman_id` (`pinjaman_id`);

--
-- Indexes for table `limit_pinjaman`
--
ALTER TABLE `limit_pinjaman`
  ADD PRIMARY KEY (`id`),
  ADD KEY `produk_id` (`produk_id`);

--
-- Indexes for table `pengajuan_pinjaman`
--
ALTER TABLE `pengajuan_pinjaman`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `produk_id` (`produk_id`),
  ADD KEY `diproses_oleh` (`diproses_oleh`),
  ADD KEY `disetujui_oleh` (`disetujui_oleh`);

--
-- Indexes for table `pinjaman`
--
ALTER TABLE `pinjaman`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `pinjaman_ibfk_2` (`pengajuan_id`);

--
-- Indexes for table `produk_koperasi`
--
ALTER TABLE `produk_koperasi`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `simpanan`
--
ALTER TABLE `simpanan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `username_2` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cicilan`
--
ALTER TABLE `cicilan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `detail_hp`
--
ALTER TABLE `detail_hp`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `limit_pinjaman`
--
ALTER TABLE `limit_pinjaman`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `pengajuan_pinjaman`
--
ALTER TABLE `pengajuan_pinjaman`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pinjaman`
--
ALTER TABLE `pinjaman`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `produk_koperasi`
--
ALTER TABLE `produk_koperasi`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `simpanan`
--
ALTER TABLE `simpanan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cicilan`
--
ALTER TABLE `cicilan`
  ADD CONSTRAINT `cicilan_ibfk_1` FOREIGN KEY (`pinjaman_id`) REFERENCES `pinjaman` (`id`);

--
-- Constraints for table `detail_hp`
--
ALTER TABLE `detail_hp`
  ADD CONSTRAINT `detail_hp_ibfk_1` FOREIGN KEY (`pinjaman_id`) REFERENCES `pinjaman` (`id`);

--
-- Constraints for table `limit_pinjaman`
--
ALTER TABLE `limit_pinjaman`
  ADD CONSTRAINT `limit_pinjaman_ibfk_1` FOREIGN KEY (`produk_id`) REFERENCES `produk_koperasi` (`id`);

--
-- Constraints for table `pengajuan_pinjaman`
--
ALTER TABLE `pengajuan_pinjaman`
  ADD CONSTRAINT `pengajuan_pinjaman_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `pengajuan_pinjaman_ibfk_2` FOREIGN KEY (`produk_id`) REFERENCES `produk_koperasi` (`id`),
  ADD CONSTRAINT `pengajuan_pinjaman_ibfk_3` FOREIGN KEY (`diproses_oleh`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `pengajuan_pinjaman_ibfk_4` FOREIGN KEY (`disetujui_oleh`) REFERENCES `users` (`id`);

--
-- Constraints for table `pinjaman`
--
ALTER TABLE `pinjaman`
  ADD CONSTRAINT `pinjaman_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `pinjaman_ibfk_2` FOREIGN KEY (`pengajuan_id`) REFERENCES `pengajuan_pinjaman` (`id`);

--
-- Constraints for table `simpanan`
--
ALTER TABLE `simpanan`
  ADD CONSTRAINT `simpanan_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
