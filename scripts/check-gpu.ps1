﻿<#
.SYNOPSIS
        Checks the GPU 
.DESCRIPTION
        This PowerShell script queries GPU details and prints it.
.EXAMPLE
        PS> ./check-gpu
.LINK
        https://github.com/fleschutz/talk2windows
.NOTES
        Author: Markus Fleschutz | License: CC0
#>

function Bytes2String { param([int64]$Bytes)
        if ($Bytes -lt 1000) { return "$Bytes bytes" }
        $Bytes /= 1000
        if ($Bytes -lt 1000) { return "$($Bytes)KB" }
        $Bytes /= 1000
        if ($Bytes -lt 1000) { return "$($Bytes)MB" }
        $Bytes /= 1000
        if ($Bytes -lt 1000) { return "$($Bytes)GB" }
        $Bytes /= 1000
        return "$($Bytes)TB"
}

try {
	& "$PSScriptRoot/say.ps1" "Hold on."
	$Details = Get-WmiObject Win32_VideoController
	$Model = $Details.Caption
	$RAMSize = $Details.AdapterRAM
	$ResWidth = $Details.CurrentHorizontalResolution
	$ResHeight = $Details.CurrentVerticalResolution
	$BitsPerPixel = $Details.CurrentBitsPerPixel
	$RefreshRate = $Details.CurrentRefreshRate
	$DriverVersion = $Details.DriverVersion
	$Status = $Details.Status
	& "$PSScriptRoot/say.ps1" "It's a $Model GPU ($(Bytes2String $RAMSize) RAM, $($ResWidth)x$($ResHeight) pixels, $BitsPerPixel bit, $RefreshRate Hz, driver $DriverVersion, status $Status)"
} catch {
        "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
        exit 1
}
