<#
.SYNOPSIS
	Close Remote Desktop
.DESCRIPTION
	This PowerShell script closes the Remote Desktoip application gracefully.
.EXAMPLE
	PS> ./close-remote-desktop
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

TaskKill /im mstsc.exe
if ($lastExitCode -ne "0") {
	& "$PSScriptRoot/say.ps1" "Sorry, Remote Desktop isn't running."
	exit 1
}
exit 0 # success
