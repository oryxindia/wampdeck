@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\tools.ps1" -Cmder
if errorlevel 1 pause
