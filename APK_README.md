# Koperasi Simpan Pinjam APK

## Cara Build APK

### 1. Persiapan
- Pastikan Flutter SDK sudah terinstall
- Pastikan Android SDK sudah terinstall
- Buka terminal/command prompt di folder project

### 2. Build APK Otomatis
Jalankan script build:
```bash
build_apk.bat
```

### 3. Build APK Manual
```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Build APK
flutter build apk --release
```

### 4. Lokasi File APK
Setelah build selesai, file APK akan tersedia di:
- `build\app\outputs\flutter-apk\app-release.apk`
- `dist\KoperasiSimpanPinjam.apk` (jika menggunakan script)

## Informasi APK
- **Nama App**: Koperasi Simpan Pinjam
- **Package**: com.koperasi.simpanpinjam
- **Version**: 1.0.0
- **Min SDK**: Android 5.0 (API 21)
- **Target SDK**: Android 14 (API 34)

## Fitur Aplikasi
- Login untuk Admin dan Anggota
- Manajemen Simpanan
- Pengajuan dan Kelola Pinjaman
- Sistem Cicilan dengan Bunga
- History Transaksi
- Notifikasi Pengajuan
- Kelola Anggota (Admin)
- Event dan Polling

## Instalasi
1. Download file APK
2. Enable "Install from Unknown Sources" di Android
3. Install APK
4. Buka aplikasi dan login

## Login Default
**Admin:**
- Username: admin
- Password: admin123

**Anggota:**
- Username: anggota1
- Password: anggota123