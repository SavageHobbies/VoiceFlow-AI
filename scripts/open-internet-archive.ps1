<#
.SYNOPSIS
	Opens the Internet Archive website 
.DESCRIPTION
	This PowerShell script launches the Web browser with the Internet Archive website.
.EXAMPLE
	PS> ./open-internet-archive
.NOTES
	Author: Markus Fleschutz / License: CC0
.LINK
	https://github.com/fleschutz/talk2windows
#>

& "$PSScriptRoot/open-browser.ps1" "https://archive.org"
exit 0 # success
