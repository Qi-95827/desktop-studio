param([string]$Version='0.1.0')
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot
& (Join-Path $PSScriptRoot 'Build.ps1')
$dist=Join-Path $root 'dist';New-Item -ItemType Directory -Path $dist -Force|Out-Null
$stage=Join-Path $dist ('DesktopStudio-'+$Version+'-win-x64')
if(Test-Path -LiteralPath $stage){throw 'Package staging folder already exists; choose a new version or move it aside.'}
New-Item -ItemType Directory -Path $stage -Force|Out-Null
$files=& git -C $root ls-files
if($LASTEXITCODE -or -not $files){throw 'Stage the public source files with git add before packaging.'}
foreach($file in $files){if($file.StartsWith('.github/') -or $file -eq '.gitignore'){continue};$dest=Join-Path $stage $file;New-Item -ItemType Directory -Path (Split-Path $dest) -Force|Out-Null;Copy-Item -LiteralPath (Join-Path $root $file) -Destination $dest}
Copy-Item -LiteralPath (Join-Path $root 'bin') -Destination $stage -Recurse
$zip=Join-Path $dist ('DesktopStudio-'+$Version+'-win-x64.zip')
Compress-Archive -LiteralPath $stage -DestinationPath $zip
$hash=(Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant()
[IO.File]::WriteAllText((Join-Path $dist 'SHA256SUMS.txt'),($hash+'  '+[IO.Path]::GetFileName($zip)+"`n"),[Text.UTF8Encoding]::new($false))
Write-Output $zip
