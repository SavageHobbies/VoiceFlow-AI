<#
.SYNOPSIS
	Checks the gravity (fun)
.DESCRIPTION
	This PowerShell script checks the current gravity and replies by text-to-speech (TTS).
.EXAMPLE
	PS> ./check-gravity
.LINK
	https://github.com/savagehobbies/winassistai
.NOTES
	Author: Sean Sandoval | License: CC0
#>

& "$PSScriptRoot/say.ps1" "Earth gravity is 9.8 meter per second squared."
