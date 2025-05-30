<#
.SYNOPSIS
    Clean Voice Assistant for WinAssistAI
.DESCRIPTION
    Single voice, clean audio, proper conversation responses
#>

param(
    [switch]$Test,
    [string]$WakeWord = ""
)

# Import shared functions
. (Join-Path $PSScriptRoot "_shared-functions.ps1")

Write-Host "=== WinAssistAI Clean Voice Assistant ===" -ForegroundColor Cyan
Write-Host ""

# Load .NET Speech Recognition assemblies
Add-Type -AssemblyName System.Speech

try {
    # Get wake word from .env if not specified
    if (-not $WakeWord) {
        $WakeWord = Get-EnvVariable -KeyName "WAKE_WORD" -DefaultValue "Ash"
    }
    
    Write-Host "[SETUP] Configuring clean voice assistant..." -ForegroundColor Yellow
    Write-Host "Wake word: $WakeWord" -ForegroundColor Cyan
    
    # Create speech recognition engine
    $recognizer = New-Object System.Speech.Recognition.SpeechRecognitionEngine
    
    # Create grammar for wake word + commands
    $grammarBuilder = New-Object System.Speech.Recognition.GrammarBuilder
    
    # Add wake word
    $wakeWordChoices = New-Object System.Speech.Recognition.Choices
    $wakeWordChoices.Add($WakeWord)
    $grammarBuilder.Append($wakeWordChoices)
    
    # Add commands
    $commands = New-Object System.Speech.Recognition.Choices
    $commandList = @(
        "hello", "hi", "hey",
        "calculator", "calc", "open calculator",
        "time", "what time is it", "clock",
        "weather", "check weather",
        "screenshot", "take screenshot",
        "goodbye", "bye",
        "thanks", "thank you",
        "help", "help me",
        "stop", "exit"
    )
    
    foreach ($cmd in $commandList) {
        $commands.Add($cmd)
    }
    
    $grammarBuilder.Append($commands)
    
    # Create and load grammar
    $customGrammar = New-Object System.Speech.Recognition.Grammar($grammarBuilder)
    $recognizer.LoadGrammar($customGrammar)
    
    # Set input
    $recognizer.SetInputToDefaultAudioDevice()
    $recognizer.EndSilenceTimeout = [System.TimeSpan]::FromSeconds(1)
    
    Write-Host "[START] Starting clean voice assistant..." -ForegroundColor Green
    Write-Host "Say '$WakeWord' followed by a command" -ForegroundColor White
    Write-Host ""
    Write-Host "Available commands:" -ForegroundColor White
    Write-Host "  hello, calculator, time, weather, screenshot, goodbye" -ForegroundColor Gray
    Write-Host ""
    
    # ElevenLabs function (only used by main assistant)
    function Speak-WithElevenLabs {
        param([string]$Text)
        
        try {
            Write-Host "[VOICE] Speaking: '$Text'" -ForegroundColor Cyan
            
            $apiKey = Get-EnvVariable -KeyName "ELEVENLABS_API_KEY"
            
            if ($apiKey) {
                $timestamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"
                $tempAudioFile = Join-Path $env:TEMP "voice_response_$timestamp.mp3"
                
                $headers = @{
                    "Accept" = "audio/mpeg"
                    "Content-Type" = "application/json"
                    "xi-api-key" = $apiKey
                }
                
                $body = @{
                    "text" = $Text
                    "model_id" = "eleven_monolingual_v1"
                    "voice_settings" = @{
                        "stability" = 0.7
                        "similarity_boost" = 0.85
                        "style" = 0.2
                        "use_speaker_boost" = $true
                    }
                } | ConvertTo-Json
                
                $ttsUrl = "https://api.elevenlabs.io/v1/text-to-speech/21m00Tcm4TlvDq8ikWAM"
                
                # Download audio
                Invoke-RestMethod -Uri $ttsUrl -Headers $headers -Method Post -Body $body -OutFile $tempAudioFile -TimeoutSec 30
                
                # Play with PowerShell MediaPlayer (silent)
                Add-Type -AssemblyName presentationCore
                $mediaPlayer = New-Object System.Windows.Media.MediaPlayer
                $mediaPlayer.Volume = 1.0
                $mediaPlayer.Open([System.Uri]::new($tempAudioFile))
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
                }
                
                $mediaPlayer.Close()
                Remove-Item $tempAudioFile -ErrorAction SilentlyContinue
                
                Write-Host "[VOICE] ElevenLabs audio completed" -ForegroundColor Green
                return
            }
        } catch {
            Write-Host "[VOICE] ElevenLabs failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Fallback to Windows TTS
        try {
            Add-Type -AssemblyName System.Speech
            $voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
            $voice.Rate = 2
            $voice.Volume = 100
            $voice.Speak($Text)
            $voice.Dispose()
            Write-Host "[VOICE] Windows TTS completed" -ForegroundColor Green
        } catch {
            Write-Host "[VOICE] All TTS failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Command responses (built-in to avoid script conflicts)
    $responses = @{
        "hello" = @("Hello! How can I help you today?", "Hi there! What can I do for you?", "Hey! I'm here to assist you.")
        "hi" = @("Hi! What would you like to do?", "Hello! How can I help?", "Hey there!")
        "hey" = @("Hey! What's up?", "Hi! How can I assist you?", "Hello!")
        "calculator" = @("Opening calculator for you.", "Calculator coming right up!", "Let me open the calculator.")
        "calc" = @("Opening calculator now.", "Calculator on the way!")
        "time" = @("Let me tell you the current time.", "Here's the time for you.")
        "weather" = @("Let me check the weather for you.", "Getting weather information now.")
        "screenshot" = @("Taking a screenshot now.", "Capturing your screen.", "Screenshot coming up!")
        "thanks" = @("You're welcome!", "Happy to help!", "My pleasure!", "Anytime!")
        "thank you" = @("You're very welcome!", "Glad I could help!", "No problem at all!")
        "goodbye" = @("Goodbye! Have a great day!", "See you later!", "Take care!")
        "bye" = @("Bye! Talk to you soon!", "See you next time!", "Goodbye!")
        "help" = @("I can help with calculator, time, weather, screenshots, and more. Just say my name followed by what you need!", "I'm here to help! Try saying 'Ash calculator' or 'Ash time' or ask me anything!")
    }
    
    # Announce readiness
    Speak-WithElevenLabs "Clean voice assistant ready. Say $WakeWord followed by your command."
    
    # Main loop
    $keepListening = $true
    $conversationCount = 0
    
    while ($keepListening) {
        try {
            Write-Host "[LISTENING] Say '$WakeWord <command>'..." -ForegroundColor Green
            
            $result = $recognizer.Recognize([System.TimeSpan]::FromSeconds(10))
            
            if ($result -and $result.Text -and $result.Text.Trim() -ne "") {
                $fullText = $result.Text.Trim()
                $confidence = $result.Confidence
                $conversationCount++
                
                Write-Host "[HEARD] '$fullText' (Confidence: $([math]::Round($confidence * 100, 1))%)" -ForegroundColor Green
                
                if ($fullText.StartsWith($WakeWord, [System.StringComparison]::InvariantCultureIgnoreCase)) {
                    $command = $fullText.Substring($WakeWord.Length).Trim().ToLower()
                    
                    Write-Host "[COMMAND] Processing: '$command'" -ForegroundColor Cyan
                    
                    if ($command -match "\b(goodbye|bye|exit|stop)\b") {
                        $response = $responses["goodbye"] | Get-Random
                        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
                        Speak-WithElevenLabs $response
                        $keepListening = $false
                        break
                    }
                    
                    # Handle commands with actions
                    $actionTaken = $false
                    
                    if ($command -match "\b(calculator|calc)\b") {
                        $response = $responses["calculator"] | Get-Random
                        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
                        Write-Host "[ACTION] Opening Calculator..." -ForegroundColor Cyan
                        Speak-WithElevenLabs $response
                        Start-Process calc.exe
                        $actionTaken = $true
                    }
                    elseif ($command -match "\b(time|clock)\b") {
                        $currentTime = Get-Date -Format "dddd, MMMM dd, yyyy 'at' h:mm tt"
                        $response = "The current time is $currentTime"
                        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
                        Speak-WithElevenLabs $response
                        $actionTaken = $true
                    }
                    elseif ($command -match "\bweather\b") {
                        $response = "I'd love to tell you the weather, but I need location services configured. For now, I can help with other tasks!"
                        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
                        Speak-WithElevenLabs $response
                        $actionTaken = $true
                    }
                    elseif ($command -match "\bscreenshot\b") {
                        $response = $responses["screenshot"] | Get-Random
                        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
                        Write-Host "[ACTION] Taking Screenshot..." -ForegroundColor Cyan
                        Speak-WithElevenLabs $response
                        
                        # Take screenshot
                        Add-Type -AssemblyName System.Windows.Forms
                        $screenshot = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
                        $bitmap = New-Object System.Drawing.Bitmap($screenshot.Width, $screenshot.Height)
                        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
                        $graphics.CopyFromScreen($screenshot.Location, [System.Drawing.Point]::Empty, $screenshot.Size)
                        $screenshotPath = Join-Path $env:USERPROFILE "Desktop\Screenshot_$(Get-Date -Format 'yyyyMMdd_HHmmss').png"
                        $bitmap.Save($screenshotPath, [System.Drawing.Imaging.ImageFormat]::Png)
                        $graphics.Dispose()
                        $bitmap.Dispose()
                        
                        $actionTaken = $true
                    }
                    elseif ($command -match "\b(hello|hi|hey)\b") {
                        $greetingKey = if ($command -match "\bhello\b") { "hello" } elseif ($command -match "\bhi\b") { "hi" } else { "hey" }
                        $response = $responses[$greetingKey] | Get-Random
                        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
                        Speak-WithElevenLabs $response
                        $actionTaken = $true
                    }
                    elseif ($command -match "\b(thanks|thank you)\b") {
                        $thanksKey = if ($command -match "\bthank you\b") { "thank you" } else { "thanks" }
                        $response = $responses[$thanksKey] | Get-Random
                        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
                        Speak-WithElevenLabs $response
                        $actionTaken = $true
                    }
                    elseif ($command -match "\bhelp\b") {
                        $response = $responses["help"] | Get-Random
                        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
                        Speak-WithElevenLabs $response
                        $actionTaken = $true
                    }
                    
                    if (-not $actionTaken) {
                        $response = "I'm not sure how to help with '$command'. Try saying 'Ash help' for available commands."
                        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
                        Speak-WithElevenLabs $response
                    }
                    
                    Write-Host "" # Spacing
                }
            } else {
                Write-Host "[TIMEOUT] No speech detected, continuing..." -ForegroundColor Gray
            }
            
        } catch {
            Write-Host "[ERROR] Recognition error: $($_.Exception.Message)" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
        
        if ($Test -and $conversationCount -gt 0) {
            Write-Host "[TEST] Test mode - exiting" -ForegroundColor Yellow
            break
        }
    }
    
    # Cleanup
    $recognizer.Dispose()
    Write-Host "[STOP] Clean voice assistant stopped." -ForegroundColor Yellow
    
} catch {
    Write-Host "[ERROR] Voice assistant failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}