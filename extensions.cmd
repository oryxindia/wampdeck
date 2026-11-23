@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\extensions.ps1" %*
if errorlevel 1 pause
