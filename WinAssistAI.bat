@echo off
cd /d "%~dp0"
echo.
echo ===============================================
echo  WinAssistAI - Voice Assistant for Windows
echo ===============================================
echo.
echo Starting WinAssistAI with Serenade Integration...
echo.

REM Check for command line parameters
if "%1"=="--no-serenade" (
    echo [INFO] Serenade integration disabled
    powershell.exe -ExecutionPolicy Bypass -File ".\scripts\win_assist_ai.ps1" -NoSerenade
) else if "%1"=="--with-serenade" (
    echo [INFO] Forcing Serenade launch
    powershell.exe -ExecutionPolicy Bypass -File ".\scripts\win_assist_ai.ps1" -WithSerenade
) else (
    echo [INFO] Auto-detecting Serenade integration
    powershell.exe -ExecutionPolicy Bypass -File ".\scripts\win_assist_ai.ps1"
)

echo.
echo Press any key to exit...
pause >nul