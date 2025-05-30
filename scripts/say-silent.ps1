<#
.SYNOPSIS
    Silent ElevenLabs TTS - No Popup Windows
.DESCRIPTION
    Plays ElevenLabs audio silently without any visible windows
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Text
)

# Import shared functions
. (Join-Path $PSScriptRoot "_shared-functions.ps1")

try {
    Write-Host "[TTS] Speaking silently: '$Text'" -ForegroundColor Cyan

    # Create unique temp file
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"
    $tempAudioFile = Join-Path $env:TEMP "elevenlabs_silent_$timestamp.mp3"

    # Get ElevenLabs config
    $elevenlabsConfigPath = Join-Path $PSScriptRoot "..\config\elevenlabs.json"
    $elevenlabsConfig = Get-Content $elevenlabsConfigPath | ConvertFrom-Json

    if ($elevenlabsConfig.enabled) {
        $apiKey = Get-EnvVariable -KeyName "ELEVENLABS_API_KEY"

        if ($apiKey) {
            $headers = @{
                "Accept" = "audio/mpeg"
                "Content-Type" = "application/json"
                "xi-api-key" = $apiKey
            }

            $body = @{
                "text" = $Text
                "model_id" = $elevenlabsConfig.model
                "voice_settings" = @{
                    "stability" = $elevenlabsConfig.voice.stability
                    "similarity_boost" = $elevenlabsConfig.voice.similarityBoost
                    "style" = $elevenlabsConfig.voice.style
                    "use_speaker_boost" = $elevenlabsConfig.voice.useSpeakerBoost
                }
            } | ConvertTo-Json

            $ttsUrl = "$($elevenlabsConfig.apiUrl)/text-to-speech/$($elevenlabsConfig.voice.id)"

            # Download audio
            Invoke-RestMethod -Uri $ttsUrl -Headers $headers -Method Post -Body $body -OutFile $tempAudioFile -TimeoutSec 30

            if (Test-Path $tempAudioFile) {
                $fileSize = (Get-Item $tempAudioFile).Length
                Write-Host "[SILENT] Audio file created ($fileSize bytes)" -ForegroundColor Green

                # Use PowerShell MediaPlayer (completely silent)
                try {
                    Add-Type -AssemblyName presentationCore
                    $mediaPlayer = New-Object System.Windows.Media.MediaPlayer
                    $mediaPlayer.Volume = 1.0
                    $mediaPlayer.Open([System.Uri]::new($tempAudioFile))
                    
                    # Wait for loading
                    $loadTimeout = 0
                    while (-not $mediaPlayer.HasAudio -and $loadTimeout -lt 50) {
                        Start-Sleep -Milliseconds 100
                        $loadTimeout++
                    }
                    
                    if ($mediaPlayer.HasAudio) {
                        $mediaPlayer.Play()
                        
                        # Get duration and wait
                        $durationTimeout = 0
                        while ($mediaPlayer.NaturalDuration.TimeSpan.TotalSeconds -eq 0 -and $durationTimeout -lt 50) {
                            Start-Sleep -Milliseconds 100
                            $durationTimeout++
                        }
                        
                        if ($mediaPlayer.NaturalDuration.TimeSpan.TotalSeconds -gt 0) {
                            $duration = $mediaPlayer.NaturalDuration.TimeSpan.TotalSeconds
                            Start-Sleep -Seconds ($duration + 0.5)
                        } else {
                            Start-Sleep -Seconds 3  # Default wait
                        }
                        
                        Write-Host "[SILENT] ✅ Audio played silently" -ForegroundColor Green
                    } else {
                        throw "Audio could not be loaded"
                    }
                    
                    $mediaPlayer.Close()
                    
                } catch {
                    Write-Host "[SILENT] MediaPlayer failed: $($_.Exception.Message)" -ForegroundColor Red
                    # Fallback to Windows TTS
                    Add-Type -AssemblyName System.Speech
                    $voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
                    $voice.Volume = 100
                    $voice.Rate = 1
                    $voice.Speak($Text)
                    $voice.Dispose()
                    Write-Host "[SILENT] ✅ Windows TTS fallback completed" -ForegroundColor Green
                }

                # Cleanup
                Start-Sleep -Seconds 1
                Remove-Item $tempAudioFile -ErrorAction SilentlyContinue

            } else {
                throw "Audio file was not created"
            }

        } else {
            throw "ELEVENLABS_API_KEY not found"
        }
    } else {
        throw "ElevenLabs is disabled in config"
    }

} catch {
    Write-Host "[SILENT] ElevenLabs failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[SILENT] Using Windows TTS..." -ForegroundColor Yellow
    
    try {
        Add-Type -AssemblyName System.Speech
        $voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
        $voice.Rate = 1
        $voice.Volume = 100
        $voice.Speak($Text)
        $voice.Dispose()
        Write-Host "[SILENT] ✅ Windows TTS completed" -ForegroundColor Green
    } catch {
        Write-Host "[SILENT] ❌ All TTS methods failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}