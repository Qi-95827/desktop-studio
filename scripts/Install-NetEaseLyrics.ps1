param([switch]$Plan,[switch]$WriteLoader)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Common.ps1')
$client=$StudioConfig.NetEaseExe
if(-not $client -or -not(Test-Path -LiteralPath $client)){throw 'Set NetEaseExe in config.json first.'}
$clientHome=Split-Path $client
$target=Join-Path $clientHome 'msimg32.dll'
$profile=Join-Path $StudioRoot 'Data\BetterNCM'
$downloads=Join-Path $StudioRoot 'downloads'
$deps=Get-Content -LiteralPath (Join-Path $StudioRoot 'lyrics-dependencies.lock.json') -Raw -Encoding UTF8|ConvertFrom-Json
$loader=Join-Path $downloads ($deps|Where-Object id -eq betterncm).file
$plugin=Join-Path $downloads ($deps|Where-Object id -eq inflink-rs).file
if($Plan){Write-Output ('Optional: download verified BetterNCM 1.3.4 and InfLink-rs 3.4.0; add '+$target+'; store plugins in '+$profile+'. No desktop or client changes in Plan mode.');exit}
if($WriteLoader){
 $expected=($deps|Where-Object id -eq betterncm).sha256
 if((Get-FileHash -LiteralPath $loader).Hash.ToLowerInvariant() -ne $expected){throw 'Loader checksum mismatch.'}
 if(Test-Path -LiteralPath $target){if((Get-FileHash -LiteralPath $target).Hash.ToLowerInvariant() -ne $expected){throw 'An existing loader was found; it has not been replaced.'}}
 else{Copy-Item -LiteralPath $loader -Destination $target}
 [Environment]::SetEnvironmentVariable('BETTERNCM_PROFILE',$profile,'User')
 # Tell Explorer to pick up the user environment for future client launches.
 Add-Type 'using System;using System.Runtime.InteropServices;public static class LyricsEnvironment{[DllImport("user32.dll",CharSet=CharSet.Unicode)]public static extern IntPtr SendMessageTimeout(IntPtr h,uint m,IntPtr w,string l,uint f,uint t,out IntPtr r);}'
 $result=[IntPtr]::Zero;[LyricsEnvironment]::SendMessageTimeout([IntPtr]0xffff,0x1A,[IntPtr]::Zero,'Environment',2,1000,[ref]$result)|Out-Null
 exit
}
$version=[Diagnostics.FileVersionInfo]::GetVersionInfo($client).FileVersion
if($version -notmatch '^3\.1\.(\d+)' -or [int]$Matches[1] -lt 20 -or [int]$Matches[1] -gt 41){throw ('This adapter is tested with NetEase 3.1.20–3.1.41; detected '+$version+'. The client has not been modified.')}
New-Item -ItemType Directory -Path $downloads,(Join-Path $profile 'plugins') -Force|Out-Null
foreach($dep in $deps){
 $path=Join-Path $downloads $dep.file
 if(-not(Test-Path -LiteralPath $path)){Invoke-WebRequest -Uri $dep.url -OutFile ($path+'.partial') -UseBasicParsing;if((Get-FileHash -LiteralPath ($path+'.partial')).Hash.ToLowerInvariant() -ne $dep.sha256){throw 'Adapter checksum mismatch.'};Move-Item -LiteralPath ($path+'.partial') -Destination $path}
 if((Get-FileHash -LiteralPath $path).Hash.ToLowerInvariant() -ne $dep.sha256){throw 'Cached adapter checksum mismatch.'}
}
if(Test-Path -LiteralPath $target){if((Get-FileHash -LiteralPath $target).Hash -ne (Get-FileHash -LiteralPath $loader).Hash){throw 'A different BetterNCM loader already exists. No client file was replaced.'}}
$pluginTarget=Join-Path $profile 'plugins\InfLink-rs.plugin'
if(Test-Path -LiteralPath $pluginTarget){$backup=Join-Path $StudioRoot ('Backups\Lyrics-'+(Get-Date -Format yyyyMMdd-HHmmss));New-Item -ItemType Directory -Path $backup -Force|Out-Null;Copy-Item -LiteralPath $pluginTarget -Destination $backup}
Copy-Item -LiteralPath $plugin -Destination $pluginTarget -Force
try{& $PSCommandPath -WriteLoader}catch [UnauthorizedAccessException]{
 $p=Start-Process -FilePath powershell.exe -Verb RunAs -WindowStyle Hidden -ArgumentList ('-NoProfile -File "'+$PSCommandPath+'" -WriteLoader') -Wait -PassThru
 if($p.ExitCode){throw 'Windows did not complete the adapter installation.'}
}
[Environment]::SetEnvironmentVariable('BETTERNCM_PROFILE',$profile,'Process')
Write-Output 'Adapter installed. Fully exit and reopen NetEase, then enable lyrics in the workbench. Original NetEase executables were not replaced.'
