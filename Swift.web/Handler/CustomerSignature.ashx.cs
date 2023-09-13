using Swift.web.Library;
using System;
using System.IO;
using System.Web;

namespace Swift.web.Handler
{
    /// <summary>
    /// Summary description for CustomerSignature
    /// </summary>
    public class CustomerSignature : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            var registerDate = context.Request.QueryString["registerDate"];
            var customerId = context.Request.QueryString["customerId"];
            var membershipNo = context.Request.QueryString["membershipNo"];
            DateTime txnDate = Convert.ToDateTime(registerDate);
            string fileUrl = GetStatic.GetCustomerFilePath() + "CustomerDocument\\" + registerDate.Replace("-", "\\") + "\\" + membershipNo + "\\" + customerId + "_signature.png";
            if (File.Exists(fileUrl))
            {
                context.Response.ContentType = fileUrl;
            }
            else
            {
                context.Response.ContentType = GetStatic.ReadWebConfig("root", "") + "Images\\na.gif";
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