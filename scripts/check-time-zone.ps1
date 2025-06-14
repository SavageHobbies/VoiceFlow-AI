<#
.SYNOPSIS
	Determines the time zone
.DESCRIPTION
	This PowerShell script determines and returns the current time zone.
.EXAMPLE
	PS> ./check-time-zone
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

try {
	$TimeZone = (Get-Timezone)

	& "$PSScriptRoot/say.ps1" "It's $($TimeZone.DisplayName)"
	exit 0 # success
} catch {
	& "$PSScriptRoot/say.ps1" "Sorry: $($Error[0])"
	exit 1
}
