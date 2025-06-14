<#
.SYNOPSIS
	Say the current year 
.DESCRIPTION
	This PowerShell script speaks the current year by text-to-speech (TTS).
.EXAMPLE
	PS> ./check-year
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

try {
	$Year = (Get-Date).Year

	& "$PSScriptRoot/say.ps1" "It's $Year."
	exit 0 # success
} catch {
	& "$PSScriptRoot/say.ps1" "Sorry: $($Error[0])"
	exit 1
}
