<#
.SYNOPSIS
	Closes Launcher
.DESCRIPTION
	This PowerShell script closes the Launcher application gracefully.
.EXAMPLE
	PS> ./close-launcher
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

& "$PSScriptRoot/say.ps1" "Okay."
tskill Launcher
