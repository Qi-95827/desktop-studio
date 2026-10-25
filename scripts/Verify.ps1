$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot
$failures=@()
foreach($file in Get-ChildItem -LiteralPath (Join-Path $root 'scripts') -Filter '*.ps1'){
 $tokens=$null;$errors=$null;[Management.Automation.Language.Parser]::ParseFile($file.FullName,[ref]$tokens,[ref]$errors)|Out-Null
 foreach($error in $errors){$failures+=($file.Name+': '+$error.Message)}
}
foreach($file in @((Join-Path $root 'config.example.json'),(Join-Path $root 'dependencies.lock.json'))+(Get-ChildItem -LiteralPath (Join-Path $root 'presets\SeelenUI') -Recurse -Filter '*.json'|ForEach-Object {$_.FullName})){
 try{Get-Content -LiteralPath $file -Raw -Encoding UTF8|ConvertFrom-Json|Out-Null}catch{$failures+=($file+': '+$_.Exception.Message)}
}
foreach($name in @('README.md','README.en.md','THIRD_PARTY_NOTICES.md','licenses\Monterey-CC-BY-NC-SA-4.0.txt')){if(-not(Test-Path -LiteralPath (Join-Path $root $name))){$failures+=('Missing '+$name)}}
$plugins=@(Get-ChildItem -LiteralPath (Join-Path $root 'presets\SeelenUI\plugins') -Recurse -Filter metadata.json|ForEach-Object {(Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8|ConvertFrom-Json).id})
$toolbar=[IO.File]::ReadAllText((Join-Path $root 'presets\SeelenUI\toolbar.yml'))
foreach($match in [regex]::Matches($toolbar,"@qih/[a-z0-9-]+")){if($match.Value -notin $plugins){$failures+=('Unresolved toolbar plugin '+$match.Value)}}
$profile=[IO.File]::ReadAllText((Join-Path $root 'scripts\Desktop-Profile.ps1'))
if(-not $profile.Contains('Start-HdpiRainmeter.ps1')){$failures+='Desktop startup does not enforce native DPI.'}
$guard=[IO.File]::ReadAllText((Join-Path $root 'scripts\Watch-DesktopIcons.ps1'))
if($guard.Contains('Update-Weather.ps1')){$failures+='Weather must refresh through data, not plugin file rewrites.'}
if($failures.Count){$failures|ForEach-Object {Write-Error $_ -ErrorAction Continue};throw 'Verification failed.'}
Write-Output 'PowerShell syntax, JSON presets, bilingual documentation and license files verified.'
