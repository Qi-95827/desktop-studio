using System;
using System.IO;
using System.Threading;
using Windows.Foundation;
using Windows.Storage.Streams;
public static class MediaThumbnail {
 public static void Save(object value,string path) {
  var stream=(IRandomAccessStream)value;
  try {
   if(stream.Size > 16 * 1024 * 1024) throw new IOException("Media thumbnail is too large.");
   using(var reader=new DataReader(stream.GetInputStreamAt(0))) {
    var operation=reader.LoadAsync((uint)stream.Size);
    var deadline=DateTime.UtcNow.AddSeconds(10);
    while(operation.Status==AsyncStatus.Started) {if(DateTime.UtcNow>deadline){operation.Cancel();throw new IOException("Media thumbnail read timed out.");}Thread.Sleep(10);}
    var count=operation.GetResults();
    var bytes=new byte[count];reader.ReadBytes(bytes);File.WriteAllBytes(path,bytes);
   }
  } finally {stream.Dispose();}
 }
}
