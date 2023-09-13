using Swift.web.Library;
using System.IO;
using System.Web;

namespace Swift.web.Remit
{
    /// <summary>
    /// Summary description for GetFileView
    /// </summary>
    public class GetFileView : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            var imageName = context.Request.QueryString["imageName"];
            var customerId = context.Request.QueryString["customerId"];
            var dirLocation = imageName.Split('_')[3].ToString() + "\\" + imageName.Split('_')[4].ToString() + "\\" + imageName.Split('_')[5].Split('.')[0].ToString() + "\\";
            var fileType = context.Request.QueryString["fileType"];
            var imgPath = GetStatic.GetAppRoot() + @"\Images\na.gif";
            var file = GetStatic.GetCustomerFilePath() + "CustomerDocument\\" + dirLocation + customerId + "\\" + imageName;
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