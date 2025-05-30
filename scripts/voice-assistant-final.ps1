<#
.SYNOPSIS
    Final Conversational Voice Assistant for WinAssistAI
.DESCRIPTION
    Fixed audio playback and truly conversational AI integration
#>

param(
    [switch]$Test,
    [string]$WakeWord = ""
)

# Import shared functions
. (Join-Path $PSScriptRoot "_shared-functions.ps1")

Write-Host "=== WinAssistAI Conversational Voice Assistant ===" -ForegroundColor Cyan
Write-Host ""

# Load .NET Speech Recognition assemblies
Add-Type -AssemblyName System.Speech

try {
    # Get wake word from .env if not specified
    if (-not $WakeWord) {
        $WakeWord = Get-EnvVariable -KeyName "WAKE_WORD" -DefaultValue "Ash"
    }
    
    Write-Host "[SETUP] Configuring conversational voice assistant..." -ForegroundColor Yellow
    Write-Host "Wake word: $WakeWord" -ForegroundColor Cyan
    
    # Create speech recognition engine
    $recognizer = New-Object System.Speech.Recognition.SpeechRecognitionEngine
    
    # Use dictation grammar for natural conversation
    $dictationGrammar = New-Object System.Speech.Recognition.DictationGrammar
    $recognizer.LoadGrammar($dictationGrammar)
    
    # Set input to default microphone
    $recognizer.SetInputToDefaultAudioDevice()
    
    # Configure for better speech capture
    $recognizer.BabbleTimeout = [System.TimeSpan]::FromSeconds(2)
    $recognizer.InitialSilenceTimeout = [System.TimeSpan]::FromSeconds(5)
    $recognizer.EndSilenceTimeout = [System.TimeSpan]::FromSeconds(1)
    
    Write-Host "[START] Starting conversational voice assistant..." -ForegroundColor Green
    Write-Host "Say '$WakeWord' followed by anything you want to say or ask" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor White
    Write-Host "  '$WakeWord hello how are you today'" -ForegroundColor Gray
    Write-Host "  '$WakeWord please open the calculator'" -ForegroundColor Gray
    Write-Host "  '$WakeWord what time is it right now'" -ForegroundColor Gray
    Write-Host "  '$WakeWord tell me about artificial intelligence'" -ForegroundColor Gray
    Write-Host "  '$WakeWord I need help with my homework'" -ForegroundColor Gray
    Write-Host "  '$WakeWord goodbye'" -ForegroundColor Gray
    Write-Host ""
    
    # Quick action keywords (these execute scripts immediately)
    $quickActions = @{
        "calculator" = "open-calculator.ps1"
        "calc" = "open-calculator.ps1"
        "time" = "what-time-is-it.ps1"
        "clock" = "what-time-is-it.ps1"
        "weather" = "check-weather.ps1"
        "screenshot" = "take-screenshot.ps1"
        "screen shot" = "take-screenshot.ps1"
        "hello" = "hello.ps1"
        "hi" = "hello.ps1"
        "goodbye" = "good-bye.ps1"
        "bye" = "good-bye.ps1"
        "thanks" = "thank-you.ps1"
        "thank you" = "thank-you.ps1"
    }
    
    # Function to play audio with multiple fallbacks
    function Play-AudioFile {
        param([string]$FilePath)
        
        Write-Host "[AUDIO] Playing audio..." -ForegroundColor Green
        
        # Method 1: System default player (most reliable)
        try {
            Start-Process -FilePath $FilePath -WindowStyle Hidden -Wait
            Write-Host "[AUDIO] Played successfully" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "[AUDIO] Default player failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Method 2: Windows Media Player
        try {
            Start-Process -FilePath "wmplayer.exe" -ArgumentList "/play /close `"$FilePath`"" -WindowStyle Hidden -Wait
            Write-Host "[AUDIO] Played with Windows Media Player" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "[AUDIO] Windows Media Player failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Method 3: PowerShell built-in
        try {
            Add-Type -AssemblyName presentationCore
            $mediaPlayer = New-Object System.Windows.Media.MediaPlayer
            $mediaPlayer.Volume = 1.0
            $mediaPlayer.Open([System.Uri]::new($FilePath))
            $mediaPlayer.Play()
            Start-Sleep -Seconds 3  # Wait for playback
            $mediaPlayer.Close()
            Write-Host "[AUDIO] Played with MediaPlayer" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "[AUDIO] MediaPlayer failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        Write-Host "[AUDIO] All playback methods failed. File: $FilePath" -ForegroundColor Red
        return $false
    }
    
    # Function to speak text (improved version)
    function Speak-Text {
        param([string]$Text)
        
        try {
            # Try ElevenLabs first
            Write-Host "[TTS] Speaking: '$Text'" -ForegroundColor Cyan
            
            # Create unique temp file
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"
            $tempAudioFile = Join-Path $env:TEMP "elevenlabs_audio_$timestamp.mp3"
            
            # Get ElevenLabs config
            $elevenlabsConfig = Get-Content (Join-Path $PSScriptRoot "..\config\elevenlabs.json") | ConvertFrom-Json
            
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
                    
                    # Play audio
                    Play-AudioFile -FilePath $tempAudioFile
                    
                    # Cleanup
                    Start-Sleep -Seconds 1
                    Remove-Item $tempAudioFile -ErrorAction SilentlyContinue
                    
                    return
                }
            }
            
            # Fallback to Windows TTS
            Write-Host "[TTS] Using Windows built-in TTS" -ForegroundColor Yellow
            Add-Type -AssemblyName System.Speech
            $voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
            $voice.Rate = 2
            $voice.Volume = 100
            $voice.Speak($Text)
            $voice.Dispose()
            
        } catch {
            Write-Host "[TTS] Speech failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Announce readiness
    Speak-Text "Hello! I'm your conversational voice assistant. Say $WakeWord and then tell me what you'd like to talk about or do."
    
    # Main conversation loop
    $keepListening = $true
    $conversationCount = 0
    
    while ($keepListening) {
        try {
            Write-Host "[LISTENING] Say '$WakeWord' followed by your message..." -ForegroundColor Green
            
            # Listen for speech
            $result = $recognizer.Recognize([System.TimeSpan]::FromSeconds(30))
            
            if ($result -and $result.Text -and $result.Text.Trim() -ne "") {
                $fullText = $result.Text.Trim()
                $confidence = $result.Confidence
                $conversationCount++
                
                Write-Host "[VOICE $conversationCount] Heard: '$fullText' (Confidence: $([math]::Round($confidence * 100, 1))%)" -ForegroundColor Green
                
                # Check if it contains the wake word
                if ($fullText.ToLower().Contains($WakeWord.ToLower())) {
                    
                    # Extract everything after the wake word
                    $wakeWordIndex = $fullText.ToLower().IndexOf($WakeWord.ToLower())
                    $userInput = $fullText.Substring($wakeWordIndex + $WakeWord.Length).Trim()
                    
                    if ($userInput -and $userInput -ne "") {
                        Write-Host "[PROCESSING] User said: '$userInput'" -ForegroundColor Cyan
                        
                        # Check for quick actions first
                        $quickActionFound = $false
                        foreach ($action in $quickActions.Keys) {
                            if ($userInput.ToLower().Contains($action)) {
                                $scriptName = $quickActions[$action]
                                $scriptPath = Join-Path $PSScriptRoot $scriptName
                                
                                if (Test-Path $scriptPath) {
                                    Write-Host "[QUICK ACTION] Executing: $scriptName" -ForegroundColor Yellow
                                    try {
                                        & $scriptPath
                                        Write-Host "[SUCCESS] Quick action completed!" -ForegroundColor Green
                                        $quickActionFound = $true
                                        break
                                    } catch {
                                        Write-Host "[ERROR] Quick action failed: $($_.Exception.Message)" -ForegroundColor Red
                                        Speak-Text "Sorry, there was an error with that command."
                                    }
                                }
                            }
                        }
                        
                        # Check for exit commands
                        if ($userInput.ToLower() -match "\b(goodbye|bye|exit|quit|stop)\b") {
                            Write-Host "[CONVERSATION] Ending conversation..." -ForegroundColor Yellow
                            Speak-Text "Goodbye! It was nice talking with you."
                            $keepListening = $false
                            break
                        }
                        
                        # If no quick action, route to AI for conversation
                        if (-not $quickActionFound) {
                            Write-Host "[AI CONVERSATION] Routing to AI: '$userInput'" -ForegroundColor Magenta
                            try {
                                & "$PSScriptRoot/converse-with-ai.ps1" -UserInputText $userInput
                                Write-Host "[AI] Conversation completed!" -ForegroundColor Green
                            } catch {
                                Write-Host "[ERROR] AI conversation failed: $($_.Exception.Message)" -ForegroundColor Red
                                Speak-Text "I'm sorry, I'm having trouble thinking right now. Could you try asking again?"
                            }
                        }
                        
                    } else {
                        # Just wake word
                        Write-Host "[WAKE] Wake word detected, waiting for request..." -ForegroundColor Yellow
                        Speak-Text "Yes? What can I help you with?"
                    }
                    
                } else {
                    # No wake word detected
                    Write-Host "[IGNORE] No wake word detected in: '$fullText'" -ForegroundColor Gray
                }
                
                Write-Host "" # Add spacing
                
            } else {
                # No clear speech detected
                Write-Host "[TIMEOUT] No clear speech detected, still listening..." -ForegroundColor Gray
            }
            
        } catch {
            Write-Host "[ERROR] Recognition error: $($_.Exception.Message)" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
        
        # Break for test mode
        if ($Test -and $conversationCount -gt 0) {
            Write-Host "[TEST] Test mode - exiting after first interaction" -ForegroundColor Yellow
            break
        }
    }
    
    # Cleanup
    $recognizer.Dispose()
    Write-Host "[STOP] Conversational voice assistant stopped." -ForegroundColor Yellow
    
} catch {
    Write-Host "[ERROR] Voice assistant failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure you have a microphone connected and working." -ForegroundColor Yellow
    exit 1
}