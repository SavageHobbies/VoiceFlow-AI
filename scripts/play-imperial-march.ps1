<#
.SYNOPSIS
	Plays the Imperial March (Star Wars)
.DESCRIPTION
	This PowerShell script plays the Imperial March used in the Star Wars film series.
.EXAMPLE
	PS> ./play-imperial-march
.NOTES
	Author: Markus Fleschutz · License: CC0
.LINK
	https://github.com/fleschutz/talk2windows
#>

[System.Console]::beep(440, 500)      
[System.Console]::beep(440, 500)
[System.Console]::beep(440, 500)       
[System.Console]::beep(349, 350)       
[System.Console]::beep(523, 150)       
[System.Console]::beep(440, 500)       
[System.Console]::beep(349, 350)       
[System.Console]::beep(523, 150)       
[System.Console]::beep(440, 1000)
[System.Console]::beep(659, 500)       
[System.Console]::beep(659, 500)       
[System.Console]::beep(659, 500)       
[System.Console]::beep(698, 350)       
[System.Console]::beep(523, 150)       
[System.Console]::beep(415, 500)       
[System.Console]::beep(349, 350)       
[System.Console]::beep(523, 150)       
[System.Console]::beep(440, 1000)
exit 0 # success
