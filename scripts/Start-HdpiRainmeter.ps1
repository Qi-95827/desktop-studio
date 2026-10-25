param([Parameter(Mandatory=$true)][string]$RainmeterExe)
$ErrorActionPreference='Stop'
Add-Type @'
using System;using System.Runtime.InteropServices;
public static class StudioRainDpi {
 [DllImport("shcore.dll")]public static extern int GetProcessDpiAwareness(IntPtr p,out int a);
 public static int Read(System.Diagnostics.Process p){int a;int hr=GetProcessDpiAwareness(p.Handle,out a);if(hr!=0)Marshal.ThrowExceptionForHR(hr);return a;}
}
'@
if(-not(Test-Path -LiteralPath $RainmeterExe)){throw 'Rainmeter executable is missing.'}
$running=@(Get-Process Rainmeter -ErrorAction SilentlyContinue)
foreach($process in $running){
 if($process.Path -ne $RainmeterExe){throw 'Another Rainmeter installation is already running.'}
 if([StudioRainDpi]::Read($process) -ne 0){continue}
 Start-Process -FilePath $RainmeterExe -ArgumentList '!Quit' -WindowStyle Hidden
 if(-not $process.WaitForExit(5000)){throw 'Rainmeter did not exit for its DPI restart.'}
}
if(-not(Get-Process Rainmeter -ErrorAction SilentlyContinue)){
 $info=[Diagnostics.ProcessStartInfo]::new()
 $info.FileName=$RainmeterExe;$info.WorkingDirectory=Split-Path $RainmeterExe
 $info.UseShellExecute=$false;$info.EnvironmentVariables['__COMPAT_LAYER']='HIGHDPIAWARE'
 [Diagnostics.Process]::Start($info)|Out-Null
 Start-Sleep -Milliseconds 500
}
$process=Get-Process Rainmeter -ErrorAction Stop|Select-Object -First 1
if([StudioRainDpi]::Read($process) -eq 0){throw 'Native DPI startup failed; widgets were not started in the required mode.'}
