@ECHO OFF
SETLOCAL

::**** xxmklink args in order left to right
::path of the shortcut (.lnk added as needed)
::path of the object represented by the shortcut
::argument string (use quotes with space, see below)
::path of the working directory (for "Start in")
::description string (shown in Shosrtcut's Properties)
::display mode (1:Normal [default], 3:Maximized, 7:Minimized)
::icon file [with optional icon index value n]

:: -new_console:z - overrides cmder/conemu as default shell so that windowstyle hidden works

"%~dp0xxmklink" "%~dp0PoShHotCorners.lnk" PowerShell.exe "-new_console:z -ExecutionPolicy Bypass -WindowStyle Hidden -File ^"%~dp0PoShHotCorners.ps1^"" "" "Windows PowerShell Hot Corners" 7 "%~dp0Icon.ico"

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
  copy "%~dp0PoShHotCorners.lnk" "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup"
  start "" "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup"
)
