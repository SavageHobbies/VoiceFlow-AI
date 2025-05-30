<#
.SYNOPSIS
    Start WinAssistAI with Native Windows Speech Recognition
.DESCRIPTION
    This script starts WinAssistAI using native Windows Speech Recognition (System.Speech)
    which is more reliable than Serenade for voice commands.
.NOTES
    This uses built-in Windows features - no external software required!
#>

param(
    [switch]$Setup,
    [switch]$Test,
    [string]$WakeWord = ""
)

# Import shared functions
. (Join-Path $PSScriptRoot "_shared-functions.ps1")

Write-Host "=== WinAssistAI Native Voice Control ===" -ForegroundColor Cyan
Write-Host "Using Windows Built-in Speech Recognition" -ForegroundColor Green
Write-Host ""

# Load .NET Speech Recognition assemblies
Add-Type -AssemblyName System.Speech

try {
    # Get wake word from .env if not specified
    if (-not $WakeWord) {
        $WakeWord = Get-EnvVariable -KeyName "WAKE_WORD" -DefaultValue "Ash"
    }
    
    Write-Host "[SETUP] Configuring voice recognition..." -ForegroundColor Yellow
    Write-Host "Wake word: $WakeWord" -ForegroundColor Cyan
    
    # Create speech recognition engine
    $recognizer = New-Object System.Speech.Recognition.SpeechRecognitionEngine
    
    # Build grammar for commands
    $grammarBuilder = New-Object System.Speech.Recognition.GrammarBuilder
    
    # Create choices for commands
    $commands = New-Object System.Speech.Recognition.Choices
    
    # Add basic commands
    $commands.Add("$WakeWord hello")
    $commands.Add("$WakeWord hi")
    $commands.Add("$WakeWord good morning")
    $commands.Add("$WakeWord good evening")
    $commands.Add("$WakeWord what time is it")
    $commands.Add("$WakeWord check weather")
    $commands.Add("$WakeWord open calculator")
    $commands.Add("$WakeWord take screenshot")
    $commands.Add("$WakeWord thank you")
    $commands.Add("$WakeWord goodbye")
    $commands.Add("$WakeWord play music")
    $commands.Add("$WakeWord empty recycle bin")
    $commands.Add("$WakeWord help")
    $commands.Add("$WakeWord stop listening")
    
    # Add AI conversation commands
    $commands.Add("$WakeWord what is the weather")
    $commands.Add("$WakeWord tell me a joke")
    $commands.Add("$WakeWord what is the time")
    
    # Build and load grammar
    $grammarBuilder.Append($commands)
    $grammar = New-Object System.Speech.Recognition.Grammar($grammarBuilder)
    $recognizer.LoadGrammar($grammar)
    
    # Set input to default microphone
    $recognizer.SetInputToDefaultAudioDevice()
    
    # Store variables for use in event handler
    $scriptRoot = $PSScriptRoot
    $currentWakeWord = $WakeWord
    
    # Add event handler for speech recognition
    $speechRecognized = Register-ObjectEvent -InputObject $recognizer -EventName "SpeechRecognized" -Action {
        $result = $Event.SourceEventArgs.Result
        $text = $result.Text
        $confidence = $result.Confidence
        
        Write-Host "[VOICE] Recognized: '$text' (Confidence: $([math]::Round($confidence * 100, 1))%)" -ForegroundColor Green
        
        # Extract command after wake word (use variables from outer scope)
        $wakeWordPattern = "^$using:currentWakeWord\s+"
        if ($text -match $wakeWordPattern) {
            $command = $text -replace $wakeWordPattern, ""
            
            # Map voice commands to script names
            $commandMap = @{
                "hello" = "hello.ps1"
                "hi" = "hello.ps1"
                "good morning" = "good-morning.ps1"
                "good evening" = "good-evening.ps1"
                "what time is it" = "what-time-is-it.ps1"
                "what is the time" = "what-time-is-it.ps1"
                "check weather" = "check-weather.ps1"
                "what is the weather" = "check-weather.ps1"
                "open calculator" = "open-calculator.ps1"
                "take screenshot" = "take-screenshot.ps1"
                "thank you" = "thank-you.ps1"
                "goodbye" = "good-bye.ps1"
                "play music" = "play-rock-music.ps1"
                "empty recycle bin" = "empty-recycle-bin.ps1"
                "help" = "i-need-help.ps1"
                "tell me a joke" = "tell-me-a-joke.ps1"
                "stop listening" = "STOP"
            }
            
            if ($commandMap.ContainsKey($command)) {
                $scriptName = $commandMap[$command]
                
                if ($scriptName -eq "STOP") {
                    Write-Host "[VOICE] Stopping voice recognition..." -ForegroundColor Yellow
                    & "$using:scriptRoot/say.ps1" "Voice recognition stopped. Goodbye!"
                    $Global:StopListening = $true
                    return
                }
                
                $scriptPath = Join-Path $using:scriptRoot $scriptName
                if (Test-Path $scriptPath) {
                    Write-Host "[EXEC] Running: $scriptName" -ForegroundColor Cyan
                    try {
                        & $scriptPath
                    } catch {
                        Write-Host "[ERROR] Failed to execute $scriptName : $($_.Exception.Message)" -ForegroundColor Red
                        & "$using:scriptRoot/say.ps1" "Sorry, there was an error running that command."
                    }
                } else {
                    Write-Host "[ERROR] Script not found: $scriptPath" -ForegroundColor Red
                    & "$using:scriptRoot/say.ps1" "Sorry, I don't know how to do that yet."
                }
            } else {
                # Route unknown commands to AI
                Write-Host "[AI] Routing to AI: $command" -ForegroundColor Magenta
                try {
                    & "$using:scriptRoot/converse-with-ai.ps1" -UserInputText $command
                } catch {
                    Write-Host "[ERROR] AI conversation failed: $($_.Exception.Message)" -ForegroundColor Red
                    & "$using:scriptRoot/say.ps1" "Sorry, I couldn't process that request."
                }
            }
        }
    }
    
    # Test mode
    if ($Test) {
        Write-Host "[TEST] Testing speech recognition..." -ForegroundColor Yellow
        & "$PSScriptRoot/say.ps1" "Voice recognition test mode. Say '$WakeWord hello' to test."
        
        $recognizer.RecognizeAsync([System.Speech.Recognition.RecognizeMode]::Multiple)
        Write-Host "Listening for 10 seconds..." -ForegroundColor Green
        Start-Sleep -Seconds 10
        $recognizer.RecognizeAsyncStop()
        
        Write-Host "[TEST] Test completed." -ForegroundColor Green
        return
    }
    
    # Start continuous recognition
    Write-Host "[START] Starting voice recognition..." -ForegroundColor Green
    Write-Host "Say '$WakeWord' followed by a command" -ForegroundColor White
    Write-Host "Available commands:" -ForegroundColor White
    Write-Host "  - hello, hi, good morning" -ForegroundColor Gray
    Write-Host "  - what time is it, check weather" -ForegroundColor Gray
    Write-Host "  - open calculator, take screenshot" -ForegroundColor Gray
    Write-Host "  - thank you, goodbye, help" -ForegroundColor Gray
    Write-Host "  - tell me a joke, play music" -ForegroundColor Gray
    Write-Host "  - stop listening (to exit)" -ForegroundColor Gray
    Write-Host ""
    
    & "$PSScriptRoot/say.ps1" "Voice recognition is now active. Say $WakeWord followed by a command."
    
    # Start recognition
    $recognizer.RecognizeAsync([System.Speech.Recognition.RecognizeMode]::Multiple)
    
    # Keep running until stop command
    $Global:StopListening = $false
    while (-not $Global:StopListening) {
        Start-Sleep -Seconds 1
    }
    
    # Cleanup
    $recognizer.RecognizeAsyncStop()
    Unregister-Event -SourceIdentifier $speechRecognized.Name
    $recognizer.Dispose()
    
    Write-Host "[STOP] Voice recognition stopped." -ForegroundColor Yellow
    
} catch {
    Write-Host "[ERROR] Voice recognition failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure you have a microphone connected and working." -ForegroundColor Yellow
    exit 1
}