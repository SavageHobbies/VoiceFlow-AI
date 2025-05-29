<#
.SYNOPSIS
    WinAssistAI - Main Startup Script
.DESCRIPTION
    This PowerShell script is the main launcher for the WinAssistAI voice assistant system.
    It provides an interactive voice-controlled interface for Windows with comprehensive
    system management, application control, and conversational capabilities.
.EXAMPLE
    PS> .\win_assist_ai.ps1
.NOTES
    Author: Sean Sandoval
    License: CC0
    GitHub: https://github.com/SavageHobbies/win_assist_ai.git
.LINK
    https://github.com/SavageHobbies/win_assist_ai.git
#>

param(
    [switch]$Help,
    [switch]$ListCommands,
    [switch]$TestVoice,
    [switch]$Version,
    [switch]$WithSerenade,
    [switch]$NoSerenade
)

# Version information
$AppVersion = "2.0.0"
$ScriptRoot = $PSScriptRoot

# Display banner
function Show-Banner {
    Write-Host @"

 ██╗    ██╗██╗███╗   ██╗ █████╗ ███████╗███████╗██╗███████╗████████╗ █████╗ ██╗
 ██║    ██║██║████╗  ██║██╔══██╗██╔════╝██╔════╝██║██╔════╝╚══██╔══╝██╔══██╗██║
 ██║ █╗ ██║██║██╔██╗ ██║███████║███████╗███████╗██║███████╗   ██║   ███████║██║
 ██║███╗██║██║██║╚██╗██║██╔══██║╚════██║╚════██║██║╚════██║   ██║   ██╔══██║██║
 ╚███╔███╔╝██║██║ ╚████║██║  ██║███████║███████║██║███████║   ██║   ██║  ██║██║
  ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝

                    Voice-Controlled Windows Assistant v$AppVersion
                    https://github.com/SavageHobbies/win_assist_ai.git 

"@ -ForegroundColor Cyan
}

# Test TTS functionality
function Test-Voice {
    Write-Host "`n[VOICE] Testing text-to-speech functionality..." -ForegroundColor Yellow
    
    # Check if ElevenLabs is configured
    $configPath = Join-Path (Split-Path $ScriptRoot -Parent) "config\elevenlabs.json"
    $elevenLabsConfigured = $false
    
    try {
        if (Test-Path $configPath) {
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            $elevenLabsConfigured = ($config.enabled -and -not [string]::IsNullOrWhiteSpace($config.apiKey))
        }
    } catch {
        # Config parsing failed, continue with Windows TTS
    }
    
    if ($elevenLabsConfigured) {
        Write-Host "[ELEVENLABS] Testing ElevenLabs AI voice..." -ForegroundColor Cyan
        & "$ScriptRoot/say.ps1" "WinAssistAI voice assistant is ready with ElevenLabs AI voice synthesis. All systems operational."
        Write-Host "[SUCCESS] ElevenLabs AI voice test completed!" -ForegroundColor Green
    } else {
        Write-Host "[WINDOWS] Testing Windows TTS..." -ForegroundColor Yellow
        & "$ScriptRoot/say.ps1" "WinAssistAI voice assistant is ready. All systems operational."
        Write-Host "[SUCCESS] Windows TTS test completed!" -ForegroundColor Green
        Write-Host "[TIP] For higher quality AI voice, run: .\setup-elevenlabs.ps1" -ForegroundColor Cyan
    }
}

# Show available command categories
function Show-CommandCategories {
    Write-Host "`n[COMMANDS] Available Command Categories:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "SYSTEM CHECKS:" -ForegroundColor Green
    Write-Host "   check-weather, check-uptime, check-health, check-internet-connection"
    Write-Host "   check-ram, check-vpn, check-temperature, check-time-zone"
    Write-Host ""
    Write-Host "CLOSE APPLICATIONS:" -ForegroundColor Red
    Write-Host "   close-calculator, close-chrome, close-discord, close-netflix"
    Write-Host "   close-spotify, close-teams, close-whatsapp, close-zoom"
    Write-Host ""
    Write-Host "OPEN APPLICATIONS:" -ForegroundColor Blue
    Write-Host "   open-calculator, open-chrome, open-discord, open-netflix"
    Write-Host "   open-spotify, open-teams, open-whatsapp, open-terminal"
    Write-Host ""
    Write-Host "INSTALL SOFTWARE:" -ForegroundColor Magenta
    Write-Host "   install-discord, install-spotify, install-zoom, install-chrome"
    Write-Host "   install-teams, install-vlc, install-firefox"
    Write-Host ""
    Write-Host "CONVERSATIONS:" -ForegroundColor Cyan
    Write-Host "   hello, hi, good-morning, good-evening, how-are-you"
    Write-Host "   thank-you, good-bye, see-you-later"
    Write-Host ""
    Write-Host "ENTERTAINMENT:" -ForegroundColor Yellow
    Write-Host "   play-rock-music, play-jazz-music, play-classical-music"
    Write-Host "   lets-play-tic-tac-toe, lets-play-wordle"
    Write-Host ""
    Write-Host "SYSTEM ACTIONS:" -ForegroundColor White
    Write-Host "   empty-recycle-bin, take-screenshot, set-timer"
    Write-Host "   hibernate-computer, reboot-computer, shut-down-computer"
}

# List all available scripts
function Show-AllCommands {
    Write-Host "`n[CATALOG] All Available Commands:" -ForegroundColor Yellow
    Write-Host ""
    
    $commands = Get-ChildItem "$ScriptRoot/*.ps1" | Where-Object { $_.Name -ne "win_assist_ai.ps1" -and $_.Name -ne "say.ps1" -and $_.Name -ne "open-browser.ps1" } | Sort-Object Name
    
    $categories = @{
        "check-" = @()
        "close-" = @()
        "open-" = @()
        "install-" = @()
        "play-" = @()
        "lets-play-" = @()
        "show-" = @()
        "set-" = @()
        "other" = @()
    }
    
    foreach ($cmd in $commands) {
        $name = $cmd.BaseName
        $categorized = $false
        foreach ($category in $categories.Keys) {
            if ($name.StartsWith($category)) {
                $categories[$category] += $name
                $categorized = $true
                break
            }
        }
        if (-not $categorized) {
            $categories["other"] += $name
        }
    }
    
    foreach ($category in $categories.Keys) {
        if ($categories[$category].Count -gt 0) {
            $categoryName = switch ($category) {
                "check-" { "SYSTEM CHECKS" }
                "close-" { "CLOSE COMMANDS" }
                "open-" { "OPEN COMMANDS" }
                "install-" { "INSTALL COMMANDS" }
                "play-" { "PLAY COMMANDS" }
                "lets-play-" { "GAME COMMANDS" }
                "show-" { "SHOW COMMANDS" }
                "set-" { "SET COMMANDS" }
                "other" { "OTHER COMMANDS" }
            }
            Write-Host "$categoryName ($($categories[$category].Count) commands):" -ForegroundColor Green
            $categories[$category] | ForEach-Object { Write-Host "   $_" }
            Write-Host ""
        }
    }
    
    Write-Host "Total: $($commands.Count) commands available" -ForegroundColor Cyan
}

# Show usage instructions
function Show-Usage {
    Write-Host "`n[HELP] How to Use Talk2Windows:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. DIRECT SCRIPT EXECUTION:" -ForegroundColor Green
    Write-Host "   Execute any script directly by running:"
    Write-Host "   PS> .\scriptname.ps1"
    Write-Host "   Example: .\hello.ps1"
    Write-Host ""
    Write-Host "2. VOICE INTEGRATION:" -ForegroundColor Blue
    Write-Host "   All scripts include text-to-speech responses"
    Write-Host "   Responses are automatically spoken when scripts run"
    Write-Host ""
    Write-Host "3. SCRIPT ORGANIZATION:" -ForegroundColor Magenta
    Write-Host "   - check-* scripts: System information and diagnostics"
    Write-Host "   - close-* scripts: Close applications and windows"
    Write-Host "   - open-* scripts: Launch applications and websites"
    Write-Host "   - install-* scripts: Install software packages"
    Write-Host "   - Conversational scripts: Friendly interactions"
    Write-Host ""
    Write-Host "4. QUICK START EXAMPLES:" -ForegroundColor Cyan
    Write-Host "   .\hello.ps1                 # Friendly greeting"
    Write-Host "   .\check-weather.ps1         # Get weather report"
    Write-Host "   .\open-calculator.ps1       # Open calculator"
    Write-Host "   .\install-discord.ps1       # Install Discord"
    Write-Host "   .\play-rock-music.ps1       # Play rock music"
    Write-Host ""
    Write-Host "5. SYSTEM REQUIREMENTS:" -ForegroundColor Yellow
    Write-Host "   - Windows 10/11 with PowerShell 5.1+"
    Write-Host "   - Text-to-Speech engine (SAPI.SPVoice)"
    Write-Host "   - Internet connection for web features"
    Write-Host "   - Administrator rights for some system operations"
    Write-Host ""
    Write-Host "6. ELEVENLABS AI VOICE (OPTIONAL):" -ForegroundColor Magenta
    Write-Host "   - ElevenLabs account and API key"
    Write-Host "   - High-quality AI voice synthesis"
    Write-Host "   - Natural-sounding speech generation"
    Write-Host "   - Setup: .\setup-elevenlabs.ps1"
    Write-Host "   - Test: .\test-elevenlabs.ps1"
}

# Show help information
function Show-Help {
    Show-Banner
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "   .\win_assist_ai.ps1 [options]"
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host "   -Help           Show this help message"
    Write-Host "   -ListCommands   List all available commands"
    Write-Host "   -TestVoice      Test text-to-speech functionality"
    Write-Host "   -Version        Show version information"
    Write-Host "   -WithSerenade   Force Serenade voice control launch"
    Write-Host "   -NoSerenade     Disable Serenade integration"
    Write-Host ""
    Write-Host "SERENADE VOICE CONTROL:" -ForegroundColor Cyan
    Write-Host "   WinAssistAI now integrates with Serenade for hands-free voice control!"
    Write-Host "   - Automatic detection and launch of Serenade"
    Write-Host "   - Voice command bridge for all WinAssistAI scripts"
    Write-Host "   - Seamless integration with existing PowerShell commands"
    Write-Host ""
    Write-Host "   Install Serenade: .\install-serenade.ps1"
    Write-Host "   Check status:     .\check-serenade.ps1"
    Write-Host "   Launch manually:  .\open-serenade.ps1"
    Write-Host ""
    Write-Host "ELEVENLABS AI VOICE:" -ForegroundColor Magenta
    Write-Host "   WinAssistAI now supports ElevenLabs AI voice synthesis!"
    Write-Host "   - Natural-sounding, high-quality AI voices"
    Write-Host "   - Multiple voice personalities and accents"
    Write-Host "   - Automatic fallback to Windows TTS if needed"
    Write-Host ""
    Write-Host "   Setup ElevenLabs: .\setup-elevenlabs.ps1"
    Write-Host "   Test AI voices:   .\test-elevenlabs.ps1"
    Write-Host "   List voices:      .\test-elevenlabs.ps1 -ListVoices"
    Write-Host ""
    Show-Usage
    Write-Host ""
    Show-CommandCategories
}

# Show version information
function Show-Version {
    Write-Host "`nWinAssistAI Voice Assistant v$AppVersion" -ForegroundColor Cyan
    Write-Host "GitHub: https://github.com/SavageHobbies/win_assist_ai.git" -ForegroundColor White
    Write-Host "License: CC0" -ForegroundColor White
}

# Serenade Integration Functions
function Initialize-SerenadeIntegration {
    Write-Host "[SERENADE] Initializing Serenade voice control integration..." -ForegroundColor Cyan
    
    # Check if user explicitly disabled Serenade
    if ($NoSerenade) {
        Write-Host "[SKIP] Serenade integration disabled by user" -ForegroundColor Yellow
        return $false
    }

    # Check if Serenade is configured
    $configFile = "$HOME\.serenade\scripts\WinAssistAI.js"
    if (!(Test-Path $configFile)) {
        Write-Host "[CONFIG] Serenade not configured - running setup..." -ForegroundColor Yellow
        & "$PSScriptRoot\setup.ps1"
        if (!(Test-Path $configFile)) {
            Write-Host "[ERROR] Setup failed - please run setup.ps1 manually" -ForegroundColor Red
            return $false
        }
    }
    
    try {
        # Check if Serenade is installed
        $serenadePaths = @(
            "$env:LOCALAPPDATA\Programs\Serenade\Serenade.exe",
            "$env:PROGRAMFILES\Serenade\Serenade.exe",
            "$env:PROGRAMFILES(X86)\Serenade\Serenade.exe"
        )
        
        $serenadeInstalled = $false
        foreach ($path in $serenadePaths) {
            if (Test-Path $path) {
                $serenadeInstalled = $true
                $env:SERENADE_PATH = $path
                break
            }
        }
        
        if ($serenadeInstalled) {
            Write-Host "[FOUND] Serenade installation detected" -ForegroundColor Green
            
            # Check if Serenade is running
            $serenadeProcess = Get-Process -Name "Serenade" -ErrorAction SilentlyContinue
            
            if (-not $serenadeProcess -and ($WithSerenade -or (-not $NoSerenade))) {
                Write-Host "[LAUNCH] Starting Serenade voice control..." -ForegroundColor Yellow
                try {
                    Start-Process -FilePath $env:SERENADE_PATH -WindowStyle Normal
                    Start-Sleep -Seconds 2
                    
                    $newProcess = Get-Process -Name "Serenade" -ErrorAction SilentlyContinue
                    if ($newProcess) {
                        Write-Host "[SUCCESS] Serenade launched successfully" -ForegroundColor Green
                        & "$ScriptRoot/say.ps1" "Serenade voice control is now active."
                    }
                } catch {
                    Write-Host "[WARNING] Could not auto-launch Serenade: $($_.Exception.Message)" -ForegroundColor Yellow
                }
            } elseif ($serenadeProcess) {
                Write-Host "[ACTIVE] Serenade is already running" -ForegroundColor Green
            }
            
            # Set up integration bridge
            Write-Host "[BRIDGE] Setting up voice command bridge..." -ForegroundColor Cyan
            try {
                & "$ScriptRoot/serenade-bridge.ps1" -Setup
                Write-Host "[SUCCESS] Serenade integration initialized" -ForegroundColor Green
                return $true
            } catch {
                Write-Host "[WARNING] Bridge setup failed: $($_.Exception.Message)" -ForegroundColor Yellow
                return $false
            }
            
        } else {
            Write-Host "[INFO] Serenade not found - voice integration optional" -ForegroundColor Yellow
            Write-Host "[TIP] Install Serenade for hands-free voice control: .\install-serenade.ps1" -ForegroundColor Cyan
            return $false
        }
        
    } catch {
        Write-Host "[WARNING] Serenade integration check failed: $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

# Main execution
try {
    # Handle command line parameters
    if ($Help) {
        Show-Help
        exit 0
    }
    
    if ($Version) {
        Show-Version
        exit 0
    }
    
    if ($TestVoice) {
        Show-Banner
        Test-Voice
        exit 0
    }
    
    if ($ListCommands) {
        Show-Banner
        Show-AllCommands
        exit 0
    }
    
    # Default behavior - show interactive menu
    Show-Banner
    
    Write-Host "[WELCOME] Welcome to Talk2Windows!" -ForegroundColor Green
    Write-Host ""
    
    # Initialize Serenade integration
    $serenadeActive = Initialize-SerenadeIntegration
    Write-Host ""
    
    # Test TTS functionality
    Test-Voice
    
    Write-Host "`n[QUICKSTART] Quick Start Options:" -ForegroundColor Yellow
    Write-Host "   1. Type '.\winassistai.ps1 -Help' for detailed usage"
    Write-Host "   2. Type '.\winassistai.ps1 -ListCommands' to see all commands"
    Write-Host "   3. Try running: .\hello.ps1"
    Write-Host "   4. Try running: .\check-weather.ps1"
    Write-Host "   5. Setup AI voice: .\setup-elevenlabs.ps1"
    Write-Host ""
    
    Show-CommandCategories
    
    if ($serenadeActive) {
        Write-Host "`n[READY] Talk2Windows with Serenade voice control is ready!" -ForegroundColor Green
        Write-Host "[VOICE] You can now use voice commands or run scripts manually." -ForegroundColor Cyan
        Write-Host "[EXAMPLES] Try saying: 'hello computer', 'check weather', 'open calculator'" -ForegroundColor Yellow
        
        # Final voice confirmation with Serenade integration
        & "$ScriptRoot/say.ps1" "Talk to Windows with Serenade voice control is ready. You can now use voice commands."
    } else {
        Write-Host "`n[READY] The system is ready! You can now run any script in this directory." -ForegroundColor Green
        Write-Host "[TIP] Pro tip: All scripts provide voice feedback when executed!" -ForegroundColor Cyan
        Write-Host "[VOICE] For hands-free control, run: .\install-serenade.ps1" -ForegroundColor Yellow
        
        # Final voice confirmation
        & "$ScriptRoot/say.ps1" "Talk to Windows is ready for your commands. Have a great day!"
    }
    
    exit 0

} catch {
    Write-Host "[ERROR] Error: $($_.Exception.Message)" -ForegroundColor Red
    & "$ScriptRoot/say.ps1" "Sorry, an error occurred during startup."
    exit 1
}