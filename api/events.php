<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];
$input = json_decode(file_get_contents('php://input'), true);

try {
    switch ($method) {
        case 'GET':
            if (isset($_GET['action']) && $_GET['action'] == 'get_events') {
                getEvents();
            }
            break;
            
        case 'POST':
            if (isset($input['action'])) {
                switch ($input['action']) {
                    case 'create_event':
                        createEvent($input);
                        break;
                    case 'vote_poll':
                        votePoll($input);
                        break;
                }
            }
            break;
            
        case 'PUT':
            if (isset($input['action']) && $input['action'] == 'update_event') {
                updateEvent($input);
            }
            break;
            
        case 'DELETE':
            if (isset($_GET['action']) && $_GET['action'] == 'delete_event' && isset($_GET['id'])) {
                deleteEvent($_GET['id']);
            }
            break;
    }
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}

function getEvents() {
    global $pdo;
    
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
    
    echo json_encode($events);
}

function createEvent($data) {
    global $pdo;
    
    $title = $data['title'];
    $description = $data['description'];
    $type = $data['type'];
    $endDate = isset($data['end_date']) ? $data['end_date'] : null;
    
    $sql = "INSERT INTO events (title, description, type, end_date) VALUES (?, ?, ?, ?)";
    $stmt = $pdo->prepare($sql);
    
    if ($stmt->execute([$title, $description, $type, $endDate])) {
        $eventId = $pdo->lastInsertId();
        
        if ($type == 'poll' && isset($data['poll_options'])) {
            $optionSql = "INSERT INTO poll_options (event_id, text) VALUES (?, ?)";
            $optionStmt = $pdo->prepare($optionSql);
            
            foreach ($data['poll_options'] as $option) {
                $optionStmt->execute([$eventId, $option]);
            }
        }
        
        echo json_encode(['success' => true, 'message' => 'Event berhasil dibuat']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Gagal membuat event']);
    }
}

function updateEvent($data) {
    global $pdo;
    
    $id = (int)$data['event_id'];
    $title = $data['title'];
    $description = $data['description'];
    $endDate = isset($data['end_date']) ? $data['end_date'] : null;
    
    $sql = "UPDATE events SET title=?, description=?, end_date=? WHERE id=?";
    $stmt = $pdo->prepare($sql);
    
    if ($stmt->execute([$title, $description, $endDate, $id])) {
        echo json_encode(['success' => true, 'message' => 'Event berhasil diupdate']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Gagal mengupdate event']);
    }
}

function deleteEvent($id) {
    global $pdo;
    
    $id = (int)$id;
    $sql = "DELETE FROM events WHERE id = ?";
    $stmt = $pdo->prepare($sql);
    
    if ($stmt->execute([$id])) {
        echo json_encode(['success' => true, 'message' => 'Event berhasil dihapus']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Gagal menghapus event']);
    }
}

function votePoll($data) {
    global $pdo;
    
    $eventId = (int)$data['event_id'];
    $userId = (int)$data['user_id'];
    $optionId = (int)$data['option_id'];
    
    // Check if user already voted
    $checkSql = "SELECT option_id FROM user_votes WHERE event_id = ? AND user_id = ?";
    $checkStmt = $pdo->prepare($checkSql);
    $checkStmt->execute([$eventId, $userId]);
    
    if ($checkStmt->rowCount() > 0) {
        $oldVote = $checkStmt->fetch(PDO::FETCH_ASSOC)['option_id'];
        
        // Update vote
        $updateSql = "UPDATE user_votes SET option_id = ? WHERE event_id = ? AND user_id = ?";
        $updateStmt = $pdo->prepare($updateSql);
        $updateStmt->execute([$optionId, $eventId, $userId]);
        
        // Update vote counts
        $pdo->prepare("UPDATE poll_options SET votes = votes - 1 WHERE id = ?")->execute([$oldVote]);
        $pdo->prepare("UPDATE poll_options SET votes = votes + 1 WHERE id = ?")->execute([$optionId]);
    } else {
        // Insert new vote
        $insertSql = "INSERT INTO user_votes (event_id, user_id, option_id) VALUES (?, ?, ?)";
        $insertStmt = $pdo->prepare($insertSql);
        $insertStmt->execute([$eventId, $userId, $optionId]);
        
        // Update vote count
        $pdo->prepare("UPDATE poll_options SET votes = votes + 1 WHERE id = ?")->execute([$optionId]);
    }
    
    echo json_encode(['success' => true, 'message' => 'Vote berhasil disimpan']);
}
?>