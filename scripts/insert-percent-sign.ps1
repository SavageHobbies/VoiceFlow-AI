﻿<#
.SYNOPSIS
	Insert percent sign
.DESCRIPTION
	This PowerShell script inserts the percent sign ('%') at the current text cursor position.
#>

(New-Object -com wscript.shell).SendKeys("{%}")
& "$PSScriptRoot/_reply.ps1" "Percent sign."
