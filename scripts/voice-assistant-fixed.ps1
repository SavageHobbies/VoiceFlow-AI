<#
.SYNOPSIS
    Fixed Voice Assistant for WinAssistAI
.DESCRIPTION
    Fixed speech recognition to capture complete utterances
#>

param(
    [switch]$Test,
    [string]$WakeWord = ""
)

# Import shared functions
. (Join-Path $PSScriptRoot "_shared-functions.ps1")

Write-Host "=== WinAssistAI Voice Assistant (Fixed) ===" -ForegroundColor Cyan
Write-Host ""

# Load .NET Speech Recognition assemblies
Add-Type -AssemblyName System.Speech

try {
    # Get wake word from .env if not specified
    if (-not $WakeWord) {
        $WakeWord = Get-EnvVariable -KeyName "WAKE_WORD" -DefaultValue "Ash"
    }
    
    Write-Host "[SETUP] Configuring voice assistant..." -ForegroundColor Yellow
    Write-Host "Wake word: $WakeWord" -ForegroundColor Cyan
    
    # Create speech recognition engine
    $recognizer = New-Object System.Speech.Recognition.SpeechRecognitionEngine
    
    # Create a simple dictation grammar to capture everything
    $dictationGrammar = New-Object System.Speech.Recognition.DictationGrammar
    $recognizer.LoadGrammar($dictationGrammar)
    
    # Set input to default microphone
    $recognizer.SetInputToDefaultAudioDevice()
    
    Write-Host "[START] Starting voice assistant..." -ForegroundColor Green
    Write-Host "Say '$WakeWord' followed by your complete request" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor White
    Write-Host "  '$WakeWord hello there'" -ForegroundColor Gray
    Write-Host "  '$WakeWord open the calculator'" -ForegroundColor Gray
    Write-Host "  '$WakeWord what time is it right now'" -ForegroundColor Gray
    Write-Host "  '$WakeWord tell me a funny joke'" -ForegroundColor Gray
    Write-Host "  '$WakeWord goodbye'" -ForegroundColor Gray
    Write-Host ""
    
    # Command shortcuts (for quick actions)
    $quickCommands = @{
        "hello" = "hello.ps1"
        "hi" = "hello.ps1"
        "what time is it" = "what-time-is-it.ps1"
        "what's the time" = "what-time-is-it.ps1"
        "time" = "what-time-is-it.ps1"
        "check weather" = "check-weather.ps1"
        "weather" = "check-weather.ps1"
        "open calculator" = "open-calculator.ps1"
        "calculator" = "open-calculator.ps1"
        "open calc" = "open-calculator.ps1"
        "calc" = "open-calculator.ps1"
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
    & "$PSScriptRoot/say-enhanced.ps1" "Voice assistant ready. Say $WakeWord followed by your complete request."
    
    # Main conversation loop
    $keepListening = $true
    $conversationCount = 0
    
    while ($keepListening) {
        try {
            Write-Host "[LISTENING] Listening for '$WakeWord'..." -ForegroundColor Green
            
            # Listen for longer utterances to get complete sentences
            $recognizer.BabbleTimeout = [System.TimeSpan]::FromSeconds(2)
            $recognizer.InitialSilenceTimeout = [System.TimeSpan]::FromSeconds(10) 
            $recognizer.EndSilenceTimeout = [System.TimeSpan]::FromSeconds(1)
            
            $result = $recognizer.Recognize([System.TimeSpan]::FromSeconds(30))
            
            if ($result -and $result.Text -and $result.Text.Trim() -ne "") {
                $fullText = $result.Text.Trim()
                $confidence = $result.Confidence
                $conversationCount++
                
                Write-Host "[VOICE $conversationCount] Full Recognition: '$fullText' (Confidence: $([math]::Round($confidence * 100, 1))%)" -ForegroundColor Green
                
                # Check if it starts with wake word
                if ($fullText.StartsWith($WakeWord, [System.StringComparison]::InvariantCultureIgnoreCase)) {
                    
                    # Extract everything after wake word
                    $userInput = $fullText.Substring($WakeWord.Length).Trim()
                    
                    if ($userInput -and $userInput -ne "") {
                        Write-Host "[PROCESSING] Command: '$userInput'" -ForegroundColor Cyan
                        
                        # Check if it's a quick command (exact match first)
                        $lowerInput = $userInput.ToLower()
                        $matchedCommand = $null
                        
                        # First try exact match
                        if ($quickCommands.ContainsKey($lowerInput)) {
                            $matchedCommand = $quickCommands[$lowerInput]
                        } else {
                            # Try partial match for commands containing the key phrase
                            foreach ($cmdKey in $quickCommands.Keys) {
                                if ($lowerInput.Contains($cmdKey)) {
                                    $matchedCommand = $quickCommands[$cmdKey]
                                    Write-Host "[MATCH] Found command '$cmdKey' in '$lowerInput'" -ForegroundColor Yellow
                                    break
                                }
                            }
                        }
                        
                        if ($matchedCommand) {
                            if ($matchedCommand -eq "STOP") {
                                Write-Host "[CONVERSATION] Ending conversation..." -ForegroundColor Yellow
                                & "$PSScriptRoot/say-enhanced.ps1" "Goodbye! It was nice talking with you."
                                $keepListening = $false
                                break
                            }
                            
                            # Execute quick command
                            $scriptPath = Join-Path $PSScriptRoot $matchedCommand
                            if (Test-Path $scriptPath) {
                                Write-Host "[EXEC] Running: $matchedCommand" -ForegroundColor Cyan
                                try {
                                    & $scriptPath
                                    Write-Host "[SUCCESS] Command completed" -ForegroundColor Green
                                } catch {
                                    Write-Host "[ERROR] Failed to execute $matchedCommand : $($_.Exception.Message)" -ForegroundColor Red
                                    & "$PSScriptRoot/say-enhanced.ps1" "Sorry, there was an error with that command."
                                }
                            }
                        } else {
                            # Route to AI for conversation
                            Write-Host "[AI CONVERSATION] Routing to AI: '$userInput'" -ForegroundColor Magenta
                            try {
                                & "$PSScriptRoot/converse-with-ai.ps1" -UserInputText $userInput
                                Write-Host "[AI] Response completed" -ForegroundColor Green
                            } catch {
                                Write-Host "[ERROR] AI conversation failed: $($_.Exception.Message)" -ForegroundColor Red
                                & "$PSScriptRoot/say-enhanced.ps1" "I'm sorry, I'm having trouble thinking right now. Could you try asking again?"
                            }
                        }
                        
                    } else {
                        # Just wake word, acknowledge and wait
                        Write-Host "[WAKE] Wake word only, waiting for command..." -ForegroundColor Yellow
                        & "$PSScriptRoot/say-enhanced.ps1" "Yes? What can I help you with?"
                    }
                    
                } else {
                    # Didn't start with wake word, ignore but show what was heard
                    Write-Host "[IGNORE] Heard: '$fullText' (no wake word '$WakeWord')" -ForegroundColor Gray
                }
                
                # Continue conversation
                Write-Host "" # Add spacing
                
            } else {
                # Timeout or no recognition
                Write-Host "[TIMEOUT] No clear speech detected, continuing..." -ForegroundColor Gray
            }
            
        } catch {
            Write-Host "[ERROR] Recognition error: $($_.Exception.Message)" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
        
        # Break for test mode after first meaningful interaction
        if ($Test -and $conversationCount -gt 0) {
            Write-Host "[TEST] Test mode - exiting after first interaction" -ForegroundColor Yellow
            break
        }
    }
    
    # Cleanup
    $recognizer.Dispose()
    Write-Host "[STOP] Voice assistant stopped." -ForegroundColor Yellow
    
} catch {
    Write-Host "[ERROR] Voice assistant failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure you have a microphone connected and working." -ForegroundColor Yellow
    exit 1
}