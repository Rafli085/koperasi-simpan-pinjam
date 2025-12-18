<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'POST':
        // Add new cicilan
        $data = json_decode(file_get_contents('php://input'), true);
        
        $stmt = $pdo->prepare("INSERT INTO cicilan (pinjaman_id, jumlah) VALUES (?, ?)");
        $result = $stmt->execute([
            $data['pinjaman_id'],
            $data['jumlah']
        ]);
        
        if($result) {
            echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Failed to add cicilan']);
        }
        break;
}
?>