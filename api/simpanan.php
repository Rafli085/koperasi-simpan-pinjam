<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        if(isset($_GET['user_id'])) {
            // Get simpanan by user
            $stmt = $pdo->prepare("SELECT s.*, u.username, u.nama FROM simpanan s JOIN users u ON s.user_id = u.id WHERE s.user_id = ? ORDER BY s.tanggal DESC");
            $stmt->execute([$_GET['user_id']]);
        } else {
            // Get all simpanan
            $stmt = $pdo->query("SELECT s.*, u.username, u.nama FROM simpanan s JOIN users u ON s.user_id = u.id ORDER BY s.tanggal DESC");
        }
        $simpanan = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($simpanan);
        break;
        
    case 'POST':
        // Add new simpanan
        $data = json_decode(file_get_contents('php://input'), true);
        
        $stmt = $pdo->prepare("INSERT INTO simpanan (user_id, jumlah) VALUES (?, ?)");
        $result = $stmt->execute([
            $data['user_id'],
            $data['jumlah']
        ]);
        
        if($result) {
            echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Failed to add simpanan']);
        }
        break;
        
    case 'DELETE':
        // Delete simpanan by user
        $data = json_decode(file_get_contents('php://input'), true);
        
        $stmt = $pdo->prepare("DELETE FROM simpanan WHERE user_id = ?");
        $result = $stmt->execute([$data['user_id']]);
        
        if($result) {
            echo json_encode(['success' => true, 'message' => 'Simpanan berhasil dihapus']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Gagal menghapus simpanan']);
        }
        break;
}
?>