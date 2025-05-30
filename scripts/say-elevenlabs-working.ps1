<#
.SYNOPSIS
    Working ElevenLabs TTS with Reliable Audio Output
.DESCRIPTION
    Uses NAudio or falls back to file association for reliable MP3 playback
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Text
)

# Import shared functions
. (Join-Path $PSScriptRoot "_shared-functions.ps1")

try {
    Write-Host "[TTS] Speaking with ElevenLabs: '$Text'" -ForegroundColor Cyan

    # Create unique temp file
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"
    $tempAudioFile = Join-Path $env:TEMP "elevenlabs_working_$timestamp.mp3"

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
            Write-Host "[ELEVENLABS] Downloading audio..." -ForegroundColor Green
            Invoke-RestMethod -Uri $ttsUrl -Headers $headers -Method Post -Body $body -OutFile $tempAudioFile -TimeoutSec 30

            if (Test-Path $tempAudioFile) {
                $fileSize = (Get-Item $tempAudioFile).Length
                Write-Host "[ELEVENLABS] Audio file created ($fileSize bytes)" -ForegroundColor Green

                # Method 1: Use mshta.exe to play audio (works on all Windows)
                try {
                    Write-Host "[AUDIO] Playing with mshta method..." -ForegroundColor Yellow
                    
                    # Create temporary HTML file that will play audio
                    $htmlFile = Join-Path $env:TEMP "play_audio_$timestamp.html"
                    $htmlContent = @"
<html>
<body>
<audio autoplay>
    <source src="file:///$($tempAudioFile.Replace('\', '/'))" type="audio/mpeg">
</audio>
<script>
    setTimeout(function() { window.close(); }, 5000);
</script>
</body>
</html>
"@
                    $htmlContent | Out-File -FilePath $htmlFile -Encoding UTF8
                    
                    # Play with mshta (silent HTML application)
                    $process = Start-Process -FilePath "mshta.exe" -ArgumentList "`"$htmlFile`"" -WindowStyle Hidden -PassThru
                    Start-Sleep -Seconds 4
                    
                    if (-not $process.HasExited) {
                        $process.Kill()
                    }
                    
                    Remove-Item $htmlFile -ErrorAction SilentlyContinue
                    Write-Host "[AUDIO] ✅ mshta audio playback completed" -ForegroundColor Green
                    
                } catch {
                    Write-Host "[AUDIO] mshta method failed: $($_.Exception.Message)" -ForegroundColor Yellow
                    
                    # Method 2: Use Windows Media Player command line
                    try {
                        Write-Host "[AUDIO] Trying wmplayer command line..." -ForegroundColor Yellow
                        
                        # Create a playlist file
                        $playlistFile = Join-Path $env:TEMP "playlist_$timestamp.wpl"
                        $playlistContent = @"
<?wpl version="1.0"?>
<smil>
    <head>
        <title>TTS Playlist</title>
    </head>
    <body>
        <seq>
            <media src="$tempAudioFile"/>
        </seq>
    </body>
</smil>
"@
                        $playlistContent | Out-File -FilePath $playlistFile -Encoding UTF8
                        
                        $process = Start-Process -FilePath "wmplayer.exe" -ArgumentList "/play /close `"$playlistFile`"" -WindowStyle Minimized -PassThru
                        Start-Sleep -Seconds 4
                        
                        if (-not $process.HasExited) {
                            $process.CloseMainWindow()
                        }
                        
                        Remove-Item $playlistFile -ErrorAction SilentlyContinue
                        Write-Host "[AUDIO] ✅ wmplayer playlist completed" -ForegroundColor Green
                        
                    } catch {
                        Write-Host "[AUDIO] wmplayer method failed: $($_.Exception.Message)" -ForegroundColor Yellow
                        
                        # Method 3: Direct file association (last resort)
                        try {
                            Write-Host "[AUDIO] Using file association..." -ForegroundColor Yellow
                            
                            $process = Start-Process -FilePath $tempAudioFile -PassThru
                            Start-Sleep -Seconds 4
                            
                            if (-not $process.HasExited) {
                                $process.CloseMainWindow()
                            }
                            
                            Write-Host "[AUDIO] ✅ File association playback completed" -ForegroundColor Green
                            
                        } catch {
                            Write-Host "[AUDIO] All playback methods failed" -ForegroundColor Red
                            throw "Could not play audio file"
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
        
        # Use best available voice
        foreach($v in $voice.GetInstalledVoices()) {
            $voiceInfo = $v.VoiceInfo
            if($voiceInfo.Name -like "*Zira*" -or $voiceInfo.Name -like "*Eva*") {
                $voice.SelectVoice($voiceInfo.Name)
                break
            }
        }
        
        $voice.Rate = 1
        $voice.Volume = 100
        $voice.Speak($Text)
        $voice.Dispose()
        Write-Host "[FALLBACK] ✅ Windows TTS completed" -ForegroundColor Green
    } catch {
        Write-Host "[FALLBACK] ❌ All TTS methods failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}