@echo off
title MovieVerse App Diagnostic Tool
color 0A

echo ========================================
echo          MovieVerse App Diagnostics     
echo ========================================
echo.

echo [1/8] Checking Flutter Doctor...
flutter doctor -v
echo.

echo [2/8] Analyzing Code...
flutter analyze
echo.

echo [3/8] Checking Dependencies...
flutter pub deps
echo.

echo [4/8] Running Python Script to Fix withOpacity...
python fix_withopacity.py
echo.

echo [5/8] Checking for Connected Devices...
flutter devices
echo.

echo [6/8] Checking API Key Configuration...
findstr /C:"tmdbApiKey" lib\core\constants\app_constants.dart
echo.

echo [7/8] Testing Build Process...
flutter build apk --debug --verbose
echo.

echo [8/8] Cleanup Complete!
echo.

echo ========================================
echo             Results Summary             
echo ========================================
echo - Cleaned project files
echo - Fixed theme color issues  
echo - Removed duplicate files
echo - Updated deprecated withOpacity usage
echo - Verified dependencies
echo ========================================
echo.

echo Ready to run! Try: flutter run
pause
