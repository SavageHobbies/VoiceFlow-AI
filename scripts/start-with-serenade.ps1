# Sim<#
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

# Import shared functions
. (Join-Path $PSScriptRoot "_shared-functions.ps1")

try {
    if (-not $QuietMode) {
        Write-Host ("WIN_ASSIST_AI + Serenade Voice Control Integration`nComplete Hands-Free Windows Assistant") -ForegroundColor Cyan
    }
    
    Write-Host "[STARTUP] Initializing WinAssistAI with Serenade integration..." -ForegroundColor Yellow
    Write-Host ""
    
    # --- Define Project Root ---
    $projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    Write-Host ("[INFO] Project root identified as: {0}" -f $projectRoot) -ForegroundColor Gray

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
            Write-Host ("[OK] Serenade found at: {0}" -f $path) -ForegroundColor Green
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
    
    # Step 1.5: Generate/Update Serenade Custom Script (winassistai-serenade.js)
    if ($serenadeInstalled) { # Only proceed if Serenade is considered installed
        Write-Host "[STEP 1.5] Configuring Serenade custom script (winassistai-serenade.js)..." -ForegroundColor Cyan
        try {
            $wakeWord = Get-EnvVariable -KeyName "WAKE_WORD" -DefaultValue "COMPUTER"
            
            # Resolve paths safely and format for JS (forward slashes)
            $commandsJsonPath = (Get-NormalizedPath -Path (Join-Path $projectRoot "scripts\serenade-commands.json"))
            $bridgePs1Path = (Get-NormalizedPath -Path (Join-Path $projectRoot "scripts\serenade-bridge.ps1"))
            
            # Define Serenade user scripts directory (Windows specific)
            $serenadeUserScriptsPath = Join-Path $env:APPDATA "Serenade\scripts"
            if (-not (Test-Path $serenadeUserScriptsPath)) {
                Write-Host ("[INFO] Creating Serenade user scripts directory: {0}" -f $serenadeUserScriptsPath) -ForegroundColor Yellow
                New-Item -ItemType Directory -Force -Path $serenadeUserScriptsPath | Out-Null
            }

            $jsTemplatePath = (Resolve-Path (Join-Path $projectRoot "scripts\serenade_custom_script_template.js")).Path
            if (-not (Test-Path $jsTemplatePath)) {
                throw ("Serenade custom script template not found at {0}" -f $jsTemplatePath)
            }
            $jsTemplateContent = Get-Content $jsTemplatePath -Raw

            $jsOutputContent = $jsTemplateContent.Replace("__WAKE_WORD_PLACEHOLDER__", $wakeWord)
            $jsOutputContent = $jsOutputContent.Replace("__COMMANDS_FILE_PATH_PLACEHOLDER__", $commandsJsonPath)
            $jsOutputContent = $jsOutputContent.Replace("__POWERSHELL_SCRIPT_BRIDGE_PLACEHOLDER__", $bridgePs1Path)

            $outputJsFilePath = Join-Path $serenadeUserScriptsPath "winassistai-serenade.js"
            Set-Content -Path $outputJsFilePath -Value $jsOutputContent -Encoding UTF8
            Write-Host ("[OK] Serenade custom script 'winassistai-serenade.js' generated/updated in '{0}'." -f $serenadeUserScriptsPath) -ForegroundColor Green
            Write-Host ("[INFO]  - Wake Word: {0}" -f $wakeWord) -ForegroundColor Gray
            Write-Host ("[INFO]  - Commands JSON Path: {0}" -f $commandsJsonPath) -ForegroundColor Gray
            Write-Host ("[INFO]  - Bridge Script Path: {0}" -f $bridgePs1Path) -ForegroundColor Gray
            Write-Host "[INFO] You may need to tell Serenade to 'reload custom scripts' or restart Serenade if it's already running." -ForegroundColor Yellow

        } catch {
            Write-Warning ("[WARNING] Failed to generate/update Serenade custom script: {0}" -f $_.Exception.Message)
            Write-Warning "[WARNING] Wake word and AI functionality via Serenade custom script might not work."
            # Continue startup, as core functionality might still work if Serenade has old/no script
        }
    } else {
        Write-Host "[SKIP] Skipping Serenade custom script generation as Serenade is not installed." -ForegroundColor Yellow
    }
    Write-Host ""

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
                Write-Host ("[OK] Serenade started successfully (PID: {0})" -f $serenadeProcess.Id) -ForegroundColor Green
            } else {
                Write-Host "[WARNING] Serenade may not have started properly" -ForegroundColor Yellow
            }
        } else {
            Write-Host ("[OK] Serenade is already running (PID: {0})" -f $serenadeProcess.Id) -ForegroundColor Green
        }
    }
    
    # Step 3: Set up integration bridge
    Write-Host "[STEP 3] Setting up voice command bridge..." -ForegroundColor Cyan
    try {
        & "$PSScriptRoot/serenade-bridge.ps1" -Setup
        Write-Host "[OK] Voice command bridge configured" -ForegroundColor Green
    } catch {
        Write-Host ("[WARNING] Bridge setup encountered issues: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
    }
    
    # Step 4: Generate Serenade configuration
    Write-Host "[STEP 4] Generating Serenade voice commands..." -ForegroundColor Cyan
    try {
        & "$PSScriptRoot/serenade-bridge.ps1" -GenerateConfig
        Write-Host "[OK] Voice command configuration generated" -ForegroundColor Green
    } catch {
        Write-Host ("[WARNING] Command generation failed: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
    }
    
    # Step 5: Start WinAssistAI with Serenade integration
    Write-Host "[STEP 5] Starting WinAssistAI with Serenade integration..." -ForegroundColor Cyan
    Write-Host ""
    
    # Test the integration
    & "$PSScriptRoot/say.ps1" "WinAssistAI with Serenade voice control is starting up."
    
    # Launch main WinAssistAI with Serenade enabled
    try {
        & "$PSScriptRoot/win_assist_ai.ps1" -WithSerenade
    } catch {
        Write-Host ("[ERROR] Failed to start WinAssistAI: {0}" -f $_.Exception.Message) -ForegroundColor Red
        & "$PSScriptRoot/say.ps1" "Failed to start the main assistant."
        exit 1
    }
    
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
                Write-Host "[OK] Desktop shortcut created successfully!" -ForegroundColor Green
            } catch {
                Write-Host ("[WARNING] Could not create shortcut: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
            }
        }
    }
    
    exit 0
    
} catch {
    Write-Host ("[ERROR] Startup error: {0}" -f $_.Exception.Message) -ForegroundColor Red
    & "$PSScriptRoot/say.ps1" "Sorry, an error occurred during startup."
    exit 1
}