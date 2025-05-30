<#
.SYNOPSIS
    Manages AI provider configurations for converse-with-ai.ps1.
.DESCRIPTION
    Allows listing AI providers, getting settings for a provider,
    setting the default AI provider, and setting the selected model for a provider.
    Configuration is stored in config/ai_config.json.
.PARAMETER ListProviders
    Lists all available AI providers configured in ai_config.json.
.PARAMETER GetProviderSettings
    Gets the current settings for a specified AI provider.
.PARAMETER SetDefaultProvider
    Sets the specified AI provider as the default.
.PARAMETER SetModel
    Sets the selected model for a specified AI provider.
.PARAMETER ProviderName
    The name of the AI provider to interact with (e.g., OpenAI).
.PARAMETER ModelName
    The name of the model to set for a provider (e.g., gpt-4).
.EXAMPLE
    .\set-ai-provider.ps1 -ListProviders
    .\set-ai-provider.ps1 -GetProviderSettings -ProviderName OpenAI
    .\set-ai-provider.ps1 -SetDefaultProvider -ProviderName OpenAI
    .\set-ai-provider.ps1 -SetModel -ProviderName OpenAI -ModelName gpt-4
#>

[CmdletBinding(DefaultParameterSetName = "None")]
param (
    [Parameter(ParameterSetName = "List", Mandatory = $true)]
    [switch]$ListProviders,

    [Parameter(ParameterSetName = "GetSettings", Mandatory = $true)]
    [switch]$GetProviderSettings,
    [Parameter(ParameterSetName = "GetSettings", Mandatory = $true)]
    [string]$ProviderNameForGet,

    [Parameter(ParameterSetName = "SetDefault", Mandatory = $true)]
    [switch]$SetDefaultProvider,
    [Parameter(ParameterSetName = "SetDefault", Mandatory = $true)]
    [string]$ProviderNameToSetDefault,

    [Parameter(ParameterSetName = "SetModel", Mandatory = $true)]
    [switch]$SetModel,
    [Parameter(ParameterSetName = "SetModel", Mandatory = $true)]
    [string]$ProviderNameForModel,
    [Parameter(ParameterSetName = "SetModel", Mandatory = $true)]
    [string]$ModelName
)

# --- Script Paths and Defaults ---
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$configDir = Join-Path $projectRoot "config"
$aiConfigPath = Join-Path $configDir "ai_config.json"

$defaultAiConfig = @{
    default_provider = "OpenAI"
    providers        = @{
        OpenAI = @{
            api_key_env      = "OPENAI_API_KEY"
            selected_model   = "gpt-3.5-turbo"
            available_models = @(
                "gpt-4",
                "gpt-4-turbo",
                "gpt-3.5-turbo"
            )
        }
    }
}

# --- Function to Speak Response ---
$sayEnhancedScriptPath = Join-Path $PSScriptRoot "say-enhanced.ps1"
function Speak-Response {
    param ([string]$TextToSpeak)
    Write-Host $TextToSpeak -ForegroundColor Cyan
    if (Test-Path $sayEnhancedScriptPath) {
        try {
            & $sayEnhancedScriptPath -Text $TextToSpeak
        } catch {
            Write-Warning ("Failed to execute say-enhanced.ps1 for speech: {0}" -f $_.Exception.Message)
        }
    } else {
        Write-Warning ("say-enhanced.ps1 not found at {0}. Cannot speak response." -f $sayEnhancedScriptPath)
    }
}

# --- Ensure Config Directory Exists ---
if (-not (Test-Path $configDir)) {
    try {
        New-Item -ItemType Directory -Force -Path $configDir | Out-Null
        Write-Host ("[INFO] Created config directory: {0}" -f $configDir) -ForegroundColor Gray
    } catch {
        Speak-Response ("Error creating config directory {0}: {1}" -f $configDir, $_.Exception.Message)
        exit 1
    }
}

# --- Load or Create AI Configuration ---
$aiConfig = $null
if (Test-Path $aiConfigPath) {
    try {
        $aiConfig = Get-Content $aiConfigPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    } catch {
        Speak-Response ("Error reading or parsing {0}: {1}. Check file integrity." -f $aiConfigPath, $_.Exception.Message)
        # Allow script to proceed if intent is to overwrite with defaults or for some operations.
    }
}

if ($null -eq $aiConfig -or $PSCmdlet.ParameterSetName -eq "None") { # Initialize if null or no params
    if ($null -eq $aiConfig) {
         Write-Warning ("{0} not found or invalid. Initializing with default configuration." -f $aiConfigPath)
    }
    $aiConfig = $defaultAiConfig | ConvertTo-Pscustomobject # Ensure it's a PSCustomObject for property assignment
}


# --- Main Logic based on Parameter Set ---
try {
    switch ($PSCmdlet.ParameterSetName) {
        "List" {
            $providerNames = ($aiConfig.providers.PSObject.Properties).Name
            if ($providerNames.Count -gt 0) {
                $listOutput = ("Available AI providers are: {0}." -f ($providerNames -join ', '))
                Speak-Response $listOutput
            } else {
                Speak-Response "No AI providers configured."
            }
        }
        "GetSettings" {
            if ($aiConfig.providers.$ProviderNameForGet) {
                $settings = $aiConfig.providers.$ProviderNameForGet
                $settingsOutput = ("Settings for {0}: Selected model is {1}. API Key Env Var: {2}. Available models: {3}." -f `
                    $ProviderNameForGet, $settings.selected_model, $settings.api_key_env, ($settings.available_models -join ', '))
                Speak-Response $settingsOutput
            } else {
                Speak-Response ("Provider '{0}' not found in configuration." -f $ProviderNameForGet)
            }
        }
        "SetDefault" {
            if ($aiConfig.providers.$ProviderNameToSetDefault) {
                $aiConfig.default_provider = $ProviderNameToSetDefault
                $aiConfig | ConvertTo-Json -Depth 5 | Set-Content -Path $aiConfigPath -Encoding UTF8 -ErrorAction Stop
                Speak-Response ("Default AI provider set to '{0}'." -f $ProviderNameToSetDefault)
            } else {
                Speak-Response ("Cannot set default: Provider '{0}' not found in configuration." -f $ProviderNameToSetDefault)
            }
        }
        "SetModel" {
            if ($aiConfig.providers.$ProviderNameForModel) {
                # Optional: Validate if $ModelName is in $aiConfig.providers.$ProviderNameForModel.available_models
                # For now, directly setting it.
                $aiConfig.providers.$ProviderNameForModel.selected_model = $ModelName
                $aiConfig | ConvertTo-Json -Depth 5 | Set-Content -Path $aiConfigPath -Encoding UTF8 -ErrorAction Stop
                Speak-Response ("Selected model for '{0}' set to '{1}'." -f $ProviderNameForModel, $ModelName)
            } else {
                Speak-Response ("Cannot set model: Provider '{0}' not found in configuration." -f $ProviderNameForModel)
            }
        }
        Default {
             if ($PSCmdlet.ParameterSetName -eq "None") {
                Speak-Response "No action specified. Use -ListProviders, -GetProviderSettings, -SetDefaultProvider, or -SetModel."
             } else {
                Speak-Response "Invalid parameter combination for set-ai-provider.ps1."
             }
        }
    }
} catch {
    Speak-Response ("An error occurred: {0}" -f $_.Exception.Message)
    exit 1
}

exit 0
