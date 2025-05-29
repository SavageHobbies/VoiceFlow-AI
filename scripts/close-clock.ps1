<#
.SYNOPSIS
	Closes the clock
.DESCRIPTION
	This PowerShell script closes the clock application gracefully.
.EXAMPLE
	PS> ./close-clock
.LINK
	https://github.com/savagehobbies/winassistai
.NOTES
	Author: Sean Sandoval | License: CC0
#>

& "$PSScriptRoot/say.ps1" "Okay."
TaskKill /im Time.exe /f
