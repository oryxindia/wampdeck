@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\refresh.ps1" %*
if errorlevel 1 pause
