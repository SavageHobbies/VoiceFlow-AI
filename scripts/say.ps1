<#
.SYNOPSIS
    Talk2Windows Text-to-Speech - Enhanced with ElevenLabs Support
.DESCRIPTION
    Automatically uses the enhanced TTS system with ElevenLabs AI when available,
    falls back to Windows SAPI if enhanced system is not available.
.PARAMETER t
    The text to speak
#>

param([string]$t="")

# Try to use enhanced TTS system first
$enhancedScript = Join-Path $PSScriptRoot "say-enhanced.ps1"

if (Test-Path $enhancedScript) {
    try {
        # Use enhanced TTS system
        & $enhancedScript -Text $t
        exit $LASTEXITCODE
    } catch {
        Write-Warning "Enhanced TTS failed, falling back to basic TTS: $($_.Exception.Message)"
    }
}

# Fallback to original Windows SAPI TTS
try {
    $TTS = New-Object -ComObject SAPI.SPVoice
    foreach($v in $TTS.GetVoices()) {
        if($v.GetDescription() -like "*- English*") {
            $TTS.Voice = $v
            break
        }
    }
    [void]$TTS.Speak($t)
    
    # Save last spoken text
    if("$env:TEMP" -ne "") {
        $tmpDir = "$env:TEMP"
    } elseif("$env:TMP" -ne "") {
        $tmpDir = "$env:TMP"
    } elseif($IsLinux) {
        $tmpDir = "/tmp"
    } else {
        $tmpDir = "C:\Temp"
    }
    "$t" | Set-Content "$tmpDir/winassistai.txt" -Encoding UTF8
    
} catch {
    Write-Warning "All TTS systems failed: $($_.Exception.Message)"
    exit 1
}

exit 0
