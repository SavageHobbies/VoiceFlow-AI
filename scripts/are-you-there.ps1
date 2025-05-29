<#
.SYNOPSIS
	Replies to "Are you there?"
.DESCRIPTION
	This PowerShell script replies to 'Are you there?' by text-to-speech (TTS).
.EXAMPLE
	PS> ./are-you-there
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

$Reply = "Yes.", "Sure.", "Yes, sure." | Get-Random
& "$PSScriptRoot/say.ps1" "$Reply"
exit 0 # success
