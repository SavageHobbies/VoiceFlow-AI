<#
.SYNOPSIS
    Install Serenade Voice Control
.DESCRIPTION
    This PowerShell script downloads and installs Serenade voice control system
    from the official website. Includes verification and setup guidance.
.EXAMPLE
    PS> .\install-serenade.ps1
.NOTES
    Author: Talk2Windows Team
    Requires: Internet connection, Administrator rights may be needed
#>

try {
    Write-Host "[SERENADE] Installing Serenade Voice Control..." -ForegroundColor Yellow
    
    # Check if already installed
    $existingProcess = Get-Process -Name "Serenade" -ErrorAction SilentlyContinue
    if ($existingProcess) {
        Write-Host "[INFO] Serenade is already running" -ForegroundColor Green
        & "$PSScriptRoot/say.ps1" "Serenade is already installed and running."
        exit 0
    }
    
    # Check common installation paths
    $serenadePaths = @(
        "$env:LOCALAPPDATA\Programs\Serenade\Serenade.exe",
        "$env:PROGRAMFILES\Serenade\Serenade.exe",
        "$env:PROGRAMFILES(X86)\Serenade\Serenade.exe"
    )
    
    $existingInstall = $false
    foreach ($path in $serenadePaths) {
        if (Test-Path $path) {
            $existingInstall = $true
            Write-Host "[INFO] Serenade is already installed at: $path" -ForegroundColor Green
            & "$PSScriptRoot/say.ps1" "Serenade is already installed. Would you like me to launch it?"
            & "$PSScriptRoot/open-serenade.ps1"
            exit 0
        }
    }
    
    # Check internet connectivity
    Write-Host "[CHECK] Checking internet connectivity..." -ForegroundColor Cyan
    try {
        $testConnection = Test-NetConnection -ComputerName "serenade.ai" -Port 443 -InformationLevel Quiet
        if (-not $testConnection) {
            throw "Cannot reach serenade.ai"
        }
    } catch {
        Write-Host "[ERROR] No internet connection or cannot reach serenade.ai" -ForegroundColor Red
        & "$PSScriptRoot/say.ps1" "Sorry, internet connection is required to download Serenade."
        exit 1
    }
    
    Write-Host "[SUCCESS] Internet connection verified" -ForegroundColor Green
    
    # Try to install via winget first (if available)
    Write-Host "[WINGET] Attempting installation via Windows Package Manager..." -ForegroundColor Cyan
    
    try {
        # Check if winget is available
        $wingetPath = Get-Command winget -ErrorAction SilentlyContinue
        if ($wingetPath) {
            Write-Host "[INFO] Windows Package Manager found, attempting installation..." -ForegroundColor Yellow
            
            # Search for Serenade in winget
            $wingetSearch = & winget search "Serenade" 2>&1
            if ($LASTEXITCODE -eq 0 -and $wingetSearch -like "*Serenade*") {
                Write-Host "[INSTALL] Installing Serenade via winget..." -ForegroundColor Green
                & winget install "Serenade.Serenade" --accept-source-agreements --accept-package-agreements
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "[SUCCESS] Serenade installed successfully via winget!" -ForegroundColor Green
                    & "$PSScriptRoot/say.ps1" "Serenade has been installed successfully."
                    
                    # Verify installation
                    Start-Sleep -Seconds 2
                    & "$PSScriptRoot/check-serenade.ps1"
                    exit 0
                }
            }
        }
    } catch {
        Write-Host "[INFO] Winget installation not available, using manual method..." -ForegroundColor Yellow
    }
    
    # Manual installation method
    Write-Host "[MANUAL] Opening Serenade download page for manual installation..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[INSTRUCTIONS] Please follow these steps:" -ForegroundColor Yellow
    Write-Host "1. Download Serenade from the opened webpage" -ForegroundColor White
    Write-Host "2. Run the downloaded installer" -ForegroundColor White
    Write-Host "3. Follow the installation wizard" -ForegroundColor White
    Write-Host "4. After installation, run: .\check-serenade.ps1" -ForegroundColor White
    Write-Host ""
    
    & "$PSScriptRoot/say.ps1" "Opening the Serenade download page. Please download and install Serenade manually."
    
    # Open download page
    & "$PSScriptRoot/open-browser.ps1" "https://serenade.ai/download"
    
    # Wait a moment then provide additional guidance
    Start-Sleep -Seconds 3
    Write-Host "[TIP] After installing Serenade:" -ForegroundColor Cyan
    Write-Host "- Run: .\open-serenade.ps1 to launch it" -ForegroundColor White
    Write-Host "- Run: .\check-serenade.ps1 to verify installation" -ForegroundColor White
    Write-Host "- The Talk2Windows system will automatically integrate with Serenade" -ForegroundColor White
    
    exit 0
    
} catch {
    Write-Host "[ERROR] Error during Serenade installation: $($_.Exception.Message)" -ForegroundColor Red
    & "$PSScriptRoot/say.ps1" "Sorry, an error occurred while installing Serenade."
    exit 1
}