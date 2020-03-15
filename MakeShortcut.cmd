@ECHO OFF
SETLOCAL

:: -new_console:z - overrides cmder/conemu as default shell so that windowstyle hidden works

set shortcutfilename=PoSh Hot Corners
nircmd shortcut PowerShell.exe "%~dp0" "%shortcutfilename%" "-ExecutionPolicy Bypass -WindowStyle Hidden -File PoShHotCorners.ps1" "%~dp0icon.ico" "" "" "%~dp0"


if %errorlevel% neq 0 (
  pause
  exit /b 1
)

echo.
echo.
echo *******************************************************
set install=Y
set /p install="copy shortcut to your auto startup folder [Y/n]: "
IF %install% equ Y (
  copy "%~dp0%shortcutfilename%.lnk" "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup"
  start "" "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup"
)
