using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using Swift.web.SwiftSystem.UserManagement.ApplicationUserPool;
using System;
using System.Web;

namespace Swift.web.Agent
{
    public partial class Default : System.Web.UI.Page
    {
        private ApplicationUserDao user = new ApplicationUserDao();
        private UserPool userPool = UserPool.GetInstance();

        protected void Page_Load(object sender, EventArgs e)
        {
            //var usr = Server.HtmlEncode(User.Identity.Name);
            //Response.Write(usr);
            //username.Attributes.Add("onkeypress", "ClearMessage()");
            //pwd.Attributes.Add("onkeypress", "isCapslock((event?event:evt))");
            // employeeId.Attributes.Add("onkeypress", "ClearMessage()");
            //   agentCode.Attributes.Add("onkeypress", "ClearMessage()");

            if (!IsPostBack)
            {
                agentCode.Focus();
                var userPool = UserPool.GetInstance();
                userPool.RemoveUser(GetStatic.GetUser());

                Session.Clear();
                Session.Abandon();

                //ValidateDc();
                //ValidateIPAddress();
            }
        }

        private void ValidateDc()
        {
            var ipAddress = Request.ServerVariables["REMOTE_ADDR"];
            var dcIdNo = Request.ClientCertificate["SERIALNUMBER"];
            var dcUserName = Request.ClientCertificate["SUBJECTCN"];
            var res = user.ValidateDcId(dcIdNo, dcUserName, ipAddress);
            if (res.ErrorCode != "0")
            {
                Response.Redirect(GetStatic.GetUrlRoot() + "/SiteDown/");
            }
        }

        private void ValidateIPAddress()
        {
            var ipAddress = Request.ServerVariables["REMOTE_ADDR"];
            System.Web.HttpBrowserCapabilities browser = Request.Browser;
            var result = user.GetIpStatus(ipAddress, browser.Platform);

            if (result.ErrorCode == "1")
            {
                //LoginBox.Visible = false;
                //sslRow.Visible = false;
                errMsg.InnerHtml = result.Msg;
                var mailBody = "<div style=\"font-size:24px; font-weight:bold\"> Suspicious Access From Outside Nepal </div><br />";
                mailBody += "<div style=\"background-color:#F00; font-size:18px; font-weight:bold; width:300px;\">IP: " + ipAddress + "</div><br />";
                mailBody += "<div style=\"font-size:18px; font-weight:bold; width:300px;\"> System Info </div>";
                var info = GetUserInfo(true);
                info = info.Replace("-:::-", "<br />");
                mailBody += info;
                var email = "";
                //GetStatic.SendEmail(ref email, "", "", "", "Fraud Analysis", mailBody, "", "0");
            }

            if (result.Id.Replace(ipAddress + ",", "") == "Y")
            {
                Response.Redirect(GetStatic.GetUrlRoot() + "/SiteDown/");
            }
        }

        private void EnableLogin()
        {
            btnLogin.Enabled = true;
        }

        private void DisableLogin()
        {
            btnLogin.Enabled = false;
        }

        private void Authenticate()
        {
            DisableLogin();
            GetStatic.WriteCookie("loginType", "AGENT");
            var ipAddress = Request.ServerVariables["remote_addr"];
            var dcIdNo = Request.ClientCertificate["SERIALNUMBER"];
            var dcUserName = Request.ClientCertificate["SUBJECTCN"];
            var dr = user.DoLoginForAgent(username.Text, pwd.Text, agentCode.Text, employeeId.Text, GetUserInfo(), ipAddress, dcIdNo, dcUserName);

            //Check Authentication From DB
            if (dr.ErrorCode != "0")
            {
                if (dr.ErrorCode == "2")
                {
                    var dbr = ManageLoginAttempts(dr.Id, dr.AttemptCount);
                    if (dbr.ErrorCode != "-13")
                        dr.Msg = dbr.Msg;
                }

                errMsg.InnerHtml = " <br /><br /> " + dr.Msg;
                errMsg.Visible = true;
                EnableLogin();
                return;
            }

            var usrName = user.FilterQuote(username.Text);
            if (dr.UserAccessLevel.ToUpper() == "S")
            {
                if (userPool.IsUserExists(usrName))
                {
                    //Session.Add("call", "admin");
                    Session.Add("usr", usrName);
                    var url = GetStatic.GetUrlRoot() + "/LoginSession.aspx";
                    Response.Redirect(url);
                    return;
                }
            }
            //Check User Pool
            var dbResult = ManageUserSession(dr);
            if (dbResult.ErrorCode != "0")
            {
                errMsg.InnerHtml = "<br/><br/>" + dbResult.Msg;
                //mes.ForeColor = System.Drawing.Color.Red;
                EnableLogin();
                return;
            }

            if (dr.isForcePwdChanged.ToUpper() == "Y")
            {
                Response.Redirect("../SwiftSystem/UserManagement/AgentUserSetup/ChangePassword.aspx");
            }

            Response.Redirect("Dashboard2.aspx");
        }

        private DbResult ManageUserSession(UserDetails ud)
        {
            Session.Clear();
            var res = SetUserPool(ud);
            if (res.ErrorCode != "0")
                return res;

            GetStatic.WriteSession("admin", ud.Id);
            GetStatic.WriteSession("fullname", ud.FullName);
            GetStatic.WriteCookie("loginType", "AGENT");
            //GetStatic.WriteSession("branchId", ud.Branch);
            //GetStatic.WriteSession("branchName", ud.BranchName);
            //GetStatic.WriteSession("address", ud.Address);
            //GetStatic.WriteSession("userType", ud.UserType);

            var cookieKey = ud.Id + "_userSessionId";
            GetStatic.WriteCookie(cookieKey, GetStatic.GetSessionId());
            return res;
        }

        private DbResult SetUserPool(UserDetails ud)
        {
            GetStatic.WriteSession("branch", ud.Branch);
            GetStatic.WriteSession("branchName", ud.BranchName);
            GetStatic.WriteSession("agent", ud.Agent);
            GetStatic.WriteSession("agentName", ud.AgentName);
            GetStatic.WriteSession("superAgent", ud.SuperAgent);
            GetStatic.WriteSession("superAgentName", ud.SuperAgentName);
            GetStatic.WriteSession("settlingAgent", ud.SettlingAgent);
            GetStatic.WriteSession("mapCodeInt", ud.MapCodeInt);
            GetStatic.WriteSession("parentMapCodeInt", ud.ParentMapCodeInt);
            GetStatic.WriteSession("mapCodeDom", ud.MapCodeDom);
            GetStatic.WriteSession("agentType", ud.AgentType);
            GetStatic.WriteSession("isActAsBranch", ud.IsActAsBranch);
            GetStatic.WriteSession("fromSendTrnTime", ud.FromSendTrnTime);
            GetStatic.WriteSession("toSendTrnTime", ud.ToSendTrnTime);
            GetStatic.WriteSession("fromPayTrnTime", ud.FromPayTrnTime);
            GetStatic.WriteSession("toPayTrnTime", ud.ToPayTrnTime);
            GetStatic.WriteSession("country", ud.Country);
            GetStatic.WriteSession("countryId", ud.CountryId);
            GetStatic.WriteSession("userType", ud.UserType);
            GetStatic.WriteSession("isHeadOffice", ud.IsHeadOffice);
            GetStatic.WriteSession("newBranchId", ud.newBranchId);
            GetStatic.WriteSession("agentLocation", ud.AgentLocation);
            GetStatic.WriteSession("agentGrp", ud.AgentGrp);
            GetStatic.WriteSession("agentEmail", ud.AgentEmail);
            GetStatic.WriteSession("agentPhone", ud.AgentPhone);
            GetStatic.WriteSession("user", ud.Id);
            GetStatic.WriteSession("agentType", "send");
            HttpBrowserCapabilities browser = Request.Browser;
            var usr = new LoggedInUser();

            usr.UserId = GetStatic.ParseInt(ud.UserId);
            usr.UserName = ud.Id;
            usr.UserFullName = ud.FullName;
            usr.LoginTime = DateTime.Now;
            usr.UserAccessLevel = ud.UserAccessLevel;
            usr.UserAgentName = ud.BranchName;
            usr.SessionTimeOutPeriod = GetStatic.ParseInt(ud.sessionTimeOut);
            usr.LastLoginTime = Convert.ToDateTime(ud.LastLoginTs);

            usr.Browser = browser.Browser + "/" + browser.Type;
            usr.IPAddress = Request.ServerVariables["remote_addr"];
            usr.SessionID = GetStatic.GetSessionId();
            usr.DcInfo = Request.ClientCertificate["SERIALNUMBER"] + ":" + Request.ClientCertificate["SUBJECTCN"];

            return userPool.AddUser(usr);
        }

        private DbResult ManageLoginAttempts(string id, int attemptCount)
        {
            var countLoginAttemptsInt = GetStatic.ParseInt(GetStatic.ReadSession(id, "0"));
            countLoginAttemptsInt++;
            GetStatic.WriteSession(id, (countLoginAttemptsInt).ToString());
            var dbResult = new DbResult();
            dbResult.SetError("-13", "", "");
            if (countLoginAttemptsInt >= attemptCount)
            {
                var lockReason = "Your account has been locked to due to continuous invalid login attempt.";
                dbResult = user.DoLockAccount(id, lockReason);
                GetStatic.WriteSession(id, "0");
                dbResult.SetError("2", lockReason, "");
                //dbResult.ErrorCode = "2";
            }
            return dbResult;
        }

        private string GetUserInfo()
        {
            return "";// "IP Adress  = " + Request.ServerVariables["REMOTE_ADDR"];
        }

        private string GetUserInfo(bool fullInfo)
        {
            System.Web.HttpBrowserCapabilities browser = Request.Browser;

            string str = " Browser Capabilities = Values -:::-"
                + "Type = " + browser.Type + "-:::-" //-:::-
                + "Name = " + browser.Browser + "-:::-"
                + "Version = " + browser.Version + "-:::-"
                + "Major Version = " + browser.MajorVersion + "-:::-"
                + "Minor Version = " + browser.MinorVersion + "-:::-"
                + "Platform = " + browser.Platform + "-:::-"
                + "Is Beta = " + browser.Beta + "-:::-"
                + "Is Crawler = " + browser.Crawler + "-:::-"
                + "Is AOL = " + browser.AOL + "-:::-"
                + "Is Win16 = " + browser.Win16 + "-:::-"
                + "Is Win32 = " + browser.Win32 + "-:::-"
                + "Supports Frames = " + browser.Frames + "-:::-"
                + "Supports Tables = " + browser.Tables + "-:::-"
                + "Supports Cookies = " + browser.Cookies + "-:::-"
                + "Supports VBScript = " + browser.VBScript + "-:::-"
                + "Supports JavaScript = " + browser.EcmaScriptVersion.ToString() + "-:::-"
                + "Supports Java Applets = " + browser.JavaApplets + "-:::-"
                + "Supports ActiveX Controls = " + browser.ActiveXControls + "-:::-"
                + "Supports JavaScript Version = " + browser["JavaScriptVersion"] + "-:::-"
                + "CDF  = " + browser.CDF + "-:::-"
                + "IP Adress  = " + Request.ServerVariables["REMOTE_ADDR"] + "-:::-"
                + "User Agent  = " + Request.ServerVariables["HTTP_USER_AGENT"] + "-:::-"
                + "Refrerer  = " + Request.ServerVariables["HTTP_REFERER"] + "-:::-"
                + "Http Accept  = " + Request.ServerVariables["HTTP_ACCEPT"] + "-:::-"
                + "Language  = " + Request.ServerVariables["HTTP_ACCEPT_LANGUAGE"];

            return str;
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            Authenticate();
        }

        protected void btnFlushUser_Click(object sender, EventArgs e)
        {
            userPool.RemoveUser(GetStatic.GetUser());
        }
    }
}