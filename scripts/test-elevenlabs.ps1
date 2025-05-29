<#
.SYNOPSIS
    ElevenLabs Voice Testing and Management
.DESCRIPTION
    Test ElevenLabs voices, manage configuration, and troubleshoot issues.
.PARAMETER Test
    Run comprehensive voice tests
.PARAMETER ListVoices
    List all available voices
.PARAMETER Voice
    Test specific voice by name or ID
.PARAMETER Text
    Custom text to test with
.PARAMETER Status
    Show current configuration status
.PARAMETER Reset
    Reset to default configuration
.EXAMPLE
    .\test-elevenlabs.ps1 -Test
    .\test-elevenlabs.ps1 -ListVoices
    .\test-elevenlabs.ps1 -Voice "Rachel" -Text "Hello world"
#>

param(
    [switch]$Test,
    [switch]$ListVoices,
    [string]$Voice = "",
    [string]$Text = "This is a test of the ElevenLabs AI voice synthesis system.",
    [switch]$Status,
    [switch]$Reset,
    [switch]$Verbose,
    [switch]$Help
)

$ScriptRoot = $PSScriptRoot
$ConfigPath = Join-Path (Split-Path $ScriptRoot -Parent) "config\elevenlabs.json"

function Show-Help {
    Write-Host @"

=== ElevenLabs Voice Testing & Management ===

Test your ElevenLabs AI voice configuration and manage settings.

USAGE:
    .\test-elevenlabs.ps1 -Test              # Run all tests
    .\test-elevenlabs.ps1 -ListVoices        # List available voices
    .\test-elevenlabs.ps1 -Status            # Show configuration status
    .\test-elevenlabs.ps1 -Voice "Rachel"    # Test specific voice
    .\test-elevenlabs.ps1 -Reset             # Reset configuration
    .\test-elevenlabs.ps1 -Help              # Show this help

OPTIONS:
    -Test           Run comprehensive voice tests
    -ListVoices     List all available ElevenLabs voices
    -Voice NAME     Test specific voice by name or ID
    -Text TEXT      Custom text to test with (default test message)
    -Status         Show current configuration and API status
    -Reset          Reset configuration to defaults
    -Verbose        Show detailed output
    -Help           Show this help message

"@ -ForegroundColor Cyan
}

function Get-Config {
    try {
        if (Test-Path $ConfigPath) {
            return Get-Content $ConfigPath -Raw | ConvertFrom-Json
        }
        return $null
    } catch {
        Write-Warning "Failed to load config: $($_.Exception.Message)"
        return $null
    }
}

function Test-ApiConnection {
    param([string]$ApiKey, [string]$ApiUrl)
    
    try {
        $headers = @{
            "xi-api-key" = $ApiKey
            "Content-Type" = "application/json"
        }
        
        $userInfo = Invoke-RestMethod -Uri "$ApiUrl/user" -Headers $headers -Method Get -TimeoutSec 10
        return @{
            Success = $true
            User = $userInfo
        }
    } catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function Get-Voices {
    param([string]$ApiKey, [string]$ApiUrl)
    
    try {
        $headers = @{
            "xi-api-key" = $ApiKey
            "Content-Type" = "application/json"
        }
        
        $response = Invoke-RestMethod -Uri "$ApiUrl/voices" -Headers $headers -Method Get -TimeoutSec 15
        return $response.voices
    } catch {
        Write-Warning "Failed to get voices: $($_.Exception.Message)"
        return $null
    }
}

function Show-Status {
    Write-Host "`n=== ElevenLabs Configuration Status ===" -ForegroundColor Cyan
    Write-Host ""
    
    $config = Get-Config
    
    if (-not $config) {
        Write-Host "[STATUS] Not configured" -ForegroundColor Red
        Write-Host "[ACTION] Run: .\setup-elevenlabs.ps1" -ForegroundColor Yellow
        return
    }
    
    Write-Host "Configuration File: $ConfigPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "SETTINGS:" -ForegroundColor Yellow
    Write-Host "• Enabled: $($config.enabled)" -ForegroundColor White
    Write-Host "• API URL: $($config.apiUrl)" -ForegroundColor White
    Write-Host "• Voice: $($config.voice.name) ($($config.voice.id))" -ForegroundColor White
    Write-Host "• Model: $($config.model)" -ForegroundColor White
    Write-Host "• Fallback to Windows: $($config.fallbackToWindows)" -ForegroundColor White
    Write-Host "• Audio Caching: $($config.cacheAudio)" -ForegroundColor White
    Write-Host ""
    
    if ($config.enabled -and -not [string]::IsNullOrWhiteSpace($config.apiKey)) {
        Write-Host "API CONNECTION:" -ForegroundColor Yellow
        $result = Test-ApiConnection -ApiKey $config.apiKey -ApiUrl $config.apiUrl
        
        if ($result.Success) {
            Write-Host "• Status: Connected ✓" -ForegroundColor Green
            if ($result.User.subscription) {
                Write-Host "• Subscription: $($result.User.subscription.tier)" -ForegroundColor White
                if ($result.User.subscription.character_count -ne $null) {
                    Write-Host "• Characters used: $($result.User.subscription.character_count)" -ForegroundColor White
                }
                if ($result.User.subscription.character_limit -ne $null) {
                    Write-Host "• Character limit: $($result.User.subscription.character_limit)" -ForegroundColor White
                }
            }
        } else {
            Write-Host "• Status: Connection failed ✗" -ForegroundColor Red
            Write-Host "• Error: $($result.Error)" -ForegroundColor Red
        }
    } else {
        Write-Host "API CONNECTION:" -ForegroundColor Yellow
        Write-Host "• Status: Not configured" -ForegroundColor Red
        Write-Host "• Action: Run setup-elevenlabs.ps1" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

function Show-VoiceList {
    $config = Get-Config
    
    if (-not $config -or -not $config.enabled -or [string]::IsNullOrWhiteSpace($config.apiKey)) {
        Write-Host "[ERROR] ElevenLabs not configured. Run .\setup-elevenlabs.ps1 first." -ForegroundColor Red
        return
    }
    
    Write-Host "`n=== Available ElevenLabs Voices ===" -ForegroundColor Cyan
    Write-Host ""
    
    $voices = Get-Voices -ApiKey $config.apiKey -ApiUrl $config.apiUrl
    
    if (-not $voices) {
        Write-Host "[ERROR] Could not fetch voices" -ForegroundColor Red
        return
    }
    
    foreach ($voice in $voices) {
        $current = if ($voice.voice_id -eq $config.voice.id) { " [CURRENT]" } else { "" }
        $premium = if ($voice.category -eq "premade") { "" } else { " [CUSTOM]" }
        
        Write-Host "Name: $($voice.name)$current$premium" -ForegroundColor ($voice.voice_id -eq $config.voice.id ? "Green" : "White")
        Write-Host "ID: $($voice.voice_id)" -ForegroundColor Gray
        Write-Host "Category: $($voice.category)" -ForegroundColor Gray
        
        if ($voice.labels) {
            if ($voice.labels.description) {
                Write-Host "Description: $($voice.labels.description)" -ForegroundColor Gray
            }
            if ($voice.labels.gender) {
                Write-Host "Gender: $($voice.labels.gender)" -ForegroundColor Gray
            }
            if ($voice.labels.age) {
                Write-Host "Age: $($voice.labels.age)" -ForegroundColor Gray
            }
            if ($voice.labels.accent) {
                Write-Host "Accent: $($voice.labels.accent)" -ForegroundColor Gray
            }
        }
        
        Write-Host ""
    }
    
    Write-Host "Total voices: $($voices.Count)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To test a voice: .\test-elevenlabs.ps1 -Voice 'VoiceName'" -ForegroundColor Yellow
}

function Test-SpecificVoice {
    param([string]$VoiceInput, [string]$TestText)
    
    $config = Get-Config
    
    if (-not $config -or -not $config.enabled -or [string]::IsNullOrWhiteSpace($config.apiKey)) {
        Write-Host "[ERROR] ElevenLabs not configured" -ForegroundColor Red
        return
    }
    
    # Get available voices
    $voices = Get-Voices -ApiKey $config.apiKey -ApiUrl $config.apiUrl
    if (-not $voices) {
        Write-Host "[ERROR] Could not fetch voices" -ForegroundColor Red
        return
    }
    
    # Find the voice
    $targetVoice = $voices | Where-Object { 
        $_.name -eq $VoiceInput -or 
        $_.voice_id -eq $VoiceInput -or 
        $_.name -like "*$VoiceInput*" 
    } | Select-Object -First 1
    
    if (-not $targetVoice) {
        Write-Host "[ERROR] Voice '$VoiceInput' not found" -ForegroundColor Red
        Write-Host "[TIP] Use -ListVoices to see available voices" -ForegroundColor Yellow
        return
    }
    
    Write-Host "`n=== Testing Voice: $($targetVoice.name) ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Voice ID: $($targetVoice.voice_id)" -ForegroundColor Gray
    Write-Host "Category: $($targetVoice.category)" -ForegroundColor Gray
    Write-Host "Text: $TestText" -ForegroundColor White
    Write-Host ""
    Write-Host "Generating speech..." -ForegroundColor Yellow
    
    try {
        & "$ScriptRoot\say-enhanced.ps1" -Text $TestText -Voice $targetVoice.voice_id -Verbose:$Verbose
        Write-Host "[✓] Voice test completed!" -ForegroundColor Green
    } catch {
        Write-Host "[✗] Voice test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Run-AllTests {
    Write-Host "`n=== ElevenLabs Comprehensive Test Suite ===" -ForegroundColor Cyan
    Write-Host ""
    
    # Test 1: Configuration
    Write-Host "TEST 1: Configuration Check" -ForegroundColor Yellow
    Write-Host "───────────────────────────" -ForegroundColor Yellow
    
    $config = Get-Config
    if ($config -and $config.enabled) {
        Write-Host "[✓] Configuration loaded" -ForegroundColor Green
    } else {
        Write-Host "[✗] Configuration not found or disabled" -ForegroundColor Red
        Write-Host "[ACTION] Run: .\setup-elevenlabs.ps1" -ForegroundColor Yellow
        return
    }
    
    # Test 2: API Connection
    Write-Host "`nTEST 2: API Connection" -ForegroundColor Yellow
    Write-Host "──────────────────────" -ForegroundColor Yellow
    
    if ([string]::IsNullOrWhiteSpace($config.apiKey)) {
        Write-Host "[✗] No API key configured" -ForegroundColor Red
        return
    }
    
    $apiTest = Test-ApiConnection -ApiKey $config.apiKey -ApiUrl $config.apiUrl
    if ($apiTest.Success) {
        Write-Host "[✓] API connection successful" -ForegroundColor Green
        if ($apiTest.User.subscription) {
            Write-Host "[INFO] Subscription: $($apiTest.User.subscription.tier)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "[✗] API connection failed: $($apiTest.Error)" -ForegroundColor Red
        return
    }
    
    # Test 3: Voice List
    Write-Host "`nTEST 3: Voice Availability" -ForegroundColor Yellow
    Write-Host "──────────────────────────" -ForegroundColor Yellow
    
    $voices = Get-Voices -ApiKey $config.apiKey -ApiUrl $config.apiUrl
    if ($voices) {
        Write-Host "[✓] Retrieved $($voices.Count) voices" -ForegroundColor Green
        
        # Check if configured voice exists
        $currentVoice = $voices | Where-Object { $_.voice_id -eq $config.voice.id }
        if ($currentVoice) {
            Write-Host "[✓] Configured voice '$($config.voice.name)' is available" -ForegroundColor Green
        } else {
            Write-Host "[⚠] Configured voice '$($config.voice.name)' not found" -ForegroundColor Yellow
            Write-Host "[INFO] Will use first available voice" -ForegroundColor Cyan
        }
    } else {
        Write-Host "[✗] Could not retrieve voices" -ForegroundColor Red
        return
    }
    
    # Test 4: Windows TTS Fallback
    Write-Host "`nTEST 4: Windows TTS Fallback" -ForegroundColor Yellow
    Write-Host "────────────────────────────" -ForegroundColor Yellow
    
    try {
        $TTS = New-Object -ComObject SAPI.SPVoice
        [void]$TTS.Speak("Testing Windows TTS fallback")
        Write-Host "[✓] Windows TTS is working" -ForegroundColor Green
    } catch {
        Write-Host "[✗] Windows TTS failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test 5: ElevenLabs TTS
    Write-Host "`nTEST 5: ElevenLabs TTS Generation" -ForegroundColor Yellow
    Write-Host "─────────────────────────────────" -ForegroundColor Yellow
    
    try {
        Write-Host "Generating test audio..." -ForegroundColor Cyan
        & "$ScriptRoot\say-enhanced.ps1" -Text "This is a test of the ElevenLabs AI voice synthesis system. If you can hear this message clearly, the integration is working perfectly." -Force elevenlabs -Verbose:$Verbose
        Write-Host "[✓] ElevenLabs TTS test completed!" -ForegroundColor Green
    } catch {
        Write-Host "[✗] ElevenLabs TTS failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test 6: Auto-switching
    Write-Host "`nTEST 6: Auto-switching (Enhanced Script)" -ForegroundColor Yellow
    Write-Host "────────────────────────────────────────" -ForegroundColor Yellow
    
    try {
        Write-Host "Testing automatic TTS selection..." -ForegroundColor Cyan
        & "$ScriptRoot\say-enhanced.ps1" -Text "Testing automatic TTS selection. This should use ElevenLabs if available, or fall back to Windows TTS." -Verbose:$Verbose
        Write-Host "[✓] Auto-switching test completed!" -ForegroundColor Green
    } catch {
        Write-Host "[✗] Auto-switching test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`n=== Test Suite Complete ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "If all tests passed, your ElevenLabs integration is working perfectly!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Available commands:" -ForegroundColor Yellow
    Write-Host "• .\say-enhanced.ps1 'Your text here'" -ForegroundColor White
    Write-Host "• .\say.ps1 'Your text here' (auto-enhanced)" -ForegroundColor White
    Write-Host "• .\test-elevenlabs.ps1 -ListVoices" -ForegroundColor White
    Write-Host "• .\test-elevenlabs.ps1 -Voice 'VoiceName'" -ForegroundColor White
}

function Reset-Configuration {
    Write-Host "`n=== Reset ElevenLabs Configuration ===" -ForegroundColor Yellow
    Write-Host ""
    
    $confirm = Read-Host "This will reset all ElevenLabs settings. Continue? (y/N)"
    
    if ($confirm -match '^y|yes$') {
        try {
            if (Test-Path $ConfigPath) {
                Remove-Item $ConfigPath -Force
                Write-Host "[✓] Configuration file removed" -ForegroundColor Green
            }
            
            # Clear cache
            $cacheDir = Join-Path (Split-Path $ScriptRoot -Parent) "cache\audio"
            if (Test-Path $cacheDir) {
                Remove-Item "$cacheDir\*" -Force -ErrorAction SilentlyContinue
                Write-Host "[✓] Audio cache cleared" -ForegroundColor Green
            }
            
            Write-Host ""
            Write-Host "Configuration has been reset." -ForegroundColor Green
            Write-Host "Run .\setup-elevenlabs.ps1 to reconfigure." -ForegroundColor Yellow
            
        } catch {
            Write-Host "[✗] Reset failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "[CANCELLED] Reset cancelled" -ForegroundColor Yellow
    }
}

# Main execution
try {
    if ($Help) {
        Show-Help
        exit 0
    }
    
    if ($Status) {
        Show-Status
        exit 0
    }
    
    if ($Reset) {
        Reset-Configuration
        exit 0
    }
    
    if ($ListVoices) {
        Show-VoiceList
        exit 0
    }
    
    if (-not [string]::IsNullOrWhiteSpace($Voice)) {
        Test-SpecificVoice -VoiceInput $Voice -TestText $Text
        exit 0
    }
    
    if ($Test) {
        Run-AllTests
        exit 0
    }
    
    # Default: Show status
    Show-Status
    
} catch {
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    if ($Verbose) {
        Write-Host "[DEBUG] $($_.ScriptStackTrace)" -ForegroundColor Gray
    }
    exit 1
}