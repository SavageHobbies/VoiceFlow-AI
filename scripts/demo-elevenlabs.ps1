<#
.SYNOPSIS
    ElevenLabs AI Voice Demonstration
.DESCRIPTION
    Interactive demonstration of ElevenLabs AI voice capabilities
    showcasing different voices, settings, and use cases.
.EXAMPLE
    .\demo-elevenlabs.ps1
#>

param(
    [switch]$Quick,
    [switch]$Verbose,
    [switch]$Help
)

if ($Help) {
    Get-Help $MyInvocation.MyCommand.Definition -Detailed
    exit 0
}

$ScriptRoot = $PSScriptRoot

function Show-DemoBanner {
    Write-Host @"

 ████████╗████████╗███████╗    ██████╗ ███████╗███╗   ███╗ ██████╗ 
 ╚══██╔══╝╚══██╔══╝██╔════╝    ██╔══██╗██╔════╝████╗ ████║██╔═══██╗
    ██║      ██║   ███████╗    ██║  ██║█████╗  ██╔████╔██║██║   ██║
    ██║      ██║   ╚════██║    ██║  ██║██╔══╝  ██║╚██╔╝██║██║   ██║
    ██║      ██║   ███████║    ██████╔╝███████╗██║ ╚═╝ ██║╚██████╔╝
    ╚═╝      ╚═╝   ╚══════╝    ╚═════╝ ╚══════╝╚═╝     ╚═╝ ╚═════╝ 

              🎙️ ElevenLabs AI Voice Demonstration 🎙️

"@ -ForegroundColor Magenta
}

function Test-ElevenLabsConfig {
    $configPath = Join-Path (Split-Path $ScriptRoot -Parent) "config\elevenlabs.json"
    
    if (-not (Test-Path $configPath)) {
        return $false
    }
    
    try {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        return ($config.enabled -and -not [string]::IsNullOrWhiteSpace($config.apiKey))
    } catch {
        return $false
    }
}

function Start-QuickDemo {
    Write-Host "[QUICK DEMO] Running quick demonstration..." -ForegroundColor Yellow
    
    if (Test-ElevenLabsConfig) {
        Write-Host "[AI VOICE] Testing ElevenLabs AI voice..." -ForegroundColor Cyan
        & "$ScriptRoot\say.ps1" "This is a quick demonstration of ElevenLabs AI voice synthesis. Notice how natural and expressive this voice sounds compared to traditional text-to-speech systems."
    } else {
        Write-Host "[WINDOWS TTS] ElevenLabs not configured, using Windows TTS..." -ForegroundColor Yellow
        & "$ScriptRoot\say.ps1" "ElevenLabs AI voice is not configured. To experience high-quality AI voice synthesis, please run the setup script."
    }
    
    Write-Host "[COMPLETE] Quick demo finished!" -ForegroundColor Green
}

function Start-FullDemo {
    Write-Host "[FULL DEMO] Starting comprehensive demonstration..." -ForegroundColor Yellow
    Write-Host ""
    
    # Demo 1: Configuration Check
    Write-Host "DEMO 1: Configuration Status" -ForegroundColor Cyan
    Write-Host "──────────────────────────────" -ForegroundColor Cyan
    
    if (Test-ElevenLabsConfig) {
        Write-Host "[✓] ElevenLabs AI voice is configured and ready!" -ForegroundColor Green
        & "$ScriptRoot\test-elevenlabs.ps1" -Status
        
        Write-Host "`nDEMO 2: AI Voice Quality" -ForegroundColor Cyan
        Write-Host "─────────────────────────" -ForegroundColor Cyan
        Write-Host "[SPEAKING] Listen to the natural quality of AI voice..." -ForegroundColor Yellow
        
        $aiMessage = @"
Welcome to the future of computer interaction! This is ElevenLabs artificial intelligence voice synthesis in action. 

Notice how natural and expressive this voice sounds. The AI can convey emotion, emphasis, and personality in ways that traditional text-to-speech simply cannot match.

This technology transforms your Talk to Windows experience, making every interaction more engaging and professional.
"@
        
        & "$ScriptRoot\say.ps1" $aiMessage
        
        Write-Host "`nDEMO 3: Voice Comparison" -ForegroundColor Cyan
        Write-Host "──────────────────────────" -ForegroundColor Cyan
        Write-Host "[COMPARISON] Now listen to the same text with Windows TTS..." -ForegroundColor Yellow
        
        $comparisonMessage = "This is the same message using traditional Windows text-to-speech. You can hear the difference in quality and naturalness."
        
        & "$ScriptRoot\say-enhanced.ps1" -Text $comparisonMessage -Force windows
        
        Write-Host "`nDEMO 4: Interactive Commands" -ForegroundColor Cyan
        Write-Host "────────────────────────────" -ForegroundColor Cyan
        Write-Host "[INTERACTIVE] Testing common Talk2Windows commands..." -ForegroundColor Yellow
        
        # Test various script types
        $commands = @(
            @{ Script = "hello.ps1"; Description = "Greeting" },
            @{ Script = "what-time-is-it.ps1"; Description = "Time check" },
            @{ Script = "thank-you.ps1"; Description = "Polite response" }
        )
        
        foreach ($cmd in $commands) {
            $scriptPath = Join-Path $ScriptRoot $cmd.Script
            if (Test-Path $scriptPath) {
                Write-Host "[DEMO] $($cmd.Description): .\$($cmd.Script)" -ForegroundColor White
                & $scriptPath
                Start-Sleep -Seconds 2
            }
        }
        
        Write-Host "`nDEMO 5: Voice Management" -ForegroundColor Cyan
        Write-Host "──────────────────────────" -ForegroundColor Cyan
        Write-Host "[INFO] Available voice management commands:" -ForegroundColor Yellow
        Write-Host "• List voices: .\test-elevenlabs.ps1 -ListVoices" -ForegroundColor White
        Write-Host "• Test voice: .\test-elevenlabs.ps1 -Voice 'VoiceName'" -ForegroundColor White
        Write-Host "• Full test: .\test-elevenlabs.ps1 -Test" -ForegroundColor White
        Write-Host "• Reset config: .\test-elevenlabs.ps1 -Reset" -ForegroundColor White
        
    } else {
        Write-Host "[INFO] ElevenLabs AI voice is not configured" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "DEMO: Windows TTS Fallback" -ForegroundColor Cyan
        Write-Host "──────────────────────────" -ForegroundColor Cyan
        Write-Host "[SPEAKING] Using Windows TTS (fallback mode)..." -ForegroundColor Yellow
        
        $fallbackMessage = @"
ElevenLabs AI voice is not yet configured, so you're hearing the Windows text-to-speech fallback system.

To experience the dramatic improvement in voice quality, sign up for a free ElevenLabs account and run the setup wizard.

The difference in naturalness and expression is remarkable!
"@
        
        & "$ScriptRoot\say.ps1" $fallbackMessage
        
        Write-Host "`n[SETUP] To configure ElevenLabs AI voice:" -ForegroundColor Cyan
        Write-Host "1. Get free API key: https://elevenlabs.io" -ForegroundColor White
        Write-Host "2. Run setup: .\setup-elevenlabs.ps1" -ForegroundColor White
        Write-Host "3. Run demo again: .\demo-elevenlabs.ps1" -ForegroundColor White
    }
    
    Write-Host "`n[COMPLETE] Full demonstration finished!" -ForegroundColor Green
}

try {
    Show-DemoBanner
    
    Write-Host "🎙️ Welcome to the ElevenLabs AI Voice Demonstration! 🎙️" -ForegroundColor Green
    Write-Host ""
    Write-Host "This demo showcases the enhanced voice capabilities of Talk2Windows" -ForegroundColor White
    Write-Host "with ElevenLabs AI voice synthesis integration." -ForegroundColor White
    Write-Host ""
    
    if ($Quick) {
        Start-QuickDemo
    } else {
        # Ask user for demo type
        Write-Host "Choose demonstration type:" -ForegroundColor Yellow
        Write-Host "1. Quick demo (30 seconds)" -ForegroundColor White
        Write-Host "2. Full demo (3-5 minutes)" -ForegroundColor White
        Write-Host "3. Configuration check only" -ForegroundColor White
        Write-Host ""
        
        $choice = Read-Host "Enter choice (1-3) or press Enter for full demo"
        
        switch ($choice) {
            "1" { 
                Start-QuickDemo 
            }
            "3" { 
                & "$ScriptRoot\test-elevenlabs.ps1" -Status 
            }
            default { 
                Start-FullDemo 
            }
        }
    }
    
    Write-Host ""
    Write-Host "🎉 Thank you for trying ElevenLabs AI Voice! 🎉" -ForegroundColor Green
    Write-Host ""
    Write-Host "Additional resources:" -ForegroundColor Yellow
    Write-Host "• Setup guide: ELEVENLABS_SETUP.md" -ForegroundColor White
    Write-Host "• Voice testing: .\test-elevenlabs.ps1" -ForegroundColor White
    Write-Host "• Configuration: .\setup-elevenlabs.ps1" -ForegroundColor White
    Write-Host "• Welcome script: .\welcome-elevenlabs.ps1" -ForegroundColor White
    Write-Host ""
    
    exit 0
    
} catch {
    Write-Host "[ERROR] Demo failed: $($_.Exception.Message)" -ForegroundColor Red
    & "$ScriptRoot\say.ps1" "Sorry, the demonstration encountered an error."
    
    if ($Verbose) {
        Write-Host "[DEBUG] $($_.ScriptStackTrace)" -ForegroundColor Gray
    }
    
    exit 1
}