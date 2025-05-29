<#
.SYNOPSIS
	Closes Notepad++
.DESCRIPTION
	This PowerShell script closes the Notepad++ application gracefully.
.EXAMPLE
	PS> ./close-note-pad-plus-plus
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

& "$PSScriptRoot/say.ps1" "Okay."
& "$PSScriptRoot/close-program.ps1" "Notepad++" "notepad++" ""
