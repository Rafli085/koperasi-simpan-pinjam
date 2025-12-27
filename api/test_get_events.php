<?php
require_once 'config.php';

header('Content-Type: application/json');

try {
    $sql = "SELECT e.* FROM events e WHERE e.is_active = 1 ORDER BY e.created_at DESC";
    $stmt = $pdo->query($sql);
    $events = [];
    
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $event = [
            'id' => (int)$row['id'],
            'title' => $row['title'],
            'description' => $row['description'],
            'type' => $row['type'],
            'created_at' => $row['created_at'],
            'end_date' => $row['end_date'],
            'is_active' => (bool)$row['is_active']
        ];
        
        if ($row['type'] == 'poll') {
            // Get poll options
            $optionSql = "SELECT * FROM poll_options WHERE event_id = ? ORDER BY id";
            $optionStmt = $pdo->prepare($optionSql);
            $optionStmt->execute([$row['id']]);
            
            $options = [];
            while ($option = $optionStmt->fetch(PDO::FETCH_ASSOC)) {
                $options[] = [
                    'id' => (int)$option['id'],
                    'text' => $option['text'],
                    'votes' => (int)$option['votes']
                ];
            }
            $event['poll_options'] = $options;
            
            // Get user votes
            $voteSql = "SELECT user_id, option_id FROM user_votes WHERE event_id = ?";
            $voteStmt = $pdo->prepare($voteSql);
            $voteStmt->execute([$row['id']]);
            
            $userVotes = [];
            while ($vote = $voteStmt->fetch(PDO::FETCH_ASSOC)) {
                $userVotes[(int)$vote['user_id']] = (int)$vote['option_id'];
            }
            $event['user_votes'] = $userVotes;
        }
        
        $events[] = $event;
    }
    
    echo json_encode($events, JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>