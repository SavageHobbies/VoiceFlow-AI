<#
.SYNOPSIS
    Ultimate Voice Assistant for WinAssistAI
.DESCRIPTION
    Fixed audio playback and improved single command recognition
#>

param(
    [switch]$Test,
    [string]$WakeWord = ""
)

# Import shared functions
. (Join-Path $PSScriptRoot "_shared-functions.ps1")

Write-Host "=== WinAssistAI Ultimate Voice Assistant ===" -ForegroundColor Cyan
Write-Host ""

# Load .NET Speech Recognition assemblies
Add-Type -AssemblyName System.Speech

try {
    # Get wake word from .env if not specified
    if (-not $WakeWord) {
        $WakeWord = Get-EnvVariable -KeyName "WAKE_WORD" -DefaultValue "Ash"
    }
    
    Write-Host "[SETUP] Configuring ultimate voice assistant..." -ForegroundColor Yellow
    Write-Host "Wake word: $WakeWord" -ForegroundColor Cyan
    
    # Create speech recognition engine
    $recognizer = New-Object System.Speech.Recognition.SpeechRecognitionEngine
    
    # Create simple grammar for wake word + single command
    $grammarBuilder = New-Object System.Speech.Recognition.GrammarBuilder
    
    # Add wake word
    $wakeWordChoices = New-Object System.Speech.Recognition.Choices
    $wakeWordChoices.Add($WakeWord)
    $grammarBuilder.Append($wakeWordChoices)
    
    # Add single command choices (limited to prevent long phrases)
    $singleCommands = New-Object System.Speech.Recognition.Choices
    $commands = @(
        "hello", "hi", "hey there",
        "calculator", "calc", "open calculator",
        "time", "what time is it", "clock",
        "weather", "check weather", "what's the weather",
        "screenshot", "take screenshot",
        "goodbye", "bye", "good bye",
        "thanks", "thank you",
        "help", "help me",
        "stop", "stop listening", "exit"
    )
    
    foreach ($cmd in $commands) {
        $singleCommands.Add($cmd)
    }
    
    $grammarBuilder.Append($singleCommands)
    
    # Create and load grammar
    $customGrammar = New-Object System.Speech.Recognition.Grammar($grammarBuilder)
    $recognizer.LoadGrammar($customGrammar)
    
    # Set input with shorter timeout to prevent long phrases
    $recognizer.SetInputToDefaultAudioDevice()
    $recognizer.BabbleTimeout = [System.TimeSpan]::FromSeconds(0)
    $recognizer.InitialSilenceTimeout = [System.TimeSpan]::FromSeconds(10)
    $recognizer.EndSilenceTimeout = [System.TimeSpan]::FromSeconds(0.8)  # Shorter to catch single commands
    
    Write-Host "[START] Starting ultimate voice assistant..." -ForegroundColor Green
    Write-Host "Say '$WakeWord' followed by ONE command at a time" -ForegroundColor White
    Write-Host ""
    Write-Host "Single Commands:" -ForegroundColor White
    Write-Host "  '$WakeWord hello'" -ForegroundColor Gray
    Write-Host "  '$WakeWord calculator'" -ForegroundColor Gray
    Write-Host "  '$WakeWord time'" -ForegroundColor Gray
    Write-Host "  '$WakeWord weather'" -ForegroundColor Gray
    Write-Host "  '$WakeWord goodbye'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "For longer conversations, start with '$WakeWord help me'" -ForegroundColor Yellow
    Write-Host ""
    
    # Quick action mapping
    $quickActions = @{
        "calculator" = "open-calculator.ps1"
        "calc" = "open-calculator.ps1"
        "open calculator" = "open-calculator.ps1"
        "time" = "what-time-is-it.ps1"
        "what time is it" = "what-time-is-it.ps1"
        "clock" = "what-time-is-it.ps1"
        "weather" = "check-weather.ps1"
        "check weather" = "check-weather.ps1"
        "what's the weather" = "check-weather.ps1"
        "screenshot" = "take-screenshot.ps1"
        "take screenshot" = "take-screenshot.ps1"
        "hello" = "hello.ps1"
        "hi" = "hello.ps1"
        "hey there" = "hello.ps1"
        "goodbye" = "good-bye.ps1"
        "bye" = "good-bye.ps1"
        "good bye" = "good-bye.ps1"
        "thanks" = "thank-you.ps1"
        "thank you" = "thank-you.ps1"
        "help" = "i-need-help.ps1"
        "help me" = "i-need-help.ps1"
    }
    
    # Function for reliable audio playback
    function Play-AudioReliably {
        param([string]$FilePath)
        
        Write-Host "[AUDIO] Playing audio..." -ForegroundColor Green
        
        # Method 1: PowerShell MediaPlayer (most reliable)
        try {
            Add-Type -AssemblyName presentationCore
            $mediaPlayer = New-Object System.Windows.Media.MediaPlayer
            $mediaPlayer.Volume = 1.0
            $mediaPlayer.Open([System.Uri]::new($FilePath))
            $mediaPlayer.Play()
            
            # Wait for duration
            $timeout = 0
            while ($mediaPlayer.NaturalDuration.TimeSpan.TotalSeconds -eq 0 -and $timeout -lt 50) {
                Start-Sleep -Milliseconds 100
                $timeout++
            }
            
            if ($mediaPlayer.NaturalDuration.TimeSpan.TotalSeconds -gt 0) {
                $duration = $mediaPlayer.NaturalDuration.TimeSpan.TotalSeconds
                Start-Sleep -Seconds ($duration + 0.5)
                Write-Host "[AUDIO] Played successfully ($([math]::Round($duration, 1))s)" -ForegroundColor Green
                $mediaPlayer.Close()
                return $true
            }
            $mediaPlayer.Close()
        } catch {
            Write-Host "[AUDIO] MediaPlayer failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Method 2: Windows built-in SoundPlayer
        try {
            Add-Type -AssemblyName System.Windows.Forms
            $player = New-Object System.Media.SoundPlayer
            $player.SoundLocation = $FilePath
            $player.PlaySync()
            Write-Host "[AUDIO] Played with SoundPlayer" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "[AUDIO] SoundPlayer failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Method 3: Start-Process with default handler
        try {
            $process = Start-Process -FilePath $FilePath -WindowStyle Hidden -PassThru
            Start-Sleep -Seconds 3
            if (-not $process.HasExited) {
                $process.CloseMainWindow()
            }
            Write-Host "[AUDIO] Played with default handler" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "[AUDIO] Default handler failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        Write-Host "[AUDIO] All audio methods failed" -ForegroundColor Red
        return $false
    }
    
    # Function to speak text with better audio handling
    function Speak-Text {
        param([string]$Text)
        
        try {
            Write-Host "[TTS] Speaking: '$Text'" -ForegroundColor Cyan
            
            # Try ElevenLabs first
            $elevenlabsConfig = Get-Content (Join-Path $PSScriptRoot "..\config\elevenlabs.json") | ConvertFrom-Json
            
            if ($elevenlabsConfig.enabled) {
                $apiKey = Get-EnvVariable -KeyName "ELEVENLABS_API_KEY"
                
                if ($apiKey) {
                    try {
                        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"
                        $tempAudioFile = Join-Path $env:TEMP "elevenlabs_audio_$timestamp.mp3"
                        
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
                        $success = Play-AudioReliably -FilePath $tempAudioFile
                        
                        # Cleanup
                        Start-Sleep -Seconds 1
                        Remove-Item $tempAudioFile -ErrorAction SilentlyContinue
                        
                        if ($success) {
                            return
                        }
                    } catch {
                        Write-Host "[TTS] ElevenLabs failed: $($_.Exception.Message)" -ForegroundColor Yellow
                    }
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
            Write-Host "[TTS] All speech methods failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Announce readiness
    Speak-Text "Ultimate voice assistant ready. Say $WakeWord followed by one command at a time."
    
    # Main conversation loop
    $keepListening = $true
    $conversationCount = 0
    
    while ($keepListening) {
        try {
            Write-Host "[LISTENING] Say '$WakeWord <single command>'..." -ForegroundColor Green
            
            # Listen for speech with shorter timeout
            $result = $recognizer.Recognize([System.TimeSpan]::FromSeconds(8))
            
            if ($result -and $result.Text -and $result.Text.Trim() -ne "") {
                $fullText = $result.Text.Trim()
                $confidence = $result.Confidence
                $conversationCount++
                
                Write-Host "[VOICE $conversationCount] Heard: '$fullText' (Confidence: $([math]::Round($confidence * 100, 1))%)" -ForegroundColor Green
                
                # Extract command after wake word
                if ($fullText.StartsWith($WakeWord, [System.StringComparison]::InvariantCultureIgnoreCase)) {
                    $userInput = $fullText.Substring($WakeWord.Length).Trim()
                    
                    Write-Host "[COMMAND] Processing: '$userInput'" -ForegroundColor Cyan
                    
                    if ($userInput -and $userInput -ne "") {
                        # Check for exit commands
                        if ($userInput.ToLower() -match "\b(goodbye|bye|exit|quit|stop)\b") {
                            Write-Host "[CONVERSATION] Ending conversation..." -ForegroundColor Yellow
                            Speak-Text "Goodbye! It was nice talking with you."
                            $keepListening = $false
                            break
                        }
                        
                        # Check for quick actions (exact match first)
                        $quickActionFound = $false
                        $lowerInput = $userInput.ToLower()
                        
                        if ($quickActions.ContainsKey($lowerInput)) {
                            $scriptName = $quickActions[$lowerInput]
                            $scriptPath = Join-Path $PSScriptRoot $scriptName
                            
                            if (Test-Path $scriptPath) {
                                Write-Host "[EXECUTE] Running: $scriptName" -ForegroundColor Yellow
                                try {
                                    & $scriptPath
                                    Write-Host "[SUCCESS] '$scriptName' completed!" -ForegroundColor Green
                                    $quickActionFound = $true
                                } catch {
                                    Write-Host "[ERROR] Execution failed: $($_.Exception.Message)" -ForegroundColor Red
                                    Speak-Text "Sorry, there was an error with that command."
                                }
                            }
                        }
                        
                        # If no quick action and it's "help me", start AI conversation
                        if (-not $quickActionFound -and $lowerInput.Contains("help")) {
                            Write-Host "[AI] Starting AI conversation mode..." -ForegroundColor Magenta
                            Speak-Text "Sure! What would you like help with? Just speak naturally after you hear the beep."
                            
                            # Switch to conversational mode temporarily
                            try {
                                Write-Host "[AI] Listening for your question..." -ForegroundColor Magenta
                                $aiResult = $recognizer.Recognize([System.TimeSpan]::FromSeconds(10))
                                
                                if ($aiResult -and $aiResult.Text) {
                                    $aiQuery = $aiResult.Text.Trim()
                                    Write-Host "[AI] Question: '$aiQuery'" -ForegroundColor Magenta
                                    
                                    & "$PSScriptRoot/converse-with-ai.ps1" -UserInputText $aiQuery
                                    Write-Host "[AI] Conversation completed!" -ForegroundColor Green
                                } else {
                                    Speak-Text "I didn't hear your question. Please try again with '$WakeWord help me'."
                                }
                            } catch {
                                Write-Host "[ERROR] AI conversation failed: $($_.Exception.Message)" -ForegroundColor Red
                                Speak-Text "Sorry, I'm having trouble with AI right now."
                            }
                        } elseif (-not $quickActionFound) {
                            # Unknown command
                            Write-Host "[UNKNOWN] Command not recognized: '$userInput'" -ForegroundColor Yellow
                            Speak-Text "I don't understand '$userInput'. Try '$WakeWord help' for available commands."
                        }
                        
                    } else {
                        # Just wake word
                        Write-Host "[WAKE] Just wake word detected" -ForegroundColor Yellow
                        Speak-Text "Yes? I'm listening for your command."
                    }
                } else {
                    Write-Host "[ERROR] This shouldn't happen - grammar should enforce wake word" -ForegroundColor Red
                }
                
                Write-Host "" # Add spacing
                
            } else {
                # No recognition
                Write-Host "[TIMEOUT] No speech detected, still listening..." -ForegroundColor Gray
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
    Write-Host "[STOP] Ultimate voice assistant stopped." -ForegroundColor Yellow
    
} catch {
    Write-Host "[ERROR] Voice assistant failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure you have a microphone connected and working." -ForegroundColor Yellow
    exit 1
}