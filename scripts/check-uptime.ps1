<#
.SYNOPSIS
	Determines the uptime 
.DESCRIPTION
	This PowerShell script determines and says the uptime by text-to-speech (TTS).
.EXAMPLE
	PS> ./check-uptime
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

try {
	if ($IsLinux) {
		$Uptime = (get-uptime)
	} else {
		$BootTime = Get-WinEvent -ProviderName eventlog | Where-Object {$_.Id -eq 6005} | Select-Object TimeCreated -First 1 
		$TimeNow = Get-Date 
		$Uptime = New-TimeSpan -Start $BootTime.TimeCreated.Date -End $TimeNow
	}
	
	$Days = $Uptime.Days
	$Hours = $Uptime.Hours
	$Minutes = $Uptime.Minutes 

	$Reply = "I'm up for "
	if ($Days -eq "1") {
		$Reply += "1 day, "
	} elseif ($Days -ne "0") {
		$Reply += "$Days days, "
	}
	if ($Hours -eq "1") {
		$Reply += "1 hour "
	} elseif ($Hours -ne "0") {
		$Reply += "$Hours hours "
	}
	if ($Minutes -eq "1") {
		$Reply += "and 1 minute"
	} elseif ($Minutes -ne "0") {
		$Reply += "and $Minutes minutes"
	}
	$Reply += "."
	& "$PSScriptRoot/say.ps1" $Reply
	exit 0 # success
} catch {
	& "$PSScriptRoot/say.ps1" "Sorry: $($Error[0])"
	exit 1
}
