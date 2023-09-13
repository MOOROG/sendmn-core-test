using Swift.API.Common;
using Swift.API.GoogleAuthenticator;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.Library;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using Swift.web.SwiftSystem.UserManagement.ApplicationUserPool;
using System;
using System.Diagnostics;
using System.Reflection;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;

namespace Swift.web.Admin
{
    public partial class Default : System.Web.UI.Page
    {
        private ApplicationUserDao user = new ApplicationUserDao();
        protected GoogleAuthenticatorAPI _auth = new GoogleAuthenticatorAPI();
        private string ipAddress = "";
        private string Username = "";
        private string pwd = "";
        private string Usercode = "";
        protected string use2FA = "Y";
        private UserPool userPool = UserPool.GetInstance();

        protected void Page_Load(object sender, EventArgs e)
        {
            spnVerion.InnerText = FileVersionInfo.GetVersionInfo(Assembly.GetExecutingAssembly().Location).FileVersion;

            ipAddress = Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (string.IsNullOrEmpty(ipAddress))
            {
                ipAddress = Request.ServerVariables["REMOTE_ADDR"];//"203.223.132.106";//
            }
            if (!IsPostBack)
            {
                if (GetStatic.ReadWebConfig("UseGoogle2FAuthAdmin", "") != "Y")
                {
                    use2FA = "N";
                    DisableGoogle2FAuth();
                }
                else
                {
                    EnableGoogle2FAuth();
                }

                string methodname = Request.Form["methodName"];
                switch (methodname)
                {
                    case "GetLogin":
                        GetLogin();
                        break;
                }
            }
            //userName.Attributes.Add("onkeypress", "ClearMessage()");
            //pwd.Attributes.Add("onkeypress", "isCapslock((event?event:evt))");
            //userCode.Attributes.Add("onkeypress", "ClearMessage()");
        }

        private void EnableGoogle2FAuth()
        {
            Google2FAuthDiv.Visible = true;
            verificationCode.Enabled = true;

            Google2FAuthDivCode.Visible = false;
            txtCompcode.Enabled = false;
        }

        private void DisableGoogle2FAuth()
        {
            Google2FAuthDiv.Visible = false;
            verificationCode.Enabled = false;

            Google2FAuthDivCode.Visible = true;
            txtCompcode.Enabled = true;
        }

        private void GetLogin()
        {
            Username = Request.Form["username"];
            pwd = Request.Form["password"];
            Usercode = Request.Form["companycode"];
            Authenticate();
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
            var dbResult = new DbResult();
            DisableLogin();
            //if (!GetStatic.IsNumeric(Usercode))
            //{
            //    dbResult.ErrorCode = "1";
            //    dbResult.Msg = "Login fails, Incorrect user name or password or user code !";
            //   // jsonSerialize(dbResult);
            //    errMsg.InnerText = dbResult.Msg;
            //    errMsg.Visible = true;
            //    EnableLogin();
            //    return;
            //}

            var dr = user.DoLogin(Username, pwd, Usercode, ipAddress, GetUserInfo(), GetStatic.GetLocation(ipAddress), verificationCode.Text, GetStatic.ReadWebConfig("UseGoogle2FAuthAdmin", ""));
            if (null == dr)
            {
                var msg = "wrong credentials.";
                // GetStatic.CallBackJs1(this, "", "ShowErrorMsg('" + msg + "');");
                errMsg.InnerText = msg;
                errMsg.Visible = true;
                EnableLogin();
                return;
            }

            if (dr.ErrorCode != "0")
            {
                //jsonSerialize(dr);
                // GetStatic.CallBackJs1(this, "", "ShowErrorMsg('" + dr.Msg + "');");
                errMsg.InnerText = dr.Msg;
                errMsg.Visible = true;
                EnableLogin();
                return;
            }

            if (GetStatic.ReadWebConfig("UseGoogle2FAuthAdmin", "") == "Y")
            {
                if (string.IsNullOrEmpty(dr.UserUniqueKey))
                {
                    errMsg.InnerText = "Please contact "+ GetStatic.ReadWebConfig("jmeName", "") + " Head office to get QR code for accessing JME Remit system!";
                    errMsg.Visible = true;
                    EnableLogin();
                    return;
                }

                var _dbRes = _auth.Verify2FA(verificationCode.Text, dr.UserUniqueKey);
                user.Log2FAuth(dr.logId, _dbRes.ErrorCode == "0" ? "1" : "0");

                if (_dbRes.ErrorCode != "0")
                {
                    errMsg.InnerText = _dbRes.Msg;
                    errMsg.Visible = true;
                    EnableLogin();
                    return;
                }
            }

            if (dr.UserAccessLevel.ToUpper() == "S")
            {
                var cookieKey = Username + "_userSessionId";
                var lastUserSessionId = GetStatic.ReadCookie(cookieKey, "");
                if (userPool.IsUserExists(Username))
                {
                    if (!userPool.IsUserExists(Username, lastUserSessionId))
                    {
                        Session.Add("usr", Username);
                        var url = GetStatic.GetUrlRoot() + "/LoginSession.aspx";
                        Response.Redirect(url);
                        return;
                    }
                    else
                    {
                        userPool.RemoveUser(Username);
                    }
                }
            }

            var db = ManageUserSession(dr);

            if (db.ErrorCode != "0")
            {
                //jsonSerialize(dr);
                // GetStatic.CallBackJs1(this, "", "ShowErrorMsg('" + dr.Msg + "');");
                errMsg.InnerText = db.Msg;
                errMsg.Visible = true;
                EnableLogin();
                return;
            }
            //jsonSerialize(dr);
            //return;

            if (dr.isForcePwdChanged.ToUpper() == "Y")
            {
                Response.Redirect("../SwiftSystem/UserManagement/ApplicationUserSetup/ChangePassword.aspx");
            }
            else
            {
                //Get2FAuthentication();
                Response.Redirect("Dashboard.aspx");
            }

            EnableLogin();
            // Response.Redirect("Popup.aspx");
        }

        private void Get2FAuthentication()
        {
            GoogleAuthenticatorModel _model = new GoogleAuthenticatorModel();
            login.Visible = false;
            //authenticate.Visible = true;
            _model = _auth.GenerateCodeAndImageURL(Username);

            //imgVerifyQRCode.ImageUrl = _model.BarCodeImageUrl;
        }

        private DbResult ManageUserSession(UserDetails ud)
        {
            Session.Clear();
            var res = SetUserPool(ud);
            if (res.ErrorCode != "0")
                return res;

            GetStatic.WriteSession("admin", Username);
            GetStatic.WriteSession("fullname", ud.FullName);
            GetStatic.WriteSession("branchId", ud.Branch);
            GetStatic.WriteSession("branchName", ud.BranchName);
            GetStatic.WriteSession("address", ud.Address);
            GetStatic.WriteSession("userType", ud.UserType);
            GetStatic.WriteCookie("loginType", "ADMIN");
      GetStatic.WriteSession("userAccessLevel", ud.UserAccessLevel);
            Session[Username + "Menu"] = new StringBuilder();
            Session.Timeout = Convert.ToInt16(ud.sessionTimeOut);
            var cookieKey = Username + "_userSessionId";
            GetStatic.WriteCookie(cookieKey, GetStatic.GetSessionId());
            return res;
        }

        private DbResult SetUserPool(UserDetails ud)
        {
            HttpBrowserCapabilities browser = Request.Browser;
            var usr = new LoggedInUser();

            usr.UserId = GetStatic.ParseInt(ud.UserId);
            usr.UserName = Username;
            usr.UserFullName = ud.FullName;
            usr.LoginTime = DateTime.Now;
            usr.UserAccessLevel = ud.UserAccessLevel;
            usr.UserAgentName = ud.BranchName;
            usr.LastLoginTime = Convert.ToDateTime(ud.LastLoginTs);
            usr.LoggedInCountry = ud.LoggedInCountry;
            usr.LoginAddress = ud.LoginAddress;
            usr.LastLoginTime = Convert.ToDateTime(ud.LastLoginTs);

            usr.Browser = browser.Browser + "/" + browser.Type;
            usr.IPAddress = ipAddress;
            usr.SessionID = GetStatic.GetSessionId();
            usr.LastActiveTime = usr.LoginTime;
            return userPool.AddUser(usr);
        }

        private string GetUserInfo()
        {
            HttpBrowserCapabilities browser = Request.Browser;

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
                + "IP Adress  = " + ipAddress + "-:::-"
                //+ "Certificate ID No  = " + dcIdNo + "-:::-"
                //+ "Certificate User Name  = " + dcUserName + "-:::-"
                + "User Agent  = " + Request.ServerVariables["HTTP_USER_AGENT"] + "-:::-"
                + "Refrerer  = " + Request.ServerVariables["HTTP_REFERER"] + "-:::-"
                + "Http Accept  = " + Request.ServerVariables["HTTP_ACCEPT"] + "-:::-"
                + "Language  = " + Request.ServerVariables["HTTP_ACCEPT_LANGUAGE"];

            return str;
        }

        public void jsonSerialize<T>(T obk)
        {
            JavaScriptSerializer jsonData = new JavaScriptSerializer();
            string jsonString = jsonData.Serialize(obk);
            Response.ContentType = "application/json";
            Response.Write(jsonString);
            Response.End();
        }

        private void GetServerCredentials()
        {
            Username = txtUsername.Text;
            pwd = txtPwd.Text;
            Usercode = txtCompcode.Text;
            Authenticate();
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            DisableLogin();
            GetServerCredentials();
        }

        //protected void bntSubmit_Click(object sender, EventArgs e)
        //{
        //    //Authenticate();
        //}
    }
}