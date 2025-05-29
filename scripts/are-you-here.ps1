<#
.SYNOPSIS
	Replies to "Are you here?"
.DESCRIPTION
	This PowerShell script replies to 'Are you here?' by text-to-speech (TTS).
.EXAMPLE
	PS> ./are-you-here
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

$Reply = "Yes.", "Sure.", "Yes, sure." | Get-Random
& "$PSScriptRoot/say.ps1" "$Reply"
exit 0 # success
