@echo off
chcp 65001 >nul
title MovieVerse App Launcher
color 0A

echo.
echo ========================================
echo          🎬 MovieVerse App 🎬
echo ========================================
echo.

echo [INFO] Starting application...
echo.

echo [1/4] Cleaning project...
call flutter clean >nul 2>&1

echo [2/4] Getting dependencies...  
call flutter pub get >nul 2>&1

echo [3/4] Checking devices...
call flutter devices

echo.
echo [4/4] 🚀 Starting MovieVerse...
echo ========================================
echo.

call flutter run

echo.
echo ========================================
echo       App session completed!
echo ========================================
pause
