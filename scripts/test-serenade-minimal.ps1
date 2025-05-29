<#
.SYNOPSIS
    Minimal Serenade Integration Test
#>

try {
    Write-Host "Minimal test script running successfully" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host "Error in minimal test: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}