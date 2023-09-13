using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;

namespace Swift.web.Remit
{
    /// <summary>
    /// Summary description for GetImageView
    /// </summary>
    public class GetImageView : IHttpHandler
    {
        /// <summary>
        /// You will need to configure this handler in the Web.config file of your web and register
        /// it with IIS before being able to use it. For more information see the following link: https://go.microsoft.com/?linkid=8101007
        /// </summary>

        #region IHttpHandler Members

        public bool IsReusable
        {
            // Return false in case your Managed Handler cannot be reused for another request.
            // Usually this would be false in case you have some state information preserved per request.
            get { return true; }
        }

        public void ProcessRequest(HttpContext context)
        {
            var imageUrl = context.Request.QueryString["imageUrl"];
            var imgPath = GetStatic.GetAppRoot() + @"Images\na.gif";
            var fullPath = Path.Combine(GetStatic.GetCustomerFilePath(), imageUrl);
            if (File.Exists(fullPath))
            {
                imgPath = fullPath;
            }
            context.Response.ContentType = "image";
            context.Response.WriteFile(imgPath);
            //write your handler implementation here.
        }

        #endregion IHttpHandler Members
    }
}