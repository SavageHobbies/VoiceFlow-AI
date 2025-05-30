<#
.SYNOPSIS
    Connects to a conversational AI (initially OpenAI) to get a response
    to user input and speaks the response.
.DESCRIPTION
    This script takes user's transcribed text, sends it to an AI provider
    configured via .env settings (AI_PROVIDER, OPENAI_API_KEY, OPENAI_MODEL),
    retrieves the AI's response, and uses say-enhanced.ps1 to speak it.
.PARAMETER UserInputText
    The text transcribed from the user's speech.
.EXAMPLE
    .\converse-with-ai.ps1 -UserInputText "What is the capital of France?"
#>
param (
    [Parameter(Mandatory=$true)]
    [string]$UserInputText
)

# Function to load .env file from repository root
function Get-EnvVariable {
    param (
        [string]$KeyName
    )
    $envFilePath = Join-Path $PSScriptRoot "..\.env" # Assumes script is in 'scripts' subdir
    if (-not (Test-Path $envFilePath)) {
        # Fallback for execution from root or other locations if $PSScriptRoot is not 'scripts'
        $altEnvFilePath = Join-Path (Resolve-Path .).Path ".env"
        if (Test-Path $altEnvFilePath) {
            $envFilePath = $altEnvFilePath
        } else {
            Write-Warning ("env file not found at {0} or {1}" -f $envFilePath, $altEnvFilePath)
            return $null
        }
    }

    try {
        $envContent = Get-Content $envFilePath -ErrorAction Stop
        foreach ($line in $envContent) {
            if ($line -match "^\s*$KeyName\s*=\s*(.+)\s*") {
                return $matches[1].Trim()
            }
        }
        Write-Warning ("Key '{0}' not found in .env file: {1}" -f $KeyName, $envFilePath)
        return $null
    } catch {
        Write-Warning ("Error reading .env file at {0}: {1}" -f $envFilePath, $_.Exception.Message)
        return $null
    }
}

# --- Script Paths and Settings ---
$sayEnhancedScriptPath = Join-Path $PSScriptRoot "say-enhanced.ps1"
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$aiConfigPath = Join-Path $projectRoot "config\ai_config.json"
$historyFilePath = Join-Path $projectRoot "data\conversation_history.json"
$maxHistoryMessages = 6

if (-not (Test-Path $sayEnhancedScriptPath)) {
    Write-Host ("CRITICAL ERROR: say-enhanced.ps1 not found at {0}. Cannot speak." -f $sayEnhancedScriptPath)
    exit 1
}

# --- Function to Speak Response ---
function Speak-Response {
    param ([string]$TextToSpeak)
    try {
        Write-Host ("AI Response: {0}" -f $TextToSpeak)
        & $sayEnhancedScriptPath -Text $TextToSpeak
    } catch {
        Write-Error ("Failed to execute say-enhanced.ps1: {0}" -f $_.Exception.Message)
        # Fallback to console if say-enhanced fails
        Write-Host ("Fallback TTS (console only): {0}" -f $TextToSpeak)
    }
}

# --- Main Logic ---

# --- Load AI Configuration from ai_config.json ---
$currentProviderName = "OpenAI" # Default
$currentModel = "gpt-3.5-turbo" # Default
$apiKeyEnvName = "OPENAI_API_KEY" # Default

if (Test-Path $aiConfigPath) {
    try {
        $aiConfig = Get-Content $aiConfigPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        if ($aiConfig -and $aiConfig.default_provider -and $aiConfig.providers.$($aiConfig.default_provider)) {
            $currentProviderName = $aiConfig.default_provider
            $providerSettings = $aiConfig.providers.$currentProviderName
            $currentModel = $providerSettings.selected_model
            $apiKeyEnvName = $providerSettings.api_key_env
            Write-Host ("[INFO] Loaded AI config: Provider={0}, Model={1}, APIKeyEnv={2}" -f $currentProviderName, $currentModel, $apiKeyEnvName) -ForegroundColor Gray
        } else {
            Write-Warning "ai_config.json is invalid or default_provider not properly configured. Using defaults." # No vars to format
            # Defaults already set, so just log
        }
    } catch {
        Write-Warning ("Could not load or parse ai_config.json: {0}. Using defaults." -f $_.Exception.Message)
        # Defaults already set
    }
} else {
    Write-Warning ("ai_config.json not found at {0}. Using defaults and attempting to read AI_PROVIDER from .env as fallback." -f $aiConfigPath)
    # Fallback to direct .env reading for AI_PROVIDER if ai_config.json is missing
    $envAiProvider = Get-EnvVariable "AI_PROVIDER"
    if (-not [string]::IsNullOrWhiteSpace($envAiProvider)) {
        $currentProviderName = $envAiProvider 
        # Assuming if AI_PROVIDER is set in .env, the other defaults for OpenAI are intended
        $apiKeyEnvName = if($currentProviderName -eq "OpenAI") { "OPENAI_API_KEY" } else { "" } # Simplistic fallback
        $currentModel = if($currentProviderName -eq "OpenAI") { "gpt-3.5-turbo" } else { "" }
         Write-Host ("[INFO] Fallback: Using AI_PROVIDER='{0}' from .env." -f $currentProviderName) -ForegroundColor Yellow
    } else {
        Speak-Response "AI configuration file (ai_config.json) not found and AI_PROVIDER not set in .env. Cannot determine AI provider."
        exit 1
    }
}

# --- Fetch API Key from .env based on configured environment variable name ---
$apiKey = Get-EnvVariable $apiKeyEnvName
if ([string]::IsNullOrWhiteSpace($apiKey)) {
    Speak-Response ("{0} not found in .env file for {1} provider. Please configure it." -f $apiKeyEnvName, $currentProviderName)
    exit 1
}

# --- Provider-Specific Logic ---
if ($currentProviderName -eq "OpenAI") {
    # $currentModel is already set from ai_config.json or default
    $openAiApiUrl = "https://api.openai.com/v1/chat/completions"

    # --- Load Conversation History ---
    $currentHistory = @()
    if (Test-Path $historyFilePath) {
        try {
            $loadedHistory = (Get-Content $historyFilePath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop).history
            if ($null -ne $loadedHistory) {
                $currentHistory = $loadedHistory
                Write-Host "[INFO] Loaded $($currentHistory.Count) messages from conversation history." -ForegroundColor Gray
            }
        } catch {
            Write-Warning ("Could not load or parse conversation history from {0}: {1}. Starting with empty history." -f $historyFilePath, $_.Exception.Message)
            $currentHistory = @()
        }
    }

    # --- Prepare messages for AI (History + Current User Input) ---
    $messagesForApi = @()
    $messagesForApi += $currentHistory # Add historical messages
    $messagesForApi += @{role = "user"; content = $UserInputText } # Add current user input

    $headers = @{
        "Authorization" = "Bearer $apiKey" # Use $apiKey fetched via $apiKeyEnvName
        "Content-Type"  = "application/json"
    }

    $body = @{
        model    = $currentModel # Use $currentModel from ai_config.json or default
        messages = $messagesForApi
        # temperature = 0.7 # Optional: Adjust for creativity
    } | ConvertTo-Json -Depth 5

    Write-Host "Sending request to OpenAI..."
    Write-Host ("Model: {0}" -f $currentModel)       # Use $currentModel
    # Write-Host "Request Body (excluding exact user content for brevity in logs): $($body | ConvertFrom-Json | Select-Object -Property model, messages | ForEach-Object {$_.messages = $_.messages.Count; $_} | ConvertTo-Json -Depth 3)"
    
    try {
        $response = Invoke-RestMethod -Uri $openAiApiUrl -Headers $headers -Method Post -Body $body -TimeoutSec 60
        
        $aiReply = $response.choices[0].message.content.Trim()

        if ([string]::IsNullOrWhiteSpace($aiReply)) {
            Speak-Response "The AI returned an empty response."
        } else {
            Speak-Response $aiReply

            # --- Save Updated History ---
            $currentHistory += @{role = "user"; content = $UserInputText }
            $currentHistory += @{role = "assistant"; content = $aiReply }

            # Trim history
            if ($currentHistory.Count -gt $maxHistoryMessages) {
                Write-Host ("[INFO] Trimming conversation history from {0} to {1} messages." -f $currentHistory.Count, $maxHistoryMessages) -ForegroundColor Gray
                $currentHistory = $currentHistory[($currentHistory.Count - $maxHistoryMessages)..($currentHistory.Count - 1)]
            }

            try {
                $dataDir = Split-Path $historyFilePath
                if (-not (Test-Path $dataDir)) {
                    New-Item -ItemType Directory -Force -Path $dataDir | Out-Null
                    Write-Host ("[INFO] Created data directory: {0}" -f $dataDir) -ForegroundColor Gray
                }
                @{history = $currentHistory} | ConvertTo-Json -Depth 5 | Set-Content -Path $historyFilePath -Encoding UTF8 -ErrorAction Stop
                Write-Host ("[INFO] Conversation history saved ({0} messages)." -f $currentHistory.Count) -ForegroundColor Gray
            } catch {
                Write-Warning ("Failed to save conversation history to {0}: {1}" -f $historyFilePath, $_.Exception.Message)
            }
        }
    } catch {
        $errorMessage = ("Error communicating with OpenAI: {0}" -f $_.Exception.Message)
        if ($_.Exception.Response) {
            $errorResponse = $_.Exception.Response | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($errorResponse -and $errorResponse.error -and $errorResponse.error.message) {
                $errorMessage += (" Details: {0}" -f $errorResponse.error.message)
            } elseif ($_.Exception.Response.StatusCode) {
                 $errorMessage += (" Status Code: {0}" -f $_.Exception.Response.StatusCode)
            }
        }
        Write-Error $errorMessage
        Speak-Response "Sorry, I couldn't connect to the AI or there was an error. $errorMessage"
    }

} else {
    # Placeholder for other AI providers
    Speak-Response "AI Provider '$currentProviderName' is not supported by this script yet."
    # Example for future expansion:
    # if ($currentProviderName -eq "Gemini") {
    #   # $apiKey is already fetched using $apiKeyEnvName which should be "GEMINI_API_KEY" from ai_config.json
    #   if ([string]::IsNullOrWhiteSpace($apiKey)) {
    #       Speak-Response "Gemini API key (via $apiKeyEnvName) is not configured in .env."
    #       exit 1
    #   }
    #   # ... Gemini API call logic using $apiKey and $currentModel ...
    # }
    exit 1
}

exit 0
