@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Windows Classic Context Menu

if /i "%~1"=="--help" goto USAGE
if /i "%~1"=="/?" goto USAGE
if /i "%~1"=="--self-test" goto SELF_TEST
if not "%~1"=="" (
    echo ERROR: Unknown option: "%~1"
    call :PRINT_USAGE
    exit /b 1
)

cls
echo ============================================
echo  Restore the Windows Classic Context Menu
echo ============================================
echo.
echo This changes the context-menu preference for the current user.
echo It does not require administrator privileges.
echo.
choice /c YN /n /m "Apply the registry change? [Y/N]: "
if errorlevel 2 (
    echo Operation cancelled.
    exit /b 0
)

reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve >nul 2>&1
if errorlevel 1 (
    echo ERROR: The registry change failed.
    exit /b 1
)

echo.
echo Registry change completed.
echo Sign out and sign back in to apply it, or restart Explorer now.
echo.
choice /c YN /n /m "Restart Explorer for the current session? [Y/N]: "
if errorlevel 2 (
    echo The change will take effect after the next sign-in.
    exit /b 0
)

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo ERROR: Windows PowerShell was not found.
    echo Sign out and sign back in to apply the change.
    exit /b 1
)

echo.
echo Restarting Explorer for the current session...
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "$sessionId=(Get-Process -Id $PID).SessionId; Get-Process explorer -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $sessionId } | Stop-Process -Force" >nul 2>&1
start "" "%SystemRoot%\explorer.exe"

powershell.exe -NoLogo -NoProfile -NonInteractive -Command "$sessionId=(Get-Process -Id $PID).SessionId; for ($i=0; $i -lt 10; $i++) { $running=@(Get-Process explorer -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $sessionId }).Count -gt 0; if ($running) { exit 0 }; Start-Sleep -Milliseconds 500 }; exit 1" >nul 2>&1
if errorlevel 1 (
    echo WARNING: Explorer did not restart within five seconds.
    echo Start Explorer manually or sign out and sign back in.
    exit /b 1
)

echo Explorer restarted successfully.
exit /b 0

:USAGE
call :PRINT_USAGE
exit /b 0

:PRINT_USAGE
echo Usage:
echo   classic-context-menu.bat
echo.
echo Restores the classic context menu for the current Windows user.
exit /b 0

:SELF_TEST
where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo SELF-TEST FAILED: Windows PowerShell was not found.
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -NonInteractive -Command "$sessionId=(Get-Process -Id $PID).SessionId; $running=@(Get-Process explorer -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $sessionId }).Count -gt 0; exit 0" >nul 2>&1
if errorlevel 1 (
    echo SELF-TEST FAILED: Explorer session check could not run.
    exit /b 1
)

echo All classic-context-menu.bat self-tests passed.
exit /b 0
