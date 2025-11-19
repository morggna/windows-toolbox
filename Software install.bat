@echo off
chcp 65001 >nul
echo ====================================
echo Windows 软件自动安装脚本 (Scoop)
echo ====================================
echo.

REM 检查 PowerShell 是否可用
powershell -Command "exit" >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未检测到 PowerShell
    pause
    exit /b 1
)

REM 检查 Scoop 是否已安装
powershell -Command "Get-Command scoop -ErrorAction SilentlyContinue" >nul 2>&1
if %errorlevel% neq 0 (
    echo Scoop 未安装，正在配置安装...
    echo.
    
    REM 询问是否自定义安装路径
    echo Scoop 默认安装在: %USERPROFILE%\scoop
    echo.
    set /p custom_path=是否自定义安装路径? (Y/N，默认 N): 
    
    if /i "%custom_path%"=="Y" (
        echo.
        echo 请输入 Scoop 安装路径（例如: D:\Scoop）
        echo 注意: 
        echo   - 路径不要包含空格
        echo   - 建议使用英文路径
        echo   - 不要使用系统保护的目录
        set /p scoop_install_path=安装路径: 
        
        REM 去除路径末尾的反斜杠
        if "%scoop_install_path:~-1%"=="\" set "scoop_install_path=%scoop_install_path:~0,-1%"
        
        echo.
        echo 将安装到: %scoop_install_path%
        echo 全局软件路径: %scoop_install_path%\global
        set /p confirm_path=确认使用此路径? (Y/N): 
        
        if /i not "%confirm_path%"=="Y" (
            echo 已取消安装
            pause
            exit /b 1
        )
        
        REM 设置环境变量
        setx SCOOP "%scoop_install_path%"
        setx SCOOP_GLOBAL "%scoop_install_path%\global"
        
        REM 为当前会话设置环境变量
        set SCOOP=%scoop_install_path%
        set SCOOP_GLOBAL=%scoop_install_path%\global
        
        echo.
        echo 环境变量已设置:
        echo SCOOP=%SCOOP%
        echo SCOOP_GLOBAL=%SCOOP_GLOBAL%
    ) else (
        echo.
        echo 使用默认安装路径: %USERPROFILE%\scoop
    )
    
    echo.
    echo 注意: 首次安装 Scoop 需要较长时间，请耐心等待
    echo.
    
    REM 安装 Scoop
    powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; iwr -useb get.scoop.sh | iex"
    
    if %errorlevel% neq 0 (
        echo.
        echo Scoop 安装失败！
        echo 请检查网络连接或手动安装 Scoop
        echo.
        echo 手动安装命令:
        echo 默认路径: irm get.scoop.sh ^| iex
        echo 自定义路径: $env:SCOOP='你的路径'; irm get.scoop.sh ^| iex
        pause
        exit /b 1
    )
    
    echo.
    echo Scoop 安装成功！
    echo 正在添加常用软件仓库...
    
    REM 添加常用 bucket
    powershell -Command "scoop bucket add extras"
    powershell -Command "scoop bucket add versions"
    powershell -Command "scoop bucket add java"
    
    echo.
    echo 安装路径信息:
    powershell -Command "Write-Host 'Scoop 路径: ' -NoNewline; scoop prefix scoop"
    echo.
)

echo Scoop 版本:
powershell -Command "scoop --version"
echo.

:MENU
echo ====================================
echo 请选择安装类型
echo ====================================
echo.
echo [1] 快速安装（开发者常用软件包）
echo [2] 自定义选择
echo [3] 查看软件列表
echo [4] 更新 Scoop
echo [5] 查看 Scoop 信息
echo [6] 退出
echo.
set /p choice=请输入选项 (1-6): 

if "%choice%"=="1" goto QUICK_INSTALL
if "%choice%"=="2" goto CUSTOM_INSTALL
if "%choice%"=="3" goto LIST_SOFTWARE
if "%choice%"=="4" goto UPDATE_SCOOP
if "%choice%"=="5" goto SCOOP_INFO
if "%choice%"=="6" goto END
echo 无效选项，请重新选择
echo.
goto MENU

:QUICK_INSTALL
echo.
echo ====================================
echo 快速安装开发者常用软件包
echo ====================================
echo.
echo 将安装以下软件:
echo - Git (版本控制)
echo - 7-Zip (压缩工具)
echo - Aria2 (下载加速)
echo - Everything (文件搜索)
echo - PowerToys (Windows 增强)
echo - VS Code (代码编辑器)
echo - Notepad++ (文本编辑器)
echo - Google Chrome (浏览器)
echo.
set /p confirm=确认安装? (Y/N): 
if /i not "%confirm%"=="Y" goto MENU

echo.
echo 开始安装...
echo.

REM 安装 aria2 加速下载
call :INSTALL_SOFTWARE "aria2" "Aria2 下载器"

REM 配置 Scoop 使用 aria2
powershell -Command "scoop config aria2-enabled true"

call :INSTALL_SOFTWARE "git" "Git"
call :INSTALL_SOFTWARE "7zip" "7-Zip"
call :INSTALL_SOFTWARE "everything" "Everything"
call :INSTALL_SOFTWARE "powertoys" "PowerToys"
call :INSTALL_SOFTWARE "vscode" "VS Code"
call :INSTALL_SOFTWARE "notepadplusplus" "Notepad++"
call :INSTALL_SOFTWARE "googlechrome" "Google Chrome"

echo.
echo ====================================
echo 快速安装完成!
echo ====================================
pause
goto MENU

:CUSTOM_INSTALL
echo.
echo ====================================
echo 自定义选择安装
echo ====================================
echo.
echo === 浏览器 ===
echo [1] Google Chrome
echo [2] Firefox
echo.
echo === 实用工具 ===
echo [3] 7-Zip (压缩)
echo.
echo [0] 返回主菜单
echo.
set /p software=请输入要安装的软件编号(用空格分隔多个,如: 1 2 3): 

if "%software%"=="0" goto MENU

echo.
echo 开始安装选中的软件...
echo.

for %%s in (%software%) do (
    if "%%s"=="1" call :INSTALL_SOFTWARE "googlechrome" "Chrome"
    if "%%s"=="2" call :INSTALL_SOFTWARE "firefox" "Firefox"
    if "%%s"=="3" call :INSTALL_SOFTWARE "7zip" "7-Zip"
)

echo.
echo ====================================
echo 自定义安装完成!
echo ====================================
pause
goto MENU

:LIST_SOFTWARE
echo.
echo ====================================
echo 软件列表
echo ====================================
echo.
echo 浏览器:
echo   - Google Chrome
echo   - Firefox
echo.
echo 实用工具:
echo   - 7-Zip (免费压缩)
echo.
echo ================================
echo 提示: 
echo - 使用 'scoop search 软件名' 搜索更多软件
echo - 使用 'scoop install 软件名' 直接安装
echo - 可自行编辑脚本添加更多软件选项
echo ================================
echo.
pause
goto MENU

:UPDATE_SCOOP
echo.
echo ====================================
echo 更新 Scoop
echo ====================================
echo.
echo 正在更新 Scoop 本身...
powershell -Command "scoop update"
echo.
echo 正在检查已安装软件的更新...
powershell -Command "scoop status"
echo.
set /p update_all=是否更新所有软件? (Y/N): 
if /i "%update_all%"=="Y" (
    echo.
    echo 正在更新所有软件...
    powershell -Command "scoop update *"
    echo.
    echo 更新完成!
) else (
    echo 已跳过软件更新
)
echo.
pause
goto MENU

:SCOOP_INFO
echo.
echo ====================================
echo Scoop 安装信息
echo ====================================
echo.
powershell -Command "Write-Host 'Scoop 版本: ' -NoNewline; scoop --version"
echo.
powershell -Command "Write-Host 'Scoop 安装路径: ' -NoNewline -ForegroundColor Cyan; Write-Host $env:SCOOP"
powershell -Command "Write-Host 'Scoop 全局路径: ' -NoNewline -ForegroundColor Cyan; Write-Host $env:SCOOP_GLOBAL"
echo.
powershell -Command "Write-Host 'Scoop 实际路径: ' -NoNewline -ForegroundColor Cyan; scoop prefix scoop"
echo.
echo 已安装的软件数量:
powershell -Command "(scoop list).Count - 1" 2>nul || echo 0
echo.
echo 已添加的 Bucket:
powershell -Command "scoop bucket list"
echo.
echo 配置信息:
powershell -Command "scoop config"
echo.
echo 磁盘占用:
powershell -Command "$scoopPath = scoop prefix scoop; if (Test-Path $scoopPath) { $size = (Get-ChildItem $scoopPath -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB; Write-Host ('总占用: {0:N2} GB' -f $size) }"
echo.
pause
goto MENU

:INSTALL_SOFTWARE
set "package_name=%~1"
set "display_name=%~2"
echo.
echo [%time%] 正在安装 %display_name%...
powershell -Command "scoop install %package_name%"
if %errorlevel% equ 0 (
    echo [成功] %display_name% 安装完成
) else (
    echo [失败] %display_name% 安装失败 (错误代码: %errorlevel%^)
    echo 提示: 某些软件可能需要先添加对应的 bucket
)
goto :EOF

:END
echo.
echo 感谢使用，再见！
echo.
echo 提示: 
echo - 使用 'scoop list' 查看已安装软件
echo - 使用 'scoop update *' 更新所有软件
echo - 使用 'scoop uninstall 软件名' 卸载软件
echo - 使用 'scoop search 关键词' 搜索软件
echo.
timeout /t 5 /nobreak
exit