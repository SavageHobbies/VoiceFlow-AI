<#
.SYNOPSIS
	Closes the Visual Studio app
.DESCRIPTION
	This PowerShell script closes the Microsoft Visual Studio application gracefully.
.EXAMPLE
	PS> ./close-visual-studio
.NOTES
	Author: Markus Fleschutz / License: CC0
.LINK
	https://github.com/fleschutz/talk2windows
#>

TaskKill /im devenv.exe
if ($lastExitCode -ne "0") {
	& "$PSScriptRoot/_reply.ps1" "Sorry, Visual Studio isn't running."
	exit 1
}
exit 0 # success
