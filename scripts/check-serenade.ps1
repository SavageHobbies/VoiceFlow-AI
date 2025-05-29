<#
.SYNOPSIS
    Check Serenade Voice Control Installation Status
.DESCRIPTION
    This PowerShell script checks if Serenade voice control system is installed
    and reports its status, version, and installation path.
.EXAMPLE
    PS> .\check-serenade.ps1
.NOTES
    Author: Talk2Windows Team
    Requires: Windows 10/11
#>

try {
    Write-Host "[SERENADE] Checking Serenade voice control installation..." -ForegroundColor Yellow
    
    # Common Serenade installation paths
    $serenadePaths = @(
        "$env:LOCALAPPDATA\Programs\Serenade\Serenade.exe",
        "$env:PROGRAMFILES\Serenade\Serenade.exe",
        "$env:PROGRAMFILES(X86)\Serenade\Serenade.exe",
        "$env:APPDATA\Local\Programs\Serenade\Serenade.exe"
    )
    
    $serenadeFound = $false
    $serenadePath = ""
    
    # Check each potential path
    foreach ($path in $serenadePaths) {
        if (Test-Path $path) {
            $serenadeFound = $true
            $serenadePath = $path
            break
        }
    }
    
    if ($serenadeFound) {
        Write-Host "[SUCCESS] Serenade found at: $serenadePath" -ForegroundColor Green
        
        # Get version information if available
        try {
            $versionInfo = Get-ItemProperty -Path $serenadePath | Select-Object VersionInfo
            $version = $versionInfo.VersionInfo.ProductVersion
            if ($version) {
                Write-Host "[VERSION] Serenade version: $version" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "[INFO] Version information not available" -ForegroundColor Yellow
        }
        
        # Check if Serenade is currently running
        $serenadeProcess = Get-Process -Name "Serenade" -ErrorAction SilentlyContinue
        if ($serenadeProcess) {
            Write-Host "[STATUS] Serenade is currently running (PID: $($serenadeProcess.Id))" -ForegroundColor Green
            & "$PSScriptRoot/say.ps1" "Serenade voice control is installed and running."
        } else {
            Write-Host "[STATUS] Serenade is installed but not running" -ForegroundColor Yellow
            & "$PSScriptRoot/say.ps1" "Serenade voice control is installed but not currently running."
        }
        
        # Save path for other scripts to use
        $env:SERENADE_PATH = $serenadePath
        Write-Host "[INFO] Serenade path saved to environment variable" -ForegroundColor Cyan
        
    } else {
        Write-Host "[WARNING] Serenade not found in common installation locations" -ForegroundColor Red
        Write-Host "[INFO] Common paths checked:" -ForegroundColor Yellow
        foreach ($path in $serenadePaths) {
            Write-Host "  - $path" -ForegroundColor Gray
        }
        Write-Host ""
        Write-Host "[HELP] To install Serenade:" -ForegroundColor Cyan
        Write-Host "  1. Visit: https://serenade.ai/download" -ForegroundColor White
        Write-Host "  2. Download and install Serenade" -ForegroundColor White
        Write-Host "  3. Run this script again to verify installation" -ForegroundColor White
        
        & "$PSScriptRoot/say.ps1" "Serenade voice control is not installed. Please visit serenade dot ai to download and install it."
    }
    
    exit 0
    
} catch {
    Write-Host "[ERROR] Error checking Serenade installation: $($_.Exception.Message)" -ForegroundColor Red
    & "$PSScriptRoot/say.ps1" "Sorry, an error occurred while checking Serenade installation."
    exit 1
}