<#
.SYNOPSIS
    Serenade Voice Control Bridge for WinAssistAI
.DESCRIPTION
    This PowerShell script creates a bridge between Serenade voice recognition
    and the WinAssistAI PowerShell command system.
#>

param(
    [switch]$Setup,
    [switch]$GenerateConfig,
    [switch]$TestIntegration,
    [string]$Command
)

# Error handling
trap {
    Write-Host "[ERROR] $_" -ForegroundColor Red
    & "$PSScriptRoot/say.ps1" "Sorry, an error occurred in the Serenade bridge."
    exit 1
}

function Get-ScriptCategory {
    param([string]$ScriptName)
    
    if ($ScriptName.StartsWith("check-")) { return "system" }
    if ($ScriptName.StartsWith("open-")) { return "application" }
    if ($ScriptName.StartsWith("close-")) { return "application" }
    if ($ScriptName.StartsWith("install-")) { return "setup" }
    if ($ScriptName.StartsWith("play-")) { return "entertainment" }
    if ($ScriptName.StartsWith("lets-play-")) { return "games" }
    if ($ScriptName.StartsWith("show-")) { return "display" }
    return "general"
}

Write-Host "[BRIDGE] WinAssistAI <-> Serenade Integration Bridge" -ForegroundColor Cyan
Write-Host ""

if ($Setup) {
    Write-Host "[SETUP] Configuring Serenade integration..." -ForegroundColor Yellow
    
    # Check Serenade installation
    if (-not (Test-Path "$env:LOCALAPPDATA\Programs\Serenade\Serenade.exe")) {
        Write-Host "[ERROR] Serenade not found. Please install it first." -ForegroundColor Red
        exit 1
    }

    # Generate configuration
    & "$PSScriptRoot/serenade-bridge.ps1" -GenerateConfig
    
    Write-Host "[SUCCESS] Setup completed!" -ForegroundColor Green
    exit 0
}

if ($GenerateConfig) {
    Write-Host "[CONFIG] Generating voice command mappings..." -ForegroundColor Yellow
    
    $scripts = Get-ChildItem "$PSScriptRoot/*.ps1" | Where-Object { 
        $_.Name -notin @("winassistai.ps1", "say.ps1", "serenade-bridge.ps1") 
    }
    
    $config = @{
        winassistai_commands = @{}
    }
    
    foreach ($script in $scripts) {
        $voiceCmd = $script.BaseName -replace '-', ' '
        $config.winassistai_commands[$voiceCmd] = @{
            script = ".\scripts\$($script.Name)"
            description = "Execute $($script.BaseName) command"
            category = Get-ScriptCategory $script.BaseName
        }
    }
    
    $config | ConvertTo-Json -Depth 3 | Out-File "$PSScriptRoot/serenade-commands.json"
    Write-Host "[SAVED] Configuration generated." -ForegroundColor Green
    exit 0
}

if ($TestIntegration) {
    Write-Host "[TEST] Testing integration..." -ForegroundColor Yellow
    
    if (-not (Get-Process -Name "Serenade" -ErrorAction SilentlyContinue)) {
        Write-Host "[WARNING] Serenade not running. Launching..." -ForegroundColor Yellow
        Start-Process "$env:LOCALAPPDATA\Programs\Serenade\Serenade.exe"
        Start-Sleep -Seconds 5
    }
    
    & "$PSScriptRoot/hello.ps1"
    Write-Host "[SUCCESS] Test completed!" -ForegroundColor Green
    exit 0
}

if ($Command) {
    # Check if the command is for the conversational AI
    if ($Command -match "^ask-ai\s+(.+)") {
        $userInputToAI = $matches[1].Trim()
        $converseScriptPath = Join-Path $PSScriptRoot "converse-with-ai.ps1"

        if (Test-Path $converseScriptPath) {
            Write-Host "[BRIDGE] Routing to AI: '$userInputToAI'" -ForegroundColor Green
            try {
                & $converseScriptPath -UserInputText $userInputToAI
            } catch {
                Write-Error "Error executing converse-with-ai.ps1: $($_.Exception.Message)"
                & "$PSScriptRoot/say.ps1" "Sorry, there was an error trying to talk to the AI."
                exit 1
            }
        } else {
            Write-Error "[ERROR] converse-with-ai.ps1 script not found at $converseScriptPath"
            & "$PSScriptRoot/say.ps1" "Sorry, the AI conversation script is missing."
            exit 1
        }
    } else {
        # Original command handling for predefined scripts
        $scriptPath = "$PSScriptRoot/$($Command -replace ' ', '-').ps1"
        if (Test-Path $scriptPath) {
            Write-Host "[BRIDGE] Executing command: $Command (Script: $scriptPath)" -ForegroundColor Green
            try {
                & $scriptPath
            } catch {
                Write-Error "Error executing script $scriptPath : $($_.Exception.Message)"
                # Potentially speak this error too
                & "$PSScriptRoot/say.ps1" "Sorry, an error occurred while running the command $Command."
                exit 1
            }
        } else {
            Write-Host "[ERROR] Command not found or script does not exist: $Command (Path attempted: $scriptPath)" -ForegroundColor Red
            # The JS template should prevent this for general queries by routing to "ask-ai"
            # This path would be hit if JS sends a specific command that doesn't map to a .ps1 file
            & "$PSScriptRoot/say.ps1" "Sorry, I didn't recognize the command $Command."
            exit 1
        }
    }
    exit 0
}

# Default status check
Write-Host "[STATUS] Serenade Bridge Status" -ForegroundColor Yellow
Write-Host "Use -Setup, -GenerateConfig, -TestIntegration or -Command parameters"
exit 0