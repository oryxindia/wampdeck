@echo off
setlocal
set "WAMPDECK_CLI_ARGS=%*"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\cli.ps1"
exit /b %ERRORLEVEL%
