<#
.SYNOPSIS
	Installs Thunderbird
.DESCRIPTION
	This PowerShell script installs Mozilla Thunderbird.
.EXAMPLE
	PS> ./install-thunderbird
.LINK
	https://github.com/fleschutz/talk2windows
.NOTES
	Author: Markus Fleschutz | License: CC0
#>

try {
	& "$PSScriptRoot/_reply.ps1" "Installing Mozilla Thunderbird, please wait..."

	& winget install --id Mozilla.Thunderbird --accept-package-agreements --accept-source-agreements
	if ($lastExitCode -ne "0") { throw "'winget install' failed" }

	& "$PSScriptRoot/_reply.ps1" "Mozilla Thunderbird installed successfully."
	exit 0 # success
} catch {
	& "$PSScriptRoot/_reply.ps1" "Sorry: $($Error[0])"
	exit 1
}
