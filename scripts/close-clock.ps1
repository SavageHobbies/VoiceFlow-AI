<#
.SYNOPSIS
	Closes the clock
.DESCRIPTION
	This PowerShell script closes the clock application gracefully.
.EXAMPLE
	PS> ./close-clock
.LINK
	https://github.com/fleschutz/talk2windows
.NOTES
	Author: Markus Fleschutz | License: CC0
#>

& "$PSScriptRoot/_reply.ps1" "Okay."
TaskKill /im Time.exe /f
exit 0 # success
