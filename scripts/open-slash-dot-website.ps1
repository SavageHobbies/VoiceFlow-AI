<#
.SYNOPSIS
	Opens the Slashdot website
.DESCRIPTION
	This PowerShell script launches the Web browser with the Slashdot website.
.EXAMPLE
	PS> ./open-slash-dot-website
.NOTES
	Author: Markus Fleschutz / License: CC0
.LINK
	https://github.com/fleschutz/talk2windows
#>

& "$PSScriptRoot/open-browser.ps1" "https://slashdot.org"
exit 0 # success
