using System;
using System.IO;

namespace Swift.web.AgentNew
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
        }

        protected void uploadImage_Click(object sender, EventArgs e)
        {
            string url = hddImgURL.Value;
            string s = url;
            UploadImage(url);
        }

        public void UploadImage(string imageData)
        {
            string fileNameWitPath = @"E:\DownloadedImageFromUrl\" + DateTime.Now.ToString().Replace("/", "-").Replace(" ", "- ").Replace(":", "") + ".png";
            using (FileStream fs = new FileStream(fileNameWitPath, FileMode.Create))
            {
                using (BinaryWriter bw = new BinaryWriter(fs))
                {
                    byte[] data = Convert.FromBase64String(imageData);
                    bw.Write(data);
                    bw.Close();
                }
            }
        }
    }
}