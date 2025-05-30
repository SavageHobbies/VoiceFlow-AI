<#
.SYNOPSIS
    Simple and reliable voice control for WinAssistAI
.DESCRIPTION
    Uses Windows Speech Recognition without complex event handlers
#>

param(
    [switch]$Test,
    [string]$WakeWord = ""
)

# Import shared functions
. (Join-Path $PSScriptRoot "_shared-functions.ps1")

Write-Host "=== WinAssistAI Voice Control (Simple) ===" -ForegroundColor Cyan
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
    
    # Add basic commands with wake word
    $commands.Add("$WakeWord hello")
    $commands.Add("$WakeWord hi")
    $commands.Add("$WakeWord what time is it")
    $commands.Add("$WakeWord check weather")
    $commands.Add("$WakeWord open calculator")
    $commands.Add("$WakeWord take screenshot")
    $commands.Add("$WakeWord thank you")
    $commands.Add("$WakeWord goodbye")
    $commands.Add("$WakeWord tell me a joke")
    $commands.Add("$WakeWord stop listening")
    
    # Build and load grammar
    $grammarBuilder.Append($commands)
    $grammar = New-Object System.Speech.Recognition.Grammar($grammarBuilder)
    $recognizer.LoadGrammar($grammar)
    
    # Set input to default microphone
    $recognizer.SetInputToDefaultAudioDevice()
    
    Write-Host "[START] Starting voice recognition..." -ForegroundColor Green
    Write-Host "Say '$WakeWord' followed by a command" -ForegroundColor White
    Write-Host "Available commands:" -ForegroundColor White
    Write-Host "  - hello, hi" -ForegroundColor Gray
    Write-Host "  - what time is it, check weather" -ForegroundColor Gray
    Write-Host "  - open calculator, take screenshot" -ForegroundColor Gray
    Write-Host "  - thank you, goodbye" -ForegroundColor Gray
    Write-Host "  - tell me a joke" -ForegroundColor Gray
    Write-Host "  - stop listening (to exit)" -ForegroundColor Gray
    Write-Host ""
    
    # Announce readiness
    & "$PSScriptRoot/say-enhanced.ps1" "Voice control is ready. Say $WakeWord followed by a command."
    
    # Command mapping
    $commandMap = @{
        "$WakeWord hello" = "hello.ps1"
        "$WakeWord hi" = "hello.ps1"
        "$WakeWord what time is it" = "what-time-is-it.ps1"
        "$WakeWord check weather" = "check-weather.ps1"
        "$WakeWord open calculator" = "open-calculator.ps1"
        "$WakeWord take screenshot" = "take-screenshot.ps1"
        "$WakeWord thank you" = "thank-you.ps1"
        "$WakeWord goodbye" = "good-bye.ps1"
        "$WakeWord tell me a joke" = "tell-me-a-joke.ps1"
        "$WakeWord stop listening" = "STOP"
    }
    
    # Main recognition loop
    $keepListening = $true
    while ($keepListening) {
        try {
            # Listen for one command
            $result = $recognizer.Recognize([System.TimeSpan]::FromSeconds(30))
            
            if ($result -and $result.Text) {
                $text = $result.Text
                $confidence = $result.Confidence
                
                Write-Host "[VOICE] Recognized: '$text' (Confidence: $([math]::Round($confidence * 100, 1))%)" -ForegroundColor Green
                
                if ($commandMap.ContainsKey($text)) {
                    $scriptName = $commandMap[$text]
                    
                    if ($scriptName -eq "STOP") {
                        Write-Host "[VOICE] Stopping voice recognition..." -ForegroundColor Yellow
                        & "$PSScriptRoot/say-enhanced.ps1" "Voice recognition stopped. Goodbye!"
                        $keepListening = $false
                        break
                    }
                    
                    $scriptPath = Join-Path $PSScriptRoot $scriptName
                    if (Test-Path $scriptPath) {
                        Write-Host "[EXEC] Running: $scriptName" -ForegroundColor Cyan
                        try {
                            & $scriptPath
                            Write-Host "[SUCCESS] Command completed successfully" -ForegroundColor Green
                        } catch {
                            Write-Host "[ERROR] Failed to execute $scriptName : $($_.Exception.Message)" -ForegroundColor Red
                            & "$PSScriptRoot/say-enhanced.ps1" "Sorry, there was an error running that command."
                        }
                    } else {
                        Write-Host "[ERROR] Script not found: $scriptPath" -ForegroundColor Red
                        & "$PSScriptRoot/say-enhanced.ps1" "Sorry, I don't know how to do that yet."
                    }
                } else {
                    Write-Host "[INFO] Command not recognized, trying AI..." -ForegroundColor Yellow
                    # Try to extract command after wake word for AI
                    if ($text.StartsWith($WakeWord)) {
                        $query = $text.Substring($WakeWord.Length).Trim()
                        if ($query) {
                            Write-Host "[AI] Routing to AI: $query" -ForegroundColor Magenta
                            try {
                                & "$PSScriptRoot/converse-with-ai.ps1" -UserInputText $query
                            } catch {
                                Write-Host "[ERROR] AI conversation failed: $($_.Exception.Message)" -ForegroundColor Red
                                & "$PSScriptRoot/say-enhanced.ps1" "Sorry, I couldn't process that request."
                            }
                        }
                    }
                }
                
                Write-Host "" # Add spacing between commands
            } else {
                # Timeout or no recognition - just continue listening
                Write-Host "[LISTEN] Listening..." -ForegroundColor Gray
            }
            
        } catch {
            Write-Host "[ERROR] Recognition error: $($_.Exception.Message)" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
        
        # Break for test mode
        if ($Test) {
            Write-Host "[TEST] Test mode - exiting after first recognition" -ForegroundColor Yellow
            break
        }
    }
    
    # Cleanup
    $recognizer.Dispose()
    Write-Host "[STOP] Voice recognition stopped." -ForegroundColor Yellow
    
} catch {
    Write-Host "[ERROR] Voice recognition failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure you have a microphone connected and working." -ForegroundColor Yellow
    exit 1
}