param([string]$InstallRoot='D:\Program Files (x86)\DesktopStudio',[switch]$Plan,[switch]$ConfigureOnly,[switch]$NoShortcuts)
$ErrorActionPreference='Stop'
$source=Split-Path $PSScriptRoot
$destination=[IO.Path]::GetFullPath($InstallRoot)
if(-not[IO.Path]::IsPathRooted($InstallRoot) -or $destination.TrimEnd('\') -eq [IO.Path]::GetPathRoot($destination).TrimEnd('\')){throw 'Choose an absolute application folder, not a drive root.'}
if($Plan){Write-Output ('Install to '+$destination);Write-Output 'Copy public launcher and presets; verify pinned upstream downloads; install Seelen UI and portable Rainmeter; apply backed-up layout; create shortcut. No desktop changes are made in Plan mode.';exit}
New-Item -ItemType Directory -Path $destination -Force|Out-Null
if($destination.TrimEnd('\') -ne $source.TrimEnd('\')){
 foreach($name in @('src','assets','scripts','presets','licenses','docs','bin','README.md','README.en.md','LICENSE','THIRD_PARTY_NOTICES.md','config.example.json','dependencies.lock.json','Start.cmd','Install.cmd')){
  $path=Join-Path $source $name
  if(Test-Path -LiteralPath $path){Copy-Item -LiteralPath $path -Destination $destination -Recurse -Force}
 }
}
if(-not(Test-Path -LiteralPath (Join-Path $destination 'bin\DesktopStudio.exe'))){& (Join-Path $destination 'scripts\Build.ps1')}
$configPath=Join-Path $destination 'config.json'
if(-not(Test-Path -LiteralPath $configPath)){
 $config=Get-Content -LiteralPath (Join-Path $destination 'config.example.json') -Raw -Encoding UTF8|ConvertFrom-Json
 foreach($candidate in @('D:\Program Files\NetEase\CloudMusic\cloudmusic.exe',(Join-Path $env:ProgramFiles 'NetEase\CloudMusic\cloudmusic.exe'),(Join-Path $env:LOCALAPPDATA 'NetEase\CloudMusic\cloudmusic.exe'))){if(Test-Path -LiteralPath $candidate){$config.NetEaseExe=$candidate;break}}
 [IO.File]::WriteAllText($configPath,($config|ConvertTo-Json -Depth 10),[Text.UTF8Encoding]::new($false))
}
if(-not $ConfigureOnly){
 & (Join-Path $destination 'scripts\Get-Dependencies.ps1')
 $config=Get-Content -LiteralPath $configPath -Raw -Encoding UTF8|ConvertFrom-Json
 if(-not(Test-Path -LiteralPath $config.SeelenExe)){
  $installer=Join-Path $destination 'downloads\Seelen.UI_2.8.10_x64-setup.exe'
  $proc=Start-Process -FilePath $installer -ArgumentList ('/S /D='+(Split-Path $config.SeelenExe)) -Wait -PassThru
  if($proc.ExitCode -ne 0 -or -not(Test-Path -LiteralPath $config.SeelenExe)){throw 'Seelen UI installation did not complete. Run its official installer, then set SeelenExe in config.json.'}
 }
 $rain=Join-Path $destination 'runtime\Rainmeter\Rainmeter.exe'
 if(-not(Test-Path -LiteralPath $rain)){
  $argsText='/S /PORTABLE=1 /VERSION=64 /AUTOSTARTUP=0 /RESTART=0 /D='+(Split-Path $rain)
  $proc=Start-Process -FilePath (Join-Path $destination 'downloads\Rainmeter-4.5.28.exe') -ArgumentList $argsText -Wait -PassThru
  if($proc.ExitCode -ne 0 -or -not(Test-Path -LiteralPath $rain)){throw 'Portable Rainmeter installation failed.'}
 }
}
& (Join-Path $destination 'scripts\Configure-Desktop.ps1') -SkipSeelen:$ConfigureOnly
if(-not $NoShortcuts){
 $shell=New-Object -ComObject WScript.Shell
 $link=$shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Desktop')) '桌面工作台.lnk'))
 $link.TargetPath=Join-Path $destination 'bin\DesktopStudio.exe';$link.WorkingDirectory=$destination;$link.IconLocation=Join-Path $destination 'assets\DesktopStudio.ico';$link.Save()
}
Write-Output ('Installed. Open '+(Join-Path $destination 'bin\DesktopStudio.exe'))
