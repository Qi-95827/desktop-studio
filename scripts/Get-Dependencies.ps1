param([string]$Destination=(Join-Path (Split-Path $PSScriptRoot) 'downloads'))
$ErrorActionPreference='Stop'
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
$lock=Get-Content -LiteralPath (Join-Path (Split-Path $PSScriptRoot) 'dependencies.lock.json') -Raw -Encoding UTF8|ConvertFrom-Json
New-Item -ItemType Directory -Path $Destination -Force|Out-Null
foreach($dep in $lock){
 $path=Join-Path $Destination $dep.file
 if(-not(Test-Path -LiteralPath $path)){
  $temp=$path+'.partial'
  Invoke-WebRequest -Uri $dep.url -OutFile $temp -UseBasicParsing
  if((Get-FileHash -LiteralPath $temp -Algorithm SHA256).Hash.ToLowerInvariant() -ne $dep.sha256){throw ('SHA256 mismatch: '+$dep.file)}
  Move-Item -LiteralPath $temp -Destination $path
 }
 if((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() -ne $dep.sha256){throw ('Cached installer SHA256 mismatch: '+$path)}
 Write-Output ('Verified '+$dep.id+' '+$dep.version)
}
