@echo off
title Malware Removal Tool
color 0A
Mode 100,30
setlocal EnableDelayedExpansion

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

:MainMenu
cls
echo.
echo ==========================
echo Malware Removal Tool
echo ==========================
echo.
echo Choose an option:
echo 1) On-demand Scanners
echo 2) Real-time Protection Antivirus
echo 3) Useful Software
echo 4) Exit
echo.
set /p choice="Enter your choice: "

if "%choice%"=="1" goto OnDemandScanners
if "%choice%"=="2" goto RealTimeProtection
if "%choice%"=="3" goto UsefulSoftware
if "%choice%"=="4" goto Exit
echo Invalid choice, please try again.
pause
goto MainMenu

:OnDemandScanners
cls
echo Select an On-demand Scanner to download:
echo 1) Kaspersky Virus Removal Tool
echo 2) HitmanPro
echo 3) Malwarebytes
echo 4) ESET Online Scanner
echo 5) AdwCleaner
echo b) Return to Main Menu
set /p av_choice="Enter your choice: "
if "%av_choice%"=="1" call :DownloadFile KRVT.exe https://devbuilds.s.kaspersky-labs.com/devbuilds/KVRT/latest/full/KVRT.exe
if "%av_choice%"=="2" call :DownloadFile HitmanPro_x64.exe https://download.sophos.com/endpoint/clients/HitmanPro_x64.exe
if "%av_choice%"=="3" call :DownloadFile MBSetup.exe https://www.malwarebytes.com/api/downloads/mb-windows?filename=MBSetup.exe
if "%av_choice%"=="4" call :DownloadFile esetonlinescanner.exe https://download.eset.com/com/eset/tools/online_scanner/latest/esetonlinescanner.exe
if "%av_choice%"=="5" call :DownloadFile adwcleaner.exe https://downloads.malwarebytes.com/file/adwcleaner
if "%av_choice%"=="b" goto OnDemandScanners
goto MainMenu

:RealTimeProtection
cls
echo Select a Real-time Protection Antivirus to download:
echo 1) Kaspersky Free Antivirus
echo 2) Bitdefender Antivirus Free Edition
echo b) Return to Main Menu
set /p av_choice="Enter your choice: "
if "%av_choice%"=="1" call :DownloadFile kaspersky-free.exe https://pdc3.trt.pdc.kaspersky.com/DownloadManagers/c6/c6205467-e7fe-47ea-b6dd-c1a5465bdcac/startup.exe
if "%av_choice%"=="2" call :DownloadFile bitdefender_avfree.exe https://download.bitdefender.com/windows/installer/en-us/bitdefender_avfree.exe
if "%av_choice%"=="b" goto RealTimeProtection
goto MainMenu

:UsefulSoftware
cls
if exist "C:\ProgramData\chocolatey\bin\choco.exe" (
    echo Chocolatey is already installed.
    goto SoftwareOptions
) else (
    echo Chocolatey is not installed, which is required for this section.
    echo Would you like to install Chocolatey now? (y/n)
    set /p choco_install=
    if /i "%choco_install%"=="y" (
        echo Installing Chocolatey...
        powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
        echo Chocolatey installation completed.
    ) else (
        echo Chocolatey installation skipped. Returning to main menu.
        goto MainMenu
    )
)

:SoftwareOptions
cls
echo Select a Useful Software to install:
echo 1) Rufus Portable
echo 2) Ventoy
echo 3) VSCode
echo 4) 7-Zip
echo 5) VLC
echo 6) Firefox
echo b) Return to Main Menu
set /p sw_choice="Enter your choice: "
if "%sw_choice%"=="1" (
    echo Installing Rufus Portable...
    choco install rufus.portable -y
    echo Rufus Portable installation completed.
    pause
)
if "%sw_choice%"=="2" (
    echo Installing Ventoy...
    choco install ventoy -y
    echo Ventoy installation completed.
    pause
)
if "%sw_choice%"=="3" (
    echo Installing VSCode...
    choco install vscode -y
    echo VSCode installation completed.
    pause
)
if "%sw_choice%"=="4" (
    echo Installing 7-Zip...
    choco install 7zip -y
    echo 7-Zip installation completed.
    pause
)
if "%sw_choice%"=="5" (
    echo Installing VLC...
    choco install vlc -y
    echo VLC installation completed.
    pause
)
if "%sw_choice%"=="6" (
    echo Installing Firefox...
    choco install firefox -y
    echo Firefox installation completed.
    pause
)
if "%sw_choice%"=="b" goto MainMenu
goto SoftwareOptions


:ConfirmDownload
echo You have chosen to download %filename%
call :DownloadFile %filename% %url%
goto MainMenu

:DownloadFile
if not exist ".\files\" (
    mkdir ".\files" >nul 2>&1
    if %errorlevel% neq 0 (
        echo Failed to create directory .\files. Please check permissions.
        pause
        goto MainMenu
    )
)
echo Downloading %1...
curl -# -o ".\files\%1" %2

if %errorlevel% equ 0 (
    echo Download complete. File %1 is ready to install.
    echo Would you like to install it now? (y/n)
    set /p install_confirm=
    if /i "%install_confirm%"=="y" (
        echo Starting installation...
        start "" ".\files\%1"
        pause
        goto MainMenu
    ) else (
        echo Installation skipped. You can manually install the file later from the .\files folder.
        pause
        goto MainMenu
    )
) else (
    echo Download failed. Please check your internet connection, firewall, or file permissions and try again.
    pause
    goto MainMenu
)

goto MainMenu

:Exit
exit
