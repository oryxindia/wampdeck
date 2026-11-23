@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\switch.ps1" %*
if errorlevel 1 pause
