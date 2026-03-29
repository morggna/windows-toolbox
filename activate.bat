@echo off
setlocal EnableDelayedExpansion
title Windows Config Script

:: ============================================
:: 接收 KMS 服务器参数
:: 用法: activate.bat <kms_host:port>
:: ============================================
set "KMS_SERVER=%~1"
if not defined KMS_SERVER (
    echo.
    echo ============================================
    echo ERROR: KMS server address not provided
    echo ============================================
    echo.
    echo Usage: activate.bat ^<kms_host:port^>
    echo Example: activate.bat 1.2.3.4:1234
    echo.
    pause >nul
    exit /b 1
)

:: ============================================
:: 权限检查
:: ============================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ============================================
    echo ERROR: Administrator privileges required
    echo ============================================
    echo.
    echo Please right-click and select "Run as administrator"
    echo.
    pause >nul
    exit /b 1
)

cls
echo ====================================
echo  Windows Configuration Script
echo ====================================
echo.
echo Loading...
timeout /t 1 /nobreak >nul

:: ============================================
:: 主菜单
:: ============================================
:MENU
cls
echo ====================================
echo  Windows Configuration Script
echo ====================================
echo.
echo  [1] Activate Windows
echo  [2] Restore Classic Context Menu
echo  [3] Run All
echo  [4] Exit
echo.
set "choice="
set /p "choice=Enter option (1-4): "

if not defined choice goto MENU_ERR
if "%choice%"=="1" goto ACTIVATION
if "%choice%"=="2" goto CONTEXTMENU
if "%choice%"=="3" goto ALL
if "%choice%"=="4" goto END

:MENU_ERR
echo.
echo  Invalid option, please try again.
timeout /t 2 /nobreak >nul
goto MENU

:: ============================================
:: Windows 激活
:: ============================================
:ACTIVATION
cls
echo.
echo ====================================
echo  Windows Activation
echo ====================================
echo.
echo  === Desktop Editions ===
echo  [1] Windows 11/10 Pro
echo  [2] Windows Enterprise LTSC 2024/2021/2019
echo.
echo  === Server Editions ===
echo  [3] Windows Server 2025 Datacenter
echo  [4] Windows Server 2022 Datacenter
echo.
echo  [0] Back to main menu
echo.

set "KEY="
set "VNAME="
set "ver="
set /p "ver=Enter version number: "

if not defined ver goto ACTIVATION_ERR
if "%ver%"=="0" goto MENU

if "%ver%"=="1" (
    set "KEY=W269N-WFGWX-YVC9B-4J6C9-T83GX"
    set "VNAME=Windows 11/10 Pro"
)
if "%ver%"=="2" (
    set "KEY=M7XTQ-FN8P6-TTKYV-9D4CC-J462D"
    set "VNAME=Windows Enterprise LTSC"
)
if "%ver%"=="3" (
    set "KEY=D764K-2NDRG-47T6Q-P8T8W-YP6DF"
    set "VNAME=Windows Server 2025 Datacenter"
)
if "%ver%"=="4" (
    set "KEY=WX4NM-KYWYW-QJJR4-XV3QB-6VM33"
    set "VNAME=Windows Server 2022 Datacenter"
)

if not defined KEY goto ACTIVATION_ERR

echo.
echo  Selected: %VNAME%
echo.
set "conf="
set /p "conf=Confirm activation? (Y/N): "
if /i not "%conf%"=="Y" goto ACTIVATION

call :DO_ACTIVATE
if errorlevel 1 (
    echo.
    echo  Activation failed! Please check the error above.
    pause
)
goto MENU

:ACTIVATION_ERR
echo.
echo  Invalid input, please try again.
timeout /t 2 /nobreak >nul
goto ACTIVATION

:: ============================================
:: 核心激活逻辑（子程序）
:: ============================================
:DO_ACTIVATE
echo.
echo  [1/3] Installing product key...
cscript //nologo %windir%\System32\slmgr.vbs /ipk %KEY%
if errorlevel 1 (
    echo  ERROR: Key installation failed!
    exit /b 1
)

echo.
echo  [2/3] Setting KMS server: %KMS_SERVER%
cscript //nologo %windir%\System32\slmgr.vbs /skms %KMS_SERVER%
if errorlevel 1 (
    echo  ERROR: KMS server configuration failed!
    exit /b 1
)

echo.
echo  [3/3] Activating Windows...
cscript //nologo %windir%\System32\slmgr.vbs /ato
if errorlevel 1 (
    echo  ERROR: Activation failed!
    exit /b 1
)

echo.
echo ====================================
echo  Windows activation completed!
echo ====================================
exit /b 0

:: ============================================
:: 恢复经典右键菜单
:: ============================================
:CONTEXTMENU
cls
echo.
echo ====================================
echo  Restore Classic Context Menu
echo ====================================
echo.
echo  WARNING: This will restart Explorer!
echo  Save all your work before continuing.
echo.
set "rest="
set /p "rest=Continue? (Y/N): "
if /i not "%rest%"=="Y" (
    echo.
    echo  Operation cancelled.
    timeout /t 2 /nobreak >nul
    goto MENU
)

call :DO_CONTEXTMENU
if errorlevel 1 (
    echo.
    echo  Operation failed! Please check the error above.
    pause
    goto MENU
)
pause
goto MENU

:: ============================================
:: 核心右键菜单逻辑（子程序）
:: ============================================
:DO_CONTEXTMENU
echo.
echo  [1/3] Modifying registry...
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve >nul 2>&1
if errorlevel 1 (
    echo  ERROR: Registry modification failed!
    exit /b 1
)
echo  Registry modified successfully.

echo.
echo  [2/3] Stopping Explorer...
taskkill /im explorer.exe >nul 2>&1
:WAIT_KILL
tasklist /fi "imagename eq explorer.exe" 2>nul | find /i "explorer.exe" >nul
if not errorlevel 1 (
    timeout /t 1 /nobreak >nul
    goto WAIT_KILL
)

echo.
echo  [3/3] Restarting Explorer...
start explorer.exe
:WAIT_START
tasklist /fi "imagename eq explorer.exe" 2>nul | find /i "explorer.exe" >nul
if errorlevel 1 (
    timeout /t 1 /nobreak >nul
    goto WAIT_START
)

echo.
echo ====================================
echo  Classic context menu restored!
echo ====================================
exit /b 0

:: ============================================
:: 一键执行全部操作
:: ============================================
:ALL
cls
echo.
echo ====================================
echo  Run All Operations
echo ====================================
echo.
echo  === Desktop Editions ===
echo  [1] Windows 11/10 Pro
echo  [2] Windows Enterprise LTSC 2024/2021/2019
echo.
echo  === Server Editions ===
echo  [3] Windows Server 2025 Datacenter
echo  [4] Windows Server 2022 Datacenter
echo.

set "KEY="
set "VNAME="
set "ver="
set /p "ver=Enter version number: "

if not defined ver goto ALL_VER_ERR

if "%ver%"=="1" (
    set "KEY=W269N-WFGWX-YVC9B-4J6C9-T83GX"
    set "VNAME=Windows 11/10 Pro"
)
if "%ver%"=="2" (
    set "KEY=M7XTQ-FN8P6-TTKYV-9D4CC-J462D"
    set "VNAME=Windows Enterprise LTSC"
)
if "%ver%"=="3" (
    set "KEY=D764K-2NDRG-47T6Q-P8T8W-YP6DF"
    set "VNAME=Windows Server 2025 Datacenter"
)
if "%ver%"=="4" (
    set "KEY=WX4NM-KYWYW-QJJR4-XV3QB-6VM33"
    set "VNAME=Windows Server 2022 Datacenter"
)

if not defined KEY goto ALL_VER_ERR

echo.
echo  Selected: %VNAME%
echo.
set "conf="
set /p "conf=Confirm activation? (Y/N): "
if /i not "%conf%"=="Y" goto ALL

call :DO_ACTIVATE
if errorlevel 1 (
    echo.
    echo  Activation failed! Skipping remaining operations.
    pause
    goto MENU
)

echo.
echo  WARNING: Next step will restart Explorer!
echo  Save all your work before continuing.
echo.
set "rest="
set /p "rest=Restore classic context menu? (Y/N): "
if /i not "%rest%"=="Y" (
    echo.
    echo  Skipped context menu restoration.
    echo.
    echo ====================================
    echo  All selected operations completed!
    echo ====================================
    pause
    goto MENU
)

call :DO_CONTEXTMENU
if errorlevel 1 (
    echo.
    echo  Context menu restoration failed!
    pause
    goto MENU
)

echo.
echo ====================================
echo  All operations completed!
echo ====================================
pause
goto MENU

:ALL_VER_ERR
echo.
echo  Invalid input, please try again.
timeout /t 2 /nobreak >nul
goto ALL

:: ============================================
:: 退出
:: ============================================
:END
cls
echo.
echo ====================================
echo  Thank you for using this tool!
echo ====================================
echo.
echo  Window will close in 3 seconds...
timeout /t 3 /nobreak >nul
endlocal
exit /b 0
