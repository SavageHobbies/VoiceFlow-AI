<#
.SYNOPSIS
    WinAssistAI Voice Control Launcher
.DESCRIPTION
    Simple launcher for WinAssistAI voice control using native Windows Speech Recognition
.EXAMPLE
    PS> .\winassistai-voice.ps1
#>

param(
    [switch]$Help,
    [switch]$Test
)

if ($Help) {
    Write-Host "WinAssistAI Voice Control" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\winassistai-voice.ps1         - Start voice control"
    Write-Host "  .\winassistai-voice.ps1 -Test   - Test voice recognition"
    Write-Host "  .\winassistai-voice.ps1 -Help   - Show this help"
    Write-Host ""
    Write-Host "VOICE COMMANDS:" -ForegroundColor Yellow
    Write-Host "  Say 'Ash' followed by:" -ForegroundColor White
    Write-Host "    hello, hi, good morning" -ForegroundColor Green
    Write-Host "    what time is it" -ForegroundColor Green
    Write-Host "    check weather" -ForegroundColor Green
    Write-Host "    open calculator" -ForegroundColor Green
    Write-Host "    take screenshot" -ForegroundColor Green
    Write-Host "    thank you, goodbye" -ForegroundColor Green
    Write-Host "    tell me a joke" -ForegroundColor Green
    Write-Host "    play music" -ForegroundColor Green
    Write-Host "    empty recycle bin" -ForegroundColor Green
    Write-Host "    help" -ForegroundColor Green
    Write-Host "    stop listening" -ForegroundColor Red
    Write-Host ""
    Write-Host "REQUIREMENTS:" -ForegroundColor Yellow
    Write-Host "  - Windows 10/11 with working microphone" -ForegroundColor White
    Write-Host "  - No additional software required!" -ForegroundColor Green
    Write-Host ""
    return
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "             WINASSISTAI VOICE CONTROL             " -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "        Voice-Controlled Windows Assistant v2.0.0   " -ForegroundColor White
Write-Host "        Native Windows Speech Recognition           " -ForegroundColor Green
Write-Host ""

if ($Test) {
    & "$PSScriptRoot\voice-assistant-working-final.ps1" -Test
} else {
    & "$PSScriptRoot\voice-assistant-working-final.ps1"
}