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
    case 'get_produk':
        getProduk();
        break;
    case 'get_limit_pinjaman':
        getLimitPinjaman();
        break;
    case 'calculate_limit':
        calculateLimit();
        break;
    case 'get_total_pinjaman_aktif':
        getTotalPinjamanAktif();
        break;
    default:
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
        break;
}

function getProduk() {
    global $conn;
    
    try {
        $sql = "SELECT * FROM produk_koperasi WHERE is_active = 1 ORDER BY id";
        $result = $conn->query($sql);
        
        $produk = [];
        while ($row = $result->fetch_assoc()) {
            $produk[] = $row;
        }
        
        echo json_encode($produk);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function getLimitPinjaman() {
    global $conn;
    
    $produk_id = $_GET['produk_id'] ?? '';
    
    try {
        $sql = "SELECT * FROM limit_pinjaman WHERE produk_id = ? ORDER BY masa_anggota_min_tahun DESC";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $produk_id);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $limits = [];
        while ($row = $result->fetch_assoc()) {
            $limits[] = $row;
        }
        
        echo json_encode($limits);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function calculateLimit() {
    global $conn;
    
    $user_id = $_POST['user_id'] ?? '';
    $produk_id = $_POST['produk_id'] ?? '';
    
    try {
        // Get user's tanggal_bergabung
        $sql = "SELECT tanggal_bergabung FROM users WHERE id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $result = $stmt->get_result();
        $user = $result->fetch_assoc();
        
        if (!$user || !$user['tanggal_bergabung']) {
            echo json_encode(['success' => false, 'message' => 'User tidak ditemukan atau tanggal bergabung belum diset']);
            return;
        }
        
        // Calculate masa anggota dalam tahun
        $tanggal_bergabung = new DateTime($user['tanggal_bergabung']);
        $sekarang = new DateTime();
        $masa_anggota = $sekarang->diff($tanggal_bergabung)->y;
        
        // Get limit berdasarkan masa anggota
        $sql = "SELECT limit_maksimal FROM limit_pinjaman 
                WHERE produk_id = ? AND masa_anggota_min_tahun <= ? 
                ORDER BY masa_anggota_min_tahun DESC LIMIT 1";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ii", $produk_id, $masa_anggota);
        $stmt->execute();
        $result = $stmt->get_result();
        $limit = $result->fetch_assoc();
        
        if (!$limit) {
            echo json_encode(['success' => false, 'message' => 'Limit tidak ditemukan untuk masa anggota ini']);
            return;
        }
        
        echo json_encode([
            'success' => true,
            'masa_anggota_tahun' => $masa_anggota,
            'limit_maksimal' => $limit['limit_maksimal']
        ]);
        
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function getTotalPinjamanAktif() {
    global $conn;
    
    $user_id = $_GET['user_id'] ?? '';
    
    try {
        $sql = "SELECT COALESCE(SUM(jumlah), 0) as total_pinjaman 
                FROM pinjaman 
                WHERE user_id = ? AND status = 'aktif'";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $result = $stmt->get_result();
        $data = $result->fetch_assoc();
        
        echo json_encode([
            'success' => true,
            'total_pinjaman_aktif' => $data['total_pinjaman']
        ]);
        
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}
?>