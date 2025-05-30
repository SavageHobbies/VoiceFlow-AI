<#
.SYNOPSIS
    Shared functions for WinAssistAI scripts
.DESCRIPTION
    This file contains utility functions used across multiple WinAssistAI PowerShell scripts.
.NOTES
    Author: WinAssistAI Team
#>

function Get-EnvVariable {
    param(
        [string]$KeyName,
        [string]$DefaultValue = ""
    )
    
    try {
        # First try to get from environment variables
        $envValue = [System.Environment]::GetEnvironmentVariable($KeyName)
        if ($envValue) {
            return $envValue
        }
        
        # If not found, try to read from .env file
        $envFilePath = Join-Path (Split-Path $PSScriptRoot -Parent) ".env"
        if (Test-Path $envFilePath) {
            $envContent = Get-Content $envFilePath -ErrorAction SilentlyContinue
            foreach ($line in $envContent) {
                if ($line -match "^$KeyName\s*=\s*(.*)$") {
                    return $matches[1].Trim()
                }
            }
        }
        
        # Return default value if not found
        return $DefaultValue
    }
    catch {
        Write-Warning "Error reading environment variable '$KeyName': $($_.Exception.Message)"
        return $DefaultValue
    }
}

function Get-NormalizedPath {
    param(
        [string]$Path
    )
    
    try {
        # Convert to absolute path and normalize separators
        $absolutePath = (Resolve-Path $Path -ErrorAction Stop).Path
        # Convert to forward slashes for JavaScript compatibility
        return $absolutePath -replace '\\', '/'
    }
    catch {
        # If path doesn't exist, just normalize the format
        $normalizedPath = [System.IO.Path]::GetFullPath($Path)
        return $normalizedPath -replace '\\', '/'
    }
}

function Test-SerenadeInstallation {
    $serenadePaths = @(
        "$env:LOCALAPPDATA\Programs\Serenade\Serenade.exe",
        "$env:PROGRAMFILES\Serenade\Serenade.exe",
        "$env:PROGRAMFILES(X86)\Serenade\Serenade.exe"
    )
    
    foreach ($path in $serenadePaths) {
        if (Test-Path $path) {
            return $path
        }
    }
    
    return $null
}

function Write-LogMessage {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level.ToUpper()) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "INFO" { Write-Host $logMessage -ForegroundColor Cyan }
        default { Write-Host $logMessage }
    }
}

function Invoke-SafeCommand {
    param(
        [scriptblock]$Command,
        [string]$ErrorMessage = "Command failed"
    )
    
    try {
        & $Command
        return $true
    }
    catch {
        Write-LogMessage "$ErrorMessage : $($_.Exception.Message)" "ERROR"
        return $false
    }
}