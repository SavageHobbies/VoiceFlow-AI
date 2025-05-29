<#
.SYNOPSIS
    ElevenLabs AI Voice Setup Wizard
.DESCRIPTION
    Interactive setup wizard for configuring ElevenLabs AI voice synthesis
    in the Talk2Windows system.
.EXAMPLE
    .\setup-elevenlabs.ps1
#>

param(
    [string]$ApiKey = "",
    [switch]$Help,
    [switch]$Verbose
)

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
    .\setup-elevenlabs.ps1              # Interactive setup
    .\setup-elevenlabs.ps1 -ApiKey KEY  # Setup with API key
    .\setup-elevenlabs.ps1 -Help        # Show this help

STEPS:
1. Sign up at https://elevenlabs.io
2. Get your API key from the dashboard
3. Run this setup script
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
        Write-Warning "Failed to get voices: $($_.Exception.Message)"
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
        Write-Host "[✗] Failed to save configuration: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Start-InteractiveSetup {
    Show-Banner
    
    Write-Host "Welcome to the ElevenLabs AI Voice Setup Wizard!" -ForegroundColor Green
    Write-Host ""
    Write-Host "This wizard will help you configure high-quality AI voice synthesis for Talk2Windows." -ForegroundColor White
    Write-Host ""
    
    # Check if already configured
    if (Test-Path $ConfigPath) {
        try {
            $existingConfig = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            if ($existingConfig.enabled -and -not [string]::IsNullOrWhiteSpace($existingConfig.apiKey)) {
                Write-Host "[INFO] ElevenLabs is already configured" -ForegroundColor Yellow
                $reconfigure = Read-Host "Do you want to reconfigure? (y/N)"
                if ($reconfigure -notmatch '^y|yes$') {
                    Write-Host "[SKIP] Setup cancelled" -ForegroundColor Yellow
                    return
                }
            }
        } catch {
            Write-Host "[WARNING] Existing config is corrupted, starting fresh setup" -ForegroundColor Yellow
        }
    }
    
    # Step 1: Get API Key
    Write-Host "STEP 1: ElevenLabs API Key" -ForegroundColor Cyan
    Write-Host "═══════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "You need an ElevenLabs API key to use AI voice synthesis." -ForegroundColor White
    Write-Host ""
    Write-Host "To get your API key:" -ForegroundColor Yellow
    Write-Host "1. Visit: https://elevenlabs.io" -ForegroundColor White
    Write-Host "2. Sign up for a free account" -ForegroundColor White
    Write-Host "3. Go to your Profile settings" -ForegroundColor White
    Write-Host "4. Copy your API key" -ForegroundColor White
    Write-Host ""
    
    if ([string]::IsNullOrWhiteSpace($ApiKey)) {
        $ApiKey = Read-Host "Enter your ElevenLabs API key"
    }
    
    if ([string]::IsNullOrWhiteSpace($ApiKey)) {
        Write-Host "[CANCELLED] Setup cancelled - no API key provided" -ForegroundColor Red
        return
    }
    
    # Step 2: Test API Key
    Write-Host "`nSTEP 2: Testing API Key" -ForegroundColor Cyan
    Write-Host "═══════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Testing your API key..." -ForegroundColor Yellow
    
    $testResult = Test-ApiKey -Key $ApiKey
    
    if (-not $testResult.Success) {
        Write-Host "[✗] API key test failed: $($testResult.Error)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please check:" -ForegroundColor Yellow
        Write-Host "• Your API key is correct" -ForegroundColor White
        Write-Host "• You have internet connection" -ForegroundColor White
        Write-Host "• ElevenLabs service is available" -ForegroundColor White
        return
    }
    
    Write-Host "[✓] API key is valid!" -ForegroundColor Green
    if ($testResult.User.subscription) {
        Write-Host "[INFO] Subscription: $($testResult.User.subscription.tier)" -ForegroundColor Cyan
    }
    Write-Host ""
    
    # Step 3: Voice Selection
    Write-Host "STEP 3: Voice Selection" -ForegroundColor Cyan
    Write-Host "══════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Fetching available voices..." -ForegroundColor Yellow
    
    $voices = Get-AvailableVoices -ApiKey $ApiKey
    
    if (-not $voices) {
        Write-Host "[WARNING] Could not fetch voices, using default (Rachel)" -ForegroundColor Yellow
        $selectedVoice = @{
            voice_id = "21m00Tcm4TlvDq8ikWAM"
            name = "Rachel"
        }
    } else {
        Write-Host ""
        Write-Host "Available voices:" -ForegroundColor Green
        Write-Host ""
        
        for ($i = 0; $i -lt $voices.Count; $i++) {
            $voice = $voices[$i]
            $description = if ($voice.labels.description) { " - $($voice.labels.description)" } else { "" }
            $gender = if ($voice.labels.gender) { " ($($voice.labels.gender))" } else { "" }
            Write-Host "  $($i + 1). $($voice.name)$gender$description" -ForegroundColor White
        }
        
        Write-Host ""
        $voiceChoice = Read-Host "Select voice number (1-$($voices.Count)) or press Enter for default (Rachel)"
        
        if ($voiceChoice -match '^\d+$' -and [int]$voiceChoice -ge 1 -and [int]$voiceChoice -le $voices.Count) {
            $selectedVoice = $voices[[int]$voiceChoice - 1]
        } else {
            $selectedVoice = $voices | Where-Object { $_.name -eq "Rachel" } | Select-Object -First 1
            if (-not $selectedVoice) {
                $selectedVoice = $voices[0] # Fall back to first voice
            }
        }
        
        Write-Host "[✓] Selected voice: $($selectedVoice.name)" -ForegroundColor Green
    }
    
    # Step 4: Advanced Settings
    Write-Host "`nSTEP 4: Voice Settings" -ForegroundColor Cyan
    Write-Host "═════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Configure voice quality settings:" -ForegroundColor White
    Write-Host ""
    
    $useAdvanced = Read-Host "Use advanced settings? (y/N)"
    
    $stability = 0.5
    $similarity = 0.75
    $style = 0.0
    
    if ($useAdvanced -match '^y|yes$') {
        Write-Host ""
        Write-Host "Stability (0.0-1.0): Controls voice consistency" -ForegroundColor Yellow
        $stabilityInput = Read-Host "Enter stability (default: 0.5)"
        if ($stabilityInput -match '^\d*\.?\d+$' -and [float]$stabilityInput -ge 0 -and [float]$stabilityInput -le 1) {
            $stability = [float]$stabilityInput
        }
        
        Write-Host ""
        Write-Host "Similarity Boost (0.0-1.0): How closely to match the original voice" -ForegroundColor Yellow
        $similarityInput = Read-Host "Enter similarity boost (default: 0.75)"
        if ($similarityInput -match '^\d*\.?\d+$' -and [float]$similarityInput -ge 0 -and [float]$similarityInput -le 1) {
            $similarity = [float]$similarityInput
        }
        
        Write-Host ""
        Write-Host "Style (0.0-1.0): Amount of style to apply" -ForegroundColor Yellow
        $styleInput = Read-Host "Enter style (default: 0.0)"
        if ($styleInput -match '^\d*\.?\d+$' -and [float]$styleInput -ge 0 -and [float]$styleInput -le 1) {
            $style = [float]$styleInput
        }
    }
    
    # Step 5: Create Configuration
    Write-Host "`nSTEP 5: Saving Configuration" -ForegroundColor Cyan
    Write-Host "═══════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    $config = Get-DefaultConfig
    $config.enabled = $true
    $config.apiKey = $ApiKey
    $config.voice.id = $selectedVoice.voice_id
    $config.voice.name = $selectedVoice.name
    $config.voice.stability = $stability
    $config.voice.similarityBoost = $similarity
    $config.voice.style = $style
    
    if (Save-Config -Config $config) {
        Write-Host ""
        Write-Host "🎉 ElevenLabs AI Voice Setup Complete! 🎉" -ForegroundColor Green
        Write-Host ""
        Write-Host "Configuration Summary:" -ForegroundColor Yellow
        Write-Host "• Voice: $($selectedVoice.name)" -ForegroundColor White
        Write-Host "• Stability: $stability" -ForegroundColor White
        Write-Host "• Similarity: $similarity" -ForegroundColor White
        Write-Host "• Style: $style" -ForegroundColor White
        Write-Host "• Fallback to Windows TTS: Enabled" -ForegroundColor White
        Write-Host ""
        
        # Test the configuration
        Write-Host "Testing your new AI voice..." -ForegroundColor Yellow
        Write-Host ""
        
        try {
            & "$ScriptRoot\say-enhanced.ps1" -Text "Hello! ElevenLabs AI voice synthesis is now configured and ready for Talk2Windows. This voice sounds much more natural than traditional text to speech systems." -Verbose
            Write-Host ""
            Write-Host "[✓] Voice test completed successfully!" -ForegroundColor Green
        } catch {
            Write-Host "[WARNING] Voice test failed: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "[INFO] You can test manually with: .\say-enhanced.ps1 -Test" -ForegroundColor Cyan
        }
        
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "• Test voices: .\say-enhanced.ps1 -ListVoices" -ForegroundColor White
        Write-Host "• Test system: .\say-enhanced.ps1 -Test" -ForegroundColor White
        Write-Host "• Use normally: All Talk2Windows scripts now use AI voice!" -ForegroundColor White
        Write-Host ""
        
    } else {
        Write-Host "[✗] Setup failed - could not save configuration" -ForegroundColor Red
    }
}

# Main execution
try {
    if ($Help) {
        Show-Help
        exit 0
    }
    
    Start-InteractiveSetup
    
} catch {
    Write-Host "[ERROR] Setup failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($Verbose) {
        Write-Host "[DEBUG] $($_.ScriptStackTrace)" -ForegroundColor Gray
    }
    exit 1
}