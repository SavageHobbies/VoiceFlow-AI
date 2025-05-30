<#
.SYNOPSIS
    Perfect Voice Assistant for WinAssistAI
.DESCRIPTION
    Fixed speech recognition to capture wake words and silent audio playback
#>

param(
    [switch]$Test,
    [string]$WakeWord = ""
)

# Import shared functions
. (Join-Path $PSScriptRoot "_shared-functions.ps1")

Write-Host "=== WinAssistAI Perfect Voice Assistant ===" -ForegroundColor Cyan
Write-Host ""

# Load .NET Speech Recognition assemblies
Add-Type -AssemblyName System.Speech

try {
    # Get wake word from .env if not specified
    if (-not $WakeWord) {
        $WakeWord = Get-EnvVariable -KeyName "WAKE_WORD" -DefaultValue "Ash"
    }
    
    Write-Host "[SETUP] Configuring perfect voice assistant..." -ForegroundColor Yellow
    Write-Host "Wake word: $WakeWord" -ForegroundColor Cyan
    
    # Create speech recognition engine with better settings
    $recognizer = New-Object System.Speech.Recognition.SpeechRecognitionEngine
    
    # Create a custom grammar that includes the wake word
    $grammarBuilder = New-Object System.Speech.Recognition.GrammarBuilder
    
    # First create a choice for wake word variations
    $wakeWordChoices = New-Object System.Speech.Recognition.Choices
    $wakeWordChoices.Add($WakeWord)
    $wakeWordChoices.Add($WakeWord.ToLower())
    $wakeWordChoices.Add($WakeWord.ToUpper())
    
    # Add the wake word as required
    $grammarBuilder.Append($wakeWordChoices)
    
    # Then add optional additional words
    $additionalWords = New-Object System.Speech.Recognition.Choices
    
    # Add common command words
    $commands = @(
        "hello", "hi", "hey", "hello there", "hi there",
        "calculator", "calc", "open calculator", "open calc",
        "time", "what time is it", "what's the time", "clock",
        "weather", "check weather", "what's the weather",
        "screenshot", "take screenshot", "screen shot",
        "goodbye", "bye", "good bye", "see you later",
        "thank you", "thanks", "thank you very much",
        "help", "help me", "I need help",
        "stop", "stop listening", "exit", "quit"
    )
    
    # Add conversational starters
    $conversations = @(
        "tell me about", "what is", "what are", "how do I", "how to",
        "explain", "help me with", "I need help with", "can you help me",
        "please help me", "I want to know about", "tell me",
        "what do you think about", "how does", "why is", "why are",
        "where is", "where are", "when is", "when was"
    )
    
    # Add all to choices
    foreach ($cmd in $commands) { $additionalWords.Add($cmd) }
    foreach ($conv in $conversations) { $additionalWords.Add($conv) }
    
    # Make additional words optional and repeatable
    $optionalPhrase = New-Object System.Speech.Recognition.GrammarBuilder($additionalWords, 0, 10)
    $grammarBuilder.Append($optionalPhrase)
    
    # Create and load the grammar
    $customGrammar = New-Object System.Speech.Recognition.Grammar($grammarBuilder)
    $recognizer.LoadGrammar($customGrammar)
    
    # Set input to default microphone with optimal settings
    $recognizer.SetInputToDefaultAudioDevice()
    $recognizer.BabbleTimeout = [System.TimeSpan]::FromSeconds(0)
    $recognizer.InitialSilenceTimeout = [System.TimeSpan]::FromSeconds(30)
    $recognizer.EndSilenceTimeout = [System.TimeSpan]::FromSeconds(1.5)
    
    Write-Host "[START] Starting perfect voice assistant..." -ForegroundColor Green
    Write-Host "Say '$WakeWord' followed by your request" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor White
    Write-Host "  '$WakeWord hello'" -ForegroundColor Gray
    Write-Host "  '$WakeWord calculator'" -ForegroundColor Gray
    Write-Host "  '$WakeWord what time is it'" -ForegroundColor Gray
    Write-Host "  '$WakeWord tell me about space'" -ForegroundColor Gray
    Write-Host "  '$WakeWord goodbye'" -ForegroundColor Gray
    Write-Host ""
    
    # Quick action mapping
    $quickActions = @{
        "calculator" = "open-calculator.ps1"
        "calc" = "open-calculator.ps1"
        "time" = "what-time-is-it.ps1"
        "clock" = "what-time-is-it.ps1"
        "weather" = "check-weather.ps1"
        "screenshot" = "take-screenshot.ps1"
        "hello" = "hello.ps1"
        "hi" = "hello.ps1"
        "hey" = "hello.ps1"
        "goodbye" = "good-bye.ps1"
        "bye" = "good-bye.ps1"
        "thanks" = "thank-you.ps1"
        "thank you" = "thank-you.ps1"
        "help" = "i-need-help.ps1"
    }
    
    # Function for silent audio playback
    function Play-AudioSilently {
        param([string]$FilePath)
        
        Write-Host "[AUDIO] Playing audio silently..." -ForegroundColor Green
        
        # Method 1: PowerShell MediaPlayer (most reliable and silent)
        try {
            Add-Type -AssemblyName presentationCore
            $mediaPlayer = New-Object System.Windows.Media.MediaPlayer
            $mediaPlayer.Volume = 1.0
            $mediaPlayer.Open([System.Uri]::new($FilePath))
            $mediaPlayer.Play()
            
            # Wait for audio duration
            $timeout = 0
            while ($mediaPlayer.NaturalDuration.TimeSpan.TotalSeconds -eq 0 -and $timeout -lt 50) {
                Start-Sleep -Milliseconds 100
                $timeout++
            }
            
            if ($mediaPlayer.NaturalDuration.TimeSpan.TotalSeconds -gt 0) {
                $duration = $mediaPlayer.NaturalDuration.TimeSpan.TotalSeconds
                Start-Sleep -Seconds ($duration + 0.5)  # Wait for full playback
                Write-Host "[AUDIO] Played silently for $([math]::Round($duration, 1)) seconds" -ForegroundColor Green
                $mediaPlayer.Close()
                return $true
            }
            
            $mediaPlayer.Close()
        } catch {
            Write-Host "[AUDIO] MediaPlayer failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Method 2: Hidden Windows Media Player
        try {
            $startInfo = New-Object System.Diagnostics.ProcessStartInfo
            $startInfo.FileName = "wmplayer.exe"
            $startInfo.Arguments = "/play /close `"$FilePath`""
            $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
            $startInfo.CreateNoWindow = $true
            
            $process = [System.Diagnostics.Process]::Start($startInfo)
            Start-Sleep -Seconds 4  # Wait for playback
            
            if (-not $process.HasExited) {
                $process.Kill()
            }
            
            Write-Host "[AUDIO] Played with hidden Windows Media Player" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "[AUDIO] Hidden WMP failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Method 3: Windows TTS fallback
        try {
            Write-Host "[AUDIO] Falling back to Windows TTS" -ForegroundColor Yellow
            Add-Type -AssemblyName System.Speech
            $voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
            $voice.Rate = 2
            $voice.Volume = 100
            $voice.Speak("Audio playback failed, using text to speech instead")
            $voice.Dispose()
            return $true
        } catch {
            Write-Host "[AUDIO] All audio methods failed" -ForegroundColor Red
            return $false
        }
    }
    
    # Function to speak text with ElevenLabs
    function Speak-Text {
        param([string]$Text)
        
        try {
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
                    
                    # Download audio silently
                    Invoke-RestMethod -Uri $ttsUrl -Headers $headers -Method Post -Body $body -OutFile $tempAudioFile -TimeoutSec 30
                    
                    # Play audio silently
                    Play-AudioSilently -FilePath $tempAudioFile
                    
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
    Speak-Text "Perfect voice assistant ready. Say $WakeWord followed by your command."
    
    # Main conversation loop
    $keepListening = $true
    $conversationCount = 0
    
    while ($keepListening) {
        try {
            Write-Host "[LISTENING] Say '$WakeWord <command>'..." -ForegroundColor Green
            
            # Listen for speech
            $result = $recognizer.Recognize([System.TimeSpan]::FromSeconds(15))
            
            if ($result -and $result.Text -and $result.Text.Trim() -ne "") {
                $fullText = $result.Text.Trim()
                $confidence = $result.Confidence
                $conversationCount++
                
                Write-Host "[VOICE $conversationCount] COMPLETE TEXT: '$fullText' (Confidence: $([math]::Round($confidence * 100, 1))%)" -ForegroundColor Green
                
                # The grammar ensures this starts with wake word, so extract command
                if ($fullText.StartsWith($WakeWord, [System.StringComparison]::InvariantCultureIgnoreCase)) {
                    $userInput = $fullText.Substring($WakeWord.Length).Trim()
                    
                    Write-Host "[SUCCESS] Wake word detected! Command: '$userInput'" -ForegroundColor Yellow
                    
                    if ($userInput -and $userInput -ne "") {
                        # Check for exit commands
                        if ($userInput.ToLower() -match "\b(goodbye|bye|exit|quit|stop)\b") {
                            Write-Host "[CONVERSATION] Ending conversation..." -ForegroundColor Yellow
                            Speak-Text "Goodbye! It was nice talking with you."
                            $keepListening = $false
                            break
                        }
                        
                        # Check for quick actions
                        $quickActionFound = $false
                        foreach ($action in $quickActions.Keys) {
                            if ($userInput.ToLower().Contains($action)) {
                                $scriptName = $quickActions[$action]
                                $scriptPath = Join-Path $PSScriptRoot $scriptName
                                
                                if (Test-Path $scriptPath) {
                                    Write-Host "[QUICK ACTION] Executing: $scriptName" -ForegroundColor Cyan
                                    try {
                                        & $scriptPath
                                        Write-Host "[SUCCESS] Quick action '$scriptName' completed!" -ForegroundColor Green
                                        $quickActionFound = $true
                                        break
                                    } catch {
                                        Write-Host "[ERROR] Quick action failed: $($_.Exception.Message)" -ForegroundColor Red
                                        Speak-Text "Sorry, there was an error with that command."
                                    }
                                }
                            }
                        }
                        
                        # If no quick action, route to AI
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
                        Write-Host "[WAKE] Just wake word detected" -ForegroundColor Yellow
                        Speak-Text "Yes? What can I help you with?"
                    }
                } else {
                    Write-Host "[ERROR] Grammar should have ensured wake word - this shouldn't happen" -ForegroundColor Red
                }
                
                Write-Host "" # Add spacing
                
            } else {
                # No recognition
                Write-Host "[TIMEOUT] No speech detected, continuing..." -ForegroundColor Gray
            }
            
        } catch {
            Write-Host "[ERROR] Recognition error: $($_.Exception.Message)" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
        
        # Break for test mode
        if ($Test -and $conversationCount -gt 0) {
            Write-Host "[TEST] Test mode - exiting after first recognition" -ForegroundColor Yellow
            break
        }
    }
    
    # Cleanup
    $recognizer.Dispose()
    Write-Host "[STOP] Perfect voice assistant stopped." -ForegroundColor Yellow
    
} catch {
    Write-Host "[ERROR] Voice assistant failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure you have a microphone connected and working." -ForegroundColor Yellow
    exit 1
}