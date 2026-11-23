@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0acceptance-test.ps1" %*
exit /b %ERRORLEVEL%