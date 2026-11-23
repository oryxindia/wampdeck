@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\hosts.ps1" %*
if errorlevel 1 pause
