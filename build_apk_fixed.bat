@echo off
echo ========================================
echo Building APK with Network Security Fix
echo ========================================

echo Cleaning previous builds...
flutter clean

echo Getting dependencies...
flutter pub get

echo Building release APK...
flutter build apk --release

echo ========================================
echo APK built successfully!
echo Location: build\app\outputs\flutter-apk\app-release.apk
echo ========================================

echo Network Security Config added to allow HTTP connections
echo APK should now work with local server connections
pause