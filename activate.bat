@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Windows KMS Client Setup

if /i "%~1"=="--help" goto USAGE
if /i "%~1"=="/?" goto USAGE
if /i "%~1"=="--self-test" goto SELF_TEST

set "KMS_SERVER=%~1"
if not defined KMS_SERVER (
    echo ERROR: KMS server address was not provided.
    echo.
    call :PRINT_USAGE
    exit /b 1
)

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo ERROR: Windows PowerShell is required for input and network validation.
    exit /b 1
)

call :VALIDATE_KMS_SERVER
if errorlevel 1 (
    echo ERROR: Invalid KMS server address: "%KMS_SERVER%"
    echo Use a DNS name or IPv4 address, optionally followed by a port.
    echo Example: kms.example.com:1688
    exit /b 1
)

fltmc >nul 2>&1
if errorlevel 1 (
    echo ERROR: Administrator privileges are required.
    echo Open Command Prompt as administrator and run this script again.
    exit /b 1
)

call :DETECT_EDITION
if errorlevel 1 exit /b 1

cls
echo ============================================
echo  Windows KMS Client Setup
echo ============================================
echo.
echo  Windows:   %PRODUCT_NAME%
echo  Edition:   %EDITION_ID%
echo  Build:     %CURRENT_BUILD%
echo  KMS host:  %KMS_SERVER%
echo.
echo This tool is for properly licensed volume-activation environments.
echo The KMS host must be operated or approved by your organization.
echo.
choice /c YN /n /m "Continue with this KMS host? [Y/N]: "
if errorlevel 2 (
    echo Operation cancelled.
    exit /b 0
)

echo.
echo Checking TCP connectivity to the KMS host...
call :TEST_KMS_CONNECTION
if errorlevel 1 (
    echo ERROR: Unable to connect to "%KMS_SERVER%".
    echo No licensing settings were changed.
    exit /b 1
)
echo KMS host is reachable.

set "INSTALL_KEY=0"
call :CHECK_KMS_CLIENT_KEY
set "KEY_CHECK_RESULT=%ERRORLEVEL%"
if not "%KEY_CHECK_RESULT%"=="0" (
    echo.
    if "%KEY_CHECK_RESULT%"=="2" (
        echo WARNING: Unable to determine the current product-key channel.
    ) else (
        echo The currently installed key is not a KMS client key.
    )
    echo.
    echo The detected edition is: %VNAME%
    echo Installing its Microsoft-published KMS client key will replace the
    echo product key currently configured on this computer.
    echo.
    choice /c YN /n /m "Install the matching KMS client key? [Y/N]: "
    if errorlevel 2 (
        echo Operation cancelled. No licensing settings were changed.
        exit /b 0
    )
    set "INSTALL_KEY=1"
) else (
    echo The currently installed product key is already a KMS client key.
)

call :CONFIGURE_AND_ACTIVATE
set "ACTIVATION_RESULT=%ERRORLEVEL%"
echo.
if "%ACTIVATION_RESULT%"=="0" (
    echo ============================================
    echo  Activation request completed successfully
    echo ============================================
) else (
    echo ============================================
    echo  Activation was not completed
    echo ============================================
)
exit /b %ACTIVATION_RESULT%

:VALIDATE_KMS_SERVER
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "$value=$env:KMS_SERVER; if ([string]::IsNullOrWhiteSpace($value) -or $value.Length -gt 259 -or $value -notmatch '^[A-Za-z0-9.-]+(?::[0-9]{1,5})?$') { exit 1 }; $parts=$value -split ':',2; $hostName=$parts[0]; if ($hostName.Length -gt 253 -or $hostName.StartsWith('.') -or $hostName.EndsWith('.') -or $hostName.Contains('..')) { exit 1 }; foreach ($label in $hostName.Split('.')) { if ($label.Length -lt 1 -or $label.Length -gt 63 -or $label -notmatch '^[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?$') { exit 1 } }; if ($parts.Count -eq 2) { $port=0; if (-not ([int]::TryParse($parts[1],[ref]$port)) -or $port -lt 1 -or $port -gt 65535) { exit 1 } }; exit 0" >nul 2>&1
exit /b %ERRORLEVEL%

:TEST_KMS_CONNECTION
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "$parts=$env:KMS_SERVER -split ':',2; $hostName=$parts[0]; $port=1688; if ($parts.Count -eq 2) { $port=[int]$parts[1] }; try { if (Test-NetConnection -ComputerName $hostName -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue) { exit 0 } } catch {}; exit 1" >nul 2>&1
exit /b %ERRORLEVEL%

:CHECK_KMS_CLIENT_KEY
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "try { $products=Get-CimInstance -ClassName SoftwareLicensingProduct -ErrorAction Stop | Where-Object { $_.ApplicationID -eq '55c92734-d682-4d71-983e-d6ec3f16059f' -and $_.PartialProductKey }; if (@($products | Where-Object { $_.Description -match 'VOLUME_KMSCLIENT' }).Count -gt 0) { exit 0 }; exit 1 } catch { exit 2 }" >nul 2>&1
exit /b %ERRORLEVEL%

:DETECT_EDITION
set "EDITION_ID="
set "PRODUCT_NAME="
set "CURRENT_BUILD="
set "KEY="
set "VNAME="

for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID 2^>nul ^| find /i "EditionID"') do set "EDITION_ID=%%B"
for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul ^| find /i "ProductName"') do set "PRODUCT_NAME=%%B"
for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber 2^>nul ^| find /i "CurrentBuildNumber"') do set "CURRENT_BUILD=%%B"

if not defined EDITION_ID (
    echo ERROR: Unable to detect the installed Windows edition.
    exit /b 1
)
if not defined PRODUCT_NAME set "PRODUCT_NAME=Windows"
if not defined CURRENT_BUILD set "CURRENT_BUILD=Unknown"

call :MAP_EDITION
exit /b %ERRORLEVEL%

:MAP_EDITION
set "KEY="
set "VNAME="

if /i "%EDITION_ID%"=="Professional" (
    set "KEY=W269N-WFGWX-YVC9B-4J6C9-T83GX"
    set "VNAME=Windows Pro"
    exit /b 0
)
if /i "%EDITION_ID%"=="EnterpriseS" (
    set "KEY=M7XTQ-FN8P6-TTKYV-9D4CC-J462D"
    set "VNAME=Windows Enterprise LTSC"
    exit /b 0
)
if /i "%EDITION_ID%"=="ServerDatacenter" goto MAP_SERVER_DATACENTER
if /i "%EDITION_ID%"=="ServerDatacenterCor" goto MAP_SERVER_DATACENTER

if /i "%EDITION_ID%"=="ServerDatacenterEval" (
    echo ERROR: Evaluation editions must be converted before KMS activation.
    echo Current edition: %EDITION_ID%
    exit /b 1
)
if /i "%EDITION_ID%"=="ServerDatacenterEvalCor" (
    echo ERROR: Evaluation editions must be converted before KMS activation.
    echo Current edition: %EDITION_ID%
    exit /b 1
)

echo ERROR: This script does not have a KMS client key mapping for:
echo        %PRODUCT_NAME% [%EDITION_ID%]
echo No licensing settings were changed.
exit /b 1

:MAP_SERVER_DATACENTER
if "%CURRENT_BUILD%"=="Unknown" (
    echo ERROR: Unable to identify the Windows Server version.
    exit /b 1
)
for /f "delims=0123456789" %%A in ("%CURRENT_BUILD%") do (
    echo ERROR: Unexpected Windows build number: %CURRENT_BUILD%
    exit /b 1
)
if %CURRENT_BUILD% GEQ 26000 (
    set "KEY=D764K-2NDRG-47T6Q-P8T8W-YP6DF"
    set "VNAME=Windows Server 2025 Datacenter"
    exit /b 0
)
if %CURRENT_BUILD% GEQ 20348 (
    set "KEY=WX4NM-KYWYW-QJJR4-XV3QB-6VM33"
    set "VNAME=Windows Server 2022 Datacenter"
    exit /b 0
)

echo ERROR: Unsupported Windows Server Datacenter build: %CURRENT_BUILD%
exit /b 1

:CONFIGURE_AND_ACTIVATE
if "%INSTALL_KEY%"=="1" (
    echo.
    echo Installing the matching KMS client key...
    cscript.exe //nologo "%SystemRoot%\System32\slmgr.vbs" /ipk "%KEY%"
    if errorlevel 1 (
        echo ERROR: Failed to install the KMS client key.
        exit /b 1
    )
)

echo.
echo [1/2] Configuring the KMS host...
cscript.exe //nologo "%SystemRoot%\System32\slmgr.vbs" /skms "%KMS_SERVER%"
if errorlevel 1 (
    echo ERROR: Failed to configure the KMS host.
    exit /b 1
)

echo.
echo [2/2] Requesting activation...
cscript.exe //nologo "%SystemRoot%\System32\slmgr.vbs" /ato
if errorlevel 1 (
    echo ERROR: Activation failed.
    echo Review the licensing status and confirm that the KMS host is
    echo authorized for this Windows edition.
    echo The selected KMS host remains configured on this computer.
    exit /b 1
)

call :SHOW_STATUS
exit /b 0

:SHOW_STATUS
echo.
echo Current activation status:
cscript.exe //nologo "%SystemRoot%\System32\slmgr.vbs" /xpr
exit /b 0

:USAGE
call :PRINT_USAGE
exit /b 0

:PRINT_USAGE
echo Usage:
echo   activate.bat ^<kms-host^>
echo   activate.bat ^<kms-host:port^>
echo.
echo Examples:
echo   activate.bat kms.example.com
echo   activate.bat 192.0.2.10:1688
echo.
echo Supported editions:
echo   Windows 10/11 Pro
echo   Windows Enterprise LTSC
echo   Windows Server 2022/2025 Datacenter
exit /b 0

:SELF_TEST
where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo SELF-TEST FAILED: Windows PowerShell was not found.
    exit /b 1
)

set "SELF_TEST_FAILED=0"
call :ASSERT_VALID_KMS "kms.example.com"
call :ASSERT_VALID_KMS "192.0.2.10:1688"
call :ASSERT_VALID_KMS "kms-01.example.com:65535"
call :ASSERT_INVALID_KMS "bad host"
call :ASSERT_INVALID_KMS "host:0"
call :ASSERT_INVALID_KMS "host:65536"
call :ASSERT_INVALID_KMS "-host.example.com"
call :ASSERT_INVALID_KMS "host&whoami"

call :CHECK_KMS_CLIENT_KEY
if errorlevel 3 (
    echo SELF-TEST FAILED: Product-key channel check returned an invalid code.
    set "SELF_TEST_FAILED=1"
)

set "EDITION_ID=Professional"
set "CURRENT_BUILD=26100"
set "PRODUCT_NAME=Windows Pro"
call :MAP_EDITION
if errorlevel 1 (
    echo SELF-TEST FAILED: Professional edition mapping was rejected.
    set "SELF_TEST_FAILED=1"
) else if not "%KEY%"=="W269N-WFGWX-YVC9B-4J6C9-T83GX" (
    echo SELF-TEST FAILED: Professional edition mapped to the wrong key.
    set "SELF_TEST_FAILED=1"
)

set "EDITION_ID=ServerDatacenter"
set "CURRENT_BUILD=20348"
set "PRODUCT_NAME=Windows Server 2022 Datacenter"
call :MAP_EDITION
if errorlevel 1 (
    echo SELF-TEST FAILED: Server 2022 mapping was rejected.
    set "SELF_TEST_FAILED=1"
) else if not "%KEY%"=="WX4NM-KYWYW-QJJR4-XV3QB-6VM33" (
    echo SELF-TEST FAILED: Server 2022 mapped to the wrong key.
    set "SELF_TEST_FAILED=1"
)

set "EDITION_ID=ServerDatacenter"
set "CURRENT_BUILD=26100"
set "PRODUCT_NAME=Windows Server 2025 Datacenter"
call :MAP_EDITION
if errorlevel 1 (
    echo SELF-TEST FAILED: Server 2025 mapping was rejected.
    set "SELF_TEST_FAILED=1"
) else if not "%KEY%"=="D764K-2NDRG-47T6Q-P8T8W-YP6DF" (
    echo SELF-TEST FAILED: Server 2025 mapped to the wrong key.
    set "SELF_TEST_FAILED=1"
)

if "%SELF_TEST_FAILED%"=="0" (
    echo All activate.bat self-tests passed.
    exit /b 0
)
exit /b 1

:ASSERT_VALID_KMS
set "KMS_SERVER=%~1"
call :VALIDATE_KMS_SERVER
if errorlevel 1 (
    echo SELF-TEST FAILED: Expected valid KMS address: "%KMS_SERVER%"
    set "SELF_TEST_FAILED=1"
)
exit /b 0

:ASSERT_INVALID_KMS
set "KMS_SERVER=%~1"
call :VALIDATE_KMS_SERVER
if not errorlevel 1 (
    echo SELF-TEST FAILED: Expected invalid KMS address: "%KMS_SERVER%"
    set "SELF_TEST_FAILED=1"
)
exit /b 0
