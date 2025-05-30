# WinAssistAI - One-Click Voice Assistant
# Simple launcher that handles everything

Write-Host "🎯 WinAssistAI Voice Assistant" -ForegroundColor Cyan
Write-Host "=" * 50

# Check if this is first run
if (-not (Test-Path ".env") -or (Get-Content ".env" -Raw) -match "YOUR_.*_KEY_HERE") {
    Write-Host ""
    Write-Host "👋 Welcome! Let's set up your voice assistant." -ForegroundColor Green
    Write-Host ""
    Write-Host "This will take 2 minutes and configure:" -ForegroundColor White
    Write-Host "  🔊 Voice output (ElevenLabs or Windows)" -ForegroundColor Yellow
    Write-Host "  🤖 AI responses (OpenAI or basic)" -ForegroundColor Yellow
    Write-Host "  💬 Wake word (default: Ash)" -ForegroundColor Yellow
    Write-Host ""
    
    $setup = Read-Host "Ready to start setup? (y/n)"
    if ($setup.ToLower() -eq "y") {
        & ".\easy-setup.ps1"
        Write-Host ""
        Write-Host "🎉 Setup complete! Starting voice assistant..." -ForegroundColor Green
        Start-Sleep 2
    } else {
        Write-Host "Run setup later with: .\easy-setup.ps1" -ForegroundColor Yellow
        exit
    }
}

# Load environment variables
if (Test-Path ".env") {
    $envVars = Get-Content ".env" | Where-Object { $_ -match "=" } | ForEach-Object {
        $key, $value = $_ -split "=", 2
        [Environment]::SetEnvironmentVariable($key, $value, "Process")
        @{ Key = $key; Value = $value }
    }
    
    $wakeWord = ($envVars | Where-Object { $_.Key -eq "WAKE_WORD" }).Value
    if (-not $wakeWord) { $wakeWord = "Ash" }
    
    Write-Host ""
    Write-Host "📊 Your Voice Assistant:" -ForegroundColor White
    $hasElevenLabs = ($envVars | Where-Object { $_.Key -eq "ELEVENLABS_API_KEY" -and $_.Value -ne "YOUR_ELEVENLABS_API_KEY_HERE" })
    $hasOpenAI = ($envVars | Where-Object { $_.Key -eq "OPENAI_API_KEY" -and $_.Value -ne "YOUR_OPENAI_API_KEY_HERE" })
    
    Write-Host "  🔊 Voice: $(if ($hasElevenLabs) { 'ElevenLabs (High Quality)' } else { 'Windows Voice' })" -ForegroundColor Green
    Write-Host "  🤖 AI: $(if ($hasOpenAI) { 'OpenAI Enabled' } else { 'Basic Responses' })" -ForegroundColor Green
    Write-Host "  💬 Wake Word: '$wakeWord'" -ForegroundColor Green
    Write-Host ""
}

Write-Host "🚀 Starting Voice Assistant..." -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Quick Commands to Try:" -ForegroundColor Yellow
Write-Host "  '$wakeWord hello'" -ForegroundColor White
Write-Host "  '$wakeWord what time is it'" -ForegroundColor White
Write-Host "  '$wakeWord tell me a joke'" -ForegroundColor White
Write-Host "  '$wakeWord stop listening' (to exit)" -ForegroundColor White
Write-Host ""

# Start the ultimate fixed voice assistant
if (Test-Path ".\scripts\voice-assistant-ultimate-fix.ps1") {
    & ".\scripts\voice-assistant-ultimate-fix.ps1"
} elseif (Test-Path ".\scripts\voice-assistant-final-fixed.ps1") {
    & ".\scripts\voice-assistant-final-fixed.ps1"
} elseif (Test-Path ".\scripts\winassistai-voice.ps1") {
    & ".\scripts\winassistai-voice.ps1"
} else {
    Write-Host "❌ Error: Voice script not found!" -ForegroundColor Red
    Write-Host "Expected: .\scripts\voice-assistant-ultimate-fix.ps1" -ForegroundColor Yellow
}