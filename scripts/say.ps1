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

# Use working Windows TTS system
$workingScript = Join-Path $PSScriptRoot "say-working.ps1"

if (Test-Path $workingScript) {
    try {
        # Use working TTS system
        & $workingScript $t
        exit $LASTEXITCODE
    } catch {
        Write-Warning "Working TTS failed, falling back to basic TTS: $($_.Exception.Message)"
    }
}

# Fallback to basic Windows SAPI TTS
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
