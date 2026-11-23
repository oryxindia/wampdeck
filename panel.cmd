@echo off
if exist "%~dp0WampDeck.exe" (
    start "" "%~dp0WampDeck.exe" %*
) else (
    start "" powershell -Sta -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0panel.ps1" %*
)
