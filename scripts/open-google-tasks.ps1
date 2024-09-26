<#
.SYNOPSIS
	Opens Google Tasks
.DESCRIPTION
	This PowerShell script launches the Web browser with Google Tasks.
#>

& "$PSScriptRoot/say.ps1" "Hold on..."
& "$PSScriptRoot/open-browser.ps1" "https://tasks.google.com/embed/?origin=https://calendar.google.com&fullWidth=1"
