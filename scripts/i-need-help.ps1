<#
.SYNOPSIS
	Shows the Talk2Windows Manual
.DESCRIPTION
	This PowerShell script launches the Web browser with the voice manual for Talk2Windows.
#>

& "$PSScriptRoot/say.ps1" "Hold on."
& "$PSScriptRoot/open-browser.ps1" "https://github.com/savagehobbies/winassistai"
