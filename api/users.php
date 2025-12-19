<?php
require_once 'config.php';

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
}
?>