<#
.SYNOPSIS
	Opens Google Contacts
.DESCRIPTION
	This PowerShell script launches the Web browser with Google Contacts.
#>

& "$PSScriptRoot/_reply.ps1" "Okay."
& "$PSScriptRoot/open-browser.ps1" "https://contacts.google.com"
exit 0 # success
