<#
.SYNOPSIS
    Launch Serenade Voice Control
.DESCRIPTION
    This PowerShell script launches the Serenade voice control application
    if it's installed on the system. Includes fallback detection and error handling.
.EXAMPLE
    PS> .\open-serenade.ps1
.NOTES
    Author: Talk2Windows Team
    Requires: Serenade installed
#>

try {
    Write-Host "[SERENADE] Launching Serenade voice control..." -ForegroundColor Yellow
    
    # Check if Serenade is already running
    $serenadeProcess = Get-Process -Name "Serenade" -ErrorAction SilentlyContinue
    if ($serenadeProcess) {
        Write-Host "[INFO] Serenade is already running (PID: $($serenadeProcess.Id))" -ForegroundColor Green
        & "$PSScriptRoot/say.ps1" "Serenade is already running."
        exit 0
    }
    
    # Common Serenade installation paths
    $serenadePaths = @(
        "$env:LOCALAPPDATA\Programs\Serenade\Serenade.exe",
        "$env:PROGRAMFILES\Serenade\Serenade.exe",
        "$env:PROGRAMFILES(X86)\Serenade\Serenade.exe",
        "$env:APPDATA\Local\Programs\Serenade\Serenade.exe"
    )
    
    # Check environment variable first (set by check-serenade.ps1)
    if ($env:SERENADE_PATH -and (Test-Path $env:SERENADE_PATH)) {
        $serenadePath = $env:SERENADE_PATH
    } else {
        # Find Serenade installation
        $serenadePath = $null
        foreach ($path in $serenadePaths) {
            if (Test-Path $path) {
                $serenadePath = $path
                break
            }
        }
    }
    
    if ($serenadePath) {
        Write-Host "[SUCCESS] Found Serenade at: $serenadePath" -ForegroundColor Green
        
        # Launch Serenade
        Write-Host "[LAUNCH] Starting Serenade..." -ForegroundColor Cyan
        Start-Process -FilePath $serenadePath -WindowStyle Normal
        
        # Wait a moment and verify it started
        Start-Sleep -Seconds 3
        $newProcess = Get-Process -Name "Serenade" -ErrorAction SilentlyContinue
        
        if ($newProcess) {
            Write-Host "[SUCCESS] Serenade launched successfully (PID: $($newProcess.Id))" -ForegroundColor Green
            & "$PSScriptRoot/say.ps1" "Serenade voice control has been launched successfully."
        } else {
            Write-Host "[WARNING] Serenade may not have started properly" -ForegroundColor Yellow
            & "$PSScriptRoot/say.ps1" "Serenade launch attempt completed, but status is uncertain."
        }
        
    } else {
        Write-Host "[ERROR] Serenade not found on this system" -ForegroundColor Red
        Write-Host "[HELP] To install Serenade:" -ForegroundColor Cyan
        Write-Host "  1. Visit: https://serenade.ai/download" -ForegroundColor White
        Write-Host "  2. Download and install Serenade" -ForegroundColor White
        Write-Host "  3. Run this script again" -ForegroundColor White
        Write-Host ""
        Write-Host "[INFO] Would you like to open the Serenade website?" -ForegroundColor Yellow
        
        & "$PSScriptRoot/say.ps1" "Serenade is not installed. Opening the Serenade website for download."
        & "$PSScriptRoot/open-serenade-website.ps1"
    }
    
    exit 0
    
} catch {
    Write-Host "[ERROR] Error launching Serenade: $($_.Exception.Message)" -ForegroundColor Red
    & "$PSScriptRoot/say.ps1" "Sorry, an error occurred while launching Serenade."
    exit 1
}