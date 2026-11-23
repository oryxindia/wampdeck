@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\ssl.ps1" %*
if errorlevel 1 pause
