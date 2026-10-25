using System;
using System.IO;
using System.Text;
using System.Linq;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Markup;
using System.Windows.Threading;
using System.Runtime.InteropServices;
using System.Xml;
using System.Collections.Generic;
using System.Web.Script.Serialization;

namespace DesktopStudio {
 public class Program {
  public static readonly string Root=Path.GetFullPath(Path.Combine(AppDomain.CurrentDomain.BaseDirectory,".."));
  public static string PathSetting(string name,string fallback="") {var path=Path.Combine(Root,"config.json");if(!File.Exists(path))path=Path.Combine(Root,"config.example.json");if(!File.Exists(path))return fallback;var data=new JavaScriptSerializer().Deserialize<Dictionary<string,object>>(File.ReadAllText(path));object value;return data.TryGetValue(name,out value)&&!String.IsNullOrWhiteSpace(Convert.ToString(value))?Convert.ToString(value):fallback;}
  public static string Seelen {get{return PathSetting("SeelenExe",@"D:\Program Files (x86)\Seelen UI\seelen-ui.exe");}}
  public static string Slu {get{return Path.Combine(Path.GetDirectoryName(Seelen),"slu.exe");}}
  public static string NetEase {get{return PathSetting("NetEaseExe");}}
  public static string Wallpaper {get{return PathSetting("WallpaperEngineExe");}}
  public static string Rain {get{return PathSetting("RainmeterExe",Path.Combine(Root,@"runtime\Rainmeter\Rainmeter.exe"));}}
  public static string Script {get{return Path.Combine(Root,@"scripts\Desktop-Profile.ps1");}}
  public static void Shell(string path,string args="") {Process.Start(new ProcessStartInfo(path,args){UseShellExecute=true});}
  public static Process Profile(string action) {return Process.Start(new ProcessStartInfo("powershell.exe","-NoProfile -WindowStyle Hidden -STA -File \""+Script+"\" -Action "+action){UseShellExecute=false,CreateNoWindow=true,WindowStyle=ProcessWindowStyle.Hidden});}
  [STAThread] public static void Main(string[] args) {
   if(args.Contains("--startup")) {var f=Path.Combine(Root,@"Data\desktop-mode.txt");var mode=File.Exists(f)?File.ReadAllText(f).Trim():"windows";Profile(mode=="apple"?"Apply":"Restore");return;}
   bool created;using(var mutex=new Mutex(true,@"Local\DesktopStudioWindow",out created)) {
    if(!created){foreach(var p in Process.GetProcessesByName("DesktopStudio")){if(p.Id!=Process.GetCurrentProcess().Id&&p.MainWindowHandle!=IntPtr.Zero){ShowWindow(p.MainWindowHandle,9);SetForegroundWindow(p.MainWindowHandle);break;}}return;}
    var app=new Application();app.DispatcherUnhandledException+=(s,e)=>{MessageBox.Show(e.Exception.Message,"桌面工作台");e.Handled=true;};app.Run(new MainWindow());
   }
  }
  [DllImport("user32.dll")]static extern bool ShowWindow(IntPtr h,int command);
  [DllImport("user32.dll")]static extern bool SetForegroundWindow(IntPtr h);
 }
 public class MainWindow:Window {
  StackPanel content; TextBlock status,toast;string page="home";DispatcherTimer timer;bool busy;
  static Brush B(string c){return (Brush)new BrushConverter().ConvertFromString(c);}
  public MainWindow() {
   Title="桌面工作台";Width=1000;Height=740;MinWidth=850;MinHeight=650;WindowStartupLocation=WindowStartupLocation.CenterScreen;Background=B("#F4F6FA");FontFamily=new FontFamily("Microsoft YaHei UI");FontSize=13;
   var icon=Path.Combine(AppDomain.CurrentDomain.BaseDirectory,"DesktopStudio.ico");if(File.Exists(icon))Icon=new System.Windows.Media.Imaging.BitmapImage(new Uri(icon));
   const string xaml=@"<Grid xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation' xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'>
<Grid.Resources>
 <Style TargetType='Button'><Setter Property='Cursor' Value='Hand'/><Setter Property='Padding' Value='16,11'/><Setter Property='BorderThickness' Value='0'/><Setter Property='Background' Value='#E9EDF5'/><Setter Property='Foreground' Value='#293449'/><Setter Property='FontSize' Value='13'/><Setter Property='Template'><Setter.Value><ControlTemplate TargetType='Button'><Border x:Name='chrome' Background='{TemplateBinding Background}' CornerRadius='10' Padding='{TemplateBinding Padding}'><ContentPresenter HorizontalAlignment='Center' VerticalAlignment='Center'/></Border><ControlTemplate.Triggers><Trigger Property='IsMouseOver' Value='True'><Setter TargetName='chrome' Property='Opacity' Value='.78'/></Trigger><Trigger Property='IsEnabled' Value='False'><Setter TargetName='chrome' Property='Opacity' Value='.45'/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter></Style>
</Grid.Resources>
<Grid.ColumnDefinitions><ColumnDefinition Width='210'/><ColumnDefinition Width='*'/></Grid.ColumnDefinitions>
<Border Background='#EAF0F8' Padding='22,28'><DockPanel><StackPanel DockPanel.Dock='Top'>
 <Border Width='48' Height='48' Background='#3679F5' CornerRadius='14' HorizontalAlignment='Left'><TextBlock Text='▦' Foreground='White' FontSize='32' HorizontalAlignment='Center' VerticalAlignment='Center'/></Border>
 <TextBlock Text='桌面工作台' FontSize='21' FontWeight='SemiBold' Margin='0,14,0,3'/><TextBlock Text='DESKTOP STUDIO' Foreground='#78859A' FontSize='10' Margin='0,0,0,30'/>
 <Button x:Name='Home' Content='桌面总览' Margin='0,0,0,8'/><Button x:Name='Widgets' Content='小组件' Margin='0,0,0,8'/><Button x:Name='Tools' Content='工具与项目' Margin='0,0,0,8'/><Button x:Name='Files' Content='分类与备份' Margin='0,0,0,8'/>
 </StackPanel><StackPanel VerticalAlignment='Bottom'><TextBlock Text='你的桌面，由你决定。' Foreground='#7A8799' FontSize='11' Margin='0,30,0,8'/><TextBlock Text='本地运行 · 独立配置与备份' Foreground='#8994A5' FontSize='10' TextWrapping='Wrap'/></StackPanel></DockPanel></Border>
<Grid Grid.Column='1' Margin='30,26,30,20'><Grid.RowDefinitions><RowDefinition Height='Auto'/><RowDefinition Height='*'/><RowDefinition Height='Auto'/></Grid.RowDefinitions>
 <DockPanel><TextBlock x:Name='Heading' Text='桌面总览' FontSize='25' FontWeight='SemiBold'/><Border Background='#E1E9F5' CornerRadius='12' Padding='12,6' HorizontalAlignment='Right'><TextBlock x:Name='Status' Text='读取状态…' FontSize='11' Foreground='#4D607A'/></Border></DockPanel>
 <ScrollViewer Grid.Row='1' VerticalScrollBarVisibility='Auto' Margin='0,20,0,12'><StackPanel x:Name='Content'/></ScrollViewer>
 <TextBlock x:Name='Toast' Grid.Row='2' Text='关闭工作台不会关闭正在运行的桌面和小组件。' Foreground='#7B8698' FontSize='11' TextWrapping='Wrap'/>
</Grid></Grid>";
   var grid=(Grid)XamlReader.Parse(xaml);Content=grid;content=(StackPanel)grid.FindName("Content");status=(TextBlock)grid.FindName("Status");toast=(TextBlock)grid.FindName("Toast");
   ((Button)grid.FindName("Home")).Click+=(s,e)=>Render("home");((Button)grid.FindName("Widgets")).Click+=(s,e)=>Render("widgets");((Button)grid.FindName("Tools")).Click+=(s,e)=>Render("tools");((Button)grid.FindName("Files")).Click+=(s,e)=>Render("files");
   timer=new DispatcherTimer{Interval=TimeSpan.FromSeconds(3)};timer.Tick+=(s,e)=>RefreshStatus();timer.Start();Render("home");
  }
  bool Running(string name){return Process.GetProcessesByName(name).Length>0;}
  void RefreshStatus(){status.Text=Running("seelen-ui")?"苹果风桌面 · 运行中":(Running("Rainmeter")?"Windows 桌面 · 组件运行中":"Windows 原生桌面");}
  TextBlock Text(string value,double size=13,string color="#273449"){return new TextBlock{Text=value,FontSize=size,Foreground=B(color),TextWrapping=TextWrapping.Wrap,Margin=new Thickness(0,0,0,8)};}
  Button Btn(string title,Action action,bool primary=false){var b=new Button{Content=title,Margin=new Thickness(0,6,8,0),HorizontalAlignment=HorizontalAlignment.Left};if(primary){b.Background=B("#3679F5");b.Foreground=Brushes.White;}b.Click+=(s,e)=>{try{action();}catch(Exception ex){toast.Text="未完成："+ex.Message;}};return b;}
  Border Card(string title,string desc,UIElement controls=null){var p=new StackPanel();var t=Text(title,16);t.FontWeight=FontWeights.SemiBold;p.Children.Add(t);p.Children.Add(Text(desc,12,"#758197"));if(controls!=null)p.Children.Add(controls);return new Border{Background=Brushes.White,CornerRadius=new CornerRadius(16),Padding=new Thickness(20),Margin=new Thickness(0,0,0,14),Child=p,BorderBrush=B("#E4E9F1"),BorderThickness=new Thickness(1)};}
  WrapPanel Row(params UIElement[] els){var p=new WrapPanel();foreach(var e in els)p.Children.Add(e);return p;}
  async void RunProfile(string action,string title){if(busy){toast.Text="正在完成上一项操作，请稍候。";return;}busy=true;toast.Text=title+"…";try{var p=Program.Profile(action);await Task.Run(()=>p.WaitForExit());toast.Text=p.ExitCode==0?title+"完成":"操作没有完整完成，请检查对应工具是否已启动。";RefreshStatus();}catch(Exception e){toast.Text=e.Message;}finally{busy=false;}}
  void Tool(string path,string args=""){if(!path.StartsWith("http")&&!File.Exists(path)&&!Directory.Exists(path))throw new FileNotFoundException("没有找到这个工具",path);Program.Shell(path,args);toast.Text="已打开。";}
  void Bang(string command){if(!Running("Rainmeter")){var startup=Program.Profile("WidgetsOn");if(!startup.WaitForExit(10000)||startup.ExitCode!=0)throw new InvalidOperationException("组件启动未完成，请先运行安装并检查路径配置。");}Program.Shell(Program.Rain,command);}
  void ToggleWidget(string name,string file){var ini=Path.Combine(Path.GetDirectoryName(Program.Rain),"Rainmeter.ini");var section="Monterey\\Widgets\\"+name;var raw=File.Exists(ini)?File.ReadAllText(ini):"";var match=System.Text.RegularExpressions.Regex.Match(raw,@"\["+System.Text.RegularExpressions.Regex.Escape(section)+@"\][\s\S]*?(?=\n\[|$)");bool enabled=Running("Rainmeter")&&System.Text.RegularExpressions.Regex.IsMatch(match.Value,@"Active=[1-9]");Bang(enabled?"!DeactivateConfig \""+section+"\"":"!ActivateConfig \""+section+"\" \""+file+"\"");toast.Text=(enabled?"已隐藏":"已显示")+name+"组件。";}
  void Render(string name){page=name;content.Children.Clear();((TextBlock)((Grid)Content).FindName("Heading")).Text=name=="home"?"桌面总览":name=="widgets"?"小组件":name=="tools"?"工具与项目":"分类与备份";RefreshStatus();
   if(name=="home"){
    content.Children.Add(Text("留一点空白，把常用的放在手边。",15,"#7A879B"));
    content.Children.Add(Card("一键切换桌面","沿用你的壁纸、八个应用分类与圆角 Dock。",Row(Btn("启动苹果风桌面",()=>RunProfile("Apply","启动苹果风桌面"),true),Btn("恢复 Windows",()=>RunProfile("Restore","恢复 Windows 桌面")))));
    content.Children.Add(Card("常用入口","设置、组件和播放器，集中在这里。",Row(Btn("Seelen UI 设置",()=>Tool(Program.Slu,"settings")),Btn("小组件管理",()=>Tool(Program.Rain,"!Manage")),Btn("更换壁纸",()=>Tool(Program.Wallpaper,"-showui")),Btn("网易云音乐",()=>Tool(Program.NetEase)))));
    content.Children.Add(Card("推荐的小组件布局","上海天气 + 月历在左上，音乐卡片在下方；便签按需打开。",Row(Btn("显示推荐布局",()=>RunProfile("ResetLayout","恢复组件布局")),Btn("全部收起",()=>RunProfile("WidgetsOff","收起小组件")),Btn("预览桌面",ShowDesktop))));
   }else if(name=="widgets"){
    content.Children.Add(Text("只显示你需要的，可以直接在桌面拖动位置。",13,"#7A879B"));
    content.Children.Add(Card("上海天气","实时温度与天气状况 · Open-Meteo",Row(Btn("显示 / 隐藏",()=>ToggleWidget("Weather","Medium.ini")),Btn("天气设置",()=>Bang("!ActivateConfig \"Monterey\\Widgets\\Weather\" \"Settings.ini\"")))));
    content.Children.Add(Card("月历","中文星期，一眼看到本月安排。",Btn("显示 / 隐藏",()=>ToggleWidget("Calendar","Medium.ini"))));
    content.Children.Add(Card("网易云音乐卡片","实时歌名、歌手、封面，以及播放 / 暂停和切歌。",Row(Btn("显示 / 隐藏",()=>ToggleWidget("Music","Wide.ini")),Btn("打开网易云",()=>Tool(Program.NetEase)))));
    content.Children.Add(Card("随手记","便签内容保存在本机。",Row(Btn("显示 / 隐藏",()=>ToggleWidget("Notes","Medium.ini")),Btn("编辑便签",EditNotes))));
    content.Children.Add(Row(Btn("重置推荐布局",()=>RunProfile("ResetLayout","恢复组件布局")),Btn("Rainmeter 管理器",()=>Tool(Program.Rain,"!Manage"))));
   }else if(name=="tools"){
    content.Children.Add(Text("已采用的工具保留各自的设置，工作台负责统一入口。",13,"#7A879B"));
    Project("Seelen UI","Dock、顶部状态栏与分类启动面板。",()=>Tool(Program.Slu,"settings"),"https://github.com/eythaann/Seelen-UI");
    Project("Rainmeter","便携版小组件运行器，程序和皮肤保存在整合包目录。",()=>Tool(Program.Rain,"!Manage"),"https://github.com/rainmeter/rainmeter");
    Project("Monterey","苹果风格的天气、日历、音乐和便签组件。",()=>Bang("!ActivateConfig \"Monterey\" \"Settings.ini\""),"https://github.com/creewick/MontereyRainmeter");
    Project("媒体接口与网易云适配","Monterey 附带 MediaPlayer；音乐卡片使用专用 SMTC 桥接，固定连接网易云。",()=>MessageBox.Show("网易云设置 → 系统 → 开启 SMTC。\n专用桥接只读取和控制 cloudmusic.exe 的媒体会话，不会修改网易云安装文件。\n桥接随小组件启动，收起组件后自动退出。","网易云适配"),"https://github.com/i2002/RainmeterMediaPlayer");
    content.Children.Add(Card("Wallpaper Engine","继续使用你原有的动态壁纸。",Btn("打开壁纸选择器",()=>Tool(Program.Wallpaper,"-showui"))));
   }else{
    content.Children.Add(Card("八个应用分类","复制快捷方式到分类文件夹后，点击同步。原文件保留在原位置。",Row(Btn("打开分类面板",()=>Tool(Program.Slu,"widget trigger @seelen/apps-menu")),Btn("查看快捷方式文件夹",()=>Tool(Path.Combine(Program.Root,"Collections"))),Btn("同步快捷方式",()=>RunProfile("SyncShortcuts","同步快捷方式")))));
    content.Children.Add(Card("备份配置","保存 Dock、主题、分类以及组件设置，方便日后恢复。",Row(Btn("备份当前配置",()=>RunProfile("Backup","备份配置"),true),Btn("打开备份目录",()=>Tool(Path.Combine(Program.Root,"Backups"))))));
    content.Children.Add(Card("本地文件","安装包、配置与脚本集中保存在整合包目录。",Row(Btn("打开工作目录",()=>Tool(Program.Root)),Btn("查看使用说明",()=>Tool(Path.Combine(Program.Root,"README.md"))),Btn("编辑工具路径",()=>Program.Shell("notepad.exe","\""+Path.Combine(Program.Root,"config.json")+"\"")))));
   }
  }
  void Project(string title,string desc,Action settings,string url){content.Children.Add(Card(title,desc,Row(Btn("打开 / 设置",settings),Btn("GitHub 项目",()=>Program.Shell(url)))));}
  void EditNotes(){var p=Path.Combine(Path.GetDirectoryName(Program.Rain),@"Skins\Monterey\@Resources\Variables\Notes.inc");var raw=File.ReadAllText(p);var m=System.Text.RegularExpressions.Regex.Match(raw,@"(?m)^Content=(.*)$");var text=new TextBox{Text=m.Groups[1].Value.TrimEnd('\r').Replace(@"[\13][\10]",Environment.NewLine),AcceptsReturn=true,TextWrapping=TextWrapping.Wrap,VerticalScrollBarVisibility=ScrollBarVisibility.Auto,Margin=new Thickness(20),FontSize=15};var win=new Window{Title="随手记",Width=480,Height=370,Owner=this,WindowStartupLocation=WindowStartupLocation.CenterOwner,Background=B("#F4F6FA")};var panel=new DockPanel();var save=Btn("保存便签",()=>{var v=text.Text.Replace("\r\n",@"[\13][\10]").Replace("\n",@"[\13][\10]");var updated=System.Text.RegularExpressions.Regex.Replace(raw,@"(?m)^Content=.*$",_=>"Content="+v);File.WriteAllText(p,updated,Encoding.Unicode);Bang("!Refresh \"Monterey\\Widgets\\Notes\"");win.Close();});save.Margin=new Thickness(20,0,20,20);DockPanel.SetDock(save,Dock.Bottom);panel.Children.Add(save);panel.Children.Add(text);win.Content=panel;win.ShowDialog();}
  void ShowDesktop(){Type t=Type.GetTypeFromProgID("Shell.Application");dynamic shell=Activator.CreateInstance(t);shell.MinimizeAll();}
 }
}
