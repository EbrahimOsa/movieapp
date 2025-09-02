# PowerShell script to run MovieVerse app
Write-Host "Starting MovieVerse App..." -ForegroundColor Green

# Set proper encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

Write-Host "Step 1: Cleaning project..." -ForegroundColor Yellow
flutter clean

Write-Host "Step 2: Getting dependencies..." -ForegroundColor Yellow  
flutter pub get

Write-Host "Step 3: Running analysis..." -ForegroundColor Yellow
flutter analyze

Write-Host "Step 4: Checking devices..." -ForegroundColor Yellow
flutter devices

Write-Host "Step 5: Starting app..." -ForegroundColor Green
flutter run --debug

Write-Host "App setup completed!" -ForegroundColor Green
