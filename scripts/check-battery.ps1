﻿<#
.SYNOPSIS
	Checks the battery status
.DESCRIPTION
	This PowerShell script checks the battery status.
.EXAMPLE
	PS> ./check-battery
.LINK
	https://github.com/fleschutz/PowerShell
.NOTES
	Author: Markus Fleschutz | License: CC0
#>

try {
	Add-Type -Assembly System.Windows.Forms
	$Details = [System.Windows.Forms.SystemInformation]::PowerStatus
	if ($Details.BatteryChargeStatus -eq "NoSystemBattery") {
		$BatteryStatus = "No battery"
	} else {
		[int]$Percent = 100*$Details.BatteryLifePercent
		[int]$Remaining = $Details.BatteryLifeRemaining / 60
		$BatteryStatus = "Battery $Percent%, $Remaining min left"
	}
	switch ($Details.PowerLineStatus) {
	"Online"  { $PowerStatus = "plugged in to AC power" }
	"Offline" { $PowerStatus = "disconnected from AC power" }
	}
	& "$PSScriptRoot/_reply.ps1" "$BatteryStatus, $PowerStatus"
	exit 0 # success
} catch {
	"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	exit 1
}