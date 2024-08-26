<#
.SYNOPSIS
	Opens Google Slides
.DESCRIPTION
	This PowerShell script launches the Web browser with Google Slides.
#>

& "$PSScriptRoot/_reply.ps1" "Hold on..."
& "$PSScriptRoot/open-browser.ps1" "https://docs.google.com/presentation/u/0/"
exit 0 # success
