@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\db.ps1" %*
if "%~1"=="" pause
