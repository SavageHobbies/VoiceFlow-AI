﻿<#
.SYNOPSIS
	Insert copyright sign
.DESCRIPTION
	This PowerShell script inserts the copyright sign.
#>

(New-Object -com wscript.shell).SendKeys("©")
& "$PSScriptRoot/_reply.ps1" "Copyright inserted."
