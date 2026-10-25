param([string]$OutputDirectory=(Join-Path (Split-Path $PSScriptRoot) 'bin'))
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot
$fw=Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319'
$compiler=Join-Path $fw 'csc.exe'
if(-not(Test-Path -LiteralPath $compiler)){throw '.NET Framework 4.8 / x64 compiler is required.'}
New-Item -ItemType Directory -Path $OutputDirectory -Force|Out-Null
$refs=@('PresentationCore.dll','PresentationFramework.dll','WindowsBase.dll')|ForEach-Object {'/r:'+(Join-Path $fw ('WPF\'+$_))}
& $compiler /nologo /target:winexe /platform:x64 ('/out:'+(Join-Path $OutputDirectory 'DesktopStudio.exe')) ('/win32icon:'+(Join-Path $root 'assets\DesktopStudio.ico')) ('/win32manifest:'+(Join-Path $root 'src\DesktopStudio.exe.manifest')) ('/r:'+(Join-Path $fw 'System.Xaml.dll')) ('/r:'+(Join-Path $fw 'System.Web.Extensions.dll')) /r:Microsoft.CSharp.dll @refs (Join-Path $root 'src\DesktopStudio.cs')
if($LASTEXITCODE){throw 'DesktopStudio build failed.'}
& $compiler /nologo /target:library /platform:x64 ('/out:'+(Join-Path $OutputDirectory 'MediaThumbnail.dll')) ('/r:'+(Join-Path $fw 'System.Runtime.dll')) ('/r:'+(Join-Path $fw 'System.Runtime.WindowsRuntime.dll')) ('/r:'+(Join-Path $env:WINDIR 'System32\WinMetadata\Windows.Foundation.winmd')) ('/r:'+(Join-Path $env:WINDIR 'System32\WinMetadata\Windows.Storage.winmd')) (Join-Path $root 'src\MediaThumbnail.cs')
if($LASTEXITCODE){throw 'MediaThumbnail build failed.'}
Copy-Item -LiteralPath (Join-Path $root 'assets\DesktopStudio.ico') -Destination $OutputDirectory -Force
Copy-Item -LiteralPath (Join-Path $root 'src\DesktopStudio.exe.config') -Destination $OutputDirectory -Force
Write-Output (Join-Path $OutputDirectory 'DesktopStudio.exe')
