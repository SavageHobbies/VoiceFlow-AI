<#
.SYNOPSIS
    Provides a text-based UI for managing key WinAssistAI settings.
.DESCRIPTION
    Allows users to configure Wake Word, ElevenLabs settings (API Key, Voice),
    and AI provider settings (Default Provider, Model) through an interactive menu.
    It reads from and writes to .env, config/elevenlabs.json, and config/ai_config.json.
.EXAMPLE
    .\configure-assistant.ps1
#>

# --- Script Setup ---
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$dotEnvPath = Join-Path $projectRoot ".env"
$elevenLabsConfigPath = Join-Path $projectRoot "config\elevenlabs.json"
$aiConfigPath = Join-Path $projectRoot "config\ai_config.json"

# Ensure config directory exists for JSON files (data dir handled by converse-with-ai.ps1)
$configDir = Join-Path $projectRoot "config"
if (-not (Test-Path $configDir)) {
    try {
        New-Item -ItemType Directory -Force -Path $configDir | Out-Null
        Write-Host ("[INFO] Created config directory: {0}" -f $configDir) -ForegroundColor Gray
    } catch {
        Write-Error ("Error creating config directory {0}: {1}" -f $configDir, $_.Exception.Message)
        # Continue, specific file operations will handle missing files later
    }
}


# --- Helper Function: Get-EnvVariable ---
function Get-EnvVariable {
    param (
        [string]$KeyName,
        [string]$DefaultValue = $null
    )
    if (-not (Test-Path $dotEnvPath)) {
        Write-Warning (".env file not found at {0}" -f $dotEnvPath)
        return $DefaultValue
    }
    try {
        $envContent = Get-Content $dotEnvPath -ErrorAction Stop
        foreach ($line in $envContent) {
            if ($line -match "^\s*$KeyName\s*=\s*(.+)\s*") {
                return $matches[1].Trim()
            }
        }
        # Write-Warning "Key '$KeyName' not found in .env file. Using default if provided."
        return $DefaultValue
    } catch {
        Write-Warning ("Error reading .env file at {0}: {1}" -f $dotEnvPath, $_.Exception.Message)
        return $DefaultValue
    }
}

# --- Helper Function: Set-EnvVariable ---
function Set-EnvVariable {
    param (
        [string]$Name,
        [string]$Value
    )
    $lines = @()
    $keyFound = $false
    $updatedLine = "$Name=$Value"

    if (Test-Path $dotEnvPath) {
        $lines = Get-Content $dotEnvPath -ErrorAction SilentlyContinue
    } else {
        Write-Host ".env file not found. Creating it." -ForegroundColor Yellow
    }

    $newLines = for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^\s*$Name\s*=") {
            $lines[$i] = $updatedLine
            $keyFound = $true
            $lines[$i] # Output updated line
        } elseif ($lines[$i] -match "^\s*#\s*$Name\s*=") { # Update commented out key
            $lines[$i] = $updatedLine
            $keyFound = $true
            $lines[$i] # Output updated line
        }
        else {
            $lines[$i] # Output existing line
        }
    }

    if (-not $keyFound) {
        $newLines += $updatedLine
    }

    try {
        Set-Content -Path $dotEnvPath -Value $newLines -Encoding UTF8 -Force -ErrorAction Stop
        Write-Host "Successfully updated '$Name' in .env file." -ForegroundColor Green
    } catch {
        Write-Error ("Failed to write to .env file at {0}: {1}" -f $dotEnvPath, $_.Exception.Message)
    }
}

# --- UI Helper: PressEnterToContinue ---
function PressEnterToContinue {
    Write-Host ""
    Read-Host "Press Enter to return to the main menu..."
}

# --- Configuration Functions ---

function Configure-WakeWord {
    Clear-Host
    Write-Host "--- Configure Wake Word ---" -ForegroundColor Yellow
    $currentWakeWord = Get-EnvVariable -KeyName "WAKE_WORD" -DefaultValue "COMPUTER"
    Write-Host ("Current Wake Word: {0}" -f $currentWakeWord)

    $newWakeWord = Read-Host ("Enter new Wake Word (or press Enter to keep current '{0}')" -f $currentWakeWord)
    if (-not [string]::IsNullOrWhiteSpace($newWakeWord) -and $newWakeWord -ne $currentWakeWord) {
        Set-EnvVariable -Name "WAKE_WORD" -Value $newWakeWord.ToUpper()
        Write-Host "Wake Word updated. You MUST restart the assistant (e.g., by running start-with-serenade.ps1) for this change to take full effect in Serenade." -ForegroundColor Yellow
    } else {
        Write-Host "Wake Word not changed."
    }
    PressEnterToContinue
}

function Configure-ElevenLabs {
    Clear-Host
    Write-Host "--- Configure ElevenLabs ---" -ForegroundColor Yellow
    $apiKey = Get-EnvVariable -KeyName "ELEVENLABS_API_KEY"

    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        Write-Host "ElevenLabs API Key is NOT set in .env file." -ForegroundColor Red
        $setApiKeyNow = Read-Host "Do you want to enter/update the API Key now? (y/n)"
        if ($setApiKeyNow -match '^y') {
            $newApiKey = Read-Host "Enter your ElevenLabs API Key"
            if (-not [string]::IsNullOrWhiteSpace($newApiKey)) {
                Set-EnvVariable -Name "ELEVENLABS_API_KEY" -Value $newApiKey
                $apiKey = $newApiKey # Use for current session
            } else {
                Write-Host "API Key not provided. ElevenLabs configuration cannot proceed fully."
                PressEnterToContinue
                return
            }
        } else {
            Write-Host "API Key not set. ElevenLabs will be disabled or use fallback TTS."
            # Ensure config reflects disabled state if key is missing
            try {
                & (Join-Path $PSScriptRoot "setup-elevenlabs.ps1") # This will test key and set enabled=false if missing
            } catch { Write-Warning "Error running setup-elevenlabs.ps1: $($_.Exception.Message)"}
            PressEnterToContinue
            return
        }
    } else {
        Write-Host "ElevenLabs API Key is currently set in .env."
        $updateApiKey = Read-Host "Do you want to update the API Key? (y/n)"
        if ($updateApiKey -match '^y') {
            $newApiKey = Read-Host "Enter your new ElevenLabs API Key (or press Enter to keep current)"
            if (-not [string]::IsNullOrWhiteSpace($newApiKey)) {
                Set-EnvVariable -Name "ELEVENLABS_API_KEY" -Value $newApiKey
            }
        }
    }
    
    Write-Host "`nListing available voices..."
    try {
        & (Join-Path $PSScriptRoot "setup-elevenlabs.ps1") -ListAvailableVoices
    } catch {
        Write-Error ("Failed to list voices: {0}" -f $_.Exception.Message)
        PressEnterToContinue
        return
    }

    $voiceId = Read-Host "`nEnter the Voice ID to use (or press Enter to skip)"
    if (-not [string]::IsNullOrWhiteSpace($voiceId)) {
        $voiceName = Read-Host "Enter a friendly name for this voice (optional, press Enter to skip)"
        try {
            if (-not [string]::IsNullOrWhiteSpace($voiceName)) {
                & (Join-Path $PSScriptRoot "setup-elevenlabs.ps1") -SetVoice -VoiceID $voiceId -VoiceName $voiceName
            } else {
                & (Join-Path $PSScriptRoot "setup-elevenlabs.ps1") -SetVoice -VoiceID $voiceId
            }
        } catch {
            Write-Error "Failed to set voice: $($_.Exception.Message)"
        }
    } else {
        Write-Host "Voice selection skipped."
    }
    PressEnterToContinue
}

function Configure-AI {
    Clear-Host
    Write-Host "--- Configure Conversational AI ---" -ForegroundColor Yellow
    
    $setAiProviderScript = Join-Path $PSScriptRoot "set-ai-provider.ps1"
    if (-not (Test-Path $setAiProviderScript)) {
        Write-Error "$setAiProviderScript not found. Cannot configure AI."
        PressEnterToContinue
        return
    }

    Write-Host "`nAvailable AI Providers:"
    try {
        & $setAiProviderScript -ListProviders
    } catch { Write-Error ("Failed to list AI providers: {0}" -f $_.Exception.Message); PressEnterToContinue; return }
    
    $newDefaultProvider = Read-Host "Enter the name of the provider to set as default (e.g., OpenAI, or press Enter to skip)"
    if (-not [string]::IsNullOrWhiteSpace($newDefaultProvider)) {
        try {
            & $setAiProviderScript -SetDefaultProvider -ProviderNameToSetDefault $newDefaultProvider
        } catch { Write-Error ("Failed to set default provider: {0}" -f $_.Exception.Message) }
    }

    # Get current default provider to configure its model
    $currentDefaultProvider = "OpenAI" # Fallback
    try {
        $aiConf = Get-Content $aiConfigPath -Raw | ConvertFrom-Json
        $currentDefaultProvider = $aiConf.default_provider
    } catch { Write-Warning "Could not read current default provider from $aiConfigPath. Assuming '$currentDefaultProvider'."}

    Write-Host ("`nConfiguring model for provider: {0}" -f $currentDefaultProvider)
    Write-Host ("Available models for {0} (from config file):" -f $currentDefaultProvider)
    try {
        & $setAiProviderScript -GetProviderSettings -ProviderNameForGet $currentDefaultProvider
    } catch { Write-Error ("Failed to get provider settings: {0}" -f $_.Exception.Message) }

    $newModel = Read-Host ("Enter the model name to use for {0} (e.g., gpt-4, or press Enter to skip)" -f $currentDefaultProvider)
    if (-not [string]::IsNullOrWhiteSpace($newModel)) {
        try {
            & $setAiProviderScript -SetModel -ProviderNameForModel $currentDefaultProvider -ModelName $newModel
        } catch { Write-Error ("Failed to set model: {0}" -f $_.Exception.Message) }
    }

    Write-Host ("`nReminder: Ensure the API key for {0} (e.g., {1}) is set in your .env file." -f $currentDefaultProvider, $aiConf.providers.$currentDefaultProvider.api_key_env) -ForegroundColor Yellow
    PressEnterToContinue
}

function View-ConfigurationSummary {
    Clear-Host
    Write-Host "--- Configuration Summary ---" -ForegroundColor Yellow

    # Wake Word
    $wakeWord = Get-EnvVariable -KeyName "WAKE_WORD" -DefaultValue "Not Set"
    Write-Host "`n[Wake Word]"
    Write-Host ("  Wake Word (.env): {0}" -f $wakeWord)

    # ElevenLabs
    Write-Host "`n[ElevenLabs TTS]"
    $elevenLabsApiKey = Get-EnvVariable -KeyName "ELEVENLABS_API_KEY"
    $elevenLabsApiKeySet = if ([string]::IsNullOrWhiteSpace($elevenLabsApiKey)) { "Not Set" } else { "Set" }
    Write-Host ("  API Key Status (.env): {0}" -f $elevenLabsApiKeySet)
    if (Test-Path $elevenLabsConfigPath) {
        try {
            $elConfig = Get-Content $elevenLabsConfigPath -Raw | ConvertFrom-Json
            Write-Host ("  Enabled (config/elevenlabs.json): {0}" -f $elConfig.enabled)
            Write-Host ("  Selected Voice (config/elevenlabs.json): {0} (ID: {1})" -f $elConfig.voice.name, $elConfig.voice.id)
        } catch { Write-Warning ("  Could not read config/elevenlabs.json: {0}" -f $_.Exception.Message)}
    } else {
        Write-Host "  config/elevenlabs.json: Not found (Run ElevenLabs setup to create)"
    }

    # AI Configuration
    Write-Host "`n[Conversational AI]"
    if (Test-Path $aiConfigPath) {
        try {
            $aiConfig = Get-Content $aiConfigPath -Raw | ConvertFrom-Json
            $defaultProvider = $aiConfig.default_provider
            Write-Host ("  Default Provider (config/ai_config.json): {0}" -f $defaultProvider)
            if ($aiConfig.providers.$defaultProvider) {
                $providerSettings = $aiConfig.providers.$defaultProvider
                Write-Host ("    Selected Model: {0}" -f $providerSettings.selected_model)
                Write-Host ("    API Key Env Var: {0}" -f $providerSettings.api_key_env)
                $apiKeyValue = Get-EnvVariable -KeyName $providerSettings.api_key_env
                $apiKeyForProviderSet = if ([string]::IsNullOrWhiteSpace($apiKeyValue)) { "Not Set" } else { "Set" }
                Write-Host ("    '{0}' Status (.env): {1}" -f $providerSettings.api_key_env, $apiKeyForProviderSet)
            } else {
                Write-Host ("    Settings for default provider '{0}' not found." -f $defaultProvider)
            }
        } catch { Write-Warning ("  Could not read config/ai_config.json: {0}" -f $_.Exception.Message)}
    } else {
        Write-Host "  config/ai_config.json: Not found (Run AI setup or use defaults in converse-with-ai.ps1)"
    }
    PressEnterToContinue
}


# --- Main Menu Loop ---
$choice = ""
do {
    Clear-Host
    Write-Host "===== WinAssistAI Configuration Menu =====" -ForegroundColor Green
    Write-Host "1. Configure Wake Word"
    Write-Host "2. Configure ElevenLabs TTS (API Key & Voice)"
    Write-Host "3. Configure Conversational AI (Provider & Model)"
    Write-Host "4. View Configuration Summary"
    Write-Host "5. Exit"
    Write-Host "========================================"
    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        "1" { Configure-WakeWord }
        "2" { Configure-ElevenLabs }
        "3" { Configure-AI }
        "4" { View-ConfigurationSummary }
        "5" { Write-Host "Exiting configuration utility." }
        default {
            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
            PressEnterToContinue
        }
    }
} while ($choice -ne "5")

Write-Host "Configuration utility finished."
exit 0
