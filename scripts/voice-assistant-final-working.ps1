<#
.SYNOPSIS
    WORKING Voice Assistant with Windows TTS and AI Conversation
.DESCRIPTION
    Uses Windows TTS and AI for a simple conversational assistant
#>

param(
    [switch]$Test,
    [string]$WakeWord = "Ash"
)

# Import shared functions
. (Join-Path $PSScriptRoot "_shared-functions.ps1")

Write-Host "=== WinAssistAI Conversational Assistant ===" -ForegroundColor Cyan
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
    
    # Use dictation grammar for natural conversation
    $dictationGrammar = New-Object System.Speech.Recognition.DictationGrammar
    $recognizer.LoadGrammar($dictationGrammar)
    
    # Set input to default microphone
    $recognizer.SetInputToDefaultAudioDevice()
    
    # Configure for better speech capture
    $recognizer.BabbleTimeout = [System.TimeSpan]::FromSeconds(2)
    $recognizer.InitialSilenceTimeout = [System.TimeSpan]::FromSeconds(5)
    $recognizer.EndSilenceTimeout = [System.TimeSpan]::FromSeconds(1)
    
    Write-Host "[START] Starting voice assistant..." -ForegroundColor Green
    Write-Host "Say '$WakeWord' followed by anything you want to say or ask" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor White
    Write-Host "  '$WakeWord hello how are you today'" -ForegroundColor Gray
    Write-Host "  '$WakeWord tell me a joke'" -ForegroundColor Gray
    Write-Host "  '$WakeWord goodbye'" -ForegroundColor Gray
    Write-Host ""
    
    # Function to speak with Windows TTS
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
    
    # Announce readiness
    Speak-Text "Hello! I'm your voice assistant. Say $WakeWord and then tell me what you'd like to talk about."
    
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
                
                Write-Host "[HEARD] '$fullText' (Confidence: $([math]::Round($confidence * 100, 1))%)" -ForegroundColor Green
                
                # Check if it contains the wake word
                if ($fullText.ToLower().Contains($WakeWord.ToLower())) {
                    $userInput = $fullText.Substring($WakeWord.Length).Trim()
                    
                    Write-Host "[PROCESSING] User said: '$userInput'" -ForegroundColor Cyan
                    
                    # Handle goodbye
                    if ($userInput.ToLower() -match "\b(goodbye|bye|exit|quit|stop)\b") {
                        Speak-Text "Goodbye! It was nice talking with you."
                        $keepListening = $false
                        break
                    }
                    
                    # Route to AI for conversation
                    Write-Host "[AI CONVERSATION] Routing to AI: '$userInput'" -ForegroundColor Magenta
                    try {
                        & "$PSScriptRoot/converse-with-ai.ps1" -UserInputText $userInput
                        Write-Host "[AI] Response completed!" -ForegroundColor Green
                    } catch {
                        Write-Host "[ERROR] AI conversation failed: $($_.Exception.Message)" -ForegroundColor Red
                        Speak-Text "I'm sorry, I'm having trouble thinking right now. Could you try asking again?"
                    }
                    
                } else {
                    # No wake word
                    Write-Host "[IGNORE] No wake word detected in: '$fullText'" -ForegroundColor Gray
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