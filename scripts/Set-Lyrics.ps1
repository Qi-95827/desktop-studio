param([bool]$Enabled=$true,[ValidateRange(2,4)][int]$Lines=3,[ValidateRange(14,24)][int]$FontSize=18,[ValidateRange(-5000,5000)][int]$OffsetMs=0,[bool]$Smooth=$true)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Common.ps1')
$data=Join-Path $StudioRoot 'Data\NetEase'
New-Item -ItemType Directory -Path $data -Force|Out-Null
$settings=@{Enabled=$Enabled;Lines=$Lines;FontSize=$FontSize;OffsetMs=$OffsetMs;Smooth=$Smooth}
$path=Join-Path $data 'lyrics-settings.json'
[IO.File]::WriteAllText(($path+'.tmp'),($settings|ConvertTo-Json),[Text.UTF8Encoding]::new($false))
Move-Item -LiteralPath ($path+'.tmp') -Destination $path -Force
$enabledInt=if($Enabled){1}else{0}
$height=[Math]::Ceiling($FontSize*2.2)
$ini="[Variables]`r`nLyricsEnabled=$enabledInt`r`nLyricsRows=$Lines`r`nLyricsFontSize=$FontSize`r`nLyricsLineHeight=$height`r`n"
[IO.File]::WriteAllText((Join-Path $data 'LyricsView.inc'),$ini,[Text.Encoding]::Unicode)
if(Get-Process Rainmeter -ErrorAction SilentlyContinue){Invoke-RainBang '!Refresh "Monterey\Widgets\Music"'}
