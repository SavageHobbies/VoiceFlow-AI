<#
.SYNOPSIS
	Closes the Edge browser
.DESCRIPTION
	This PowerShell script closes the Microsoft Edge Web browser gracefully.
.EXAMPLE
	PS> ./close-edge
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

TaskKill /im msedge.exe /f /t
if ($lastExitCode -ne "0") {
	& "$PSScriptRoot/say.ps1" "Sorry, Microsoft Edge isn't running."
	exit 1
}
exit 0 # success
