<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        if(isset($_GET['username']) && isset($_GET['password'])) {
            // Login
            $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ? AND password = ?");
            $stmt->execute([$_GET['username'], $_GET['password']]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if($user) {
                echo json_encode(['success' => true, 'user' => $user]);
            } else {
                echo json_encode(['success' => false, 'message' => 'Invalid credentials']);
            }
        } else {
            // Get all users
            $stmt = $pdo->query("SELECT * FROM users");
            $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($users);
        }
        break;
        
    case 'POST':
        // Add new user
        $data = json_decode(file_get_contents('php://input'), true);
        
        $stmt = $pdo->prepare("INSERT INTO users (username, nama, password, role) VALUES (?, ?, ?, ?)");
        $result = $stmt->execute([
            $data['username'],
            $data['nama'], 
            $data['password'],
            $data['role']
        ]);
        
        if($result) {
            echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Failed to add user']);
        }
        break;
}
?>