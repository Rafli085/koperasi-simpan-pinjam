<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

require_once 'config.php';

$action = $_GET['action'] ?? $_POST['action'] ?? '';

switch ($action) {
    case 'ajukan':
        ajukanPinjaman();
        break;
    case 'list_pengajuan':
        listPengajuan();
        break;
    case 'proses_admin':
        prosesAdmin();
        break;
    case 'approval_ketua':
        approvalKetua();
        break;
    default:
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
        break;
}

function ajukanPinjaman() {
    global $conn;
    
    $user_id = $_POST['user_id'] ?? '';
    $produk_id = $_POST['produk_id'] ?? '';
    $jumlah = $_POST['jumlah'] ?? '';
    $tenor = $_POST['tenor'] ?? '';
    $keperluan = $_POST['keperluan'] ?? '';
    $merk_hp = $_POST['merk_hp'] ?? null;
    $model_hp = $_POST['model_hp'] ?? null;
    $harga_hp = $_POST['harga_hp'] ?? null;
    
    try {
        $sql = "INSERT INTO pengajuan_pinjaman (user_id, produk_id, jumlah, tenor, keperluan, merk_hp, model_hp, harga_hp) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("iidisssd", $user_id, $produk_id, $jumlah, $tenor, $keperluan, $merk_hp, $model_hp, $harga_hp);
        
        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => 'Pengajuan berhasil dikirim']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Gagal mengirim pengajuan']);
        }
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function listPengajuan() {
    global $conn;
    
    $role = $_GET['role'] ?? '';
    $user_id = $_GET['user_id'] ?? '';
    
    try {
        if ($role == 'anggota') {
            $sql = "SELECT p.*, pk.nama_produk, u.nama as nama_anggota 
                    FROM pengajuan_pinjaman p 
                    JOIN produk_koperasi pk ON p.produk_id = pk.id 
                    JOIN users u ON p.user_id = u.id 
                    WHERE p.user_id = ? 
                    ORDER BY p.tanggal_pengajuan DESC";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("i", $user_id);
        } else if ($role == 'admin_keuangan') {
            $sql = "SELECT p.*, pk.nama_produk, u.nama as nama_anggota 
                    FROM pengajuan_pinjaman p 
                    JOIN produk_koperasi pk ON p.produk_id = pk.id 
                    JOIN users u ON p.user_id = u.id 
                    WHERE p.status IN ('pending', 'diproses_admin') 
                    ORDER BY p.tanggal_pengajuan ASC";
            $stmt = $conn->prepare($sql);
        } else if ($role == 'ketua') {
            $sql = "SELECT p.*, pk.nama_produk, u.nama as nama_anggota, ua.nama as diproses_oleh_nama
                    FROM pengajuan_pinjaman p 
                    JOIN produk_koperasi pk ON p.produk_id = pk.id 
                    JOIN users u ON p.user_id = u.id 
                    LEFT JOIN users ua ON p.diproses_oleh = ua.id
                    WHERE p.status = 'menunggu_approval' 
                    ORDER BY p.tanggal_diproses ASC";
            $stmt = $conn->prepare($sql);
        }
        
        $stmt->execute();
        $result = $stmt->get_result();
        
        $pengajuan = [];
        while ($row = $result->fetch_assoc()) {
            $pengajuan[] = $row;
        }
        
        echo json_encode($pengajuan);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function prosesAdmin() {
    global $conn;
    
    $pengajuan_id = $_POST['pengajuan_id'] ?? '';
    $admin_id = $_POST['admin_id'] ?? '';
    $action = $_POST['admin_action'] ?? ''; // 'approve' atau 'reject'
    $catatan = $_POST['catatan'] ?? '';
    
    try {
        if ($action == 'approve') {
            // Update status ke menunggu_approval untuk ketua
            $sql = "UPDATE pengajuan_pinjaman 
                    SET status = 'menunggu_approval', 
                        catatan_admin = ?, 
                        diproses_oleh = ?, 
                        tanggal_diproses = NOW() 
                    WHERE id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("sii", $catatan, $admin_id, $pengajuan_id);
        } else {
            // Tolak pengajuan
            $sql = "UPDATE pengajuan_pinjaman 
                    SET status = 'ditolak', 
                        catatan_admin = ?, 
                        diproses_oleh = ?, 
                        tanggal_diproses = NOW() 
                    WHERE id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("sii", $catatan, $admin_id, $pengajuan_id);
        }
        
        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => 'Pengajuan berhasil diproses']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Gagal memproses pengajuan']);
        }
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function approvalKetua() {
    global $conn;
    
    $pengajuan_id = $_POST['pengajuan_id'] ?? '';
    $ketua_id = $_POST['ketua_id'] ?? '';
    $action = $_POST['ketua_action'] ?? ''; // 'approve' atau 'reject'
    $catatan = $_POST['catatan'] ?? '';
    
    try {
        $conn->begin_transaction();
        
        if ($action == 'approve') {
            // Get pengajuan data
            $sql = "SELECT * FROM pengajuan_pinjaman WHERE id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("i", $pengajuan_id);
            $stmt->execute();
            $pengajuan = $stmt->get_result()->fetch_assoc();
            
            // Create pinjaman record
            $sql = "INSERT INTO pinjaman (pengajuan_id, user_id, produk_id, jenis_produk, jumlah, tenor, bunga_persen, bunga_per, status, tanggal_approval) 
                    SELECT ?, p.user_id, p.produk_id, pk.jenis, p.jumlah, p.tenor, pk.bunga_persen, pk.bunga_per, 'aktif', NOW()
                    FROM pengajuan_pinjaman p 
                    JOIN produk_koperasi pk ON p.produk_id = pk.id 
                    WHERE p.id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("ii", $pengajuan_id, $pengajuan_id);
            $stmt->execute();
            
            $pinjaman_id = $conn->insert_id;
            
            // Jika produk HP, insert detail HP
            if ($pengajuan['merk_hp']) {
                $sql = "INSERT INTO detail_hp (pinjaman_id, merk_hp, model_hp, harga_hp) VALUES (?, ?, ?, ?)";
                $stmt = $conn->prepare($sql);
                $stmt->bind_param("issd", $pinjaman_id, $pengajuan['merk_hp'], $pengajuan['model_hp'], $pengajuan['harga_hp']);
                $stmt->execute();
            }
            
            // Update pengajuan status
            $sql = "UPDATE pengajuan_pinjaman 
                    SET status = 'disetujui', 
                        catatan_ketua = ?, 
                        disetujui_oleh = ?, 
                        tanggal_approval = NOW() 
                    WHERE id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("sii", $catatan, $ketua_id, $pengajuan_id);
            $stmt->execute();
        } else {
            // Tolak pengajuan
            $sql = "UPDATE pengajuan_pinjaman 
                    SET status = 'ditolak', 
                        catatan_ketua = ?, 
                        disetujui_oleh = ?, 
                        tanggal_approval = NOW() 
                    WHERE id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("sii", $catatan, $ketua_id, $pengajuan_id);
            $stmt->execute();
        }
        
        $conn->commit();
        echo json_encode(['success' => true, 'message' => 'Pengajuan berhasil diproses']);
        
    } catch (Exception $e) {
        $conn->rollback();
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}
?>