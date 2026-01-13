<?php
header('Content-Type: text/plain');
header('Access-Control-Allow-Origin: *');

require_once 'config.php';

try {
    echo "=== DEBUGGING PINJAMAN FLEXI ISSUE ===\n\n";
    
    // Check produk_koperasi table
    echo "1. PRODUK_KOPERASI TABLE:\n";
    $stmt = $pdo->query("SELECT * FROM produk_koperasi ORDER BY id");
    $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach($products as $product) {
        echo "ID: {$product['id']}, Name: {$product['nama_produk']}\n";
    }
    
    // Check recent pengajuan_pinjaman with Pinjaman Flexi
    echo "\n2. RECENT PENGAJUAN PINJAMAN (Flexi):\n";
    $stmt = $pdo->prepare("
        SELECT pp.id, pp.user_id, pp.produk_id, pp.status, pk.nama_produk, u.nama
        FROM pengajuan_pinjaman pp
        LEFT JOIN produk_koperasi pk ON pp.produk_id = pk.id
        LEFT JOIN users u ON pp.user_id = u.id
        WHERE pp.produk_id = 2
        ORDER BY pp.id DESC
        LIMIT 5
    ");
    $stmt->execute();
    $pengajuan = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach($pengajuan as $p) {
        echo "Pengajuan ID: {$p['id']}, User: {$p['nama']}, Produk ID: {$p['produk_id']}, Produk: {$p['nama_produk']}, Status: {$p['status']}\n";
    }
    
    // Check pinjaman table for Flexi loans
    echo "\n3. PINJAMAN TABLE (Flexi):\n";
    $stmt = $pdo->prepare("
        SELECT p.id, p.pengajuan_id, p.user_id, p.produk_id, p.status, pk.nama_produk, u.nama
        FROM pinjaman p
        LEFT JOIN produk_koperasi pk ON p.produk_id = pk.id
        LEFT JOIN users u ON p.user_id = u.id
        WHERE p.produk_id = 2
        ORDER BY p.id DESC
        LIMIT 5
    ");
    $stmt->execute();
    $pinjaman = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach($pinjaman as $p) {
        echo "Pinjaman ID: {$p['id']}, Pengajuan ID: {$p['pengajuan_id']}, User: {$p['nama']}, Produk ID: {$p['produk_id']}, Produk: {$p['nama_produk']}\n";
    }
    
    // Check for any pinjaman with NULL or wrong produk_id
    echo "\n4. PINJAMAN WITH ISSUES:\n";
    $stmt = $pdo->query("
        SELECT p.id, p.pengajuan_id, p.produk_id, pk.nama_produk, pp.produk_id as original_produk_id, pk2.nama_produk as original_produk_name
        FROM pinjaman p
        LEFT JOIN produk_koperasi pk ON p.produk_id = pk.id
        LEFT JOIN pengajuan_pinjaman pp ON p.pengajuan_id = pp.id
        LEFT JOIN produk_koperasi pk2 ON pp.produk_id = pk2.id
        WHERE p.produk_id != pp.produk_id OR p.produk_id IS NULL
        ORDER BY p.id DESC
        LIMIT 10
    ");
    $issues = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($issues)) {
        echo "No issues found - produk_id transfer is working correctly\n";
    } else {
        foreach($issues as $issue) {
            echo "Pinjaman ID: {$issue['id']}, Current Produk ID: {$issue['produk_id']} ({$issue['nama_produk']}), Should be: {$issue['original_produk_id']} ({$issue['original_produk_name']})\n";
        }
    }
    
    echo "\n=== DEBUG COMPLETED ===\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>