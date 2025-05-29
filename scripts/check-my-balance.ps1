<#
.SYNOPSIS
	Checks the balance (fun)
.DESCRIPTION
	This PowerShell script checks the balance and replies by text-to-speech (TTS).
.EXAMPLE
	PS> ./check-my-balance
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

& "$PSScriptRoot/say.ps1" "OK, what's your account number?"
