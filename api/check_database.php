<?php
header('Content-Type: text/plain');
header('Access-Control-Allow-Origin: *');

require_once 'config.php';

try {
    echo "=== CHECKING PRODUK_KOPERASI TABLE ===\n";
    
    // Check if produk_koperasi table exists and has data
    $stmt = $pdo->query("SELECT * FROM produk_koperasi ORDER BY id");
    $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Current produk_koperasi data:\n";
    foreach($products as $product) {
        echo "ID: {$product['id']}, Name: {$product['nama_produk']}\n";
    }
    
    // Insert/Update produk data if needed
    echo "\n=== UPDATING PRODUK DATA ===\n";
    $stmt = $pdo->prepare("
        INSERT INTO produk_koperasi (id, nama_produk, bunga_persen, bunga_per, tenor_min, tenor_max) VALUES
        (1, 'Pinjaman Tunai', 12, 'tahun', 10, 60),
        (2, 'Pinjaman Flexi', 5, 'bulan', 1, 24),
        (3, 'Beli HP', 12, 'tahun', 10, 36)
        ON DUPLICATE KEY UPDATE
        nama_produk = VALUES(nama_produk),
        bunga_persen = VALUES(bunga_persen),
        bunga_per = VALUES(bunga_per),
        tenor_min = VALUES(tenor_min),
        tenor_max = VALUES(tenor_max)
    ");
    
    $result = $stmt->execute();
    echo "Produk data updated: " . ($result ? "Success" : "Failed") . "\n";
    
    // Check updated produk data
    $stmt = $pdo->query("SELECT * FROM produk_koperasi ORDER BY id");
    $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "\nUpdated produk_koperasi data:\n";
    foreach($products as $product) {
        echo "ID: {$product['id']}, Name: {$product['nama_produk']}, Bunga: {$product['bunga_persen']}% per {$product['bunga_per']}\n";
    }
    
    // Check pinjaman data with product names
    echo "\n=== CHECKING PINJAMAN DATA ===\n";
    $stmt = $pdo->query("
        SELECT p.id, p.user_id, p.jumlah, p.tenor, p.status, p.produk_id, pk.nama_produk 
        FROM pinjaman p 
        LEFT JOIN produk_koperasi pk ON p.produk_id = pk.id 
        ORDER BY p.id DESC
        LIMIT 10
    ");
    $pinjaman = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Sample pinjaman data with product names:\n";
    foreach($pinjaman as $p) {
        echo "ID: {$p['id']}, User: {$p['user_id']}, Produk ID: {$p['produk_id']}, Produk: {$p['nama_produk']}, Jumlah: {$p['jumlah']}\n";
    }
    
    // Check for pinjaman without produk_id
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM pinjaman WHERE produk_id IS NULL OR produk_id = 0");
    $nullCount = $stmt->fetchColumn();
    
    if ($nullCount > 0) {
        echo "\n=== FIXING NULL PRODUK_ID ===\n";
        echo "Found {$nullCount} pinjaman with NULL or 0 produk_id\n";
        
        // Update NULL produk_id to default (1 = Pinjaman Tunai)
        $stmt = $pdo->prepare("UPDATE pinjaman SET produk_id = 1 WHERE produk_id IS NULL OR produk_id = 0");
        $result = $stmt->execute();
        echo "Updated NULL produk_id: " . ($result ? "Success" : "Failed") . "\n";
    }
    
    echo "\n=== DATABASE CHECK COMPLETED ===\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>