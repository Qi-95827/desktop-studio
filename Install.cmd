@echo off
setlocal
powershell.exe -NoProfile -File "%~dp0scripts\Install.ps1"
if errorlevel 1 pause
