<#
.SYNOPSIS
	Replies to "Are you listening?"
.DESCRIPTION
	This PowerShell script replies to 'Are you listening?' by text-to-speech (TTS).
.EXAMPLE
	PS> ./are-you-listening
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

$Reply = "Yes.", "Sure.", "Yes, sure.", "Always." | Get-Random
& "$PSScriptRoot/say.ps1" "$Reply"
exit 0 # success
