using System.Diagnostics;
using System.Globalization;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using Lyricify.Lyrics.Parsers;
using Lyricify.Lyrics.Providers.Web;
using NeteaseApi = Lyricify.Lyrics.Providers.Web.Netease.Api;

namespace DesktopStudio.Lyrics;

public record Settings(bool Enabled = true, int Lines = 3, int FontSize = 18, int OffsetMs = 0, bool Smooth = true);
public record Snapshot(string Title = "", string Artist = "", string SongId = "", int State = 0,
 double PositionMs = 0, double DurationMs = 0, long UpdatedUnixMs = 0, bool HasTimeline = false, long ObservedUnixMs = 0);
public record Line(int Time, string Text);

public static class Timeline
{
 public static int Current(IReadOnlyList<Line> lines, double position)
 {int lo=0,hi=lines.Count-1,result=-1;while(lo<=hi){int mid=(lo+hi)/2;if(lines[mid].Time<=position){result=mid;lo=mid+1;}else hi=mid-1;}return result;}
 public static double Position(Snapshot s,long now)
 {var elapsed=s.State==1?Math.Clamp(now-s.UpdatedUnixMs,0,1800):0;return Math.Clamp(s.PositionMs+elapsed,0,Math.Max(s.DurationMs,0));}
 public static string Safe(string text)=>text.Replace('"','＂').Replace('[','［').Replace(']','］').Replace('#','＃').Replace('\r',' ').Replace('\n',' ');
 public static List<Line> Parse(string raw)=>LrcParser.Parse(raw.AsSpan()).Lines?
  .Where(l=>l.StartTime.HasValue).Select(l=>new Line(l.StartTime!.Value,l.Text.Trim()))
  .OrderBy(l=>l.Time).GroupBy(l=>l.Time).Select(g=>new Line(g.Key,string.Join(" · ",g.Select(l=>l.Text).Distinct())))
  .ToList()??new();
}

static class Rain
{
 [StructLayout(LayoutKind.Sequential)]struct CopyData {public IntPtr Data;public int Size;public IntPtr Text;}
 [DllImport("user32.dll",CharSet=CharSet.Unicode)]static extern IntPtr FindWindow(string cls,string title);
 [DllImport("user32.dll",CharSet=CharSet.Unicode,SetLastError=true)]static extern IntPtr SendMessageTimeout(IntPtr h,uint m,IntPtr w,ref CopyData d,uint flags,uint timeout,out IntPtr result);
 public static bool Alive=>FindWindow("DummyRainWClass","Rainmeter control window")!=IntPtr.Zero;
 public static void Bang(string command)
 {var h=FindWindow("DummyRainWClass","Rainmeter control window");if(h==IntPtr.Zero)return;var ptr=Marshal.StringToHGlobalUni(command);try{var d=new CopyData{Data=new IntPtr(1),Size=(command.Length+1)*2,Text=ptr};SendMessageTimeout(h,0x4A,IntPtr.Zero,ref d,2,800,out _);}finally{Marshal.FreeHGlobal(ptr);}}
 public static string Set(string meter,string option,string value)=>$"[!SetOption \"{meter}\" \"{option}\" \"{value}\" \"Monterey\\Widgets\\Music\"]";
 public static string Cmd(string action)=>$"[!CommandMeasure LyricsAnimation \"{action}\" \"Monterey\\Widgets\\Music\"]";
 public const string Redraw="[!UpdateMeterGroup Lyrics \"Monterey\\Widgets\\Music\"][!Redraw \"Monterey\\Widgets\\Music\"]";
}

static class Program
{
 static readonly JsonSerializerOptions Json=new(){PropertyNameCaseInsensitive=true,WriteIndented=true};
 static readonly NeteaseApi Api=new();
 static string root="",data="";
 static T? Read<T>(string path){try{return JsonSerializer.Deserialize<T>(File.ReadAllText(path),Json);}catch{return default;}}
 static void Write(string name,object value){try{File.WriteAllText(Path.Combine(data,name)+".tmp",JsonSerializer.Serialize(value,Json),new UTF8Encoding(false));File.Move(Path.Combine(data,name)+".tmp",Path.Combine(data,name),true);}catch{}}
 static Settings GetSettings(){var s=Read<Settings>(Path.Combine(data,"lyrics-settings.json"))??new();return s with{Lines=Math.Clamp(s.Lines,2,4),FontSize=Math.Clamp(s.FontSize,14,24),OffsetMs=Math.Clamp(s.OffsetMs,-5000,5000)};}
 static async Task<List<Line>> Fetch(string id)
 {
  if(!Regex.IsMatch(id,@"^\d{1,20}$"))return new();
  var cache=Path.Combine(data,"LyricsCache",id+".json");var saved=Read<List<Line>>(cache);if(saved?.Count>0)return saved;
  var result=await Api.GetLyric(id);var lines=Timeline.Parse(result?.Lrc?.Lyric??"");
  if(lines.Count>0){Directory.CreateDirectory(Path.GetDirectoryName(cache)!);File.WriteAllText(cache,JsonSerializer.Serialize(lines,Json),new UTF8Encoding(false));}return lines;
 }
 static void Render(IReadOnlyList<Line> lines,int current,Settings settings,string message,bool animate)
 {
  int anchor=(settings.Lines-1)/2;
  var b=new StringBuilder();
  for(int i=0;i<6;i++)
  {int index=current-anchor+i;string text=lines.Count==0?(i==anchor?message:""):(index>=0&&index<lines.Count?lines[index].Text:"");
   b.Append(Rain.Set("Lyric"+i,"Text",Timeline.Safe(text)));
   b.Append(Rain.Set("Lyric"+i,"FontColor",i==anchor?"26323C":"78828CAA"));
   b.Append(Rain.Set("Lyric"+i,"FontWeight",i==anchor?"600":"400"));
  }
  b.Append(Rain.Cmd(animate&&settings.Smooth?"Scroll()":"Reset()"));b.Append(Rain.Redraw);Rain.Bang(b.ToString());
 }
 static int SelfTest()
 {
  var list=Timeline.Parse("[offset:100]\n[00:01.00]Alpha\n[00:02.00][00:04.00]Beta\n");
  if(list.Count!=3||list[0].Time!=900||Timeline.Current(list,899)!=-1||Timeline.Current(list,1900)!=1||Timeline.Current(list,5000)!=2)throw new Exception("Parser/window test failed");
  var s=new Snapshot(State:2,PositionMs:5000,DurationMs:9000,UpdatedUnixMs:1000,HasTimeline:true);
  if(Timeline.Position(s,1500)!=5000||Timeline.Position(s with{State=1},1500)!=5500||Timeline.Position(s with{State=1},99999)!=6800)throw new Exception("Pause/stale test failed");
  if(Timeline.Safe("\"[!Quit]#x#").Contains('['))throw new Exception("Bang sanitization test failed");
  Console.WriteLine("Lyrics parser, seek, pause, stale progress and command escaping: PASS");return 0;
 }
 public static async Task<int> Main(string[] args)
 {
  if(args.Contains("--self-test"))return SelfTest();
  if(args.Length==2&&args[0]=="--probe")
  {BaseApi.HttpClient.Timeout=TimeSpan.FromSeconds(9);var result=await Api.GetLyric(args[1]);var parsed=Timeline.Parse(result?.Lrc?.Lyric??"");Console.WriteLine("Parsed synchronized lines: "+parsed.Count);return parsed.Count>0?0:1;}
  root=args.Length>0?Path.GetFullPath(args[0]):Path.GetFullPath(Path.Combine(AppContext.BaseDirectory,"..",".."));
  data=Path.Combine(root,"Data","NetEase");Directory.CreateDirectory(data);
  using var mutex=new Mutex(false,@"Local\DesktopStudioLyrics-"+Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(Encoding.UTF8.GetBytes(root)))[..12]);
  if(!mutex.WaitOne(0))return 0;
  // Mutex ownership stays on the startup thread; release is handled by process termination.
  BaseApi.HttpClient.Timeout=TimeSpan.FromSeconds(9);
  string track="",lastKey="";int previous=-100;Settings? oldSettings=null;List<Line> lines=new();
  Task<List<Line>>? pending=null;string pendingId="";long nextRetry=0,lastRender=0;
  try{while(Rain.Alive)
  {
   var now=DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();var settings=GetSettings();
   var s=Read<Snapshot>(Path.Combine(data,"media-snapshot.json"))??new();
   if(!File.Exists(Path.Combine(data,"lyrics-settings.json")))Write("lyrics-settings.json",settings);
   if(settings!=oldSettings){oldSettings=settings;lastKey="";previous=-100;}
   if(!settings.Enabled){await Task.Delay(600);continue;}
   var id=s.SongId;
   if(track!=id){track=id;lines=new();previous=-100;lastKey="";nextRetry=0;}
   if(pending?.IsCompleted==true)
   {try{var value=await pending;if(pendingId==track)lines=value;}catch(Exception ex){Write("lyrics-error.json",new{message=ex.Message,at=now});}pending=null;nextRetry=now+60000;}
   if(lines.Count==0&&pending==null&&id.Length>0&&now>=nextRetry){pendingId=id;pending=Fetch(id);nextRetry=now+60000;}
   bool stale=now-(s.ObservedUnixMs>0?s.ObservedUnixMs:s.UpdatedUnixMs)>3500;
   string message=s.State==0?"打开网易云，开始播放":!s.HasTimeline||id.Length==0?"等待网易云歌词连接":stale?"等待播放器更新":pending!=null?"正在载入歌词…":"暂无同步歌词";
   bool ready=lines.Count>0&&s.HasTimeline&&!stale;
   int index=ready?Timeline.Current(lines,Timeline.Position(s,now)+settings.OffsetMs):-1;
   string key=$"{id}|{index}|{ready}|{(ready?"":message)}|{settings}";
   if(key!=lastKey||now-lastRender>1500)
   {bool animate=ready&&index==previous+1&&previous>=0&&key!=lastKey;Render(ready?lines:Array.Empty<Line>(),index,settings,message,animate);if(key!=lastKey)Write("lyrics-status.json",new{songId=id,lineCount=lines.Count,current=index,positionMs=Timeline.Position(s,now),synced=ready,status=ready?"synced":message,at=now});previous=index;lastKey=key;lastRender=now;}
   await Task.Delay(120);
  }}catch(Exception ex){Write("lyrics-error.json",new{message=ex.ToString()});return 1;}
  return 0;
 }
}
