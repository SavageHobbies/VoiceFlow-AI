<#
.SYNOPSIS
    Welcome to ElevenLabs AI Voice Integration
.DESCRIPTION
    Demonstrates the ElevenLabs AI voice integration with Talk2Windows.
    This script showcases the enhanced voice quality and provides
    a warm welcome message using AI voice synthesis.
.EXAMPLE
    .\welcome-elevenlabs.ps1
#>

param(
    [switch]$Verbose,
    [switch]$Help
)

if ($Help) {
    Get-Help $MyInvocation.MyCommand.Definition -Detailed
    exit 0
}

$ScriptRoot = $PSScriptRoot

function Show-ElevenLabsBanner {
    Write-Host @"

 ███████╗██╗     ███████╗██╗   ██╗███████╗███╗   ██╗██╗      █████╗ ██████╗ ███████╗
 ██╔════╝██║     ██╔════╝██║   ██║██╔════╝████╗  ██║██║     ██╔══██╗██╔══██╗██╔════╝
 █████╗  ██║     █████╗  ██║   ██║█████╗  ██╔██╗ ██║██║     ███████║██████╔╝███████╗
 ██╔══╝  ██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║██║     ██╔══██║██╔══██╗╚════██║
 ███████╗███████╗███████╗ ╚████╔╝ ███████╗██║ ╚████║███████╗██║  ██║██████╔╝███████║
 ╚══════╝╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝

              🎙️ AI Voice Integration for Talk2Windows 🎙️
                   Natural • Expressive • Professional

"@ -ForegroundColor Magenta
}

try {
    Show-ElevenLabsBanner
    
    Write-Host "[WELCOME] Checking ElevenLabs AI voice integration..." -ForegroundColor Cyan
    
    # Check if ElevenLabs is configured
    $configPath = Join-Path (Split-Path $ScriptRoot -Parent) "config\elevenlabs.json"
    $elevenLabsConfigured = $false
    
    if (Test-Path $configPath) {
        try {
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            $elevenLabsConfigured = ($config.enabled -and -not [string]::IsNullOrWhiteSpace($config.apiKey))
            
            if ($elevenLabsConfigured) {
                Write-Host "[✓] ElevenLabs AI voice is configured and ready!" -ForegroundColor Green
                Write-Host "[VOICE] Current voice: $($config.voice.name)" -ForegroundColor Cyan
                
                # Enhanced welcome message with ElevenLabs
                $welcomeMessage = @"
Welcome to Talk to Windows with ElevenLabs AI voice synthesis! 

This system now features high-quality, natural-sounding AI voices that make your computer interactions more engaging and professional. 

The AI voice you're hearing right now is much more realistic than traditional text-to-speech systems. You can choose from dozens of different voice personalities, adjust voice settings, and enjoy seamless fallback to Windows TTS if needed.

All your existing Talk to Windows commands now sound better than ever. Whether you're checking the weather, opening applications, or having conversations with your computer, the AI voice brings a new level of quality to your experience.

Thank you for upgrading to ElevenLabs AI voice synthesis. Your computer now sounds as smart as it acts!
"@
                
                Write-Host "`n[AI VOICE] Playing welcome message with ElevenLabs..." -ForegroundColor Yellow
                & "$ScriptRoot\say.ps1" $welcomeMessage
                
                Write-Host "`n[SUCCESS] ElevenLabs AI voice demonstration completed!" -ForegroundColor Green
                Write-Host ""
                Write-Host "Next steps:" -ForegroundColor Yellow
                Write-Host "• Test different voices: .\test-elevenlabs.ps1 -ListVoices" -ForegroundColor White
                Write-Host "• Adjust settings: Edit config\elevenlabs.json" -ForegroundColor White
                Write-Host "• Try voice commands: All existing scripts now use AI voice!" -ForegroundColor White
                
            } else {
                Write-Host "[INFO] ElevenLabs is installed but not configured" -ForegroundColor Yellow
                
                $basicMessage = "Welcome to Talk to Windows! ElevenLabs AI voice is available but not yet configured. Would you like to set up high-quality AI voice synthesis?"
                
                Write-Host "`n[WINDOWS TTS] Playing message with Windows TTS..." -ForegroundColor Yellow
                & "$ScriptRoot\say.ps1" $basicMessage
                
                Write-Host "`n[SETUP] To configure ElevenLabs AI voice:" -ForegroundColor Cyan
                Write-Host "1. Run: .\setup-elevenlabs.ps1" -ForegroundColor White
                Write-Host "2. Get API key from: https://elevenlabs.io" -ForegroundColor White
                Write-Host "3. Follow the interactive setup wizard" -ForegroundColor White
            }
        } catch {
            Write-Host "[WARNING] Configuration file exists but is invalid" -ForegroundColor Yellow
            $elevenLabsConfigured = $false
        }
    }
    
    if (-not $elevenLabsConfigured) {
        Write-Host "[INFO] ElevenLabs not configured - using Windows TTS" -ForegroundColor Yellow
        
        $setupMessage = @"
Welcome to Talk to Windows! 

This system supports ElevenLabs AI voice synthesis for high-quality, natural-sounding speech. 

To upgrade from Windows text-to-speech to AI voice synthesis, run the setup script and get your free API key from ElevenLabs. 

The setup process is quick and easy, and you'll immediately notice the improved voice quality.
"@
        
        Write-Host "`n[WINDOWS TTS] Playing setup information..." -ForegroundColor Yellow
        & "$ScriptRoot\say.ps1" $setupMessage
        
        Write-Host "`n[SETUP] To enable ElevenLabs AI voice:" -ForegroundColor Cyan
        Write-Host "1. Run: .\setup-elevenlabs.ps1" -ForegroundColor White
        Write-Host "2. Sign up at: https://elevenlabs.io (free tier available)" -ForegroundColor White
        Write-Host "3. Copy your API key and complete setup" -ForegroundColor White
        Write-Host "4. Run this script again to hear the difference!" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "🎉 Talk2Windows with ElevenLabs Integration 🎉" -ForegroundColor Green
    Write-Host ""
    
    exit 0
    
} catch {
    Write-Host "[ERROR] Welcome script failed: $($_.Exception.Message)" -ForegroundColor Red
    & "$ScriptRoot\say.ps1" "Sorry, the welcome script encountered an error."
    
    if ($Verbose) {
        Write-Host "[DEBUG] $($_.ScriptStackTrace)" -ForegroundColor Gray
    }
    
    exit 1
}