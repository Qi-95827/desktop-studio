param([switch]$SkipSeelen)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Common.ps1')
foreach($name in @('Data\NetEase','Backups','Collections')){New-Item -ItemType Directory -Path (Join-Path $StudioRoot $name) -Force|Out-Null}
$archive=Join-Path $StudioRoot 'downloads\Monterey_1.0.2.rmskin'
$dependencies=Get-Content -LiteralPath (Join-Path $StudioRoot 'dependencies.lock.json') -Raw -Encoding UTF8|ConvertFrom-Json
$dep=$dependencies|Where-Object {$_.id -eq 'monterey'}
if(-not(Test-Path -LiteralPath $archive) -or (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant() -ne $dep.sha256){throw 'Download and verify Monterey first with Get-Dependencies.ps1.'}
$stamp=Get-Date -Format yyyyMMdd-HHmmss
$backup=Join-Path $StudioRoot ('Backups\Before-Setup-'+$stamp)
New-Item -ItemType Directory -Path $backup -Force|Out-Null
if(Test-Path -LiteralPath (Join-Path $RainmeterHome 'Rainmeter.ini')){Copy-Item -LiteralPath (Join-Path $RainmeterHome 'Rainmeter.ini') -Destination $backup}
if(-not $SkipSeelen -and (Get-Process seelen-ui -ErrorAction SilentlyContinue)){throw 'Close Seelen UI before applying a preset. Existing settings have not been changed.'}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip=[IO.Compression.ZipFile]::OpenRead($archive)
try{foreach($entry in $zip.Entries){
 if($entry.FullName.EndsWith('/')){continue}
 if($entry.FullName.StartsWith('Skins/Monterey/')){$target=Join-Path $RainmeterHome $entry.FullName}
 elseif($entry.FullName.StartsWith('Plugins/64bit/')){$target=Join-Path $RainmeterHome ('Plugins\'+[IO.Path]::GetFileName($entry.FullName))}
 else{continue}
 $absolute=[IO.Path]::GetFullPath($target)
 if(-not $absolute.StartsWith([IO.Path]::GetFullPath($RainmeterHome).TrimEnd('\')+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Unsafe archive path.'}
 New-Item -ItemType Directory -Path (Split-Path $absolute) -Force|Out-Null
 [IO.Compression.ZipFileExtensions]::ExtractToFile($entry,$absolute,$true)
}}finally{$zip.Dispose()}
$overlay=Join-Path $StudioRoot 'presets\Monterey'
foreach($file in Get-ChildItem -LiteralPath $overlay -Recurse -File){
 if($file.Extension -notin @('.ini','.inc','.lua')){continue}
 $relative=$file.FullName.Substring($overlay.Length+1)
 $target=Join-Path $RainmeterHome ('Skins\Monterey\'+$relative)
 $text=[IO.File]::ReadAllText($file.FullName).Replace('__STUDIO_ROOT__',$StudioRoot).Replace('__RAINMETER_HOME__',$RainmeterHome).Replace('__NETEASE_EXE__',[string]$StudioConfig.NetEaseExe).Replace('__CITY__',[string]$StudioConfig.City).Replace('__LATITUDE__',$StudioConfig.Latitude.ToString([Globalization.CultureInfo]::InvariantCulture)).Replace('__LONGITUDE__',$StudioConfig.Longitude.ToString([Globalization.CultureInfo]::InvariantCulture))
 New-Item -ItemType Directory -Path (Split-Path $target) -Force|Out-Null
 $encoding=if($file.Extension -eq '.lua'){[Text.UTF8Encoding]::new($false)}else{[Text.Encoding]::Unicode}
 [IO.File]::WriteAllText($target,$text,$encoding)
}
$state="[Variables]`r`nMusicTitle=网易云音乐`r`nMusicArtist=等待播放`r`nMusicState=0`r`nMusicCover=`r`n"
[IO.File]::WriteAllText((Join-Path $StudioRoot 'Data\NetEase\MusicState.inc'),$state,[Text.Encoding]::Unicode)
& (Join-Path $PSScriptRoot 'Set-Lyrics.ps1') -Enabled $false
$ini="[Rainmeter]`r`nSkinPath=$RainmeterHome\Skins\`r`nLogging=0`r`nLanguage=2052`r`n"
foreach($spec in @(@('Weather',3,150,240),@('Calendar',2,480,240),@('Music',6,150,570))){$ini+="`r`n[Monterey\Widgets\$($spec[0])]`r`nActive=$($spec[1])`r`nWindowX=$($spec[2])`r`nWindowY=$($spec[3])`r`nAlwaysOnTop=-2`r`nDraggable=1`r`nKeepOnScreen=1`r`nSnapEdges=1`r`n"}
[IO.File]::WriteAllText((Join-Path $RainmeterHome 'Rainmeter.ini'),$ini,[Text.Encoding]::Unicode)
$layers='HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers'
if(-not $SkipSeelen){New-Item -Path $layers -Force|Out-Null;New-ItemProperty -Path $layers -Name $RainmeterExe -Value '~ HIGHDPIAWARE' -PropertyType String -Force|Out-Null}
& (Join-Path $PSScriptRoot 'Sync-Shortcuts.ps1') -InitializeOnly
if($SkipSeelen){Write-Output 'Isolated widget configuration complete; Seelen and startup registration were not changed.';exit}
if(Test-Path -LiteralPath $SeelenData){Copy-Item -LiteralPath $SeelenData -Destination (Join-Path $backup 'SeelenUI') -Recurse -Force}
New-Item -ItemType Directory -Path $SeelenData -Force|Out-Null
foreach($name in @('themes','plugins')){Copy-Item -LiteralPath (Join-Path $StudioRoot ('presets\SeelenUI\'+$name)) -Destination $SeelenData -Recurse -Force}
$settingsPath=Join-Path $SeelenData 'settings.json'
if(Test-Path -LiteralPath $settingsPath){$settings=Get-Content -LiteralPath $settingsPath -Raw -Encoding UTF8|ConvertFrom-Json}else{$settings=[pscustomobject]@{}}
function Set-Property($Object,[string]$Name,$Value){$Object|Add-Member -NotePropertyName $Name -NotePropertyValue $Value -Force}
Set-Property $settings 'language' 'zh-CN';Set-Property $settings 'dateFormat' 'M月D日 ddd HH:mm'
$themes=@($settings.activeThemes)+@('@default/theme','@qih/mac-minimal')|Where-Object {$_}|Select-Object -Unique
Set-Property $settings 'activeThemes' @($themes)
if(-not $settings.byWidget){Set-Property $settings 'byWidget' ([pscustomobject]@{})}
$weg=@{enabled=$true;mode='MinContent';position='Bottom';hideMode='OnOverlap';size=52;padding=10;margin=12;spaceBetweenItems=8;showInstanceCounter=$false;showWindowTitle=$false;splitWindows=$false;temporalItemsVisibility='All';pinnedItemsVisibility='Always'}
$bar=@{enabled=$true;position='Top';hideMode='Never';itemSize=16;padding=5;margin=0}
Set-Property $settings.byWidget '@seelen/weg' $weg;Set-Property $settings.byWidget '@seelen/fancy-toolbar' $bar
foreach($id in @('@seelen/window-manager','@seelen/wallpaper-manager','@seelen/task-switcher')){Set-Property $settings.byWidget $id @{enabled=$false}}
Set-Property $settings.byWidget '@seelen/apps-menu' @{enabled=$true;defaultView='favorites'}
[IO.File]::WriteAllText($settingsPath,($settings|ConvertTo-Json -Depth 40),[Text.UTF8Encoding]::new($false))
$toolbar=Join-Path $SeelenData 'data\seelen-fancy-toolbar';New-Item -ItemType Directory -Path $toolbar -Force|Out-Null
Copy-Item -LiteralPath (Join-Path $StudioRoot 'presets\SeelenUI\toolbar.yml') -Destination (Join-Path $toolbar 'state.yml') -Force
$dock=Join-Path $SeelenData 'data\seelen-weg';New-Item -ItemType Directory -Path $dock -Force|Out-Null
function DockItem([string]$Name,[string]$Path){@{type='AppOrFile';id=[guid]::NewGuid().ToString();displayName=$Name;path=$Path;umid=$null;pinned=$true;preventPinning=$false;relaunch=$null}}
$dockState=@{isReorderDisabled=$false;left=@(@{type='Plugin';id=[guid]::NewGuid().ToString();plugin='@qih/launchpad'});center=@((DockItem '文件' (Join-Path $env:WINDIR 'explorer.exe')),(DockItem '桌面工作台' (Join-Path $StudioRoot 'bin\DesktopStudio.exe')));right=@(@{type='Plugin';id=[guid]::NewGuid().ToString();plugin='@default/weg-trash-bin'})}
if($StudioConfig.NetEaseExe){$dockState.center+=DockItem '网易云音乐' $StudioConfig.NetEaseExe}
[IO.File]::WriteAllText((Join-Path $dock 'state.yml'),($dockState|ConvertTo-Json -Depth 12),[Text.UTF8Encoding]::new($false))
& (Join-Path $PSScriptRoot 'Sync-Shortcuts.ps1')
& (Join-Path $PSScriptRoot 'Update-Weather.ps1')
Write-Output ('Preset configured; previous configuration saved to '+$backup)
