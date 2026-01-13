@echo off
echo ========================================
echo    BUILDING KOPERASI SIMPAN PINJAM APK
echo ========================================

echo.
echo 1. Cleaning previous build...
flutter clean

echo.
echo 2. Getting dependencies...
flutter pub get

echo.
echo 3. Building APK (Release)...
flutter build apk --release

echo.
echo 4. Build completed!
echo APK location: build\app\outputs\flutter-apk\app-release.apk

echo.
echo 5. Creating distribution folder...
if not exist "dist" mkdir dist
copy "build\app\outputs\flutter-apk\app-release.apk" "dist\KoperasiSimpanPinjam.apk"

echo.
echo ========================================
echo APK ready for distribution!
echo File: dist\KoperasiSimpanPinjam.apk
echo ========================================
pause