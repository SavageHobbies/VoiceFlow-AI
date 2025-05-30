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

# Function to load .env file from repository root
function Get-EnvVariable {
    param (
        [string]$KeyName
    )
    $envFilePath = Join-Path $PSScriptRoot "..\.env" # Assumes script is in 'scripts' subdir
    if (-not (Test-Path $envFilePath)) {
        Write-Warning ".env file not found at $($envFilePath)"
        return $null
    }
    $envContent = Get-Content $envFilePath
    foreach ($line in $envContent) {
        if ($line -match "^\s*$KeyName\s*=\s*(.+)\s*$") {
            return $matches[1].Trim()
        }
    }
    Write-Warning "Key '$KeyName' not found in .env file."
    return $null
}

# Error handling
trap {
    Write-Host "[SAY-ENHANCED ERROR] $($_.Exception.Message)" -ForegroundColor Red
    if ($Verbose) {
        Write-Host "[DEBUG] $($_.ScriptStackTrace)" -ForegroundColor Gray
    }
    exit 1
}

function Invoke-WindowsTTS {
    param([string]$TextToSpeak)
    Write-Host "[INFO] Using Windows built-in TTS." -ForegroundColor Yellow
    Add-Type -AssemblyName System.Speech
    $speech = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $speech.Speak($TextToSpeak)
}

function Invoke-SmartTTS {
    param([string]$Text)
    
    $elevenLabsApiKey = Get-EnvVariable "ELEVENLABS_API_KEY"
    $configFilePath = Join-Path $PSScriptRoot "..\config\elevenlabs.json" # Adjusted path

    if (-not (Test-Path $configFilePath)) {
        Write-Warning "ElevenLabs config file not found at $configFilePath. Falling back to Windows TTS."
        Invoke-WindowsTTS -Text $Text
        return $true
    }

    $config = Get-Content $configFilePath | ConvertFrom-Json
    
    if (-not $config.enabled) {
        Write-Host "[INFO] ElevenLabs TTS is disabled in config. Falling back to Windows TTS." -ForegroundColor Yellow
        Invoke-WindowsTTS -Text $Text
        return $true
    }

    if ([string]::IsNullOrWhiteSpace($elevenLabsApiKey)) {
        Write-Warning "ELEVENLABS_API_KEY not found in .env file. Falling back to Windows TTS."
        Invoke-WindowsTTS -Text $Text
        return $true
    }

    # Prioritize API key from .env, even if config has one (it shouldn't anymore)
    # $config.apiKey is now just a placeholder "loaded_from_env" after setup-elevenlabs.ps1 changes

    Write-Host "[INFO] Attempting ElevenLabs TTS..." -ForegroundColor Cyan
    
    $headers = @{
        "Content-Type" = "application/json"
        "xi-api-key"   = $elevenLabsApiKey
    }

    $body = @{
        text    = $Text
        model_id = $config.model # "eleven_monolingual_v1" or as configured
        voice_settings = @{
            stability       = $config.voice.stability
            similarity_boost = $config.voice.similarityBoost
            style           = $config.voice.style
            use_speaker_boost = $config.voice.useSpeakerBoost
        }
    } | ConvertTo-Json -Depth 5

    $apiUrl = $config.apiUrl # Should be "https://api.elevenlabs.io/v1"
    $voiceId = $config.voice.id 
    $ttsUrl = "$apiUrl/text-to-speech/$voiceId"
    
    try {
        # Use OutFile to properly save binary audio data with unique filename
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"
        $tempAudioFile = Join-Path $env:TEMP "elevenlabs_audio_$timestamp.mp3"
        Invoke-RestMethod -Uri $ttsUrl -Headers $headers -Method Post -Body $body -OutFile $tempAudioFile -TimeoutSec 30
        
        # Play the audio file with a single reliable method
        Write-Host "[ELEVENLABS] Playing audio with ElevenLabs voice..." -ForegroundColor Green
        
        try {
            # Use Windows Media Player with synchronous playback (wait for completion)
            Start-Process -FilePath "wmplayer.exe" -ArgumentList "/play /close `"$tempAudioFile`"" -WindowStyle Hidden -Wait
            Write-Host "[ELEVENLABS] ✅ Audio playback completed" -ForegroundColor Green
        } catch {
            Write-Host "[ELEVENLABS] Audio playback failed: $($_.Exception.Message)" -ForegroundColor Red
            # Fallback to Windows TTS
            Write-Host "[ELEVENLABS] Falling back to Windows TTS..." -ForegroundColor Yellow
            Invoke-WindowsTTS -TextToSpeak $Text
        }
        
        # Clean up temp file
        # Remove-Item $tempAudioFile -ErrorAction SilentlyContinue

        return $true
    } catch {
        Write-Warning "ElevenLabs TTS failed: $($_.Exception.Message)"
        if ($config.fallbackToWindows) {
            Write-Warning "Falling back to Windows TTS."
            Invoke-WindowsTTS -Text $Text
            return $true
        }
        return $false
    }
}

# Main execution
if ($Setup) {
    Write-Host "[INFO] To configure ElevenLabs, please run 'scripts\setup-elevenlabs.ps1'" -ForegroundColor Yellow
    # The actual setup script is setup-elevenlabs.ps1
    exit 0
}

if ($Test) {
    Write-Host "[TEST] Testing TTS systems..." -ForegroundColor Yellow
    # Test: Say a phrase using SmartTTS
    Invoke-SmartTTS -Text "This is a test of the enhanced text to speech system."
    # Add more specific tests if needed, e.g., force Windows TTS
    Write-Host "[INFO] Testing Windows TTS directly:"
    Invoke-WindowsTTS -Text "This is a direct test of Windows built-in text to speech."
    exit 0
}

if ($ListVoices) {
    Write-Host "[VOICES] Listing available TTS voices..." -ForegroundColor Yellow
    Write-Host "[INFO] For ElevenLabs voices, please refer to your ElevenLabs account or run setup."
    Write-Host "[INFO] Windows TTS voices available on this system:"
    Add-Type -AssemblyName System.Speech
    $speech = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $speech.GetInstalledVoices() | ForEach-Object { $_.VoiceInfo.Name }
    exit 0
}

if (-not [string]::IsNullOrWhiteSpace($Text)) {
    Invoke-SmartTTS -Text $Text
    # The Invoke-SmartTTS function now handles its own success/failure reporting or fallback.
} else {
    Write-Host "Usage: .\say-enhanced.ps1 -Text 'Your text here'" -ForegroundColor Yellow # Added -Text parameter for clarity
    Write-Host "       .\say-enhanced.ps1 -Setup   (Note: Actual setup is in setup-elevenlabs.ps1)"
    Write-Host "       .\say-enhanced.ps1 -Test"
    Write-Host "       .\say-enhanced.ps1 -ListVoices"
    exit 1
}

exit 0