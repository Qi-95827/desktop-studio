param([ValidateSet('Watch','PlayPause','Next','Previous')] [string]$Action='Watch')
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Common.ps1')
$mediaRoot=Join-Path $StudioRoot 'Data\NetEase'
New-Item -ItemType Directory -Path $mediaRoot -Force|Out-Null
Add-Type -AssemblyName System.Runtime.WindowsRuntime
Add-Type -Path (Join-Path $StudioRoot 'bin\MediaThumbnail.dll')
$null=[Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager,Windows.Media.Control,ContentType=WindowsRuntime]
$null=[Windows.Storage.Streams.IRandomAccessStreamWithContentType,Windows.Storage.Streams,ContentType=WindowsRuntime]
$asTask=[System.WindowsRuntimeSystemExtensions].GetMethods()|Where-Object {$_.Name -eq 'AsTask' -and $_.IsGenericMethod -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'}|Select-Object -First 1
function Await-Result($op,$type){$task=$asTask.MakeGenericMethod($type).Invoke($null,@($op));$task.Wait();$task.Result}
$manager=Await-Result ([Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager]::RequestAsync()) ([Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager])
function Get-NetEaseSession {$manager.GetSessions()|Where-Object {$_.SourceAppUserModelId -match 'cloudmusic'}|Select-Object -First 1}
if($Action -ne 'Watch') {
 $session=Get-NetEaseSession
 if($session){switch($Action){'PlayPause'{$op=$session.TryTogglePlayPauseAsync()};'Next'{$op=$session.TrySkipNextAsync()};'Previous'{$op=$session.TrySkipPreviousAsync()}};Await-Result $op ([bool])|Out-Null}
 exit
}
$mutex=[Threading.Mutex]::new($false,'Local\DesktopStudioNetEaseBridge')
if(-not $mutex.WaitOne(0)){exit}
$lastTrack='';$lastState='';$cover=''
try {
 while(Get-Process Rainmeter -ErrorAction SilentlyContinue){
  try {
   $session=Get-NetEaseSession
   $title='网易云音乐';$artist='打开网易云，开始播放';$state=0
   if($session){
    $props=Await-Result ($session.TryGetMediaPropertiesAsync()) ([Windows.Media.Control.GlobalSystemMediaTransportControlsSessionMediaProperties])
    $title=$props.Title;$artist=$props.Artist;$playback=$session.GetPlaybackInfo().PlaybackStatus.ToString();$state=if($playback -eq 'Playing'){1}elseif($playback -eq 'Paused'){2}else{0}
    $track=$title+'|'+$artist
    if($track -ne $lastTrack){
     $cover=''
     if($props.Thumbnail){
      $stream=Await-Result ($props.Thumbnail.OpenReadAsync()) ([Windows.Storage.Streams.IRandomAccessStreamWithContentType])
      $hash=[BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($track))).Replace('-','').Substring(0,16)
      $cover=Join-Path $mediaRoot ('cover-'+$hash+'.jpg')
      [MediaThumbnail]::Save($stream,$cover)
     }
     $lastTrack=$track
    }
   }
   $title=$title -replace '[\r\n]',' ' -replace '#','＃';$artist=$artist -replace '[\r\n]',' ' -replace '#','＃'
   $output="title=$title`nartist=$artist`nstate=$state`ncover=$cover`n"
   if($output -ne $lastState){
    [IO.File]::WriteAllText((Join-Path $mediaRoot 'state.txt'),$output,[Text.UTF8Encoding]::new($false))
    # Rainmeter's native Unicode INI reader avoids the Lua ANSI conversion.
    $ini="[Variables]`r`nMusicTitle=$title`r`nMusicArtist=$artist`r`nMusicState=$state`r`nMusicCover=$cover`r`n"
    [IO.File]::WriteAllText((Join-Path $mediaRoot 'MusicState.inc'),$ini,[Text.Encoding]::Unicode)
    Start-Process -FilePath $RainmeterExe -ArgumentList '!Refresh "Monterey\Widgets\Music"' -WindowStyle Hidden
    $lastState=$output
    [IO.File]::WriteAllText((Join-Path $mediaRoot 'last-error.txt'),'')
   }
  }catch{$_.Exception.Message|Set-Content (Join-Path $mediaRoot 'last-error.txt') -Encoding UTF8}
  Start-Sleep -Seconds 2
 }
}finally{$mutex.ReleaseMutex();$mutex.Dispose()}
