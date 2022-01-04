<#
.SYNOPSIS
	Opens the GitHub website
.DESCRIPTION
	This PowerShell script launches the Web browser with the GitHub website.
.EXAMPLE
	PS> ./open-github-website
.NOTES
	Author: Markus Fleschutz / License: CC0
.LINK
	https://github.com/fleschutz/talk2windows
#>

& "$PSScriptRoot/open-browser.ps1" "https://github.com"
exit 0 # success
