<#
.SYNOPSIS
    WORKING Voice Assistant with Windows TTS that you can actually hear
.DESCRIPTION
    Uses Windows TTS that works and better speech recognition
#>

param(
    [switch]$Test,
    [string]$WakeWord = "Ash"
)

# Import shared functions
. (Join-Path $PSScriptRoot "_shared-functions.ps1")

Write-Host "=== WinAssistAI WORKING Voice Assistant ===" -ForegroundColor Green
Write-Host ""

# Load .NET Speech Recognition assemblies
Add-Type -AssemblyName System.Speech

try {
    Write-Host "[SETUP] Configuring WORKING voice assistant..." -ForegroundColor Yellow
    Write-Host "Wake word: $WakeWord" -ForegroundColor Cyan
    
    # Function to speak with Windows TTS (that actually works)
    function Speak-Text {
        param([string]$Text)
        
        try {
            Write-Host "[VOICE] Speaking with Windows TTS: '$Text'" -ForegroundColor Cyan
            
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
            $voice.Speak($Text)
            $voice.Dispose()
            
            Write-Host "[VOICE] ✅ Windows TTS completed successfully" -ForegroundColor Green
            
        } catch {
            Write-Host "[VOICE] ❌ Windows TTS failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Create speech recognition engine
    $recognizer = New-Object System.Speech.Recognition.SpeechRecognitionEngine
    
    # Create simple grammar for better recognition
    $grammarBuilder = New-Object System.Speech.Recognition.GrammarBuilder
    
    # Add wake word
    $wakeWordChoices = New-Object System.Speech.Recognition.Choices
    $wakeWordChoices.Add($WakeWord)
    $grammarBuilder.Append($wakeWordChoices)
    
    # Add specific commands
    $commands = New-Object System.Speech.Recognition.Choices
    $commandList = @(
        "hello",
        "calculator", 
        "time",
        "weather",
        "screenshot",
        "goodbye"
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
    $recognizer.EndSilenceTimeout = [System.TimeSpan]::FromSeconds(1.5)
    
    Write-Host "[START] Starting WORKING voice assistant..." -ForegroundColor Green
    Write-Host "Say '$WakeWord' followed by a command" -ForegroundColor White
    Write-Host ""
    Write-Host "Available commands:" -ForegroundColor White
    Write-Host "  hello, calculator, time, weather, screenshot, goodbye" -ForegroundColor Gray
    Write-Host ""
    
    # Command responses
    $responses = @{
        "hello" = "Hello! How can I help you today?"
        "calculator" = "Opening calculator for you."
        "time" = "Let me tell you the current time."
        "weather" = "Here's the weather information."
        "screenshot" = "Taking a screenshot now."
        "goodbye" = "Goodbye! Have a great day!"
    }
    
    # Announce readiness
    Speak-Text "Voice assistant ready. Say $WakeWord followed by your command."
    
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
                    
                    # Handle goodbye
                    if ($command -match "\bgoodbye\b") {
                        $response = $responses["goodbye"]
                        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
                        Speak-Text $response
                        $keepListening = $false
                        break
                    }
                    
                    # Handle specific commands
                    $actionTaken = $false
                    
                    if ($command -match "\bcalculator\b") {
                        $response = $responses["calculator"]
                        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
                        Write-Host "[ACTION] Opening Calculator..." -ForegroundColor Cyan
                        Speak-Text $response
                        Start-Process calc.exe
                        $actionTaken = $true
                    }
                    elseif ($command -match "\btime\b") {
                        $currentTime = Get-Date -Format "dddd, MMMM dd, yyyy 'at' h:mm tt"
                        $response = "The current time is $currentTime"
                        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
                        Speak-Text $response
                        $actionTaken = $true
                    }
                    elseif ($command -match "\bweather\b") {
                        $response = "I'd love to tell you the weather, but I need location services configured. For now, I can help with other tasks!"
                        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
                        Speak-Text $response
                        $actionTaken = $true
                    }
                    elseif ($command -match "\bscreenshot\b") {
                        $response = $responses["screenshot"]
                        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
                        Write-Host "[ACTION] Taking Screenshot..." -ForegroundColor Cyan
                        Speak-Text $response
                        
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
                    elseif ($command -match "\bhello\b") {
                        $response = $responses["hello"]
                        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
                        Speak-Text $response
                        $actionTaken = $true
                    }
                    
                    if (-not $actionTaken) {
                        $response = "I'm not sure how to help with '$command'. Try saying '$WakeWord' followed by: hello, calculator, time, weather, screenshot, or goodbye."
                        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
                        Speak-Text $response
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
    Write-Host "[STOP] Voice assistant stopped." -ForegroundColor Yellow
    
} catch {
    Write-Host "[ERROR] Voice assistant failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}