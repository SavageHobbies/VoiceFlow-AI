<#
.SYNOPSIS
    Conversational Voice Assistant for WinAssistAI
.DESCRIPTION
    Provides natural conversation with AI integration and continuous listening
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
    
    # Build grammar for wake word + any phrase
    $grammarBuilder = New-Object System.Speech.Recognition.GrammarBuilder
    
    # Create pattern: WakeWord + anything
    $wakeWordChoice = New-Object System.Speech.Recognition.Choices
    $wakeWordChoice.Add($WakeWord)
    
    $grammarBuilder.Append($wakeWordChoice)
    $grammarBuilder.AppendWildcard() # Allow any text after wake word
    
    # Create and load grammar
    $grammar = New-Object System.Speech.Recognition.Grammar($grammarBuilder)
    $recognizer.LoadGrammar($grammar)
    
    # Set input to default microphone
    $recognizer.SetInputToDefaultAudioDevice()
    
    Write-Host "[START] Starting conversational voice assistant..." -ForegroundColor Green
    Write-Host "Say '$WakeWord' followed by anything you want to say" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor White
    Write-Host "  '$WakeWord hello' - Greeting" -ForegroundColor Gray
    Write-Host "  '$WakeWord what time is it' - Ask the time" -ForegroundColor Gray
    Write-Host "  '$WakeWord open calculator' - Open programs" -ForegroundColor Gray
    Write-Host "  '$WakeWord tell me about quantum physics' - Ask AI anything" -ForegroundColor Gray
    Write-Host "  '$WakeWord how was your day' - Casual conversation" -ForegroundColor Gray
    Write-Host "  '$WakeWord goodbye' - End conversation" -ForegroundColor Gray
    Write-Host ""
    
    # Command shortcuts (for quick actions)
    $quickCommands = @{
        "hello" = "hello.ps1"
        "hi" = "hello.ps1"
        "what time is it" = "what-time-is-it.ps1"
        "what's the time" = "what-time-is-it.ps1"
        "check weather" = "check-weather.ps1"
        "weather" = "check-weather.ps1"
        "open calculator" = "open-calculator.ps1"
        "calculator" = "open-calculator.ps1"
        "take screenshot" = "take-screenshot.ps1"
        "screenshot" = "take-screenshot.ps1"
        "thank you" = "thank-you.ps1"
        "thanks" = "thank-you.ps1"
        "goodbye" = "good-bye.ps1"
        "bye" = "good-bye.ps1"
        "stop listening" = "STOP"
        "exit" = "STOP"
        "quit" = "STOP"
    }
    
    # Announce readiness
    & "$PSScriptRoot/say-enhanced.ps1" "Hello! I'm your conversational voice assistant. Say $WakeWord and then tell me what you'd like to do or talk about."
    
    # Main conversation loop
    $keepListening = $true
    $conversationCount = 0
    
    while ($keepListening) {
        try {
            Write-Host "[LISTENING] Say '$WakeWord' followed by your request..." -ForegroundColor Green
            
            # Listen for input with longer timeout for conversation
            $result = $recognizer.Recognize([System.TimeSpan]::FromSeconds(60))
            
            if ($result -and $result.Text) {
                $text = $result.Text
                $confidence = $result.Confidence
                $conversationCount++
                
                Write-Host "[VOICE $conversationCount] Recognized: '$text' (Confidence: $([math]::Round($confidence * 100, 1))%)" -ForegroundColor Green
                
                # Extract command/query after wake word
                if ($text.StartsWith($WakeWord, [System.StringComparison]::InvariantCultureIgnoreCase)) {
                    $userInput = $text.Substring($WakeWord.Length).Trim()
                    
                    if ($userInput) {
                        Write-Host "[PROCESSING] User said: '$userInput'" -ForegroundColor Cyan
                        
                        # Check if it's a quick command
                        $lowerInput = $userInput.ToLower()
                        if ($quickCommands.ContainsKey($lowerInput)) {
                            $scriptName = $quickCommands[$lowerInput]
                            
                            if ($scriptName -eq "STOP") {
                                Write-Host "[CONVERSATION] Ending conversation..." -ForegroundColor Yellow
                                & "$PSScriptRoot/say-enhanced.ps1" "Goodbye! It was nice talking with you."
                                $keepListening = $false
                                break
                            }
                            
                            # Execute quick command
                            $scriptPath = Join-Path $PSScriptRoot $scriptName
                            if (Test-Path $scriptPath) {
                                Write-Host "[EXEC] Running quick command: $scriptName" -ForegroundColor Cyan
                                try {
                                    & $scriptPath
                                    Write-Host "[SUCCESS] Command completed" -ForegroundColor Green
                                } catch {
                                    Write-Host "[ERROR] Failed to execute $scriptName : $($_.Exception.Message)" -ForegroundColor Red
                                    & "$PSScriptRoot/say-enhanced.ps1" "Sorry, there was an error with that command."
                                }
                            }
                        } else {
                            # Route everything else to AI for conversation
                            Write-Host "[AI CONVERSATION] Routing to AI: '$userInput'" -ForegroundColor Magenta
                            try {
                                & "$PSScriptRoot/converse-with-ai.ps1" -UserInputText $userInput
                                Write-Host "[AI] Response completed" -ForegroundColor Green
                            } catch {
                                Write-Host "[ERROR] AI conversation failed: $($_.Exception.Message)" -ForegroundColor Red
                                & "$PSScriptRoot/say-enhanced.ps1" "I'm sorry, I'm having trouble thinking right now. Could you try asking again?"
                            }
                        }
                        
                        # Continue conversation
                        Write-Host "" # Add spacing
                        Write-Host "[READY] Ready for next conversation..." -ForegroundColor Green
                        
                    } else {
                        # Just wake word, acknowledge and wait
                        Write-Host "[WAKE] Wake word detected, waiting for request..." -ForegroundColor Yellow
                        & "$PSScriptRoot/say-enhanced.ps1" "Yes? What can I help you with?"
                    }
                } else {
                    # Didn't start with wake word, ignore
                    Write-Host "[IGNORE] Speech didn't start with wake word '$WakeWord'" -ForegroundColor Gray
                }
                
            } else {
                # Timeout - just continue listening
                Write-Host "[TIMEOUT] No speech detected, continuing to listen..." -ForegroundColor Gray
            }
            
        } catch {
            Write-Host "[ERROR] Recognition error: $($_.Exception.Message)" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
        
        # Break for test mode after first interaction
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