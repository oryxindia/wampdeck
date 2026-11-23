@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\status.ps1"
if "%~1"=="" pause
