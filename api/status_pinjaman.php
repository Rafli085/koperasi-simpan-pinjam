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
    case 'get_status_pinjaman':
        getStatusPinjaman();
        break;
    case 'update_status_lunas':
        updateStatusLunas();
        break;
    case 'get_detail_pinjaman':
        getDetailPinjaman();
        break;
    default:
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
        break;
}

function getStatusPinjaman() {
    global $conn;
    
    $pinjaman_id = $_GET['pinjaman_id'] ?? '';
    
    try {
        // Get pinjaman data
        $sql = "SELECT p.*, pk.bunga_persen, pk.bunga_per 
                FROM pinjaman p 
                JOIN produk_koperasi pk ON p.produk_id = pk.id 
                WHERE p.id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $pinjaman_id);
        $stmt->execute();
        $pinjaman = $stmt->get_result()->fetch_assoc();
        
        if (!$pinjaman) {
            echo json_encode(['success' => false, 'message' => 'Pinjaman tidak ditemukan']);
            return;
        }
        
        // Get total cicilan
        $sql = "SELECT COALESCE(SUM(jumlah), 0) as total_cicilan FROM cicilan WHERE pinjaman_id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $pinjaman_id);
        $stmt->execute();
        $result = $stmt->get_result()->fetch_assoc();
        $total_cicilan = $result['total_cicilan'];
        
        // Calculate total yang harus dibayar (pokok + bunga)
        $pokok = $pinjaman['jumlah'];
        $bunga_persen = $pinjaman['bunga_persen'];
        $tenor = $pinjaman['tenor'];
        
        if ($pinjaman['bunga_per'] == 'tahun') {
            $bunga = ($pokok * $bunga_persen / 100) * ($tenor / 12);
        } else {
            $bunga = ($pokok * $bunga_persen / 100) * $tenor;
        }
        
        $total_harus_bayar = $pokok + $bunga;
        $sisa_pinjaman = $total_harus_bayar - $total_cicilan;
        
        // Determine status
        $status_lunas = $sisa_pinjaman <= 0;
        
        echo json_encode([
            'success' => true,
            'pinjaman_id' => $pinjaman_id,
            'jumlah_pokok' => $pokok,
            'bunga' => $bunga,
            'total_harus_bayar' => $total_harus_bayar,
            'total_cicilan' => $total_cicilan,
            'sisa_pinjaman' => max(0, $sisa_pinjaman),
            'status_lunas' => $status_lunas,
            'status_current' => $pinjaman['status']
        ]);
        
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function updateStatusLunas() {
    global $conn;
    
    try {
        // Get all active pinjaman
        $sql = "SELECT p.id, p.jumlah, p.tenor, pk.bunga_persen, pk.bunga_per
                FROM pinjaman p 
                JOIN produk_koperasi pk ON p.produk_id = pk.id 
                WHERE p.status = 'aktif'";
        $result = $conn->query($sql);
        
        $updated = 0;
        
        while ($pinjaman = $result->fetch_assoc()) {
            // Get total cicilan
            $sql_cicilan = "SELECT COALESCE(SUM(jumlah), 0) as total_cicilan FROM cicilan WHERE pinjaman_id = ?";
            $stmt = $conn->prepare($sql_cicilan);
            $stmt->bind_param("i", $pinjaman['id']);
            $stmt->execute();
            $cicilan_result = $stmt->get_result()->fetch_assoc();
            $total_cicilan = $cicilan_result['total_cicilan'];
            
            // Calculate total yang harus dibayar
            $pokok = $pinjaman['jumlah'];
            $bunga_persen = $pinjaman['bunga_persen'];
            $tenor = $pinjaman['tenor'];
            
            if ($pinjaman['bunga_per'] == 'tahun') {
                $bunga = ($pokok * $bunga_persen / 100) * ($tenor / 12);
            } else {
                $bunga = ($pokok * $bunga_persen / 100) * $tenor;
            }
            
            $total_harus_bayar = $pokok + $bunga;
            
            // Update status jika sudah lunas
            if ($total_cicilan >= $total_harus_bayar) {
                $sql_update = "UPDATE pinjaman SET status = 'lunas' WHERE id = ?";
                $stmt_update = $conn->prepare($sql_update);
                $stmt_update->bind_param("i", $pinjaman['id']);
                $stmt_update->execute();
                $updated++;
            }
        }
        
        echo json_encode([
            'success' => true, 
            'message' => "$updated pinjaman diupdate ke status lunas"
        ]);
        
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function getDetailPinjaman() {
    global $conn;
    
    $user_id = $_GET['user_id'] ?? '';
    
    try {
        $sql = "SELECT p.*, pk.nama_produk, pk.bunga_persen, pk.bunga_per,
                       COALESCE(SUM(c.jumlah), 0) as total_cicilan
                FROM pinjaman p 
                JOIN produk_koperasi pk ON p.produk_id = pk.id 
                LEFT JOIN cicilan c ON p.id = c.pinjaman_id
                WHERE p.user_id = ? AND p.status IN ('aktif', 'lunas')
                GROUP BY p.id
                ORDER BY p.tanggal DESC";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $pinjaman_list = [];
        while ($row = $result->fetch_assoc()) {
            // Calculate sisa pinjaman
            $pokok = $row['jumlah'];
            $bunga_persen = $row['bunga_persen'];
            $tenor = $row['tenor'];
            
            if ($row['bunga_per'] == 'tahun') {
                $bunga = ($pokok * $bunga_persen / 100) * ($tenor / 12);
            } else {
                $bunga = ($pokok * $bunga_persen / 100) * $tenor;
            }
            
            $total_harus_bayar = $pokok + $bunga;
            $sisa_pinjaman = max(0, $total_harus_bayar - $row['total_cicilan']);
            
            $row['bunga'] = $bunga;
            $row['total_harus_bayar'] = $total_harus_bayar;
            $row['sisa_pinjaman'] = $sisa_pinjaman;
            $row['status_lunas'] = $sisa_pinjaman <= 0;
            
            $pinjaman_list[] = $row;
        }
        
        echo json_encode($pinjaman_list);
        
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}
?>