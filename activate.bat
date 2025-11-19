@echo off
chcp 65001 >nul
echo ====================================
echo Windows 配置脚本
echo ====================================
echo.

:MENU
echo 请选择要执行的操作:
echo.
echo [1] Windows 激活
echo [2] 恢复经典右键菜单
echo [3] 执行全部操作
echo [4] 退出
echo.
set /p choice=请输入选项 (1-4): 

if "%choice%"=="1" goto ACTIVATION
if "%choice%"=="2" goto CONTEXTMENU
if "%choice%"=="3" goto ALL
if "%choice%"=="4" goto END
echo 无效选项，请重新选择
echo.
goto MENU

:ACTIVATION
echo.
echo ====================================
echo Windows 激活
echo ====================================
echo.
echo 请选择您的 Windows 版本:
echo.
echo === Windows 桌面版 ===
echo [1] Windows 11/10 专业版 (Pro)
echo [2] Windows 企业版 LTSC (2024/2021/2019)
echo.
echo === Windows Server ===
echo [3] Windows Server 2025 数据中心版
echo [4] Windows Server 2022 数据中心版
echo.
echo [0] 返回主菜单
echo.
set /p version=请输入版本编号: 

if "%version%"=="0" goto MENU
if "%version%"=="1" set PRODUCT_KEY=W269N-WFGWX-YVC9B-4J6C9-T83GX & set VERSION_NAME=Windows 11/10 专业版
if "%version%"=="2" set PRODUCT_KEY=M7XTQ-FN8P6-TTKYV-9D4CC-J462D & set VERSION_NAME=Windows 企业版 LTSC (2024/2021/2019)
if "%version%"=="3" set PRODUCT_KEY=D764K-2NDRG-47T6Q-P8T8W-YP6DF & set VERSION_NAME=Windows Server 2025 数据中心版
if "%version%"=="4" set PRODUCT_KEY=WX4NM-KYWYW-QJJR4-XV3QB-6VM33 & set VERSION_NAME=Windows Server 2022 数据中心版

if not defined PRODUCT_KEY (
    echo 无效的版本编号，请重新选择
    timeout /t 2 /nobreak >nul
    goto ACTIVATION
)

echo.
echo 您选择的版本: %VERSION_NAME%
echo.
set /p confirm=确认激活此版本? (Y/N): 
if /i not "%confirm%"=="Y" goto ACTIVATION

echo.
echo 正在安装产品密钥...
slmgr.vbs /ipk %PRODUCT_KEY%
if errorlevel 1 (
    echo 密钥安装失败，可能是版本不匹配
    pause
    goto ACTIVATION
)
timeout /t 3 /nobreak >nul

echo.
echo 正在设置 KMS 服务器...
slmgr.vbs /skms 23.80.88.43:10568
timeout /t 3 /nobreak >nul

echo.
echo 正在激活 Windows...
slmgr.vbs /ato
timeout /t 5 /nobreak >nul

echo.
echo ====================================
echo Windows 激活完成!
echo ====================================
pause
goto MENU

:CONTEXTMENU
echo.
echo ====================================
echo 恢复经典右键菜单
echo ====================================
set /p restore=是否恢复经典右键菜单? (Y/N): 
if /i "%restore%"=="Y" (
    echo.
    echo 正在恢复经典右键菜单...
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
    echo.
    echo 重启文件资源管理器以应用右键菜单更改...
    taskkill /f /im explorer.exe
    start explorer.exe
    echo.
    echo 经典右键菜单恢复完成!
) else (
    echo 已跳过恢复经典右键菜单
)
echo.
pause
goto MENU

:ALL
echo.
echo ====================================
echo 执行全部操作
echo ====================================
goto ACTIVATION_ALL

:ACTIVATION_ALL
echo.
echo 请选择您的 Windows 版本:
echo.
echo === Windows 桌面版 ===
echo [1] Windows 11/10 专业版 (Pro)
echo [2] Windows 企业版 LTSC (2024/2021/2019)
echo.
echo === Windows Server ===
echo [3] Windows Server 2025 数据中心版
echo [4] Windows Server 2022 数据中心版
echo.
set /p version=请输入版本编号: 

if "%version%"=="1" set PRODUCT_KEY=W269N-WFGWX-YVC9B-4J6C9-T83GX & set VERSION_NAME=Windows 11/10 专业版
if "%version%"=="2" set PRODUCT_KEY=M7XTQ-FN8P6-TTKYV-9D4CC-J462D & set VERSION_NAME=Windows 企业版 LTSC (2024/2021/2019)
if "%version%"=="3" set PRODUCT_KEY=D764K-2NDRG-47T6Q-P8T8W-YP6DF & set VERSION_NAME=Windows Server 2025 数据中心版
if "%version%"=="4" set PRODUCT_KEY=WX4NM-KYWYW-QJJR4-XV3QB-6VM33 & set VERSION_NAME=Windows Server 2022 数据中心版

if not defined PRODUCT_KEY (
    echo 无效的版本编号，请重新选择
    timeout /t 2 /nobreak >nul
    goto ACTIVATION_ALL
)

echo.
echo 您选择的版本: %VERSION_NAME%
echo.
set /p confirm=确认激活此版本? (Y/N): 
if /i not "%confirm%"=="Y" goto ACTIVATION_ALL

echo.
echo 正在安装产品密钥...
slmgr.vbs /ipk %PRODUCT_KEY%
if errorlevel 1 (
    echo 密钥安装失败，可能是版本不匹配
    pause
    goto ACTIVATION_ALL
)
timeout /t 3 /nobreak >nul

echo.
echo 正在设置 KMS 服务器...
slmgr.vbs /skms 23.80.88.43:10568
timeout /t 3 /nobreak >nul

echo.
echo 正在激活 Windows...
slmgr.vbs /ato
timeout /t 5 /nobreak >nul

echo.
echo ====================================
echo Windows 激活完成!
echo ====================================

echo.
set /p restore=是否恢复经典右键菜单? (Y/N): 
if /i "%restore%"=="Y" (
    echo.
    echo 正在恢复经典右键菜单...
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
    echo.
    echo 重启文件资源管理器以应用右键菜单更改...
    taskkill /f /im explorer.exe
    start explorer.exe
    echo.
    echo 经典右键菜单恢复完成!
) else (
    echo 已跳过恢复经典右键菜单
)

echo.
echo ====================================
echo 所有配置完成!
echo ====================================
pause
goto MENU

:END
echo.
echo 感谢使用，再见！
timeout /t 2 /nobreak >nul
exit