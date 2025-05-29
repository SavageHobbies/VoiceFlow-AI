<#
.SYNOPSIS
	Replies to "Are you awake?"
.DESCRIPTION
	This PowerShell script replies to 'Are you awake?' by text-to-speech (TTS).
.EXAMPLE
	PS> ./are-you-awake
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

$Reply = "Yes.", "Sure.", "Yes, sure.", "Always." | Get-Random
& "$PSScriptRoot/say.ps1" "$Reply"
exit 0 # success
