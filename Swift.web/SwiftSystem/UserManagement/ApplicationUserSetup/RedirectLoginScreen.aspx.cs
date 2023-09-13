using System;
using System.Web.UI;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Library;
using Swift.web.SwiftSystem.UserManagement.ApplicationUserPool;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationUserSetup
{
    public partial class RedirectLoginScreen : Page
    {
        ApplicationUserDao user = new ApplicationUserDao();
        private SwiftLibrary sl = new SwiftLibrary();
        UserPool userPool = UserPool.GetInstance();       


        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CheckUserLogin();
            }
        }

        private string GetUserName()
        {
            return GetStatic.ReadQueryString("userName", "");
        }

        private void CheckUserLogin()
        {
            LoginAuthentication();
        }

        private void LoginAuthentication()
        {
            GetStatic.WriteCookie("loginType", "AGENT");
            var dr = user.CheckUserForLoginScreen(GetUserName());
            if(dr.ErrorCode != "0")
            {
                GetStatic.ShowErrorMessage(dr.Msg);
                return;
            }
            var dbResult = ManageUserSession(dr);
            Response.Redirect("Redirect.aspx");
        }

        private DbResult ManageUserSession(UserDetails ud)
        {
            Session.Clear();
            var res = SetUserPool(ud);
            if (res.ErrorCode != "0")
                return res;

            GetStatic.WriteSession("admin", ud.UserId);
            GetStatic.WriteSession("fullname", ud.FullName);
            GetStatic.WriteSession("branch", ud.Branch);
            GetStatic.WriteSession("branchName", ud.BranchName);
            var cookieKey = ud.UserId + "_userSessionId";
            GetStatic.WriteCookie(cookieKey, GetStatic.GetSessionId());
            return res;
        }

        private DbResult SetUserPool(UserDetails ud)
        {
            System.Web.HttpBrowserCapabilities browser = Request.Browser;
            var usr = new LoggedInUser();

            usr.UserId = GetStatic.ParseInt(ud.UserId);
            usr.UserName = ud.UserId;
            usr.UserFullName = ud.FullName;
            usr.LoginTime = DateTime.Now;
            usr.UserAccessLevel = "M";
            usr.SessionTimeOutPeriod = GetStatic.ParseInt(ud.sessionTimeOut);
            usr.LastLoginTime = Convert.ToDateTime(ud.LastLoginTs);

            usr.Browser = browser.Browser + "/" + browser.Type;
            usr.IPAddress = GetStatic.GetLoggedInUser().IPAddress;
            usr.SessionID = GetStatic.GetSessionId();
            usr.LastActiveTime = usr.LoginTime;
            return userPool.MutipleRemoteLogin(usr);
        }
    }

}