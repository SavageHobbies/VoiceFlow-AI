<#
.SYNOPSIS
    Install Talk2Windows Dependencies
.DESCRIPTION
    Installs Node.js dependencies required for ElevenLabs integration
    and other advanced features of Talk2Windows.
.EXAMPLE
    .\install-dependencies.ps1
#>

param(
    [switch]$Force,
    [switch]$Verbose,
    [switch]$Help
)

if ($Help) {
    Get-Help $MyInvocation.MyCommand.Definition -Detailed
    exit 0
}

$ScriptRoot = $PSScriptRoot
$ProjectRoot = Split-Path $ScriptRoot -Parent

function Test-NodeJS {
    try {
        $nodeVersion = node --version 2>$null
        if ($nodeVersion) {
            return @{ Available = $true; Version = $nodeVersion }
        }
    } catch {
        # Node not found
    }
    return @{ Available = $false; Version = $null }
}

function Test-NPM {
    try {
        $npmVersion = npm --version 2>$null
        if ($npmVersion) {
            return @{ Available = $true; Version = $npmVersion }
        }
    } catch {
        # NPM not found
    }
    return @{ Available = $false; Version = $null }
}

try {
    Write-Host @"

 ████████╗ █████╗ ██╗     ██╗  ██╗██████╗ ██╗    ██╗██╗███████╗
 ╚══██╔══╝██╔══██╗██║     ██║ ██╔╝╚════██╗██║    ██║██║██╔════╝
    ██║   ███████║██║     █████╔╝  █████╔╝██║ █╗ ██║██║█████╗  
    ██║   ██╔══██║██║     ██╔═██╗ ██╔═══╝ ██║███╗██║██║██╔══╝  
    ██║   ██║  ██║███████╗██║  ██╗███████╗╚███╔███╔╝██║███████╗
    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚═╝╚══════╝

                    Dependency Installation Script
                   
"@ -ForegroundColor Cyan

    Write-Host "[INFO] Installing Talk2Windows dependencies..." -ForegroundColor Green
    Write-Host ""
    
    # Check Node.js availability
    Write-Host "[CHECK] Checking Node.js..." -ForegroundColor Yellow
    $nodeCheck = Test-NodeJS
    
    if ($nodeCheck.Available) {
        Write-Host "[✓] Node.js found: $($nodeCheck.Version)" -ForegroundColor Green
    } else {
        Write-Host "[✗] Node.js not found" -ForegroundColor Red
        Write-Host "[INFO] Node.js is required for ElevenLabs integration" -ForegroundColor Yellow
        Write-Host "[DOWNLOAD] Please install Node.js from: https://nodejs.org" -ForegroundColor Cyan
        Write-Host "[TIP] After installing Node.js, run this script again" -ForegroundColor Yellow
        exit 1
    }
    
    # Check NPM availability
    Write-Host "[CHECK] Checking NPM..." -ForegroundColor Yellow
    $npmCheck = Test-NPM
    
    if ($npmCheck.Available) {
        Write-Host "[✓] NPM found: $($npmCheck.Version)" -ForegroundColor Green
    } else {
        Write-Host "[✗] NPM not found" -ForegroundColor Red
        Write-Host "[ERROR] NPM should be included with Node.js installation" -ForegroundColor Red
        exit 1
    }
    
    # Check if package.json exists
    $packageJsonPath = Join-Path $ProjectRoot "package.json"
    if (-not (Test-Path $packageJsonPath)) {
        Write-Host "[ERROR] package.json not found in project root" -ForegroundColor Red
        Write-Host "[PATH] Expected: $packageJsonPath" -ForegroundColor Gray
        exit 1
    }
    
    Write-Host "[✓] package.json found" -ForegroundColor Green
    
    # Check if node_modules exists
    $nodeModulesPath = Join-Path $ProjectRoot "node_modules"
    $nodeModulesExists = Test-Path $nodeModulesPath
    
    if ($nodeModulesExists -and -not $Force) {
        Write-Host "[INFO] Dependencies already installed" -ForegroundColor Yellow
        Write-Host "[TIP] Use -Force to reinstall dependencies" -ForegroundColor Cyan
        
        # Show installed packages
        try {
            Write-Host "`n[PACKAGES] Installed dependencies:" -ForegroundColor Cyan
            Set-Location $ProjectRoot
            $packages = npm list --depth=0 --json 2>$null | ConvertFrom-Json
            
            if ($packages.dependencies) {
                foreach ($package in $packages.dependencies.PSObject.Properties) {
                    Write-Host "  • $($package.Name): $($package.Value.version)" -ForegroundColor White
                }
            }
        } catch {
            Write-Host "[WARNING] Could not list installed packages" -ForegroundColor Yellow
        }
        
        Write-Host "`n[SUCCESS] Dependencies are ready!" -ForegroundColor Green
        exit 0
    }
    
    # Install dependencies
    Write-Host "`n[INSTALL] Installing Node.js dependencies..." -ForegroundColor Yellow
    Write-Host "[INFO] This may take a few minutes..." -ForegroundColor Cyan
    
    Set-Location $ProjectRoot
    
    if ($Force -and $nodeModulesExists) {
        Write-Host "[CLEAN] Removing existing node_modules..." -ForegroundColor Yellow
        Remove-Item $nodeModulesPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Run npm install
    Write-Host "[NPM] Running npm install..." -ForegroundColor Yellow
    $installResult = Start-Process -FilePath "npm" -ArgumentList "install" -Wait -PassThru -WindowStyle Hidden
    
    if ($installResult.ExitCode -eq 0) {
        Write-Host "[✓] Dependencies installed successfully!" -ForegroundColor Green
        
        # Verify installation
        Write-Host "`n[VERIFY] Verifying installation..." -ForegroundColor Yellow
        
        try {
            $packages = npm list --depth=0 --json 2>$null | ConvertFrom-Json
            
            if ($packages.dependencies) {
                Write-Host "[✓] Installed packages:" -ForegroundColor Green
                foreach ($package in $packages.dependencies.PSObject.Properties) {
                    Write-Host "  • $($package.Name): $($package.Value.version)" -ForegroundColor White
                }
            }
            
            # Test ElevenLabs functionality
            Write-Host "`n[TEST] Testing ElevenLabs integration..." -ForegroundColor Yellow
            
            $testScript = Join-Path $ScriptRoot "test-elevenlabs.ps1"
            if (Test-Path $testScript) {
                Write-Host "[✓] ElevenLabs test script available" -ForegroundColor Green
                Write-Host "[INFO] Run .\test-elevenlabs.ps1 -Status to check configuration" -ForegroundColor Cyan
            }
            
        } catch {
            Write-Host "[WARNING] Could not verify installation: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "[✗] NPM install failed with exit code: $($installResult.ExitCode)" -ForegroundColor Red
        Write-Host "[TIP] Try running 'npm install' manually in the project directory" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "`n🎉 Installation Complete! 🎉" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Setup ElevenLabs: .\setup-elevenlabs.ps1" -ForegroundColor White
    Write-Host "2. Test the system: .\test-elevenlabs.ps1 -Test" -ForegroundColor White
    Write-Host "3. Start Talk2Windows: node winassistai.js --start-full" -ForegroundColor White
    Write-Host ""
    Write-Host "For ElevenLabs AI voice:" -ForegroundColor Cyan
    Write-Host "• Get free API key: https://elevenlabs.io" -ForegroundColor White
    Write-Host "• Run setup wizard: .\setup-elevenlabs.ps1" -ForegroundColor White
    Write-Host ""
    
    exit 0
    
} catch {
    Write-Host "[ERROR] Installation failed: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($Verbose) {
        Write-Host "[DEBUG] $($_.ScriptStackTrace)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Ensure Node.js is installed: https://nodejs.org" -ForegroundColor White
    Write-Host "2. Check internet connection" -ForegroundColor White
    Write-Host "3. Run PowerShell as Administrator if needed" -ForegroundColor White
    Write-Host "4. Try manual installation: npm install" -ForegroundColor White
    
    exit 1
} finally {
    # Return to script directory
    Set-Location $ScriptRoot
}