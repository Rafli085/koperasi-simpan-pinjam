<?php
require_once 'config.php';

echo "<h2>Database Debug</h2>";

try {
    // Check events table
    echo "<h3>Events Table:</h3>";
    $stmt = $pdo->query("SELECT * FROM events ORDER BY created_at DESC");
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "<p>ID: {$row['id']}, Title: {$row['title']}, Type: {$row['type']}, Active: {$row['is_active']}</p>";
    }
    
    // Check poll_options table
    echo "<h3>Poll Options Table:</h3>";
    $stmt = $pdo->query("SELECT * FROM poll_options ORDER BY event_id, id");
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "<p>Event ID: {$row['event_id']}, Option: {$row['text']}, Votes: {$row['votes']}</p>";
    }
    
    // Check user_votes table
    echo "<h3>User Votes Table:</h3>";
    $stmt = $pdo->query("SELECT * FROM user_votes ORDER BY event_id, user_id");
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "<p>Event ID: {$row['event_id']}, User ID: {$row['user_id']}, Option ID: {$row['option_id']}</p>";
    }
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>