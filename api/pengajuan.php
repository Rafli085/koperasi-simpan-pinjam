<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

require_once 'config.php';

// Bersihkan output buffer
ob_clean();

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? $_POST['action'] ?? '';

switch($method) {
    case 'POST':
        if(isset($_POST['action'])) {
            if($_POST['action'] == 'ajukan') {
                try {
                    $stmt = $pdo->prepare("
                        INSERT INTO pengajuan_pinjaman 
                        (user_id, produk_id, jumlah, tenor, keperluan, merk_hp, model_hp, harga_hp) 
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                    ");
                    
                    $result = $stmt->execute([
                        $_POST['user_id'],
                        $_POST['produk_id'],
                        $_POST['jumlah'],
                        $_POST['tenor'],
                        $_POST['keperluan'] ?? '',
                        $_POST['merk_hp'] ?? null,
                        $_POST['model_hp'] ?? null,
                        $_POST['harga_hp'] ?? 0
                    ]);
                    
                    if($result) {
                        echo json_encode(['success' => true, 'message' => 'Pengajuan berhasil dikirim']);
                    } else {
                        echo json_encode(['success' => false, 'message' => 'Gagal menyimpan pengajuan']);
                    }
                } catch(Exception $e) {
                    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
                }
            } elseif($_POST['action'] == 'proses_admin') {
                $stmt = $pdo->prepare("UPDATE pengajuan_pinjaman SET status = 'diproses_admin' WHERE id = ?");
                $result = $stmt->execute([$_POST['pengajuan_id']]);
                echo json_encode(['success' => $result, 'message' => $result ? 'Berhasil diproses' : 'Gagal diproses']);
            } elseif($_POST['action'] == 'approve_ketua') {
                $stmt = $pdo->prepare("UPDATE pengajuan_pinjaman SET status = ? WHERE id = ?");
                $result = $stmt->execute([$_POST['status'], $_POST['pengajuan_id']]);
                echo json_encode(['success' => $result, 'message' => $result ? 'Berhasil diproses' : 'Gagal diproses']);
            } elseif($_POST['action'] == 'proses_ke_pinjaman') {
                try {
                    $pdo->beginTransaction();
                    
                    $stmt = $pdo->prepare("SELECT * FROM pengajuan_pinjaman WHERE id = ?");
                    $stmt->execute([$_POST['pengajuan_id']]);
                    $pengajuan = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    if(!$pengajuan || $pengajuan['status'] != 'disetujui') {
                        $pdo->rollBack();
                        echo json_encode(['success' => false, 'message' => 'Pengajuan tidak valid']);
                        exit;
                    }
                    
                    // Cek apakah sudah diproses sebelumnya
                    $checkStmt = $pdo->prepare("SELECT id FROM pinjaman WHERE pengajuan_id = ?");
                    $checkStmt->execute([$pengajuan['id']]);
                    if ($checkStmt->fetch()) {
                        $pdo->rollBack();
                        echo json_encode(['success' => false, 'message' => 'Pengajuan sudah diproses']);
                        exit;
                    }

                    $stmt = $pdo->prepare("
                        INSERT INTO pinjaman (pengajuan_id, user_id, produk_id, jumlah, tenor, status, tanggal) 
                        VALUES (?, ?, ?, ?, ?, 'aktif', NOW())
                    ");
                    
                    $stmt->execute([
                        $pengajuan['id'],
                        $pengajuan['user_id'],
                        $pengajuan['produk_id'],
                        $pengajuan['jumlah'],
                        $pengajuan['tenor']
                    ]);
                    
                    // Tidak update status pengajuan ke 'ok' karena tidak ada di enum
                    // Filter di list_baru akan menangani agar tidak muncul lagi
                    
                    $pdo->commit();
                    echo json_encode(['success' => true, 'message' => 'Berhasil diproses ke pinjaman']);
                } catch(Exception $e) {
                    $pdo->rollBack();
                    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
                }
            } elseif($_POST['action'] == 'hapus') {
                $stmt = $pdo->prepare("DELETE FROM pengajuan_pinjaman WHERE id = ?");
                $result = $stmt->execute([$_POST['pengajuan_id']]);
                echo json_encode(['success' => $result, 'message' => $result ? 'Berhasil dihapus' : 'Gagal dihapus']);
            }
        }
        break;
        
    case 'GET':
        if($_GET['action'] == 'list') {
            $stmt = $pdo->prepare("
                SELECT p.*, pk.nama_produk, u.nama as nama_anggota
                FROM pengajuan_pinjaman p
                LEFT JOIN produk_koperasi pk ON p.produk_id = pk.id
                LEFT JOIN users u ON p.user_id = u.id
                WHERE p.user_id = ?
                ORDER BY p.tanggal_pengajuan DESC
            ");
            $stmt->execute([$_GET['user_id']]);
            echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
        } elseif($_GET['action'] == 'list_baru') {
            $role = $_GET['role'] ?? 'admin_keuangan';
            
            if($role == 'admin_keuangan') {
                $stmt = $pdo->prepare("
                    SELECT p.*, pk.nama_produk, u.nama as nama_anggota
                    FROM pengajuan_pinjaman p
                    LEFT JOIN produk_koperasi pk ON p.produk_id = pk.id
                    LEFT JOIN users u ON p.user_id = u.id
                    LEFT JOIN pinjaman pinj ON p.id = pinj.pengajuan_id
                    WHERE p.status IN ('pending', 'disetujui')
                    AND pinj.id IS NULL
                    ORDER BY p.tanggal_pengajuan DESC
                ");
            } else {
                $stmt = $pdo->prepare("
                    SELECT p.*, pk.nama_produk, u.nama as nama_anggota
                    FROM pengajuan_pinjaman p
                    LEFT JOIN produk_koperasi pk ON p.produk_id = pk.id
                    LEFT JOIN users u ON p.user_id = u.id
                    WHERE p.status = 'diproses_admin'
                    ORDER BY p.tanggal_pengajuan DESC
                ");
            }
            
            $stmt->execute();
            echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
        }
        break;
}
?>