<#
.SYNOPSIS
    Clears the conversation history file used by converse-with-ai.ps1.
.DESCRIPTION
    This script deletes the conversation_history.json file from the data
    directory, effectively clearing the context for future AI conversations.
    It then announces that the history has been cleared.
.EXAMPLE
    .\clear-conversation-history.ps1
#>

# --- Script Paths ---
$sayEnhancedScriptPath = Join-Path $PSScriptRoot "say-enhanced.ps1"
if (-not (Test-Path $sayEnhancedScriptPath)) {
    Write-Host ("Error: say-enhanced.ps1 not found at {0}. Cannot speak confirmation." -f $sayEnhancedScriptPath)
    # We can still proceed with deletion, but won't be able to speak.
}

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$historyFilePath = Join-Path $projectRoot "data\conversation_history.json"

# --- Main Logic ---
$message = ""

if (Test-Path $historyFilePath) {
    try {
        Remove-Item $historyFilePath -Force -ErrorAction Stop
        $message = "Conversation history has been cleared."
        Write-Host "[INFO] $message File deleted: $historyFilePath" -ForegroundColor Green
    } catch {
        $message = ("Error trying to clear conversation history: {0}" -f $_.Exception.Message)
        Write-Error "[ERROR] $message"
    }
} else {
    $message = "No conversation history found to clear."
    Write-Host "[INFO] $message File did not exist: $historyFilePath" -ForegroundColor Yellow
}

# Announce the result
if (Test-Path $sayEnhancedScriptPath) {
    try {
        & $sayEnhancedScriptPath -Text $message
    } catch {
        Write-Error ("Failed to execute say-enhanced.ps1 for confirmation: {0}" -f $_.Exception.Message)
        Write-Host "Fallback TTS (console only): $message" # Fallback if say-enhanced fails
    }
} else {
    Write-Host $message # Console output if say-enhanced.ps1 is missing
}

exit 0
