<#
.SYNOPSIS
	Replies to "Are you happy?"
.DESCRIPTION
	This PowerShell script replies to 'Are you happy?' by text-to-speech (TTS).
.EXAMPLE
	PS> ./are-you-happy
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

& "$PSScriptRoot/say.ps1" "Yes, I am."
exit 0 # success
