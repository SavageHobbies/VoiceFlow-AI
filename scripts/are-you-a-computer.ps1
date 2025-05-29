<#
.SYNOPSIS
	Answers to "are you a computer?"
.DESCRIPTION
	This PowerShell script replies to 'are you a computer?' by text-to-speech (TTS).
.EXAMPLE
	PS> ./are-you-a-computer
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

& "$PSScriptRoot/say.ps1" "Not exactly. I'm the operating system of this computer."
exit 0 # success
