<#
.SYNOPSIS
    Enhanced Text-to-Speech with fallback capabilities
.DESCRIPTION
    Provides advanced TTS features with automatic fallback to basic TTS when needed
#>

param(
    [string]$Text,
    [switch]$Setup,
    [switch]$Test,
    [switch]$ListVoices,
    [switch]$Verbose
)

# Error handling
trap {
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    if ($Verbose) {
        Write-Host "[DEBUG] $($_.ScriptStackTrace)" -ForegroundColor Gray
    }
    exit 1
}

function Invoke-SmartTTS {
    param([string]$Text)
    
    try {
        # Try ElevenLabs TTS first
        if (Test-Path "$PSScriptRoot/elevenlabs-tts.ps1") {
            & "$PSScriptRoot/elevenlabs-tts.ps1" -Text $Text
            return $true
        }
        
        # Fallback to basic TTS
        Add-Type -AssemblyName System.Speech
        $speech = New-Object System.Speech.Synthesis.SpeechSynthesizer
        $speech.Speak($Text)
        return $true
    }
    catch {
        Write-Warning "TTS failed: $($_.Exception.Message)"
        return $false
    }
}

# Main execution
if ($Setup) {
    Write-Host "[SETUP] Configuring ElevenLabs TTS..." -ForegroundColor Yellow
    # Setup logic here
    exit 0
}

if ($Test) {
    Write-Host "[TEST] Testing TTS systems..." -ForegroundColor Yellow
    # Test logic here
    exit 0
}

if ($ListVoices) {
    Write-Host "[VOICES] Available TTS voices:" -ForegroundColor Yellow
    # Voice listing logic here
    exit 0
}

if (-not [string]::IsNullOrWhiteSpace($Text)) {
    $success = Invoke-SmartTTS -Text $Text
    if (-not $success) {
        Write-Warning "TTS failed for all systems"
        exit 1
    }
} else {
    Write-Host "Usage: .\say-enhanced.ps1 'Your text here'" -ForegroundColor Yellow
    Write-Host "       .\say-enhanced.ps1 -Setup" -ForegroundColor Yellow
    Write-Host "       .\say-enhanced.ps1 -Test" -ForegroundColor Yellow
    Write-Host "       .\say-enhanced.ps1 -ListVoices" -ForegroundColor Yellow
    exit 1
}

exit 0