using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Web;

namespace Swift.web
{
    public class Global : System.Web.HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
      log4net.Config.XmlConfigurator.Configure();
    }

        protected void Session_Start(object sender, EventArgs e)
        {
        }

        protected void Application_BeginRequest(object sender, EventArgs e)
        {
        }

        protected void Application_AuthenticateRequest(object sender, EventArgs e)
        {
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            //return;
            HttpException err = Server.GetLastError() as HttpException;
            DbResult dr = new DbResult();
            if (err != null)
            {
                var page = HttpContext.Current.Request.Url.ToString();
                dr = GetStatic.LogError(err, page);
            }

            Server.ClearError();
            var url = GetStatic.GetVirtualDirName() + "/Error.aspx";
            //Response.Redirect(url + "?id=" + dr.Id);
            Server.Transfer(url + "?id=" + dr.Id);
        }

        protected void Session_End(object sender, EventArgs e)
        {
        }

        protected void Application_End(object sender, EventArgs e)
        {
        }
    }
}