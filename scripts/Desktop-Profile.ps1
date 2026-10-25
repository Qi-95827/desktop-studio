param([ValidateSet('Apply','Restore','WidgetsOn','WidgetsOff','ResetLayout','Backup','SyncShortcuts')] [string]$Action='Apply')
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Common.ps1')
$mode=Join-Path $StudioRoot 'Data\desktop-mode.txt'
New-Item -ItemType Directory -Path (Split-Path $mode) -Force|Out-Null
function Widgets-On {
 if(-not(Test-Path -LiteralPath $RainmeterExe)){throw 'Run Install.cmd before starting widgets.'}
 $running=Get-Process Rainmeter -ErrorAction SilentlyContinue
 if($running -and @($running|Where-Object {$_.Path -ne $RainmeterExe}).Count){throw 'Another Rainmeter installation is already running. Exit it before using this package.'}
 & (Join-Path $PSScriptRoot 'Start-HdpiRainmeter.ps1') -RainmeterExe $RainmeterExe
 Start-StudioWorker 'NetEase-Media.ps1'
 & (Join-Path $PSScriptRoot 'Start-Lyrics.ps1')
}
switch($Action){
 'Apply'{
  if(-not(Test-Path -LiteralPath $SeelenExe)){throw 'Run Install.cmd, or set SeelenExe in config.json.'}
  if(-not(Get-Process seelen-ui -ErrorAction SilentlyContinue)){
   Start-ScheduledTask -TaskPath '\Seelen\' -TaskName 'Seelen UI Service' -ErrorAction SilentlyContinue
   Start-Process -FilePath $SeelenExe -WindowStyle Hidden
   Start-Sleep -Milliseconds 700
  }
  Widgets-On
  [IO.File]::WriteAllText($mode,'apple')
  Start-StudioWorker 'Watch-DesktopIcons.ps1'
  if($StudioConfig.RestoreWallpaperEngine -and $StudioConfig.WallpaperEngineExe -and (Test-Path -LiteralPath $StudioConfig.WallpaperEngineExe) -and -not(Get-Process wallpaper64 -ErrorAction SilentlyContinue)){Start-Process -FilePath $StudioConfig.WallpaperEngineExe -ArgumentList '-silent' -WindowStyle Hidden}
  New-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name DesktopStudio -PropertyType String -Value ('"'+(Join-Path $StudioRoot 'bin\DesktopStudio.exe')+'" --startup') -Force|Out-Null
 }
 'Restore'{
  [IO.File]::WriteAllText($mode,'windows')
  $service=Join-Path (Split-Path $SeelenExe) 'slu-service.exe'
  if(Test-Path -LiteralPath $service){& $service stop}
  Stop-Process -Name seelen-ui -ErrorAction SilentlyContinue
  if(Get-Process Rainmeter -ErrorAction SilentlyContinue){Invoke-RainBang '!Quit'}
  Get-CimInstance Win32_Process|Where-Object {$_.Name -eq 'powershell.exe' -and $_.CommandLine -like ('*'+(Join-Path $PSScriptRoot 'Watch-DesktopIcons.ps1')+'*')}|ForEach-Object {Stop-Process -Id $_.ProcessId -ErrorAction SilentlyContinue}
  & (Join-Path $PSScriptRoot 'Desktop-IconVisibility.ps1') -Mode Show|Out-Null
  Add-Type 'using System;using System.Runtime.InteropServices;public static class StudioTaskbar{[DllImport("user32.dll",CharSet=CharSet.Unicode)]public static extern IntPtr FindWindow(string c,string t);[DllImport("user32.dll")]public static extern bool ShowWindow(IntPtr h,int c);}'
  foreach($class in @('Shell_TrayWnd','Shell_SecondaryTrayWnd')){$h=[StudioTaskbar]::FindWindow($class,$null);if($h -ne [IntPtr]::Zero){[StudioTaskbar]::ShowWindow($h,5)|Out-Null}}
 }
 'WidgetsOn'{Widgets-On}
 'WidgetsOff'{if(Get-Process Rainmeter -ErrorAction SilentlyContinue){Invoke-RainBang '!Quit'}}
 'ResetLayout'{
  Widgets-On
  foreach($spec in @(@('Weather','Medium.ini',150,240),@('Calendar','Medium.ini',480,240),@('Music','Wide.ini',150,570))){$config='Monterey\Widgets\'+$spec[0];Invoke-RainBang ('!ActivateConfig "'+$config+'" "'+$spec[1]+'"');Start-Sleep -Milliseconds 150;Invoke-RainBang ('!Move '+$spec[2]+' '+$spec[3]+' "'+$config+'"')}
 }
 'SyncShortcuts'{& (Join-Path $PSScriptRoot 'Sync-Shortcuts.ps1')}
 'Backup'{
  $folder=Join-Path $StudioRoot ('Backups\Profile-'+(Get-Date -Format yyyyMMdd-HHmmss));New-Item -ItemType Directory -Path $folder -Force|Out-Null
  New-Item -ItemType Directory -Path (Join-Path $folder 'SeelenUI') -Force|Out-Null
  if(Test-Path -LiteralPath $SeelenData){foreach($name in @('settings.json','data','themes','plugins','iconpacks')){$p=Join-Path $SeelenData $name;if(Test-Path -LiteralPath $p){Copy-Item -LiteralPath $p -Destination (Join-Path $folder 'SeelenUI') -Recurse -Force}}}
  foreach($name in @('Rainmeter.ini','Skins\Monterey\@Resources\Variables')){$p=Join-Path $RainmeterHome $name;if(Test-Path -LiteralPath $p){Copy-Item -LiteralPath $p -Destination $folder -Recurse -Force}}
  Copy-Item -LiteralPath $StudioConfigPath -Destination $folder -ErrorAction SilentlyContinue
  Compress-Archive -LiteralPath $folder -DestinationPath ($folder+'.zip');Write-Output ($folder+'.zip')
 }
}
