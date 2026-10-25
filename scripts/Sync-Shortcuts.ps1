param([switch]$InitializeOnly)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Common.ps1')
$categories=Get-Content -LiteralPath (Join-Path $StudioRoot 'presets\categories.json') -Raw -Encoding UTF8|ConvertFrom-Json
$folders=@()
foreach($name in $categories){
 $folder=Join-Path $StudioRoot ('Collections\'+$name)
 New-Item -ItemType Directory -Path $folder -Force|Out-Null
 $items=@(Get-ChildItem -LiteralPath $folder -File|Where-Object {$_.Extension -in @('.lnk','.url')}|Sort-Object Name|ForEach-Object {$_.FullName.ToLowerInvariant()})
 $folders+=@{type='folder';itemId=('desktop-studio-'+[Array]::IndexOf($categories,$name));name=$name;itemIds=$items}
}
if($InitializeOnly){return}
$path=Join-Path $SeelenData 'data\seelen-apps-menu'
New-Item -ItemType Directory -Path $path -Force|Out-Null
[IO.File]::WriteAllText((Join-Path $path 'favorites.json'),(ConvertTo-Json -InputObject @($folders) -Depth 10),[Text.UTF8Encoding]::new($false))
Write-Output 'Eight shortcut folders synchronized. Reopen the application menu to refresh.'
