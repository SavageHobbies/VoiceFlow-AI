<#
.SYNOPSIS
    Enhanced Text-to-Speech with WORKING ElevenLabs Audio
.DESCRIPTION
    Fixed audio playback for ElevenLabs voice
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Text
)

# Import shared functions
. (Join-Path $PSScriptRoot "_shared-functions.ps1")

try {
    Write-Host "[TTS] Speaking: '$Text'" -ForegroundColor Cyan

    # Create unique temp file
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"
    $tempAudioFile = Join-Path $env:TEMP "elevenlabs_audio_$timestamp.mp3"

    # Get ElevenLabs config
    $elevenlabsConfigPath = Join-Path $PSScriptRoot "..\config\elevenlabs.json"
    $elevenlabsConfig = Get-Content $elevenlabsConfigPath | ConvertFrom-Json

    if ($elevenlabsConfig.enabled) {
        $apiKey = Get-EnvVariable -KeyName "ELEVENLABS_API_KEY"

        if ($apiKey) {
            Write-Host "[ELEVENLABS] Generating audio..." -ForegroundColor Green
            
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
                Write-Host "[ELEVENLABS] Audio file created ($fileSize bytes)" -ForegroundColor Green

                # Method 1: Direct file execution (most reliable for MP3)
                try {
                    Write-Host "[AUDIO] Playing with default MP3 player..." -ForegroundColor Yellow
                    Start-Process -FilePath $tempAudioFile -Wait
                    Write-Host "[AUDIO] ✅ Audio played successfully!" -ForegroundColor Green
                } catch {
                    Write-Host "[AUDIO] Default player failed: $($_.Exception.Message)" -ForegroundColor Red
                    
                    # Method 2: Windows Media Player with proper path
                    try {
                        Write-Host "[AUDIO] Trying Windows Media Player..." -ForegroundColor Yellow
                        $wmplayerPath = "${env:ProgramFiles}\Windows Media Player\wmplayer.exe"
                        if (Test-Path $wmplayerPath) {
                            Start-Process -FilePath $wmplayerPath -ArgumentList "`"$tempAudioFile`"" -Wait
                            Write-Host "[AUDIO] ✅ Windows Media Player successful!" -ForegroundColor Green
                        } else {
                            throw "Windows Media Player not found"
                        }
                    } catch {
                        Write-Host "[AUDIO] Windows Media Player failed: $($_.Exception.Message)" -ForegroundColor Red
                        
                        # Method 3: PowerShell MediaPlayer with proper loading
                        try {
                            Write-Host "[AUDIO] Trying PowerShell MediaPlayer..." -ForegroundColor Yellow
                            Add-Type -AssemblyName presentationCore
                            $mediaPlayer = New-Object System.Windows.Media.MediaPlayer
                            $mediaPlayer.Volume = 1.0
                            
                            # Open and load media
                            $mediaPlayer.Open([System.Uri]::new($tempAudioFile))
                            
                            # Wait for media to load
                            $loadTimeout = 0
                            while (-not $mediaPlayer.HasAudio -and $loadTimeout -lt 50) {
                                Start-Sleep -Milliseconds 100
                                $loadTimeout++
                            }
                            
                            if ($mediaPlayer.HasAudio) {
                                $mediaPlayer.Play()
                                
                                # Wait for duration info
                                $durationTimeout = 0
                                while ($mediaPlayer.NaturalDuration.TimeSpan.TotalSeconds -eq 0 -and $durationTimeout -lt 50) {
                                    Start-Sleep -Milliseconds 100
                                    $durationTimeout++
                                }
                                
                                if ($mediaPlayer.NaturalDuration.TimeSpan.TotalSeconds -gt 0) {
                                    $duration = $mediaPlayer.NaturalDuration.TimeSpan.TotalSeconds
                                    Write-Host "[AUDIO] Playing for $([math]::Round($duration, 1)) seconds..." -ForegroundColor Yellow
                                    Start-Sleep -Seconds ($duration + 1)
                                    Write-Host "[AUDIO] ✅ PowerShell MediaPlayer successful!" -ForegroundColor Green
                                } else {
                                    Start-Sleep -Seconds 4  # Default wait
                                    Write-Host "[AUDIO] ✅ PowerShell MediaPlayer played (no duration info)" -ForegroundColor Green
                                }
                            } else {
                                throw "Media could not be loaded"
                            }
                            
                            $mediaPlayer.Close()
                            
                        } catch {
                            Write-Host "[AUDIO] PowerShell MediaPlayer failed: $($_.Exception.Message)" -ForegroundColor Red
                            
                            # Method 4: VLC if available
                            try {
                                Write-Host "[AUDIO] Trying VLC..." -ForegroundColor Yellow
                                $vlcPath = "${env:ProgramFiles}\VideoLAN\VLC\vlc.exe"
                                if (Test-Path $vlcPath) {
                                    Start-Process -FilePath $vlcPath -ArgumentList "--intf dummy --play-and-exit `"$tempAudioFile`"" -Wait
                                    Write-Host "[AUDIO] ✅ VLC successful!" -ForegroundColor Green
                                } else {
                                    throw "VLC not found"
                                }
                            } catch {
                                Write-Host "[AUDIO] VLC failed: $($_.Exception.Message)" -ForegroundColor Red
                                Write-Host "[AUDIO] ❌ All audio playback methods failed!" -ForegroundColor Red
                                Write-Host "[AUDIO] File saved at: $tempAudioFile" -ForegroundColor Gray
                                Write-Host "[AUDIO] You can manually double-click this file to test audio" -ForegroundColor Gray
                            }
                        }
                    }
                }

                # Cleanup
                Start-Sleep -Seconds 2
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
    Write-Host "[ELEVENLABS] ElevenLabs failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[FALLBACK] Using Windows TTS..." -ForegroundColor Yellow
    
    try {
        Add-Type -AssemblyName System.Speech
        $voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
        $voice.Rate = 2
        $voice.Volume = 100
        $voice.Speak($Text)
        $voice.Dispose()
        Write-Host "[FALLBACK] ✅ Windows TTS completed" -ForegroundColor Green
    } catch {
        Write-Host "[FALLBACK] ❌ Windows TTS also failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}