@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Install-Prototype.ps1"
set "result=%errorlevel%"
pause
exit /b %result%
