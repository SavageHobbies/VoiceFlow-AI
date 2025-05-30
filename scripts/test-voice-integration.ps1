<#
.SYNOPSIS
    Test WinAssistAI voice integration with Serenade
.DESCRIPTION
    This script helps test and troubleshoot voice command integration
#>

Write-Host "=== WinAssistAI Voice Integration Test ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check if Serenade is running
Write-Host "1. Checking Serenade process..." -ForegroundColor Yellow
$serenadeProcess = Get-Process -Name "Serenade" -ErrorAction SilentlyContinue
if ($serenadeProcess) {
    Write-Host "   OK Serenade is running (PID: $($serenadeProcess.Id))" -ForegroundColor Green
} else {
    Write-Host "   ERROR Serenade is not running" -ForegroundColor Red
    exit 1
}

# Test 2: Check if custom script exists
Write-Host "2. Checking custom script..." -ForegroundColor Yellow
$scriptPath = "$env:USERPROFILE\.serenade\scripts\WinAssistAI.js"
if (Test-Path $scriptPath) {
    Write-Host "   OK Custom script found at: $scriptPath" -ForegroundColor Green
} else {
    Write-Host "   ERROR Custom script not found" -ForegroundColor Red
}

# Test 3: Check script content
Write-Host "3. Checking script configuration..." -ForegroundColor Yellow
if (Test-Path $scriptPath) {
    $content = Get-Content $scriptPath -Raw
    if ($content -match 'WAKE_WORD = "Ash"') {
        Write-Host "   OK Wake word configured: Ash" -ForegroundColor Green
    } else {
        Write-Host "   WARNING Wake word configuration unclear" -ForegroundColor Yellow
    }
    
    if ($content -match 'serenade\.global\(\)\.command') {
        Write-Host "   OK Voice commands defined" -ForegroundColor Green
    } else {
        Write-Host "   ERROR No voice commands found" -ForegroundColor Red
    }
}

# Test 4: Test bridge functionality
Write-Host "4. Testing bridge functionality..." -ForegroundColor Yellow
try {
    $result = & "$PSScriptRoot\serenade-bridge.ps1" -Command "hello" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   OK Bridge test successful" -ForegroundColor Green
    } else {
        Write-Host "   ERROR Bridge test failed" -ForegroundColor Red
    }
} catch {
    Write-Host "   ERROR Bridge test error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Voice Command Test Instructions ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Now test these voice commands:" -ForegroundColor White
Write-Host "  1. Say: Ash hello" -ForegroundColor Green
Write-Host "  2. Say: Ash what time is it" -ForegroundColor Green
Write-Host "  3. Say: Ash check weather" -ForegroundColor Green
Write-Host "  4. Say: Ash open calculator" -ForegroundColor Green
Write-Host ""

Write-Host "If voice commands do not work:" -ForegroundColor Yellow
Write-Host "  - Make sure Serenade is in Listening mode (not Paused)" -ForegroundColor White
Write-Host "  - Check microphone permissions in Serenade settings" -ForegroundColor White
Write-Host "  - Try restarting Serenade completely" -ForegroundColor White
Write-Host "  - Speak clearly and at normal pace" -ForegroundColor White
Write-Host ""

Write-Host "Test completed. Try the voice commands above!" -ForegroundColor Green