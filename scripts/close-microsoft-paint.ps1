<#
.SYNOPSIS
	Closes the Microsoft Paint app 
.DESCRIPTION
	This PowerShell script closes the Microsoft Paint application gracefully.
.EXAMPLE
	PS> ./close-microsoft-paint
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

TaskKill /im mspaint.exe
if ($lastExitCode -ne "0") {
	& "$PSScriptRoot/say.ps1" "Sorry, Microsoft Paint isn't running."
	exit 1
}
exit 0 # success
