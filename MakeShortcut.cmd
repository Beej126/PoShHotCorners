@echo off
::**** xxmklink args in order left to right
::path of the shortcut (.lnk added as needed)
::path of the object represented by the shortcut
::argument string (use quotes with space, see below)
::path of the working directory (for "Start in")
::description string (shown in Shosrtcut's Properties)
::display mode (1:Normal [default], 3:Maximized, 7:Minimized)
::icon file [with optional icon index value n]

"%~dp0xxmklink" "%~dp0PoShHotCorners.lnk" PowerShell.exe "-WindowStyle Hidden %~dp0PoShHotCorners.ps1" "" "Windows PowerShell Hot Corners" 7 "%~dp0Icon.ico"

if %errorlevel% neq 0 pause