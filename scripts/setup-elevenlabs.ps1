<#
.SYNOPSIS
    ElevenLabs AI Voice Setup Wizard
.DESCRIPTION
    Interactive setup wizard for configuring ElevenLabs AI voice synthesis
    in the Talk2Windows system.
.EXAMPLE
    .\setup-elevenlabs.ps1
    .\setup-elevenlabs.ps1 -SetVoiceID "21m00Tcm4TlvDq8ikWAM" -SetVoiceName "Rachel"
    .\setup-elevenlabs.ps1 -ListAvailableVoices
.NOTES
    This script interacts with config/elevenlabs.json and requires ELEVENLABS_API_KEY in the .env file.
#>

[CmdletBinding(DefaultParameterSetName = "Interactive")]
param(
    [Parameter(ParameterSetName = "Interactive")]
    [switch]$Interactive,

    [Parameter(ParameterSetName = "SetVoice", Mandatory = $true)]
    [switch]$SetVoice,
    [Parameter(ParameterSetName = "SetVoice", Mandatory = $true)]
    [string]$VoiceID,
    [Parameter(ParameterSetName = "SetVoice")]
    [string]$VoiceName,

    [Parameter(ParameterSetName = "ListVoices")]
    [switch]$ListAvailableVoices,

    [Parameter(Mandatory = $false)] # Kept for general script structure, not directly used for API key input
    [switch]$Help,
    [Parameter(Mandatory = $false)]
    [switch]$Verbose
)

# Function to load .env file from repository root
function Get-EnvVariable {
    param (
        [string]$KeyName
    )
    $envFilePath = Join-Path $PSScriptRoot "..\.env" # Assumes script is in 'scripts' subdir
    if (-not (Test-Path $envFilePath)) {
        Write-Warning ("env file not found at {0}" -f $envFilePath)
        return $null
    }
    $envContent = Get-Content $envFilePath
    foreach ($line in $envContent) {
        if ($line -match "^\s*$KeyName\s*=\s*(.+)\s*$") {
            return $matches[1].Trim()
        }
    }
    Write-Warning ("Key '{0}' not found in .env file." -f $KeyName)
    return $null
}

$ScriptRoot = $PSScriptRoot
$ConfigPath = Join-Path (Split-Path $ScriptRoot -Parent) "config\elevenlabs.json"

function Show-Help {
    Write-Host @"

=== ElevenLabs AI Voice Setup ===

This wizard will help you configure ElevenLabs AI voice synthesis for Talk2Windows.

REQUIREMENTS:
• ElevenLabs account (https://elevenlabs.io)
• API key from ElevenLabs dashboard
• Internet connection

USAGE:
    .\setup-elevenlabs.ps1                     # Interactive full setup
    .\setup-elevenlabs.ps1 -Interactive        # Explicitly run interactive full setup
    .\setup-elevenlabs.ps1 -SetVoice -VoiceID "YourVoiceID" [-SetVoiceName "OptionalVoiceName"] # Set specific voice
    .\setup-elevenlabs.ps1 -ListAvailableVoices  # List all available voices from ElevenLabs
    .\setup-elevenlabs.ps1 -Help               # Show this help

STEPS (for manual understanding, API key is from .env):
1. Ensure ELEVENLABS_API_KEY is in your .env file.
2. Run this script using one of the modes above.
4. Test your voice configuration

"@ -ForegroundColor Cyan
}

function Show-Banner {
    Write-Host @"

 ███████╗██╗     ███████╗██╗   ██╗███████╗███╗   ██╗██╗      █████╗ ██████╗ ███████╗
 ██╔════╝██║     ██╔════╝██║   ██║██╔════╝████╗  ██║██║     ██╔══██╗██╔══██╗██╔════╝
 █████╗  ██║     █████╗  ██║   ██║█████╗  ██╔██╗ ██║██║     ███████║██████╔╝███████╗
 ██╔══╝  ██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║██║     ██╔══██║██╔══██╗╚════██║
 ███████╗███████╗███████╗ ╚████╔╝ ███████╗██║ ╚████║███████╗██║  ██║██████╔╝███████║
 ╚══════╝╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝

                           AI Voice Synthesis Setup
                          https://elevenlabs.io

"@ -ForegroundColor Magenta
}

function Test-ApiKey {
    param([string]$Key, [string]$ApiUrl = "https://api.elevenlabs.io/v1")
    
    try {
        $headers = @{
            "xi-api-key" = $Key
            "Content-Type" = "application/json"
        }
        
        $response = Invoke-RestMethod -Uri "$ApiUrl/user" -Headers $headers -Method Get -TimeoutSec 10
        return @{ Success = $true; User = $response }
    } catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

function Get-AvailableVoices {
    param([string]$ApiKey, [string]$ApiUrl = "https://api.elevenlabs.io/v1")
    
    try {
        $headers = @{
            "xi-api-key" = $ApiKey
            "Content-Type" = "application/json"
        }
        
        $response = Invoke-RestMethod -Uri "$ApiUrl/voices" -Headers $headers -Method Get -TimeoutSec 15
        return $response.voices
    } catch {
        Write-Warning ("Failed to get voices: {0}" -f $_.Exception.Message)
        return $null
    }
}

function Get-DefaultConfig {
    return @{
        enabled = $false
        apiKey = ""
        apiUrl = "https://api.elevenlabs.io/v1"
        voice = @{
            id = "21m00Tcm4TlvDq8ikWAM"
            name = "Rachel"
            stability = 0.5
            similarityBoost = 0.75
            style = 0.0
            useSpeakerBoost = $true
        }
        model = "eleven_monolingual_v1"
        outputFormat = "mp3_44100_128"
        chunkLengthSchedule = @(120, 160, 250, 290)
        fallbackToWindows = $true
        cacheAudio = $true
        cacheDirectory = "cache/audio"
        timeout = 30000
        retries = 3
        quality = "high"
    }
}

function Save-Config {
    param([PSCustomObject]$Config)
    
    try {
        $configDir = Split-Path $ConfigPath -Parent
        if (-not (Test-Path $configDir)) {
            New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        }
        
        $Config | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath -Encoding UTF8
        Write-Host "[✓] Configuration saved to: $ConfigPath" -ForegroundColor Green
        return $true
    } catch {
        Write-Host ("[✗] Failed to save configuration: {0}" -f $_.Exception.Message) -ForegroundColor Red
        return $false
    }
}


function Start-InteractiveSetup {
    Show-Banner
    Write-Host "Welcome to the ElevenLabs AI Voice Setup Wizard!" -ForegroundColor Green
    Write-Host ""

    # Load existing config or get defaults
    $config = if (Test-Path $ConfigPath) {
        Get-Content $ConfigPath -Raw | ConvertFrom-Json
    } else {
        Get-DefaultConfig
    }

    # Attempt to load API key from .env file - This also sets $config.enabled
    $apiKeyValid = Test-And-SetApiKeyStatus -ConfigRef ([ref]$config)
    if (-not $apiKeyValid) {
        Save-Config -Config $config # Save with enabled:false if key is bad/missing
        return # Exit if API key is not found or invalid
    }
    
    Write-Host ""
    Write-Host "This wizard will help you configure high-quality AI voice synthesis for Talk2Windows." -ForegroundColor White
    Write-Host ""
    
    # Prompt for re-configuration of voice/settings if already configured
    if ($config.enabled -and $config.apiKey -eq "loaded_from_env") { 
        $reconfigure = Read-Host "ElevenLabs is already configured (API key loaded). Do you want to change voice or other settings? (y/N)"
        if ($reconfigure -notmatch '^y|yes$') {
            Write-Host "[SKIP] Setup for voice and other settings cancelled. Configuration remains as is." -ForegroundColor Yellow
            Save-Config -Config $config 
            return
        }
    }
    
    # API Key is valid and $config.enabled is true here.
    Perform-InteractiveVoiceSelection -ConfigRef ([ref]$config) -ApiKey $Global:ApiKey
    Perform-InteractiveAdvancedSettings -ConfigRef ([ref]$config)
    Save-ConfigurationAndTest -Config $config
}

# Helper to test API key and set config.enabled status
function Test-And-SetApiKeyStatus {
    param([ref]$ConfigRef)

    $envApiKey = Get-EnvVariable "ELEVENLABS_API_KEY"
    $Global:ApiKey = $envApiKey # Make it available globally if found for other functions

    if (-not [string]::IsNullOrWhiteSpace($envApiKey)) {
        Write-Host ("[INFO] ELEVENLABS_API_KEY found in .env file. Testing it...") -ForegroundColor Green
        $testResult = Test-ApiKey -Key $Global:ApiKey
        
        if ($testResult.Success) {
            Write-Host "[✓] API key is valid!" -ForegroundColor Green
            if ($testResult.User.subscription) {
                Write-Host ("[INFO] Subscription: {0}" -f $testResult.User.subscription.tier) -ForegroundColor Cyan
            }
            $ConfigRef.Value.enabled = $true
            Write-Host "[INFO] ElevenLabs will be ENABLED in the configuration." -ForegroundColor Green
            return $true
        } else {
            Write-Warning ("[✗] API key test failed: {0} using key from .env." -f $testResult.Error)
            Write-Host "Please check your .env file and ensure the API key is correct." -ForegroundColor Yellow
            $ConfigRef.Value.enabled = $false
            Write-Host "[INFO] ElevenLabs will be DISABLED due to invalid API key." -ForegroundColor Yellow
            return $false
        }
    } else {
        Write-Error "ELEVENLABS_API_KEY not found or empty in .env file."
        Write-Host "Please create or update .env file with your API key." -ForegroundColor Yellow
        $ConfigRef.Value.enabled = $false
        Write-Host "[INFO] ElevenLabs will be DISABLED due to missing API key." -ForegroundColor Yellow
        return $false
    }
}

# Helper for interactive voice selection part
function Perform-InteractiveVoiceSelection {
    param([ref]$ConfigRef, [string]$ApiKey)

    Write-Host "`nSTEP 1: Voice Selection" -ForegroundColor Cyan
    Write-Host "══════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Fetching available voices..." -ForegroundColor Yellow
    
    $voices = Get-AvailableVoices -ApiKey $ApiKey
    
    if (-not $voices) {
        Write-Warning ("[WARNING] Could not fetch voices. Using default (Rachel).")
        $ConfigRef.Value.voice.id = "21m00Tcm4TlvDq8ikWAM"
        $ConfigRef.Value.voice.name = "Rachel"
    } else {
        Write-Host "`nAvailable voices:" -ForegroundColor Green
        for ($i = 0; $i -lt $voices.Count; $i++) {
            $voice = $voices[$i]
            $description = if ($voice.labels.description) { " - $($voice.labels.description)" } else { "" }
            $gender = if ($voice.labels.gender) { " ($($voice.labels.gender))" } else { "" }
            Write-Host ("  {0}. {1}{2}{3}" -f ($i + 1), $voice.name, $gender, $description) -ForegroundColor White
        }
        Write-Host ""
        $voiceChoice = Read-Host "Select voice number (1-$($voices.Count)) or press Enter for default (Rachel)"
        
        $selectedVoiceEntry = $null
        if ($voiceChoice -match '^\d+$' -and [int]$voiceChoice -ge 1 -and [int]$voiceChoice -le $voices.Count) {
            $selectedVoiceEntry = $voices[[int]$voiceChoice - 1]
        } else {
            $selectedVoiceEntry = $voices | Where-Object { $_.name -eq "Rachel" } | Select-Object -First 1
            if (-not $selectedVoiceEntry) { $selectedVoiceEntry = $voices[0] } # Fallback
        }
        $ConfigRef.Value.voice.id = $selectedVoiceEntry.voice_id
        $ConfigRef.Value.voice.name = $selectedVoiceEntry.name
        Write-Host ("[✓] Selected voice: {0}" -f $selectedVoiceEntry.name) -ForegroundColor Green
    }
}

# Helper for interactive advanced settings part
function Perform-InteractiveAdvancedSettings {
    param([ref]$ConfigRef)

    Write-Host "`nSTEP 2: Voice Settings" -ForegroundColor Cyan
    Write-Host "══════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Configure voice quality settings:" -ForegroundColor White
    Write-Host ""
    
    $useAdvanced = Read-Host "Use advanced settings? (y/N)"
    
    # Use current config values as defaults if they exist, otherwise use script defaults
    $stability = if ($ConfigRef.Value.voice.stability) { $ConfigRef.Value.voice.stability } else { 0.5 }
    $similarity = if ($ConfigRef.Value.voice.similarityBoost) { $ConfigRef.Value.voice.similarityBoost } else { 0.75 }
    $style = if ($ConfigRef.Value.voice.style) { $ConfigRef.Value.voice.style } else { 0.0 }
    
    if ($useAdvanced -match '^y|yes$') {
        Write-Host ""
        Write-Host ("Stability (0.0-1.0): Controls voice consistency. Current: {0}" -f $stability) -ForegroundColor Yellow
        $stabilityInput = Read-Host "Enter stability (default: $stability)"
        if ($stabilityInput -match '^\d*\.?\d+$' -and [float]$stabilityInput -ge 0 -and [float]$stabilityInput -le 1) {
            $stability = [float]$stabilityInput
        }
        
        Write-Host ""
        Write-Host ("Similarity Boost (0.0-1.0): How closely to match the original voice. Current: {0}" -f $similarity) -ForegroundColor Yellow
        $similarityInput = Read-Host "Enter similarity boost (default: $similarity)"
        if ($similarityInput -match '^\d*\.?\d+$' -and [float]$similarityInput -ge 0 -and [float]$similarityInput -le 1) {
            $similarity = [float]$similarityInput
        }
        
        Write-Host ""
        Write-Host ("Style (0.0-1.0): Amount of style to apply. Current: {0}" -f $style) -ForegroundColor Yellow
        $styleInput = Read-Host "Enter style (default: $style)"
        if ($styleInput -match '^\d*\.?\d+$' -and [float]$styleInput -ge 0 -and [float]$styleInput -le 1) {
            $style = [float]$styleInput
        }
    }
    $ConfigRef.Value.voice.stability = $stability
    $ConfigRef.Value.voice.similarityBoost = $similarity
    $ConfigRef.Value.voice.style = $style
}

# Helper to save configuration and test
function Save-ConfigurationAndTest {
    param([PSCustomObject]$Config)

    Write-Host "`nSTEP 3: Saving Configuration" -ForegroundColor Cyan
    Write-Host "═══════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    $Config.apiKey = "loaded_from_env" # Ensure placeholder is set
    
    if (Save-Config -Config $Config) {
        Write-Host "`n🎉 ElevenLabs AI Voice Setup Complete! 🎉" -ForegroundColor Green
        Write-Host "`nConfiguration Summary:" -ForegroundColor Yellow
        Write-Host ("• Enabled: {0}" -f $Config.enabled) -ForegroundColor White
        Write-Host ("• Voice: {0} (ID: {1})" -f $Config.voice.name, $Config.voice.id) -ForegroundColor White
        Write-Host ("• Stability: {0}" -f $Config.voice.stability) -ForegroundColor White
        Write-Host ("• Similarity: {0}" -f $Config.voice.similarityBoost) -ForegroundColor White
        Write-Host ("• Style: {0}" -f $Config.voice.style) -ForegroundColor White
        Write-Host ""
        
        if ($Config.enabled) {
            Write-Host "Testing your new AI voice..." -ForegroundColor Yellow
            try {
                & "$ScriptRoot\say-enhanced.ps1" -Text "Hello! ElevenLabs AI voice synthesis is now configured and ready." -Verbose
                Write-Host "`n[✓] Voice test completed successfully!" -ForegroundColor Green
            } catch {
                Write-Warning ("`n[WARNING] Voice test failed: {0}" -f $_.Exception.Message)
                Write-Host "[INFO] You can test manually with: .\say-enhanced.ps1 -Text ""Test message""" -ForegroundColor Cyan
            }
        } else {
            Write-Warning "[INFO] ElevenLabs is currently disabled. Voice test skipped."
        }
        Write-Host "`nNext steps:" -ForegroundColor Yellow
        Write-Host "• Use WinAssistAI commands; they will use ElevenLabs if enabled." -ForegroundColor White
    } else {
        Speak-Response "Setup failed - could not save configuration."
    }
}

# Function to set voice non-interactively
function Set-ElevenLabsVoiceNonInteractive {
    param(
        [string]$NewVoiceID,
        [string]$NewVoiceName # Optional
    )
    Show-Banner
    Write-Host "Setting ElevenLabs Voice Non-Interactively..." -ForegroundColor Green
    
    $config = if (Test-Path $ConfigPath) {
        Get-Content $ConfigPath -Raw | ConvertFrom-Json
    } else {
        Get-DefaultConfig
    }

    $apiKeyValid = Test-And-SetApiKeyStatus -ConfigRef ([ref]$config)
    if (-not $apiKeyValid) {
        Save-Config -Config $config # Save with enabled:false
        Speak-Response "Cannot set voice. API key is missing or invalid."
        exit 1
    }

    $config.voice.id = $NewVoiceID
    if (-not [string]::IsNullOrWhiteSpace($NewVoiceName)) {
        $config.voice.name = $NewVoiceName
    } else {
        # Attempt to fetch voice name if not provided
        $voices = Get-AvailableVoices -ApiKey $Global:ApiKey
        $foundVoice = $voices | Where-Object {$_.voice_id -eq $NewVoiceID} | Select-Object -First 1
        if ($foundVoice) {
            $config.voice.name = $foundVoice.name
        } else {
            $config.voice.name = ("ID: {0} (Name not fetched)" -f $NewVoiceID)
            Write-Warning ("Could not fetch name for voice ID {0}. Storing ID only." -f $NewVoiceID)
        }
    }
    
    $config.apiKey = "loaded_from_env"
    if (Save-Config -Config $config) {
        Speak-Response ("ElevenLabs voice set to {0}." -f $config.voice.name)
    } else {
        Speak-Response "Failed to save new voice configuration."
    }
}

# Function to list available voices non-interactively
function List-ElevenLabsVoicesNonInteractive {
    Show-Banner
    Write-Host "Fetching available ElevenLabs voices..." -ForegroundColor Green
    $envApiKey = Get-EnvVariable "ELEVENLABS_API_KEY"
    if ([string]::IsNullOrWhiteSpace($envApiKey)) {
        Speak-Response "Cannot list voices. ELEVENLABS_API_KEY not found in .env file."
        exit 1
    }
    $testResult = Test-ApiKey -Key $envApiKey
    if (-not $testResult.Success) {
        Speak-Response ("Cannot list voices. API key is invalid: {0}" -f $testResult.Error)
        exit 1
    }

    $voices = Get-AvailableVoices -ApiKey $envApiKey
    if ($voices) {
        Write-Host "`nAvailable Voices:" -ForegroundColor Green
        $voiceListText = "Available voices are: "
        $voiceDetails = @()
        foreach ($voice in $voices) {
            $detail = "$($voice.name) (ID: $($voice.voice_id))"
            $description = if ($voice.labels.description) { " - $($voice.labels.description)" } else { "" }
            $gender = if ($voice.labels.gender) { " ($($voice.labels.gender))" } else { "" }
            Write-Host ("  {0}{1} ID: {2}{3}" -f $voice.name, $gender, $voice.voice_id, $description) -ForegroundColor White
            $voiceDetails += $detail
        }
        Speak-Response ($voiceListText + ($voiceDetails -join ", "))
    } else {
        Speak-Response "Could not retrieve voices from ElevenLabs."
    }
}

# --- Speak-Response Helper (if not already defined globally, ensure it's here) ---
# Assuming say-enhanced.ps1 is in the same PSScriptRoot for this script too.
$sayEnhancedScriptPath = Join-Path $PSScriptRoot "say-enhanced.ps1"
function Speak-Response { param([string]$Text) Write-Host $Text -ForegroundColor Cyan; if(Test-Path $sayEnhancedScriptPath) { & $sayEnhancedScriptPath -Text $Text } }


# Main execution logic based on parameters
try {
    if ($Help) { Show-Help; exit 0 }

    switch ($PSCmdlet.ParameterSetName) {
        "SetVoice" {
            Set-ElevenLabsVoiceNonInteractive -VoiceID $VoiceID -VoiceName $VoiceName
        }
        "ListVoices" {
            List-ElevenLabsVoicesNonInteractive
        }
        "Interactive" {
            Start-InteractiveSetup
        }
        Default { # Also catches -Interactive if it's the default set
            Start-InteractiveSetup
        }
    }
} catch {
    Speak-Response ("An error occurred in setup: {0}" -f $_.Exception.Message)
    if ($Verbose) {
        Write-Host ("[DEBUG] {0}" -f $_.ScriptStackTrace) -ForegroundColor Gray
    }
    exit 1
}