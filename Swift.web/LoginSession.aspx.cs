using Swift.DAL.BL.System.UserManagement;
using Swift.web.Library;
using Swift.web.SwiftSystem.UserManagement.ApplicationUserPool;
using System;

namespace Swift.web
{
    public partial class LoginSession : System.Web.UI.Page
    {
        private string callFrom = "";
        private string userName = "";
        private ApplicationUserDao user = new ApplicationUserDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            userName = GetStatic.ReadSession("usr", "");
            //callFrom = GetStatic.ReadSession("call", "");
            mes.InnerHtml = "<b>Your session has already been started.</b><br/>";
            mes.InnerHtml += "You are already being logged on from IP :" + UserPool.GetInstance().GetUser(userName).IPAddress + "";
            btnContinue.Visible = false;
        }

        protected void btnClearSession_Click(object sender, EventArgs e)
        {
            var userPool = UserPool.GetInstance();
            userPool.RemoveUser(user.FilterQuote(userName));
            mes.InnerHtml = "<b>Your session has been cleared successfully.</b>";
            btnContinue.Visible = true;
            btnClearSession.Visible = false;
        }

        protected void btnContinue_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            var url = GetStatic.GetUrlRoot();
            var loginType = GetStatic.ReadCookie("loginType", "");
            switch (loginType.ToUpper())
            {
                case "ADMIN":
                    url += "/Admin";
                    break;

                case "AGENT":
                    url += "/Agent";
                    break;

                case "AGENTINT":
                    url += "/SendMoney";
                    break;
            }
            Response.Redirect(url);
        }
    }
}