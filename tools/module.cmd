@echo off
rem Uplift module tools for Windows. Double-click for a menu, or run:  tools\module.cmd <command> <module>
rem Uses Windows PowerShell, which is part of Windows. Nothing to install, no admin rights needed.
rem -ExecutionPolicy Bypass applies to this one run only and does not change any setting.
setlocal
if "%~1"=="" goto menu
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0module.ps1" %*
exit /b %errorlevel%

:menu
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0module.ps1" menu
set "rc=%errorlevel%"
echo.
pause
exit /b %rc%
