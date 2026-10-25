param([switch]$SelfContained,[string]$OutputDirectory)
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot
$env:DOTNET_CLI_HOME=Join-Path $root '.build\dotnet'
$env:NUGET_PACKAGES=Join-Path $root '.build\packages'
$env:DOTNET_CLI_TELEMETRY_OPTOUT='1'
$env:DOTNET_SKIP_FIRST_TIME_EXPERIENCE='1'
$output=if($OutputDirectory){[IO.Path]::GetFullPath($OutputDirectory)}else{Join-Path $root 'bin\Lyrics'}
$log=Join-Path $root '.build\lyrics-build.log'
New-Item -ItemType Directory -Path (Split-Path $log) -Force|Out-Null
$arguments=@('publish',(Join-Path $root 'src\LyricsBridge\LyricsBridge.csproj'),'-c','Release','-o',$output,'-p:RunAnalyzers=false','-v','quiet')
if($SelfContained){$arguments+=@('-r','win-x64','--self-contained','true')}
& dotnet @arguments *> $log
if($LASTEXITCODE){Get-Content -LiteralPath $log -Tail 25;throw 'Lyrics worker build failed.'}
& dotnet (Join-Path $output 'DesktopStudio.Lyrics.dll') --self-test
if($LASTEXITCODE){throw 'Lyrics timeline validation failed.'}
if($SelfContained){
 $pack=Get-ChildItem -LiteralPath (Join-Path $env:NUGET_PACKAGES 'microsoft.netcore.app.runtime.win-x64') -Directory|Sort-Object {[version]$_.Name} -Descending|Select-Object -First 1
 foreach($name in @('LICENSE.TXT','THIRD-PARTY-NOTICES.TXT')){Copy-Item -LiteralPath (Join-Path $pack.FullName $name) -Destination $output -Force}
}
Write-Output $output
