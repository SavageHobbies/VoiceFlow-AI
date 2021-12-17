﻿<#
.SYNOPSIS
	Opens the CNN website
.DESCRIPTION
	This script launches the Web browser with the CNN website.
.EXAMPLE
	PS> ./open-cnn-website
.NOTES
	Author: Markus Fleschutz · License: CC0
.LINK
	https://github.com/fleschutz/talk2windows
#>

& "$PSScriptRoot/_launch-browser.ps1" "https://www.cnn.com"
exit 0 # success
