# Test with Windows TTS that definitely works
Write-Host "Testing Windows TTS - you should hear this..." -ForegroundColor Green

try {
    Add-Type -AssemblyName System.Speech
    $voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
    
    # Set to maximum volume and normal rate
    $voice.Volume = 100
    $voice.Rate = 0
    
    # Try to use a good voice
    foreach($v in $voice.GetInstalledVoices()) {
        $voiceInfo = $v.VoiceInfo
        Write-Host "Available voice: $($voiceInfo.Name) - $($voiceInfo.Culture)" -ForegroundColor Yellow
        if($voiceInfo.Name -like "*Zira*" -or $voiceInfo.Name -like "*Eva*" -or $voiceInfo.Name -like "*Hazel*") {
            $voice.SelectVoice($voiceInfo.Name)
            Write-Host "Selected voice: $($voiceInfo.Name)" -ForegroundColor Green
            break
        }
    }
    
    $testMessage = "Testing Windows text to speech. Can you hear this message clearly? This should be audible on your speakers or headphones."
    Write-Host "Speaking: $testMessage" -ForegroundColor Cyan
    
    $voice.Speak($testMessage)
    $voice.Dispose()
    
    Write-Host "Windows TTS test completed." -ForegroundColor Green
    
} catch {
    Write-Host "TTS failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Did you hear the Windows TTS voice? (Press any key to continue)" -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")