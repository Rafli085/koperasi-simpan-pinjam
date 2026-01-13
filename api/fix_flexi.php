<?php
header('Content-Type: text/plain');
header('Access-Control-Allow-Origin: *');

require_once 'config.php';

try {
    echo "=== FIXING PINJAMAN FLEXI PRODUK_ID ===\n\n";
    
    // First, ensure produk_koperasi has correct data
    echo "1. UPDATING PRODUK_KOPERASI TABLE:\n";
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
    
    // Fix pinjaman table where produk_id doesn't match pengajuan_pinjaman
    echo "\n2. FIXING PINJAMAN PRODUK_ID MISMATCHES:\n";
    $stmt = $pdo->prepare("
        UPDATE pinjaman p
        JOIN pengajuan_pinjaman pp ON p.pengajuan_id = pp.id
        SET p.produk_id = pp.produk_id
        WHERE p.produk_id != pp.produk_id OR p.produk_id IS NULL
    ");
    $result = $stmt->execute();
    $affected = $stmt->rowCount();
    echo "Fixed {$affected} pinjaman records with wrong produk_id\n";
    
    // Verify the fix
    echo "\n3. VERIFICATION - PINJAMAN FLEXI AFTER FIX:\n";
    $stmt = $pdo->query("
        SELECT p.id, p.pengajuan_id, p.user_id, p.produk_id, pk.nama_produk, u.nama
        FROM pinjaman p
        LEFT JOIN produk_koperasi pk ON p.produk_id = pk.id
        LEFT JOIN users u ON p.user_id = u.id
        WHERE p.produk_id = 2
        ORDER BY p.id DESC
        LIMIT 5
    ");
    $pinjaman = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($pinjaman)) {
        echo "No Pinjaman Flexi found in pinjaman table\n";
    } else {
        foreach($pinjaman as $p) {
            echo "Pinjaman ID: {$p['id']}, User: {$p['nama']}, Produk: {$p['nama_produk']}\n";
        }
    }
    
    echo "\n=== FIX COMPLETED ===\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>