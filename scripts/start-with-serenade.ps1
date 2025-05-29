<#
.SYNOPSIS
    Start WinAssistAI with Full Serenade Integration
.DESCRIPTION
    This PowerShell script starts the WinAssistAI system with complete Serenade
    voice control integration. It handles automatic installation, configuration,
    and startup of both systems working together seamlessly.
.EXAMPLE
    PS> .\start-with-serenade.ps1
.NOTES
    Author: WinAssistAI Team
    Requires: Windows 10/11, Internet connection for Serenade download
#>

param(
    [switch]$AutoInstall,
    [switch]$QuietMode,
    [switch]$ForceReinstall
)

try {
    if (-not $QuietMode) {
        Write-Host @"
WIN_ASSIST_AI + Serenade Voice Control Integration
Complete Hands-Free Windows Assistant
"@ -ForegroundColor Cyan
    }
    
    Write-Host "[STARTUP] Initializing WinAssistAI with Serenade integration..." -ForegroundColor Yellow
    Write-Host ""
    
    # Step 1: Check Serenade installation
    Write-Host "[STEP 1] Checking Serenade installation..." -ForegroundColor Cyan
    
    $serenadeInstalled = $false
    $serenadePaths = @(
        "$env:LOCALAPPDATA\Programs\Serenade\Serenade.exe",
        "$env:PROGRAMFILES\Serenade\Serenade.exe",
        "$env:PROGRAMFILES(X86)\Serenade\Serenade.exe"
    )
    
    foreach ($path in $serenadePaths) {
        if (Test-Path $path) {
            $serenadeInstalled = $true
            $env:SERENADE_PATH = $path
            Write-Host "[✓] Serenade found at: $path" -ForegroundColor Green
            break
        }
    }
    
    if (-not $serenadeInstalled -or $ForceReinstall) {
        if ($AutoInstall) {
            Write-Host "[INSTALL] Auto-installing Serenade..." -ForegroundColor Yellow
            & "$PSScriptRoot/install-serenade.ps1"
            
            # Re-check after installation
            Start-Sleep -Seconds 2
            foreach ($path in $serenadePaths) {
                if (Test-Path $path) {
                    $serenadeInstalled = $true
                    $env:SERENADE_PATH = $path
                    break
                }
            }
        } else {
            Write-Host "[WARNING] Serenade not found!" -ForegroundColor Red
            Write-Host "[OPTION] Run with -AutoInstall to automatically install Serenade" -ForegroundColor Yellow
            Write-Host "[MANUAL] Or run: .\install-serenade.ps1" -ForegroundColor Cyan
            
            $response = Read-Host "Would you like to install Serenade now? (y/n)"
            if ($response -eq 'y' -or $response -eq 'Y') {
                & "$PSScriptRoot/install-serenade.ps1"
                
                # Re-check after installation
                Start-Sleep -Seconds 2
                foreach ($path in $serenadePaths) {
                    if (Test-Path $path) {
                        $serenadeInstalled = $true
                        $env:SERENADE_PATH = $path
                        break
                    }
                }
            }
        }
    }
    
    # Step 2: Launch Serenade if installed
    if ($serenadeInstalled) {
        Write-Host "[STEP 2] Starting Serenade voice control..." -ForegroundColor Cyan
        
        $serenadeProcess = Get-Process -Name "Serenade" -ErrorAction SilentlyContinue
        if (-not $serenadeProcess) {
            Write-Host "[LAUNCH] Starting Serenade..." -ForegroundColor Yellow
            Start-Process -FilePath $env:SERENADE_PATH -WindowStyle Normal
            
            # Wait for Serenade to start
            $timeout = 10
            $count = 0
            do {
                Start-Sleep -Seconds 1
                $serenadeProcess = Get-Process -Name "Serenade" -ErrorAction SilentlyContinue
                $count++
            } while (-not $serenadeProcess -and $count -lt $timeout)
            
            if ($serenadeProcess) {
                Write-Host "[✓] Serenade started successfully (PID: $($serenadeProcess.Id))" -ForegroundColor Green
            } else {
                Write-Host "[WARNING] Serenade may not have started properly" -ForegroundColor Yellow
            }
        } else {
            Write-Host "[✓] Serenade is already running (PID: $($serenadeProcess.Id))" -ForegroundColor Green
        }
    }
    
    # Step 3: Set up integration bridge
    Write-Host "[STEP 3] Setting up voice command bridge..." -ForegroundColor Cyan
    try {
        & "$PSScriptRoot/serenade-bridge.ps1" -Setup
        Write-Host "[✓] Voice command bridge configured" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] Bridge setup encountered issues: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Step 4: Generate Serenade configuration
    Write-Host "[STEP 4] Generating Serenade voice commands..." -ForegroundColor Cyan
    try {
        & "$PSScriptRoot/serenade-bridge.ps1" -GenerateConfig
        Write-Host "[✓] Voice command configuration generated" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] Command generation failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Step 5: Start WinAssistAI with Serenade integration
    Write-Host "[STEP 5] Starting WinAssistAI with Serenade integration..." -ForegroundColor Cyan
    Write-Host ""
    
    # Test the integration
    & "$PSScriptRoot/say.ps1" "WinAssistAI with Serenade voice control is starting up."
    
    # Launch main WinAssistAI with Serenade enabled
    & "$PSScriptRoot/win_assist_ai.ps1" -WithSerenade
    
    Write-Host ""
    Write-Host "[SUCCESS] WinAssistAI + Serenade integration startup completed!" -ForegroundColor Green
    Write-Host ""
    
    if ($serenadeInstalled) {
        Write-Host "[READY] Voice Control Ready! Try these commands:" -ForegroundColor Yellow
        Write-Host "  • 'hello computer'        - Friendly greeting" -ForegroundColor White
        Write-Host "  • 'check weather'         - Get weather report" -ForegroundColor White
        Write-Host "  • 'open calculator'       - Launch calculator" -ForegroundColor White
        Write-Host "  • 'take screenshot'       - Capture screen" -ForegroundColor White
        Write-Host "  • 'thank you computer'    - Polite response" -ForegroundColor White
        Write-Host ""
        Write-Host "[TIP] Say 'win assist ai' to access the main help system" -ForegroundColor Cyan
        
        & "$PSScriptRoot/say.ps1" "Voice control is now active. You can start giving voice commands."
    } else {
        Write-Host "[INFO] Running in manual mode - Serenade not available" -ForegroundColor Yellow
        Write-Host "[HELP] Install Serenade later with: .\install-serenade.ps1" -ForegroundColor Cyan
    }
    
    # Create startup shortcut option
    if ($serenadeInstalled) {
        Write-Host ""
        $createShortcut = Read-Host "Create desktop shortcut for WinAssistAI + Serenade? (y/n)"
        if ($createShortcut -eq 'y' -or $createShortcut -eq 'Y') {
            try {
                $shell = New-Object -ComObject WScript.Shell
                $shortcut = $shell.CreateShortcut("$env:USERPROFILE\Desktop\WinAssistAI + Serenade.lnk")
                $shortcut.TargetPath = "powershell.exe"
                $shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$PSScriptRoot\start-with-serenade.ps1`""
                $shortcut.WorkingDirectory = $PSScriptRoot
                $shortcut.Description = "WinAssistAI with Serenade Voice Control"
                $shortcut.Save()
                Write-Host "[✓] Desktop shortcut created successfully!" -ForegroundColor Green
            } catch {
                Write-Host "[WARNING] Could not create shortcut: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }
    
    exit 0
    
} catch {
    Write-Host "[ERROR] Startup error: $($_.Exception.Message)" -ForegroundColor Red
    & "$PSScriptRoot/say.ps1" "Sorry, an error occurred during startup."
    exit 1
}