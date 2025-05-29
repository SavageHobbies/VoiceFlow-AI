<#
.SYNOPSIS
	Closes Microsoft's Cortana application
.DESCRIPTION
	This PowerShell script closes Microsoft's Cortana application gracefully.
.EXAMPLE
	PS> ./close-cortana
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

& "$PSScriptRoot/close-program.ps1" "Cortana" "Cortana" "Cortana"
