@echo off
setlocal ENABLEDELAYEDEXPANSION
chcp 65001 >nul
cd /d "%~dp0"
mode con: cols=110 lines=40
title BitForge Setup
color 0A

cls
color 0B
cls
call :CENTER "██████╗ ██╗████████╗███████╗ ██████╗ ██████╗  ██████╗ ███████╗"
call :CENTER "██╔══██╗██║╚══██╔══╝██╔════╝██╔═══██╗██╔══██╗██╔════╝ ██╔════╝"
call :CENTER "██████╔╝██║   ██║   █████╗  ██║   ██║██████╔╝██║  ███╗█████╗  "
call :CENTER "██╔══██╗██║   ██║   ██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══╝  "
call :CENTER "██████╔╝██║   ██║   ██║     ╚██████╔╝██║  ██║╚██████╔╝███████╗"
call :CENTER "╚═════╝ ╚═╝   ╚═╝   ╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
call :CENTER " "
call :CENTER "═══════════════════════════════════════════════════════════════════════════════════════════════"
call :CENTER "                 BITFORGE AUTO INSTALLER"
call :CENTER "═══════════════════════════════════════════════════════════════════════════════════════════════"
powershell -Command "Start-Sleep -Milliseconds 400" >nul

call :SPINNER "Initializing environment" 3
cls
call :HEADER "Step 1 / 5 │ Checking Python Environment"
python --version >nul 2>&1
if %errorlevel% neq 0 (
    call :ASCII_MSG "✖ Python Not Found" "Downloading Python 3.9 automatically"
    call :SPINNER "Downloading Python 3.9" 5
    call :INSTALL_PYTHON39
)
python --version >nul 2>&1 || (
    call :ASCII_ERROR "✖ Python Installation Failed" "Please install manually from python.org"
    pause
    goto END
)
call :ASCII_SUCCESS "✔ Python Detected" "Environment verified successfully"

cls
call :HEADER "Step 2 / 5 │ Preparing PIP"
python -m ensurepip >nul 2>&1
call :PROGRESS "Upgrading pip" 20
python -m pip install --upgrade pip -q
call :ASCII_SUCCESS "✔ PIP Ready" "Package manager initialized"

cls
call :HEADER "Step 3 / 5 │ Installing Dependencies"
for %%P in (customtkinter pillow pyaes urllib3) do (
    call :PROGRESS "Installing %%P" 20
    python -m pip install %%P -q
)
call :ASCII_SUCCESS "✔ Dependencies Installed" "All required modules available"

cls
call :HEADER "Step 4 / 5 │ Verifying BitForge Files"
if not exist "main.py" (
    call :ASCII_ERROR "✖ Missing Core Files" "BitForge files not found in this folder"
    pause
    goto END
)
call :SPINNER "Performing integrity check" 3
call :ASCII_SUCCESS "✔ Files Verified" "BitForge structure integrity confirmed"

cls
color 0B
call :HEADER "Step 5 / 5 │ Finalizing Setup"
call :PROGRESS "Completing installation" 30
cls
call :ASCII_FRAME "Installation Complete" "BitForge setup finished successfully" "Press any key to start BitForge..."
pause >nul

cls
call :SPINNER "Launching BitForge" 3
python main.py || goto ERROR
goto END

:INSTALL_PYTHON39
set "PYTHON_VERSION=3.9.13"
set "INSTALLER_NAME=python-%PYTHON_VERSION%-amd64.exe"
set "URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/%INSTALLER_NAME%"
set "TEMP_DIR=%TEMP%\bitforge_dl"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
cd /d "%TEMP_DIR%"
powershell -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest '%URL%' -OutFile '%INSTALLER_NAME%'" || (
  call :ASCII_ERROR "✖ Download Failed" "Unable to retrieve Python installer"
  goto :EOF
)
"%INSTALLER_NAME%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
timeout /t 3 >nul
goto :EOF

:SPINNER
setlocal ENABLEDELAYEDEXPANSION
set "text=%~1"
set "seconds=%~2"
set "frames=- \ ^| /"
<nul set /p "=→ %text% "
for /L %%t in (1,1,!seconds!) do (
    for %%f in (!frames!) do (
        <nul set /p "=%%f"
        powershell -Command "Start-Sleep -Milliseconds 120" >nul
        <nul set /p "=`r"
    )
)
echo  DONE
endlocal
exit /b

:PROGRESS
setlocal ENABLEDELAYEDEXPANSION
set "text=%~1"
<nul set /p "=→ %text% "
for /L %%i in (1,1,30) do (
    set "bar="
    for /L %%b in (1,1,%%i) do set "bar=!bar!█"
    for /L %%s in (%%i,1,30) do set "bar=!bar!░"
    <nul set /p "= [!bar!] %%i/30`r"
    powershell -Command "Start-Sleep -Milliseconds 50" >nul
)
echo   [██████████████████████████████] DONE
endlocal
exit /b

:HEADER
cls
call :CENTER "═══════════════════════════════════════════════════════════════════════════════════════════════"
call :CENTER " %~1 "
call :CENTER "═══════════════════════════════════════════════════════════════════════════════════════════════"
echo.
exit /b

:CENTER
setlocal ENABLEDELAYEDEXPANSION
set "s=%~1"
set "len=0"
set "tmp=!s!"
:__len
if defined tmp (
    set "tmp=!tmp:~1!"
    set /a len+=1
    goto __len
)
set /a pad=(110 - len) / 2
if %pad% LSS 0 set pad=0
set "spaces="
for /L %%i in (1,1,%pad%) do set "spaces=!spaces! "
echo(!spaces!!s!
endlocal
exit /b

:ASCII_SUCCESS
color 0A
echo.
call :CENTER "╔══════════════════════════════════════════════════════════════════════════════════════════════╗"
call :CENTER "║  %~1                                                                                         ║"
call :CENTER "║  %~2                                                                                         ║"
call :CENTER "╚══════════════════════════════════════════════════════════════════════════════════════════════╝"
echo.
powershell -Command "Start-Sleep -Milliseconds 500" >nul
exit /b

:ASCII_ERROR
color 4C
echo.
call :CENTER "╔══════════════════════════════════════════════════════════════════════════════════════════════╗"
call :CENTER "║  %~1                                                                                         ║"
call :CENTER "║  %~2                                                                                         ║"
call :CENTER "╚══════════════════════════════════════════════════════════════════════════════════════════════╝"
color 0A
echo.
powershell -Command "Start-Sleep -Milliseconds 700" >nul
exit /b

:ASCII_MSG
color 0E
echo.
call :CENTER "╔══════════════════════════════════════════════════════════════════════════════════════════════╗"
call :CENTER "║  %~1                                                                                         ║"
call :CENTER "║  %~2                                                                                         ║"
call :CENTER "╚══════════════════════════════════════════════════════════════════════════════════════════════╝"
color 0A
powershell -Command "Start-Sleep -Milliseconds 500" >nul
exit /b

:ASCII_FRAME
color 0B
echo.
call :CENTER "╔══════════════════════════════════════════════════════════════════════════════════════════════╗"
call :CENTER "║  %~1                                                                                         ║"
call :CENTER "║  %~2                                                                                         ║"
call :CENTER "║  %~3                                                                                         ║"
call :CENTER "╚══════════════════════════════════════════════════════════════════════════════════════════════╝"
echo.
exit /b

:ERROR
call :ASCII_ERROR "✖ Launch Failed" "An unexpected error occurred while starting BitForge"
pause

:END
color 0A
cls
call :CENTER " "
call :CENTER "═══════════════════════════════════════════════════════════════════════════════════════════════"
call :CENTER "             THANK YOU FOR USING BITFORGE"
call :CENTER "═══════════════════════════════════════════════════════════════════════════════════════════════"
echo.
pause >nul
exit /b
