<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'POST':
        if($_POST['action'] == 'bayar') {
            try {
                $pdo->beginTransaction();
                
                $tanggal = isset($_POST['tanggal']) ? $_POST['tanggal'] : date('Y-m-d');
                
                // Insert cicilan
                $stmt = $pdo->prepare("
                    INSERT INTO cicilan (pinjaman_id, jumlah, tanggal) 
                    VALUES (?, ?, ?)
                ");
                $stmt->execute([$_POST['pinjaman_id'], $_POST['jumlah_bayar'], $tanggal]);
                
                // Hitung total cicilan
                $stmt = $pdo->prepare("SELECT SUM(jumlah) as total_cicilan FROM cicilan WHERE pinjaman_id = ?");
                $stmt->execute([$_POST['pinjaman_id']]);
                $totalCicilan = $stmt->fetchColumn() ?: 0;
                
                // Get pinjaman details untuk hitung bunga
                $stmt = $pdo->prepare("
                    SELECT p.jumlah, p.tenor, pk.nama_produk 
                    FROM pinjaman p 
                    LEFT JOIN produk_koperasi pk ON p.produk_id = pk.id 
                    WHERE p.id = ?
                ");
                $stmt->execute([$_POST['pinjaman_id']]);
                $pinjaman = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if (!$pinjaman) {
                    throw new Exception('Pinjaman tidak ditemukan');
                }
                
                $principal = $pinjaman['jumlah'];
                $tenor = $pinjaman['tenor'];
                $productName = $pinjaman['nama_produk'] ?? 'Pinjaman Tunai';
                
                // Hitung total yang harus dibayar (pokok + bunga)
                $totalHarusDibayar = $principal;
                if (stripos($productName, 'flexi') !== false) {
                    // Pinjaman Flexi: 5% per bulan
                    $bunga = $principal * 0.05 * $tenor;
                } else {
                    // Pinjaman Tunai/Beli HP: 12% per tahun
                    $bunga = $principal * 0.12 * ($tenor / 12);
                }
                $totalHarusDibayar = $principal + $bunga;
                
                // Cek jika lunas
                if($totalCicilan >= $totalHarusDibayar) {
                    $stmt = $pdo->prepare("UPDATE pinjaman SET status = 'lunas' WHERE id = ?");
                    $stmt->execute([$_POST['pinjaman_id']]);
                }
                
                $pdo->commit();
                echo json_encode(['success' => true, 'message' => 'Cicilan berhasil dicatat']);
            } catch(Exception $e) {
                $pdo->rollBack();
                echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
            }
        }
        break;
        
    case 'GET':
        if($_GET['action'] == 'list') {
            $stmt = $pdo->prepare("
                SELECT c.*, p.jumlah as jumlah_pinjaman, u.nama as nama_anggota
                FROM cicilan c
                JOIN pinjaman p ON c.pinjaman_id = p.id
                JOIN users u ON p.user_id = u.id
                WHERE c.pinjaman_id = ?
                ORDER BY c.tanggal DESC
            ");
            $stmt->execute([$_GET['pinjaman_id']]);
            echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
        } elseif($_GET['action'] == 'history') {
            if(isset($_GET['user_id'])) {
                // History untuk anggota tertentu
                $stmt = $pdo->prepare("
                    SELECT c.*, p.jumlah as jumlah_pinjaman, u.nama as nama_anggota, pk.nama_produk
                    FROM cicilan c
                    JOIN pinjaman p ON c.pinjaman_id = p.id
                    JOIN users u ON p.user_id = u.id
                    LEFT JOIN produk_koperasi pk ON p.produk_id = pk.id
                    WHERE p.user_id = ?
                    ORDER BY c.tanggal DESC
                ");
                $stmt->execute([$_GET['user_id']]);
            } else {
                // History semua cicilan untuk admin
                $stmt = $pdo->prepare("
                    SELECT c.*, p.jumlah as jumlah_pinjaman, u.nama as nama_anggota, pk.nama_produk
                    FROM cicilan c
                    JOIN pinjaman p ON c.pinjaman_id = p.id
                    JOIN users u ON p.user_id = u.id
                    LEFT JOIN produk_koperasi pk ON p.produk_id = pk.id
                    ORDER BY c.tanggal DESC
                ");
                $stmt->execute();
            }
            echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
        }
        break;
        
    case 'PUT':
        $data = json_decode(file_get_contents('php://input'), true);
        if($data['action'] == 'edit') {
            try {
                $stmt = $pdo->prepare("UPDATE cicilan SET jumlah = ?, tanggal = ? WHERE id = ?");
                $result = $stmt->execute([$data['jumlah'], $data['tanggal'], $data['id']]);
                echo json_encode(['success' => $result, 'message' => $result ? 'Cicilan berhasil diupdate' : 'Gagal mengupdate cicilan']);
            } catch(Exception $e) {
                echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
            }
        }
        break;
        
    case 'DELETE':
        $data = json_decode(file_get_contents('php://input'), true);
        try {
            $stmt = $pdo->prepare("DELETE FROM cicilan WHERE id = ?");
            $result = $stmt->execute([$data['id']]);
            echo json_encode(['success' => $result, 'message' => $result ? 'Cicilan berhasil dihapus' : 'Gagal menghapus cicilan']);
        } catch(Exception $e) {
            echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
        }
        break;
}
?>