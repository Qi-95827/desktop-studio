$StudioRoot=Split-Path $PSScriptRoot
$StudioConfigPath=Join-Path $StudioRoot 'config.json'
if(Test-Path -LiteralPath $StudioConfigPath){$StudioConfig=Get-Content -LiteralPath $StudioConfigPath -Raw -Encoding UTF8|ConvertFrom-Json}else{$StudioConfig=Get-Content -LiteralPath (Join-Path $StudioRoot 'config.example.json') -Raw -Encoding UTF8|ConvertFrom-Json}
$RainmeterExe=if($StudioConfig.RainmeterExe){$StudioConfig.RainmeterExe}else{Join-Path $StudioRoot 'runtime\Rainmeter\Rainmeter.exe'}
$RainmeterHome=Split-Path $RainmeterExe
$SeelenExe=$StudioConfig.SeelenExe
$SeelenCli=Join-Path (Split-Path $SeelenExe) 'slu.exe'
$SeelenData=Join-Path $env:APPDATA 'com.seelen.seelen-ui'
function Start-StudioWorker([string]$Name){Start-Process -FilePath (Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe') -ArgumentList ('-NoProfile -WindowStyle Hidden -STA -File "'+(Join-Path $PSScriptRoot $Name)+'"') -WindowStyle Hidden}
function Invoke-RainBang([string]$Command){if(-not(Test-Path -LiteralPath $RainmeterExe)){throw 'Run Install.cmd to install the widget runtime first.'};Start-Process -FilePath $RainmeterExe -ArgumentList $Command -WindowStyle Hidden}
