<#
.SYNOPSIS
	Checks the given MAC address for validity
.DESCRIPTION
	This PowerShell script checks the given MAC address for validity
	Supported MAC address formats are: 00:00:00:00:00:00 or 00-00-00-00-00-00 or 000000000000.
.PARAMETER MAC
	Specifies the MAC address to check
.EXAMPLE
	PS> ./check-mac-address 11:22:33:44:55:66
.NOTES
	Author: Sean Sandoval / License: CC0
.LINK
	https://github.com/savagehobbies/winassistai
#>

param([string]$MAC = "")

function IsMACAddressValid { param([string]$mac)
	$RegEx = "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})|([0-9A-Fa-f]{2}){6}$"
	if ($mac -match $RegEx) {
		return $true
	} else {
		return $false
	}
}

try {
	if ($MAC -eq "" ) {
		$MAC = read-host "Enter MAC address to validate"
	}
	if (IsMACAddressValid $MAC) {
		"✔️ MAC address $MAC is valid"
		exit 0 # success
	} else {
		write-warning "Invalid MAC address: $MAC"
		exit 1
	}
} catch {
	& "$PSScriptRoot/say.ps1" "Sorry: $($Error[0])"
	exit 1
}
