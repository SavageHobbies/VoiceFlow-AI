<#
.SYNOPSIS
	Closes Thunderbird
.DESCRIPTION
	This PowerShell script closes the Mozilla Thunderbird email application gracefully.
#>

try {
	TaskKill /im thunderbird.exe
	if ($lastExitCode -ne "0") { throw "Can't close Mozilla Thunderbird, maybe it's not running." }

	& "$PSScriptRoot/_reply.ps1" "Thunderbird closed."
} catch { 
	& "$PSScriptRoot/_reply.ps1" "Sorry: $($Error[0])"
}
