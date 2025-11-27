@echo off
title Windows Config Script

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ============================================
    echo ERROR: Administrator privileges required
    echo ============================================
    echo.
    echo Please right-click and select "Run as administrator"
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

echo ====================================
echo Windows Configuration Script
echo ====================================
echo.
echo Loading...
timeout /t 1 /nobreak >nul
cls

:MENU
cls
echo ====================================
echo Windows Configuration Script
echo ====================================
echo.
echo Select an option:
echo.
echo [1] Activate Windows
echo [2] Restore Classic Context Menu
echo [3] Run All
echo [4] Exit
echo.
set choice=
set /p choice=Enter option (1-4): 

if not defined choice (
    echo.
    echo ERROR: Please enter an option!
    timeout /t 2 /nobreak >nul
    goto MENU
)

if "%choice%"=="1" goto ACTIVATION
if "%choice%"=="2" goto CONTEXTMENU
if "%choice%"=="3" goto ALL
if "%choice%"=="4" goto END
echo.
echo Invalid option!
timeout /t 2 /nobreak >nul
goto MENU

:ACTIVATION
cls
echo.
echo ====================================
echo Windows Activation
echo ====================================
echo.
echo Select your Windows version:
echo.
echo === Desktop Editions ===
echo [1] Windows 11/10 Pro
echo [2] Windows Enterprise LTSC 2024/2021/2019
echo.
echo === Server Editions ===
echo [3] Windows Server 2025 Datacenter
echo [4] Windows Server 2022 Datacenter
echo.
echo [0] Back to main menu
echo.
set ver=
set /p ver=Enter version number: 

if not defined ver (
    echo.
    echo ERROR: Please enter version number!
    timeout /t 2 /nobreak >nul
    goto ACTIVATION
)

if "%ver%"=="0" goto MENU

set KEY=
set VNAME=

if "%ver%"=="1" (
    set KEY=W269N-WFGWX-YVC9B-4J6C9-T83GX
    set VNAME=Windows 11/10 Pro
)
if "%ver%"=="2" (
    set KEY=M7XTQ-FN8P6-TTKYV-9D4CC-J462D
    set VNAME=Windows Enterprise LTSC
)
if "%ver%"=="3" (
    set KEY=D764K-2NDRG-47T6Q-P8T8W-YP6DF
    set VNAME=Windows Server 2025 Datacenter
)
if "%ver%"=="4" (
    set KEY=WX4NM-KYWYW-QJJR4-XV3QB-6VM33
    set VNAME=Windows Server 2022 Datacenter
)

if not defined KEY (
    echo.
    echo Invalid version number!
    timeout /t 2 /nobreak >nul
    goto ACTIVATION
)

echo.
echo Selected version: %VNAME%
echo.
set conf=
set /p conf=Confirm activation? (Y/N): 
if /i not "%conf%"=="Y" goto ACTIVATION

echo.
echo Installing product key...
slmgr.vbs /ipk %KEY%
if errorlevel 1 (
    echo Key installation failed!
    pause
    goto ACTIVATION
)
timeout /t 3 /nobreak >nul

echo.
echo Setting KMS server...
slmgr.vbs /skms 23.80.88.43:10568
timeout /t 3 /nobreak >nul

echo.
echo Activating Windows...
slmgr.vbs /ato
timeout /t 5 /nobreak >nul

echo.
echo ====================================
echo Windows activation completed!
echo ====================================
pause
goto MENU

:CONTEXTMENU
cls
echo.
echo ====================================
echo Restore Classic Context Menu
echo ====================================
echo.
echo WARNING: This will restart Explorer!
echo Save all your work before continuing.
echo.
set rest=
set /p rest=Continue? (Y/N): 
if /i not "%rest%"=="Y" (
    echo Operation cancelled.
    echo.
    pause
    goto MENU
)

echo.
echo Modifying registry...
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve

if errorlevel 1 (
    echo Registry modification failed!
    pause
    goto MENU
)

echo.
echo Registry modified successfully!
echo Restarting Explorer...
timeout /t 2 /nobreak >nul

taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 /nobreak >nul
start explorer.exe

echo.
echo Waiting for Explorer to start...
timeout /t 3 /nobreak >nul

echo.
echo ====================================
echo Classic context menu restored!
echo ====================================
pause
goto MENU

:ALL
cls
echo.
echo ====================================
echo Run All Operations
echo ====================================
goto ACTIVATION_ALL

:ACTIVATION_ALL
echo.
echo Select your Windows version:
echo.
echo === Desktop Editions ===
echo [1] Windows 11/10 Pro
echo [2] Windows Enterprise LTSC 2024/2021/2019
echo.
echo === Server Editions ===
echo [3] Windows Server 2025 Datacenter
echo [4] Windows Server 2022 Datacenter
echo.
set ver=
set /p ver=Enter version number: 

set KEY=
set VNAME=

if "%ver%"=="1" (
    set KEY=W269N-WFGWX-YVC9B-4J6C9-T83GX
    set VNAME=Windows 11/10 Pro
)
if "%ver%"=="2" (
    set KEY=M7XTQ-FN8P6-TTKYV-9D4CC-J462D
    set VNAME=Windows Enterprise LTSC
)
if "%ver%"=="3" (
    set KEY=D764K-2NDRG-47T6Q-P8T8W-YP6DF
    set VNAME=Windows Server 2025 Datacenter
)
if "%ver%"=="4" (
    set KEY=WX4NM-KYWYW-QJJR4-XV3QB-6VM33
    set VNAME=Windows Server 2022 Datacenter
)

if not defined KEY (
    echo Invalid version number!
    timeout /t 2 /nobreak >nul
    goto ACTIVATION_ALL
)

echo.
echo Selected version: %VNAME%
echo.
set conf=
set /p conf=Confirm activation? (Y/N): 
if /i not "%conf%"=="Y" goto ACTIVATION_ALL

echo.
echo Installing product key...
slmgr.vbs /ipk %KEY%
if errorlevel 1 (
    echo Key installation failed!
    pause
    goto ACTIVATION_ALL
)
timeout /t 3 /nobreak >nul

echo.
echo Setting KMS server...
slmgr.vbs /skms 23.80.88.43:10568
timeout /t 3 /nobreak >nul

echo.
echo Activating Windows...
slmgr.vbs /ato
timeout /t 5 /nobreak >nul

echo.
echo ====================================
echo Windows activation completed!
echo ====================================

echo.
echo WARNING: Next operation will restart Explorer!
echo Save all your work before continuing.
echo.
set rest=
set /p rest=Restore classic context menu? (Y/N): 
if /i not "%rest%"=="Y" (
    echo Skipped context menu restoration.
    echo.
    echo ====================================
    echo Activation completed!
    echo ====================================
    pause
    goto MENU
)

echo.
echo Modifying registry...
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve

if errorlevel 1 (
    echo Registry modification failed!
    pause
    goto MENU
)

echo.
echo Registry modified successfully!
echo Restarting Explorer...
timeout /t 2 /nobreak >nul

taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 /nobreak >nul
start explorer.exe

echo.
echo Waiting for Explorer to start...
timeout /t 3 /nobreak >nul

echo.
echo ====================================
echo All configurations completed!
echo ====================================
pause
goto MENU

:END
cls
echo.
echo ====================================
echo Thank you for using this tool!
echo ====================================
echo.
echo Window will close in 3 seconds...
echo Or press any key to exit now
timeout /t 3
exit /b 0
