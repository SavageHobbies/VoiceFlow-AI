<#
.SYNOPSIS
	Opens 'The Telegraph'
.DESCRIPTION
	This PowerShell script launches the Web browser with telegraph.co.uk
#>

& "$PSScriptRoot/_reply.ps1" "Okay."
& "$PSScriptRoot/open-browser.ps1" "https://www.telegraph.co.uk/"
