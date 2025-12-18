<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        if(isset($_GET['user_id'])) {
            // Get pinjaman by user with cicilan
            $stmt = $pdo->prepare("
                SELECT p.*, u.nama,
                       COALESCE(SUM(c.jumlah), 0) as total_cicilan
                FROM pinjaman p 
                JOIN users u ON p.user_id = u.id 
                LEFT JOIN cicilan c ON p.id = c.pinjaman_id
                WHERE p.user_id = ?
                GROUP BY p.id
                ORDER BY p.tanggal DESC
            ");
            $stmt->execute([$_GET['user_id']]);
        } else {
            // Get all pinjaman
            $stmt = $pdo->query("
                SELECT p.*, u.nama,
                       COALESCE(SUM(c.jumlah), 0) as total_cicilan
                FROM pinjaman p 
                JOIN users u ON p.user_id = u.id 
                LEFT JOIN cicilan c ON p.id = c.pinjaman_id
                GROUP BY p.id
                ORDER BY p.tanggal DESC
            ");
        }
        $pinjaman = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($pinjaman);
        break;
        
    case 'POST':
        // Add new pinjaman
        $data = json_decode(file_get_contents('php://input'), true);
        
        $stmt = $pdo->prepare("INSERT INTO pinjaman (user_id, jumlah, tenor) VALUES (?, ?, ?)");
        $result = $stmt->execute([
            $data['user_id'],
            $data['jumlah'],
            $data['tenor']
        ]);
        
        if($result) {
            echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Failed to add pinjaman']);
        }
        break;
        
    case 'PUT':
        // Update pinjaman status
        $data = json_decode(file_get_contents('php://input'), true);
        
        $stmt = $pdo->prepare("UPDATE pinjaman SET status = ? WHERE id = ?");
        $result = $stmt->execute([
            $data['status'],
            $data['id']
        ]);
        
        echo json_encode(['success' => $result]);
        break;
}
?>