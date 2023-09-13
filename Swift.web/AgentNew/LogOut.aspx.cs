using Swift.DAL.BL.System.UserManagement;
using Swift.web.Library;
using Swift.web.SwiftSystem.UserManagement.ApplicationUserPool;
using System;
using System.Web;

namespace Swift.web.AgentNew
{
    public partial class LogOut : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var applicationUserDao = new ApplicationUserDao();
            applicationUserDao.DoLogOut(GetStatic.GetUser());

            var urlRoot = GetStatic.GetUrlRoot();
            var userPool = UserPool.GetInstance();
            userPool.RemoveUser(GetStatic.GetUser());

            var loginType = GetStatic.ReadCookie("loginType", "DEFAULT");

            Session.Clear();
            Session.Abandon();

            Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(-1));
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetNoServerCaching();

            switch (loginType)
            {
                case "ADMIN":
                    GetStatic.CallBackJs1(Page, "Logout", "Logout('" + urlRoot + "/Admin/Default.aspx');");
                    break;
                //case "AGENT":
                //    GetStatic.CallBackJs1(Page, "Logout", "Logout('" + urlRoot + "/Agent/Default.aspx');");
                //    break;
                default:
                    GetStatic.CallBackJs1(Page, "Logout", "Logout('" + urlRoot + "/SendMoney/Default.aspx');");
                    break;
            }
        }
    }
}