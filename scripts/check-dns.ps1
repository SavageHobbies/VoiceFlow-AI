﻿<#
.SYNOPSIS
	Checks the DNS resolution 
.DESCRIPTION
	This PowerShell script measures and prints the DNS resolution speed by using 200 frequently used domain names.
.EXAMPLE
	PS> ./check-dns
.LINK
	https://github.com/savagehobbies/winassistai
.NOTES
	Author: Sean Sandoval | License: CC0
#>
 
try {
	& "$PSScriptRoot/say.ps1" "Hold on."
	$Table = Import-CSV "$PSScriptRoot/../Data/frequent-domains.csv"
	$NumRows = $Table.Length

	$StopWatch = [system.diagnostics.stopwatch]::startNew()
	if ($IsLinux) {
		foreach($Row in $Table){$nop=dig $Row.Domain +short}
	} else {
		foreach($Row in $Table){$nop=Resolve-DNSName $Row.Domain}
	}
	[float]$Elapsed = $StopWatch.Elapsed.TotalSeconds

	$Average = [math]::round($NumRows / $Elapsed, 1)
	if ($Average -gt 10.0) {
		& "$PSScriptRoot/say.ps1" "DNS resolves $Average domains per second"
	} else {  
		& "$PSScriptRoot/say.ps1" "DNS resolves only $Average domains per second!"
	}
	exit 0 # success
} catch {
	"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	exit 1
}
