@echo off
set "NAME=%~1"
if "%NAME%"=="" set /p NAME=Project name (lowercase, dashes allowed): 
if "%NAME%"=="" exit /b 1
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\new.ps1" -Name "%NAME%" %2 %3 %4 %5 %6 %7 %8
if errorlevel 1 pause
