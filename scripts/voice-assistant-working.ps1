<#
.SYNOPSIS
    Working Voice Assistant for WinAssistAI
.DESCRIPTION
    Uses proper grammar pattern to capture Ash + complete phrases
#>

param(
    [switch]$Test,
    [string]$WakeWord = ""
)

# Import shared functions
. (Join-Path $PSScriptRoot "_shared-functions.ps1")

Write-Host "=== WinAssistAI Voice Assistant (Working) ===" -ForegroundColor Cyan
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
    
    # Create specific command patterns instead of wildcards
    $grammarBuilder = New-Object System.Speech.Recognition.GrammarBuilder
    $commands = New-Object System.Speech.Recognition.Choices
    
    # Add all possible commands explicitly
    $allCommands = @(
        "$WakeWord hello",
        "$WakeWord hi",
        "$WakeWord hey",
        "$WakeWord good morning",
        "$WakeWord good evening",
        "$WakeWord what time is it",
        "$WakeWord what's the time",
        "$WakeWord time",
        "$WakeWord check weather",
        "$WakeWord weather",
        "$WakeWord what's the weather",
        "$WakeWord open calculator",
        "$WakeWord calculator",
        "$WakeWord open calc",
        "$WakeWord calc",
        "$WakeWord take screenshot",
        "$WakeWord screenshot",
        "$WakeWord screen shot",
        "$WakeWord thank you",
        "$WakeWord thanks",
        "$WakeWord goodbye",
        "$WakeWord bye",
        "$WakeWord good bye",
        "$WakeWord stop listening",
        "$WakeWord stop",
        "$WakeWord exit",
        "$WakeWord quit",
        "$WakeWord tell me a joke",
        "$WakeWord joke",
        "$WakeWord help",
        "$WakeWord help me"
    )
    
    # Add conversational phrases
    $conversationalCommands = @(
        "$WakeWord tell me about",
        "$WakeWord what is",
        "$WakeWord what are",
        "$WakeWord how do I",
        "$WakeWord how to",
        "$WakeWord explain",
        "$WakeWord help me with",
        "$WakeWord I need help with",
        "$WakeWord can you help me",
        "$WakeWord please help me"
    )
    
    # Add all commands to choices
    foreach ($cmd in $allCommands) {
        $commands.Add($cmd)
    }
    
    foreach ($cmd in $conversationalCommands) {
        $commands.Add($cmd)
    }
    
    # Build and load grammar
    $grammarBuilder.Append($commands)
    $grammar = New-Object System.Speech.Recognition.Grammar($grammarBuilder)
    $recognizer.LoadGrammar($grammar)
    
    # Also add a dictation grammar for longer phrases
    $dictationGrammar = New-Object System.Speech.Recognition.DictationGrammar
    $recognizer.LoadGrammar($dictationGrammar)
    
    # Set input to default microphone
    $recognizer.SetInputToDefaultAudioDevice()
    
    Write-Host "[START] Starting voice assistant..." -ForegroundColor Green
    Write-Host "Say '$WakeWord' followed by a command" -ForegroundColor White
    Write-Host ""
    Write-Host "Quick Commands:" -ForegroundColor White
    Write-Host "  '$WakeWord hello'" -ForegroundColor Gray
    Write-Host "  '$WakeWord calculator'" -ForegroundColor Gray
    Write-Host "  '$WakeWord what time is it'" -ForegroundColor Gray
    Write-Host "  '$WakeWord weather'" -ForegroundColor Gray
    Write-Host "  '$WakeWord goodbye'" -ForegroundColor Gray
    Write-Host ""
    
    # Command mapping
    $quickCommands = @{
        "hello" = "hello.ps1"
        "hi" = "hello.ps1"
        "hey" = "hello.ps1"
        "good morning" = "good-morning.ps1"
        "good evening" = "good-evening.ps1"
        "what time is it" = "what-time-is-it.ps1"
        "what's the time" = "what-time-is-it.ps1"
        "time" = "what-time-is-it.ps1"
        "check weather" = "check-weather.ps1"
        "weather" = "check-weather.ps1"
        "what's the weather" = "check-weather.ps1"
        "open calculator" = "open-calculator.ps1"
        "calculator" = "open-calculator.ps1"
        "open calc" = "open-calculator.ps1"
        "calc" = "open-calculator.ps1"
        "take screenshot" = "take-screenshot.ps1"
        "screenshot" = "take-screenshot.ps1"
        "screen shot" = "take-screenshot.ps1"
        "thank you" = "thank-you.ps1"
        "thanks" = "thank-you.ps1"
        "goodbye" = "good-bye.ps1"
        "bye" = "good-bye.ps1"
        "good bye" = "good-bye.ps1"
        "tell me a joke" = "tell-me-a-joke.ps1"
        "joke" = "tell-me-a-joke.ps1"
        "help" = "i-need-help.ps1"
        "help me" = "i-need-help.ps1"
        "stop listening" = "STOP"
        "stop" = "STOP"
        "exit" = "STOP"
        "quit" = "STOP"
    }
    
    # Announce readiness
    & "$PSScriptRoot/say-enhanced.ps1" "Voice assistant ready. Say $WakeWord followed by a command."
    
    # Main conversation loop
    $keepListening = $true
    $conversationCount = 0
    
    while ($keepListening) {
        try {
            Write-Host "[LISTENING] Say '$WakeWord <command>'..." -ForegroundColor Green
            
            $result = $recognizer.Recognize([System.TimeSpan]::FromSeconds(15))
            
            if ($result -and $result.Text -and $result.Text.Trim() -ne "") {
                $fullText = $result.Text.Trim()
                $confidence = $result.Confidence
                $conversationCount++
                
                Write-Host "[VOICE $conversationCount] Recognized: '$fullText' (Confidence: $([math]::Round($confidence * 100, 1))%)" -ForegroundColor Green
                
                # Check if it starts with wake word
                if ($fullText.StartsWith($WakeWord, [System.StringComparison]::InvariantCultureIgnoreCase)) {
                    
                    # Extract command after wake word
                    $userInput = $fullText.Substring($WakeWord.Length).Trim()
                    
                    if ($userInput -and $userInput -ne "") {
                        Write-Host "[PROCESSING] Command: '$userInput'" -ForegroundColor Cyan
                        
                        # Check for exact match first
                        $lowerInput = $userInput.ToLower()
                        $matchedCommand = $null
                        
                        if ($quickCommands.ContainsKey($lowerInput)) {
                            $matchedCommand = $quickCommands[$lowerInput]
                            Write-Host "[MATCH] Exact match: '$lowerInput'" -ForegroundColor Yellow
                        } else {
                            # Try partial match
                            foreach ($cmdKey in $quickCommands.Keys) {
                                if ($lowerInput.Contains($cmdKey)) {
                                    $matchedCommand = $quickCommands[$cmdKey]
                                    Write-Host "[MATCH] Partial match: '$cmdKey' in '$lowerInput'" -ForegroundColor Yellow
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
                            
                            # Execute command
                            $scriptPath = Join-Path $PSScriptRoot $matchedCommand
                            if (Test-Path $scriptPath) {
                                Write-Host "[EXEC] Running: $matchedCommand" -ForegroundColor Cyan
                                try {
                                    & $scriptPath
                                    Write-Host "[SUCCESS] Command '$matchedCommand' completed successfully!" -ForegroundColor Green
                                } catch {
                                    Write-Host "[ERROR] Failed to execute $matchedCommand : $($_.Exception.Message)" -ForegroundColor Red
                                    & "$PSScriptRoot/say-enhanced.ps1" "Sorry, there was an error with that command."
                                }
                            } else {
                                Write-Host "[ERROR] Script not found: $scriptPath" -ForegroundColor Red
                                & "$PSScriptRoot/say-enhanced.ps1" "Sorry, I don't have that command available."
                            }
                        } else {
                            # Route to AI for conversation
                            Write-Host "[AI CONVERSATION] Routing to AI: '$userInput'" -ForegroundColor Magenta
                            try {
                                & "$PSScriptRoot/converse-with-ai.ps1" -UserInputText $userInput
                                Write-Host "[AI] Response completed successfully!" -ForegroundColor Green
                            } catch {
                                Write-Host "[ERROR] AI conversation failed: $($_.Exception.Message)" -ForegroundColor Red
                                & "$PSScriptRoot/say-enhanced.ps1" "I'm sorry, I'm having trouble thinking right now. Could you try asking again?"
                            }
                        }
                        
                    } else {
                        # Just wake word
                        Write-Host "[WAKE] Wake word detected, waiting for command..." -ForegroundColor Yellow
                        & "$PSScriptRoot/say-enhanced.ps1" "Yes? What can I help you with?"
                    }
                    
                } else {
                    # No wake word
                    Write-Host "[IGNORE] No wake word detected: '$fullText'" -ForegroundColor Gray
                }
                
                Write-Host "" # Spacing
                
            } else {
                # No recognition
                Write-Host "[TIMEOUT] No speech detected, continuing to listen..." -ForegroundColor Gray
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
    Write-Host "[STOP] Voice assistant stopped." -ForegroundColor Yellow
    
} catch {
    Write-Host "[ERROR] Voice assistant failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure you have a microphone connected and working." -ForegroundColor Yellow
    exit 1
}