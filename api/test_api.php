<?php
// Test file untuk memverifikasi API
echo "<h2>Test API Koperasi</h2>";

// Test koneksi database
require_once 'config.php';

echo "<h3>1. Test Koneksi Database</h3>";
try {
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM users");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "✅ Database connected! Total users: " . $result['total'] . "<br>";
} catch(Exception $e) {
    echo "❌ Database error: " . $e->getMessage() . "<br>";
}

echo "<h3>2. Test Data Users</h3>";
try {
    $stmt = $pdo->query("SELECT id, username, nama, role FROM users");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "<table border='1' style='border-collapse: collapse;'>";
    echo "<tr><th>ID</th><th>Username</th><th>Nama</th><th>Role</th></tr>";
    
    foreach($users as $user) {
        echo "<tr>";
        echo "<td>" . $user['id'] . "</td>";
        echo "<td>" . $user['username'] . "</td>";
        echo "<td>" . $user['nama'] . "</td>";
        echo "<td>" . $user['role'] . "</td>";
        echo "</tr>";
    }
    echo "</table>";
    
} catch(Exception $e) {
    echo "❌ Error getting users: " . $e->getMessage() . "<br>";
}

echo "<h3>3. Test Login API</h3>";
echo "<form method='POST'>";
echo "Username: <input type='text' name='test_username' value='anggota1'><br><br>";
echo "Password: <input type='text' name='test_password' value='123456'><br><br>";
echo "<input type='submit' name='test_login' value='Test Login'>";
echo "</form>";

if(isset($_POST['test_login'])) {
    $username = $_POST['test_username'];
    $password = $_POST['test_password'];
    
    echo "<h4>Testing login with: $username / $password</h4>";
    
    // Test login logic
    $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ? AND password = ?");
    $stmt->execute([trim($username), trim($password)]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if($user) {
        echo "✅ Login SUCCESS!<br>";
        echo "User data: " . json_encode($user) . "<br>";
    } else {
        echo "❌ Login FAILED!<br>";
        echo "No user found with username: $username and password: $password<br>";
    }
}

echo "<h3>4. Test API Endpoint</h3>";
echo "<p>API URL: <a href='users.php?action=list' target='_blank'>users.php?action=list</a></p>";
?>