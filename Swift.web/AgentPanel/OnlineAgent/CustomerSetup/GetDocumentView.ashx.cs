using Swift.web.Library;
using System.IO;
using System.Linq;
using System.Web;

namespace Swift.web.AgentPanel.OnlineAgent.CustomerSetup
{
    /// <summary>
    /// Summary description for VerifyDocuments
    /// </summary>
    public class GetDocumentView : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            var imageName = context.Request.QueryString["imageName"];
            var idNumber = context.Request.QueryString["idNumber"];
            var imgPath = GetStatic.GetAppRoot() + @"Images\na.gif";
            var file = GetStatic.GetFilePath() + "CustomerDocument\\" + idNumber + "\\" + imageName;
            string type = imageName.Split('.')[1];
            string[] imageExtensions = { ".jpg", ".tif", ".gif", ".png", ".tiff", ".bmp", ".jpg", ".jpeg" };
            if (File.Exists(file))
            {
                imgPath = file;
            }

            if (imgPath.ToLower().EndsWith(".pdf"))
            {
                context.Response.ContentType = "application/pdf";
            }
            else if (imageExtensions.Contains("." + type))
            {
                context.Response.ContentType = "image/png";
            }

            context.Response.WriteFile(imgPath);
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}