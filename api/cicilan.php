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
        // Add new cicilan
        $data = json_decode(file_get_contents('php://input'), true);
        
        try {
            $conn->begin_transaction();
            
            // Insert cicilan
            $stmt = $conn->prepare("INSERT INTO cicilan (pinjaman_id, jumlah) VALUES (?, ?)");
            $stmt->bind_param("id", $data['pinjaman_id'], $data['jumlah']);
            $result = $stmt->execute();
            
            if($result) {
                // Check if pinjaman should be marked as lunas
                $pinjaman_id = $data['pinjaman_id'];
                
                // Get pinjaman data with bunga
                $sql = "SELECT p.jumlah, p.tenor, pk.bunga_persen, pk.bunga_per 
                        FROM pinjaman p 
                        JOIN produk_koperasi pk ON p.produk_id = pk.id 
                        WHERE p.id = ?";
                $stmt = $conn->prepare($sql);
                $stmt->bind_param("i", $pinjaman_id);
                $stmt->execute();
                $pinjaman = $stmt->get_result()->fetch_assoc();
                
                // Get total cicilan
                $sql = "SELECT COALESCE(SUM(jumlah), 0) as total_cicilan FROM cicilan WHERE pinjaman_id = ?";
                $stmt = $conn->prepare($sql);
                $stmt->bind_param("i", $pinjaman_id);
                $stmt->execute();
                $result_cicilan = $stmt->get_result()->fetch_assoc();
                $total_cicilan = $result_cicilan['total_cicilan'];
                
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
                    $sql = "UPDATE pinjaman SET status = 'lunas' WHERE id = ?";
                    $stmt = $conn->prepare($sql);
                    $stmt->bind_param("i", $pinjaman_id);
                    $stmt->execute();
                }
                
                $conn->commit();
                echo json_encode(['success' => true, 'id' => $conn->insert_id]);
            } else {
                $conn->rollback();
                echo json_encode(['success' => false, 'message' => 'Failed to add cicilan']);
            }
        } catch (Exception $e) {
            $conn->rollback();
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
        break;
}
?>