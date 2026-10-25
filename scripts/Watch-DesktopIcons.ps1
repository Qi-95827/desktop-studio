$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Common.ps1')
$mutex=[Threading.Mutex]::new($false,'Local\DesktopStudioIconGuard')
if(-not $mutex.WaitOne(0)){exit}
$weather=[DateTime]::MinValue;$hidden=$false
try{
 while(Get-Process seelen-ui -ErrorAction SilentlyContinue){
  if($StudioConfig.HideDesktopIcons -and -not $hidden){& (Join-Path $PSScriptRoot 'Desktop-IconVisibility.ps1') -Mode Hide|Out-Null;$hidden=$true}
  Start-Sleep -Seconds 2
 }
}finally{if($hidden){& (Join-Path $PSScriptRoot 'Desktop-IconVisibility.ps1') -Mode Show|Out-Null};$mutex.ReleaseMutex();$mutex.Dispose()}
