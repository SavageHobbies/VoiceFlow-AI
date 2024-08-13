﻿<#
.SYNOPSIS
	Insert backslash sign
.DESCRIPTION
	This PowerShell script inserts the backslash sign at the current text cursor position.
#>

(New-Object -com wscript.shell).SendKeys("\")
& "$PSScriptRoot/_reply.ps1" "Backslash."
