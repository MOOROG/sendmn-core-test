using Swift.web.Library;
using System.IO;
using System.Web;

namespace Swift.web.Remit.Administration.OnlineCustomer
{
    /// <summary>
    /// Summary description for VerifyDocuments
    /// </summary>
    public class GetDocumentView : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            var imageName = context.Request.QueryString["imageName"];
            var customerId = context.Request.QueryString["customerId"];
            var fileType = context.Request.QueryString["fileType"];
            var imgPath = GetStatic.GetAppRoot() + @"\Images\na.gif";
            var file = GetStatic.GetFilePath() + "CustomerDocument\\" + customerId + "\\" + imageName;
            bool a = fileType.Contains("image");
            if (File.Exists(file) && a)
            {
                imgPath = file;
                context.Response.ContentType = fileType;
            }
            else
            {
                context.Response.ContentType = fileType;
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