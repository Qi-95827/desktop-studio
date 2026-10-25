@echo off
setlocal
if not exist "%~dp0bin\DesktopStudio.exe" (
  powershell.exe -NoProfile -File "%~dp0scripts\Build.ps1"
  if errorlevel 1 (pause & exit /b 1)
)
start "" "%~dp0bin\DesktopStudio.exe"
