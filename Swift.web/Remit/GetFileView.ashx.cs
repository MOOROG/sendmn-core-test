using Swift.web.Library;
using System.IO;
using System.Web;

namespace Swift.web.AgentPanel.OnlineAgent.CustomerSetup
{
    /// <summary>
    /// Summary description for GetFileView
    /// </summary>
    public class GetFileView : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            var imageName = context.Request.QueryString["fileName"];
            var imgNF = GetStatic.GetAppRoot() + @"Images\na.gif";
            if (imageName == "" || imageName == null)
            {
                context.Response.WriteFile(imgNF);
            }
            else
            {
                var registerDate = context.Request.QueryString["registerDate"];
                var membershipNo = context.Request.QueryString["membershipNo"];
                var fileName = context.Request.QueryString["fileName"];
                var imgPath = Path.Combine(GetStatic.GetCustomerFilePath(), "CustomerDocument", registerDate.Replace("-", "\\"), membershipNo, fileName);

                if (File.Exists(imgPath))
                {
                    context.Response.ContentType = imgPath;
                }
                else
                {
                    context.Response.ContentType = imgNF;
                }
            }
            context.Response.WriteFile(context.Response.ContentType);
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