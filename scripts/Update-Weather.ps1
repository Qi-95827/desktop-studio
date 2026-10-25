$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Common.ps1')
if(Get-Process seelen-ui -ErrorAction SilentlyContinue){throw 'Exit Seelen UI before changing weather settings. Data refresh itself does not need a plugin reload.'}
$path=Join-Path $SeelenData 'plugins\shanghai-weather\metadata.json'
if(-not(Test-Path -LiteralPath $path)){return}
$lat=$StudioConfig.Latitude.ToString([Globalization.CultureInfo]::InvariantCulture)
$lon=$StudioConfig.Longitude.ToString([Globalization.CultureInfo]::InvariantCulture)
$city=ConvertTo-Json -InputObject ([string]$StudioConfig.City) -Compress
$plugin=Get-Content -LiteralPath $path -Raw -Encoding UTF8|ConvertFrom-Json
$plugin.plugin|Add-Member -NotePropertyName remoteData -NotePropertyValue @{weather=@{url=('https://api.open-meteo.com/v1/forecast?latitude='+$lat+'&longitude='+$lon+'&current=temperature_2m,weather_code&timezone=auto&format=csv');updateIntervalSeconds=1800;requestInit=@{}}} -Force
$plugin.plugin.template='try { const rows = weather.trim().split("\n"); const values = rows[rows.length - 1].split(","); return [icon("TbCloud"), '+$city+' + " " + Math.round(Number(values[1])) + "°"]; } catch (e) { return [icon("TbCloud"), '+$city+']; }'
[IO.File]::WriteAllText($path,($plugin|ConvertTo-Json -Depth 20),[Text.UTF8Encoding]::new($false))
