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

switch ($method) {

    // =====================
    // GET PINJAMAN
    // =====================
    case 'GET':
        if (isset($_GET['user_id'])) {
            // Get pinjaman by user with cicilan
            $stmt = $pdo->prepare("
                SELECT p.*, u.nama, pk.nama_produk,
                       COALESCE(SUM(c.jumlah), 0) AS total_cicilan
                FROM pinjaman p
                JOIN users u ON p.user_id = u.id
                LEFT JOIN produk_koperasi pk ON p.produk_id = pk.id
                LEFT JOIN cicilan c ON p.id = c.pinjaman_id
                WHERE p.user_id = ?
                GROUP BY p.id
                ORDER BY p.tanggal DESC
            ");
            $stmt->execute([$_GET['user_id']]);
        } else {
            // Get all pinjaman (admin)
            $stmt = $pdo->query("
                SELECT p.*, u.nama, pk.nama_produk,
                       COALESCE(SUM(c.jumlah), 0) AS total_cicilan
                FROM pinjaman p
                JOIN users u ON p.user_id = u.id
                LEFT JOIN produk_koperasi pk ON p.produk_id = pk.id
                LEFT JOIN cicilan c ON p.id = c.pinjaman_id
                GROUP BY p.id
                ORDER BY p.tanggal DESC
            ");
        }

        $pinjaman = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($pinjaman);
        break;

    // =====================
    // ADD PINJAMAN
    // =====================
    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);

        $stmt = $pdo->prepare("
            INSERT INTO pinjaman (user_id, jumlah, tenor)
            VALUES (?, ?, ?)
        ");

        $result = $stmt->execute([
            $data['user_id'],
            $data['jumlah'],
            $data['tenor']
        ]);

        if ($result) {
            echo json_encode([
                'success' => true,
                'id' => $pdo->lastInsertId()
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to add pinjaman'
            ]);
        }
        break;

    // =====================
    // UPDATE STATUS PINJAMAN
    // =====================
    case 'PUT':
        $data = json_decode(file_get_contents('php://input'), true);

        if(isset($data['action']) && $data['action'] == 'edit') {
            // Edit pinjaman
            $stmt = $pdo->prepare("
                UPDATE pinjaman
                SET jumlah = ?, tenor = ?
                WHERE id = ?
            ");
            
            $result = $stmt->execute([
                $data['jumlah'],
                $data['tenor'],
                $data['id']
            ]);
            
            echo json_encode(['success' => $result]);
        } else {
            // Update status (perilaku lama)
            if (in_array($data['status'], ['aktif', 'ditolak'])) {
                $stmt = $pdo->prepare("
                    UPDATE pinjaman
                    SET status = ?, tanggal_approval = NOW()
                    WHERE id = ?
                ");
            } else {
                $stmt = $pdo->prepare("
                    UPDATE pinjaman
                    SET status = ?
                    WHERE id = ?
                ");
            }

            $result = $stmt->execute([
                $data['status'],
                $data['id']
            ]);

            echo json_encode(['success' => $result]);
        }
        break;

    // =====================
    // DELETE PINJAMAN
    // =====================
    case 'DELETE':
        try {
            $input = file_get_contents('php://input');
            $data = json_decode($input, true);
            
            if (!$data || !isset($data['id'])) {
                echo json_encode(['success' => false, 'message' => 'ID pinjaman tidak valid']);
                exit;
            }
            
            $pdo->beginTransaction();
            
            // Delete cicilan first (foreign key constraint)
            $stmt = $pdo->prepare("DELETE FROM cicilan WHERE pinjaman_id = ?");
            $stmt->execute([$data['id']]);
            
            // Then delete pinjaman
            $stmt = $pdo->prepare("DELETE FROM pinjaman WHERE id = ?");
            $result = $stmt->execute([$data['id']]);
            
            if ($result) {
                $pdo->commit();
                echo json_encode([
                    'success' => true, 
                    'message' => 'Pinjaman berhasil dihapus'
                ]);
            } else {
                $pdo->rollBack();
                echo json_encode([
                    'success' => false, 
                    'message' => 'Gagal menghapus pinjaman'
                ]);
            }
        } catch (Exception $e) {
            $pdo->rollBack();
            echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
        }
        break;
}
?>
