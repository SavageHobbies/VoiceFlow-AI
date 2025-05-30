# Test audio output
Write-Host "Testing Windows TTS..." -ForegroundColor Green

try {
    Add-Type -AssemblyName System.Speech
    $voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $voice.Volume = 100
    $voice.Rate = 0
    Write-Host "Speaking test message..." -ForegroundColor Yellow
    $voice.Speak("Testing Windows text to speech. Can you hear this message?")
    $voice.Dispose()
    Write-Host "TTS test completed." -ForegroundColor Green
} catch {
    Write-Host "TTS failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")