$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Common.ps1')
$exe=Join-Path $StudioRoot 'bin\Lyrics\DesktopStudio.Lyrics.exe'
if(-not(Test-Path -LiteralPath $exe)){return}
$settings=Join-Path $StudioRoot 'Data\NetEase\lyrics-settings.json'
if(Test-Path -LiteralPath $settings){
 $s=Get-Content -LiteralPath $settings -Raw -Encoding UTF8|ConvertFrom-Json
 & (Join-Path $PSScriptRoot 'Set-Lyrics.ps1') -Enabled ([bool]$s.Enabled) -Lines ([int]$s.Lines) -FontSize ([int]$s.FontSize) -OffsetMs ([int]$s.OffsetMs) -Smooth ([bool]$s.Smooth)
}else{& (Join-Path $PSScriptRoot 'Set-Lyrics.ps1')}
Start-Process -FilePath $exe -ArgumentList ('"'+$StudioRoot+'"') -WindowStyle Hidden
