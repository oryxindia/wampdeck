@echo off
if "%~1"=="" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\start.ps1" -Open
  pause
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\start.ps1" %*
  if errorlevel 1 pause
)
