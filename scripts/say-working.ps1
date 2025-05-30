<#
.SYNOPSIS
    Working TTS using Windows voices that actually work
.DESCRIPTION
    Uses Windows TTS with the best available voice
#>

param([string]$t="")

try {
    Write-Host "[TTS] Speaking with Windows voice: '$t'" -ForegroundColor Cyan
    
    Add-Type -AssemblyName System.Speech
    $voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
    
    # Use the best available voice (Zira if available)
    foreach($v in $voice.GetInstalledVoices()) {
        $voiceInfo = $v.VoiceInfo
        if($voiceInfo.Name -like "*Zira*") {
            $voice.SelectVoice($voiceInfo.Name)
            Write-Host "[VOICE] Using: $($voiceInfo.Name)" -ForegroundColor Green
            break
        }
    }
    
    $voice.Rate = 1  # Normal speaking rate
    $voice.Volume = 100  # Maximum volume
    $voice.Speak($t)
    $voice.Dispose()
    
    Write-Host "[TTS] ✅ Windows TTS completed successfully" -ForegroundColor Green
    
    # Save last spoken text
    if("$env:TEMP" -ne "") {
        "$t" | Set-Content "$env:TEMP/winassistai.txt" -Encoding UTF8
    }
    
} catch {
    Write-Host "[TTS] ❌ Windows TTS failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

exit 0