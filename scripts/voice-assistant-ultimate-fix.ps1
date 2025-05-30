<#
.SYNOPSIS
    Ultimate Fixed Voice Assistant - Proper microphone control and better recognition
.DESCRIPTION
    Fixes self-hearing issue with proper microphone control and better English recognition
#>

param(
    [switch]$Test,
    [string]$WakeWord = "Ash"
)

# Import shared functions
. (Join-Path $PSScriptRoot "_shared-functions.ps1")

Write-Host "=== WinAssistAI ULTIMATE FIXED Voice Assistant ===" -ForegroundColor Green
Write-Host ""

# Load .NET Speech Recognition assemblies
Add-Type -AssemblyName System.Speech

try {
    Write-Host "[SETUP] Configuring ultimate voice assistant..." -ForegroundColor Yellow
    Write-Host "Wake word: $WakeWord" -ForegroundColor Cyan
    
    # Global recognition state flag
    $script:isListening = $false
    
    # Function to speak with proper microphone control
    function Speak-Text {
        param([string]$Text)
        
        try {
            Write-Host "[VOICE] Speaking: '$Text'" -ForegroundColor Cyan
            
            # STOP listening completely during speech
            $script:isListening = $false
            Write-Host "[AUDIO] 🔇 Microphone DISABLED during speech" -ForegroundColor Red
            
            # Use the enhanced TTS script
            $enhancedScript = Join-Path $PSScriptRoot "say-enhanced.ps1"
            
            if (Test-Path $enhancedScript) {
                & $enhancedScript -Text $Text
                Write-Host "[VOICE] ✅ Enhanced TTS completed successfully" -ForegroundColor Green
            } else {
                # Fallback to Windows TTS
                Add-Type -AssemblyName System.Speech
                $voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
                $voice.Rate = 1
                $voice.Volume = 100
                $voice.Speak($Text)
                $voice.Dispose()
                Write-Host "[VOICE] ✅ Windows TTS completed" -ForegroundColor Green
            }
            
            # Much longer pause to ensure audio is completely finished
            Write-Host "[AUDIO] 🔇 Waiting for audio to completely finish..." -ForegroundColor Yellow
            Start-Sleep -Milliseconds 5000
            
            # Re-enable listening
            $script:isListening = $true
            Write-Host "[AUDIO] 🎤 Microphone RE-ENABLED - Ready to listen" -ForegroundColor Green
            
        } catch {
            Write-Host "[VOICE] ❌ Speech failed: $($_.Exception.Message)" -ForegroundColor Red
            $script:isListening = $true  # Re-enable on error
        }
    }
    
    # Conversation memory storage
    $script:conversationHistory = @()
    
    # Function to add to conversation memory
    function Add-ConversationMemory {
        param([string]$UserInput, [string]$AssistantResponse)
        
        $script:conversationHistory += @{
            Timestamp = Get-Date
            User = $UserInput
            Assistant = $AssistantResponse
        }
        
        # Keep only last 10 exchanges
        if ($script:conversationHistory.Count -gt 10) {
            $script:conversationHistory = $script:conversationHistory[-10..-1]
        }
    }
    
    # Function to get AI response
    function Get-AIResponse {
        param([string]$Question)
        
        try {
            # Load environment variables
            $envFilePath = Join-Path $PSScriptRoot "..\.env"
            if (-not (Test-Path $envFilePath)) {
                return "I'm still learning! Try asking me about time, calculator, or screenshots."
            }
            
            $envContent = Get-Content $envFilePath
            $openaiKey = ""
            foreach ($line in $envContent) {
                if ($line -match "^\s*OPENAI_API_KEY\s*=\s*(.+)\s*$") {
                    $openaiKey = $matches[1].Trim()
                    break
                }
            }
            
            if ([string]::IsNullOrWhiteSpace($openaiKey) -or $openaiKey -eq "YOUR_OPENAI_API_KEY_HERE") {
                return "I'd love to chat more, but I need my AI brain configured first! For now, I can help with time, calculator, and screenshots."
            }
            
            Write-Host "[AI] Processing: '$Question'" -ForegroundColor Cyan
            
            $headers = @{
                "Authorization" = "Bearer $openaiKey"
                "Content-Type" = "application/json"
            }
            
            # Build conversation context
            $systemPrompt = "You are Ash, a friendly voice assistant. Keep responses brief and conversational (1-2 sentences). Be helpful and natural."
            
            # Build message array
            $messages = @(
                @{ role = "system"; content = $systemPrompt }
                @{ role = "user"; content = $Question }
            )
            
            $body = @{
                model = "gpt-3.5-turbo"
                messages = $messages
                max_tokens = 100
                temperature = 0.7
            } | ConvertTo-Json -Depth 6
            
            $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" -Headers $headers -Method Post -Body $body -TimeoutSec 15
            
            $aiResponse = $response.choices[0].message.content.Trim()
            Write-Host "[AI] Response: '$aiResponse'" -ForegroundColor Green
            
            Add-ConversationMemory -UserInput $Question -AssistantResponse $aiResponse
            return $aiResponse
            
        } catch {
            Write-Host "[AI] Error: $($_.Exception.Message)" -ForegroundColor Red
            return "I'm having trouble thinking right now. What else can I help with?"
        }
    }
    
    # Function to process commands
    function ProcessCommand {
        param([string]$UserInput)
        
        $command = $UserInput.ToLower()
        Write-Host "[PROCESSING] '$UserInput'" -ForegroundColor Cyan
        
        # Handle specific commands first
        if ($command -match "\b(calculator|calc)\b") {
            $response = "Opening calculator now."
            Write-Host "[ACTION] Opening Calculator..." -ForegroundColor Cyan
            Speak-Text $response
            Start-Process calc.exe
            return
        }
        elseif ($command -match "\btime\b") {
            $currentTime = Get-Date -Format "h:mm tt on dddd, MMMM dd"
            $response = "It's $currentTime"
            Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
            Speak-Text $response
            return
        }
        elseif ($command -match "\b(screenshot|screen shot|take a screenshot|take a screen shot)\b") {
            $response = "Taking screenshot now."
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
            return
        }
        elseif ($command -match "\b(chrome|google chrome|browser)\b") {
            $response = "Opening Google Chrome."
            Write-Host "[ACTION] Opening Chrome..." -ForegroundColor Cyan
            Speak-Text $response
            try {
                Start-Process "chrome.exe"
            } catch {
                try {
                    Start-Process "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
                } catch {
                    Start-Process "msedge.exe"
                }
            }
            return
        }
        elseif ($command -match "\b(hello|hi|hey)\b") {
            $response = "Hello! What can I help you with?"
            Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
            Speak-Text $response
            return
        }
        
        # Use AI for everything else
        $response = Get-AIResponse $UserInput
        Write-Host "[RESPONSE] $response" -ForegroundColor Yellow
        Speak-Text $response
    }
    
    # Create speech recognition engine with ONLY dictation for better natural speech
    $recognizer = New-Object System.Speech.Recognition.SpeechRecognitionEngine
    
    # Use ONLY dictation grammar - this works best for natural speech
    $dictationGrammar = New-Object System.Speech.Recognition.DictationGrammar
    $recognizer.LoadGrammar($dictationGrammar)
    
    Write-Host "[RECOGNITION] Using dictation mode for natural speech recognition" -ForegroundColor Green
    
    # Optimized audio settings for natural speech recognition
    $recognizer.SetInputToDefaultAudioDevice()
    $recognizer.EndSilenceTimeout = [System.TimeSpan]::FromSeconds(1.5)
    $recognizer.BabbleTimeout = [System.TimeSpan]::FromSeconds(2.0)
    $recognizer.InitialSilenceTimeout = [System.TimeSpan]::FromSeconds(4.0)
    
    Write-Host "[AUDIO] Audio settings optimized for natural speech" -ForegroundColor Green
    
    Write-Host "[START] Ultimate voice assistant ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎤 ULTIMATE CONVERSATIONAL MODE:" -ForegroundColor Cyan
    Write-Host "  1. Say '$WakeWord' + your command (e.g., '$WakeWord hello')" -ForegroundColor White
    Write-Host "  2. Wait for response, then continue conversation" -ForegroundColor White
    Write-Host "  3. Say '$WakeWord stop listening' to end" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Optimized for clear English speakers!" -ForegroundColor Yellow
    Write-Host "  • Targeted grammar for better recognition" -ForegroundColor Gray
    Write-Host "  • Proper microphone control prevents self-hearing" -ForegroundColor Gray
    Write-Host ""
    
    # Short greeting to minimize self-hearing
    $greeting = "Hi! I'm Ash. Ready to chat."
    $script:isListening = $true
    Speak-Text $greeting
    
    # Main conversation loop with proper microphone control
    $keepListening = $true
    $conversationActive = $false
    $conversationCount = 0
    
    while ($keepListening) {
        try {
            # Only listen when flag is enabled (not during speech output)
            if (-not $script:isListening) {
                Start-Sleep -Milliseconds 100
                continue
            }
            
            if (-not $conversationActive) {
                Write-Host "[LISTENING] Say '$WakeWord' + your command..." -ForegroundColor Green
            } else {
                Write-Host "[CONVERSATION] Listening... (say '$WakeWord stop listening' to end)" -ForegroundColor Cyan
            }
            
            $result = $recognizer.Recognize([System.TimeSpan]::FromSeconds(30))
            
            # Only process if we're supposed to be listening
            if (-not $script:isListening) {
                Write-Host "[IGNORED] Speech during output - microphone was disabled" -ForegroundColor Gray
                continue
            }
            
            if ($result -and $result.Text -and $result.Text.Trim() -ne "") {
                $fullText = $result.Text.Trim()
                $confidence = $result.Confidence
                
                # Better filtering to prevent self-hearing fragments
                if ($confidence -lt 0.35) {
                    Write-Host "[IGNORED] '$fullText' (Confidence: $([math]::Round($confidence * 100, 1))% - too low)" -ForegroundColor Gray
                    continue
                }
                
                $conversationCount++
                Write-Host "[HEARD] '$fullText' (Confidence: $([math]::Round($confidence * 100, 1))%)" -ForegroundColor Green
                
                $normalizedText = $fullText.ToLower()
                
                # Look for wake word
                if ($normalizedText -match '\b(ash|cash|hash|patch)\b') {
                    $conversationActive = $true
                    Write-Host "[CONVERSATION] Started!" -ForegroundColor Green
                    
                    # Extract command after wake word
                    $words = $fullText.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
                    if ($words.Length -gt 1) {
                        $command = ($words[1..($words.Length-1)] -join ' ')
                        
                        # Check for exit commands
                        if ($command.ToLower() -match "\b(stop listening|quit|goodbye|exit)\b") {
                            $response = "Goodbye! Have a great day!"
                            Speak-Text $response
                            $keepListening = $false
                            break
                        }
                        
                        # Process the command
                        ProcessCommand -UserInput $command
                    } else {
                        # Just wake word
                        $greeting = "I'm listening. What can I help with?"
                        Speak-Text $greeting
                    }
                } elseif ($conversationActive) {
                    # In conversation mode, process everything
                    ProcessCommand -UserInput $fullText
                }
            } else {
                Write-Host "[TIMEOUT] No speech detected" -ForegroundColor Gray
            }
            
        } catch {
            Write-Host "[ERROR] Recognition error: $($_.Exception.Message)" -ForegroundColor Red
            Start-Sleep -Seconds 1
            $script:isListening = $true  # Ensure listening is re-enabled
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