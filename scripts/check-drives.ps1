<#
.SYNOPSIS
	Checks all local drives 
.DESCRIPTION
	This PowerShell script checks all local drives for free space left (20 GB by default).
.PARAMETER MinLevel
	Specifies the minimum level in Gigabyte
.EXAMPLE
	PS> ./check-drives
.NOTES
	Author: Markus Fleschutz · License: CC0
.LINK
	https://github.com/fleschutz/talk2windows
#>

param([int]$MinLevel = 20) # minimum level in GB

try {
	$Drives = Get-PSDrive -PSProvider FileSystem 
	foreach($Drive in $Drives) {
		$DriveDetails = (Get-PSDrive $Drive.Name)
		[int]$Free = (($DriveDetails.Free / 1024) / 1024) / 1024
		[int]$Used = (($DriveDetails.Used / 1024) / 1024) / 1024
		[int]$Total = ($Used + $Free)

		if ($Total -eq "0") {
			$Reply = "Drive $($Drive.Name): is empty."
		} elseif ($Free -lt $MinLevel) {
			$Reply = "Drive $($Drive.Name): has only $Free GB left to use! $Used of $Total GB is in use."
		} else {
			$Reply = "Drive $($Drive.Name): has $($Free) GB left, $($Total) GB total."
		}
		& "$PSScriptRoot/_reply.ps1" "$Reply"
	}
	exit 0 # success
} catch {
	"⚠️ Error: $($Error[0]) ($($MyInvocation.MyCommand.Name):$($_.InvocationInfo.ScriptLineNumber))"
	exit 1
}
