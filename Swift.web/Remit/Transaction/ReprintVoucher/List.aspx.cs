using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Net;
using System.Web.UI;
using System.Windows.Forms;
using SelectPdf;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.ReprintVoucher {
  public partial class List : Page {
    private const string ViewFunctionId = "20121100";
    private readonly ReceiptDao _obj = new ReceiptDao();
    private readonly SwiftLibrary _sl = new SwiftLibrary();

    protected void Page_Load(object sender, EventArgs e) {
      Authenticate();
      //ToImage("SMN14298858", "");
    }

    //private void ToImage(string controlNo, string email) {
    //  // read parameters from the webpage
    //  string url = "http://localhost:55555/Remit/Transaction/ReprintVoucher/SendIntlReceipt.aspx?controlNo="+ controlNo + "&flg=0";
    //  string fileNameWitPath = "receipt" + "-" + DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss").Replace("/", "").Replace(" ", "").Replace(":", "") + ".png";
    //  string path = @"D:\downloads\" + fileNameWitPath;

    //  ImageFormat imageFormat = ImageFormat.Png;
    //  int webPageWidth = 1024;
    //  int webPageHeight = 0;
    //  HtmlToImage imgConverter = new HtmlToImage();
    //  imgConverter.WebPageWidth = webPageWidth;
    //  imgConverter.WebPageHeight = webPageHeight;
    //  Image image = imgConverter.ConvertUrl(url);
    //  //image.Save(Response.OutputStream, imageFormat);
    //  //image.Save(path, imageFormat);
      
      
    //  string stampImg = @"D:\downloads\SanhuuTamga.png";

    //  Image bitmap = (System.Drawing.Image)image;
    //  Image bitmaps = (System.Drawing.Image)Bitmap.FromFile(stampImg);
    //  Image btmp = new Bitmap(bitmap.Width, bitmap.Height);

    //  using (Graphics gr = Graphics.FromImage(btmp)) {
    //    gr.DrawImage(bitmap, new Point(0, 0));
    //    gr.DrawImage(bitmaps, 800, 350, 180, 90);
    //  }
    //  bitmap.Dispose();
    //  image.Dispose();
    //  if (File.Exists(fileNameWitPath)) {
    //    File.Delete(fileNameWitPath);
    //  }

    //  //btmp.Save(path, ImageFormat.Png);
    //  var stream = new MemoryStream();
    //  btmp.Save(stream, imageFormat);
    //  stream.Position = 0;
    //  SendEmail("MyReceipt", "Attached", "mdsuka@gmail.com", stream);
    //}

    //private void SendEmail(string msgSubject, string msgBody, string toEmailId, MemoryStream ms) {
    //  SmtpMailSetting mail = new SmtpMailSetting {
    //    MsgBody = msgBody,
    //    MsgSubject = msgSubject,
    //    ToEmails = toEmailId,
    //  };
    //  mail.SendSmtpMailSimple(mail, ms);
    //}

    private void Authenticate() {
      _sl.CheckAuthentication(ViewFunctionId);
    }
  }
}