param([ValidateSet('Read','Hide','Show')] [string]$Mode = 'Read')
$ErrorActionPreference = 'Stop'
Add-Type -IgnoreWarnings -TypeDefinition @'
using System;
using System.Text;
using System.Runtime.InteropServices;
using System.Collections.Generic;
[ComImport, Guid("6d5140c1-7436-11ce-8034-00aa006009fa"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IDeskServiceProvider { [PreserveSig] int QueryService(ref Guid service, ref Guid iid, out IntPtr result); }
public class DesktopIconRecord { public string Name; public string Path; public int X; public int Y; }
public static class DesktopLayoutReader {
 [StructLayout(LayoutKind.Sequential)] public struct Point { public int X,Y; }
 [StructLayout(LayoutKind.Explicit, Size=272)] public struct StrRet { [FieldOffset(0)] public uint Type; [FieldOffset(8)] public IntPtr Ptr; }
 [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int GetPtr(IntPtr self, out IntPtr p);
 [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int GetFolder(IntPtr self, ref Guid id, out IntPtr p);
 [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int GetCount(IntPtr self, uint flags, out int count);
 [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int GetItem(IntPtr self, int index, out IntPtr pidl);
 [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int GetPoint(IntPtr self, IntPtr pidl, out Point point);
 [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int GetName(IntPtr self, IntPtr pidl, uint flags, out StrRet name);
 [UnmanagedFunctionPointer(CallingConvention.StdCall)] delegate int SetFlags(IntPtr self, uint mask, uint flags);
 [DllImport("shlwapi.dll",CharSet=CharSet.Unicode)] static extern int StrRetToBufW(ref StrRet name, IntPtr pidl, StringBuilder text, uint size);
 static T Method<T>(IntPtr p,int slot) where T:class { return Marshal.GetDelegateForFunctionPointer(Marshal.ReadIntPtr(Marshal.ReadIntPtr(p),slot*IntPtr.Size),typeof(T)) as T; }
 static void Check(int hr) { Marshal.ThrowExceptionForHR(hr); }
 static string Name(IntPtr folder,IntPtr pidl,uint flags) { StrRet sr; Check(Method<GetName>(folder,11)(folder,pidl,flags,out sr)); var b=new StringBuilder(32768); Check(StrRetToBufW(ref sr,pidl,b,32768)); return b.ToString(); }
 public static void SetIconsHidden(object dispatch, bool hidden) {
  Guid service=new Guid("4C96BE40-915C-11CF-99D3-00AA004AE837"), browserId=new Guid("000214E2-0000-0000-C000-000000000046"), viewId=new Guid("1af3a467-214f-4298-908e-06b03e0b39f9");
  IntPtr browser=IntPtr.Zero,view=IntPtr.Zero,fv=IntPtr.Zero;
  try { Check(((IDeskServiceProvider)dispatch).QueryService(ref service,ref browserId,out browser)); Check(Method<GetPtr>(browser,15)(browser,out view)); Check(Marshal.QueryInterface(view,ref viewId,out fv)); Check(Method<SetFlags>(fv,24)(fv,0x1000,hidden ? 0x1000u : 0)); }
  finally {foreach(var p in new[]{fv,view,browser}) if(p!=IntPtr.Zero) Marshal.Release(p);}
 }
 public static List<DesktopIconRecord> Read(object dispatch) {
  Guid service=new Guid("4C96BE40-915C-11CF-99D3-00AA004AE837"), browserId=new Guid("000214E2-0000-0000-C000-000000000046"), viewId=new Guid("cde725b0-ccc9-4519-917e-325d72fab4ce"), folderId=new Guid("000214E6-0000-0000-C000-000000000046");
  IntPtr browser=IntPtr.Zero, view=IntPtr.Zero, fv=IntPtr.Zero, folder=IntPtr.Zero;
  try { Check(((IDeskServiceProvider)dispatch).QueryService(ref service,ref browserId,out browser)); Check(Method<GetPtr>(browser,15)(browser,out view)); Check(Marshal.QueryInterface(view,ref viewId,out fv)); Check(Method<GetFolder>(fv,5)(fv,ref folderId,out folder)); int count; Check(Method<GetCount>(fv,7)(fv,2,out count)); var result=new List<DesktopIconRecord>();
   for(int i=0;i<count;i++) { IntPtr pidl; Check(Method<GetItem>(fv,6)(fv,i,out pidl)); try { Point pt; Check(Method<GetPoint>(fv,11)(fv,pidl,out pt)); result.Add(new DesktopIconRecord{Name=Name(folder,pidl,0),Path=Name(folder,pidl,0x8000),X=pt.X,Y=pt.Y}); } finally {Marshal.FreeCoTaskMem(pidl);} }
   return result;
  } finally {foreach(var p in new[]{folder,fv,view,browser}) if(p!=IntPtr.Zero) Marshal.Release(p);}
 }
}
'@
$desktopShell = New-Object -ComObject Shell.Application
$desktopWindows = $desktopShell.Windows()
$desktopLocation = 0
$desktopRoot = $null
$desktopHwnd = 0
$desktopDispatch = $desktopWindows.FindWindowSW([ref]$desktopLocation,[ref]$desktopRoot,8,[ref]$desktopHwnd,1)
if ($Mode -eq 'Read') {
 $desktopIcons = [DesktopLayoutReader]::Read($desktopDispatch)

 $desktopIcons | Sort-Object X,Y | Format-Table Name,X,Y,Path -AutoSize
} else {
 [DesktopLayoutReader]::SetIconsHidden($desktopDispatch, $Mode -eq 'Hide')
 Set-ItemProperty -LiteralPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name HideIcons -Value ([int]($Mode -eq 'Hide'))
 Write-Output "Desktop icon visibility set: $Mode"
}
