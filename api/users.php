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

switch($method) {
    case 'GET':
        if(isset($_GET['action']) && $_GET['action'] == 'list') {
            // Get all users
            $stmt = $pdo->query("SELECT * FROM users");
            $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($users);
        }
        break;
        
    case 'POST':
        if(isset($_POST['action'])) {
            if($_POST['action'] == 'login') {
                // Login
                $username = trim($_POST['username']);
                $password = trim($_POST['password']);
                
                $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ? AND password = ?");
                $stmt->execute([$username, $password]);
                $user = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if($user) {
                    echo json_encode(['success' => true, 'user' => $user]);
                } else {
                    echo json_encode(['success' => false, 'message' => 'Username atau password salah']);
                }
            } elseif($_POST['action'] == 'add') {
                // Add new user
                $stmt = $pdo->prepare("INSERT INTO users (username, nama, password, role) VALUES (?, ?, ?, ?)");
                $result = $stmt->execute([
                    trim($_POST['username']),
                    trim($_POST['nama']), 
                    trim($_POST['password']),
                    trim($_POST['role'])
                ]);
                
                if($result) {
                    echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
                } else {
                    echo json_encode(['success' => false, 'message' => 'Failed to add user']);
                }
            }
        }
        break;
        
    case 'PUT':
        $data = json_decode(file_get_contents('php://input'), true);
        if($data && isset($data['action']) && $data['action'] == 'edit') {
            try {
                $stmt = $pdo->prepare("UPDATE users SET username = ?, nama = ? WHERE id = ?");
                $result = $stmt->execute([
                    trim($data['username']),
                    trim($data['nama']),
                    $data['id']
                ]);
                
                if($result) {
                    echo json_encode(['success' => true, 'message' => 'User berhasil diupdate']);
                } else {
                    echo json_encode(['success' => false, 'message' => 'Gagal mengupdate user']);
                }
            } catch(Exception $e) {
                echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
            }
        }
        break;
        
    case 'DELETE':
        $data = json_decode(file_get_contents('php://input'), true);
        if($data && isset($data['action']) && $data['action'] == 'delete') {
            try {
                $stmt = $pdo->prepare("DELETE FROM users WHERE id = ?");
                $result = $stmt->execute([$data['id']]);
                
                if($result) {
                    echo json_encode(['success' => true, 'message' => 'User berhasil dihapus']);
                } else {
                    echo json_encode(['success' => false, 'message' => 'Gagal menghapus user']);
                }
            } catch(Exception $e) {
                echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
            }
        }
        break;
}
?>