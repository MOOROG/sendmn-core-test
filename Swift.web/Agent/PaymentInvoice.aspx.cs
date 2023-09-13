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

namespace Swift.web.Agent
{
    public partial class PaymentInvoice : System.Web.UI.Page
    {
        protected GoogleAuthenticatorAPI _auth = new GoogleAuthenticatorAPI();
        private string Username = "";
        private string pwd = "";
        private string Usercode = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string methodname = Request.Form["methodName"];
                switch (methodname)
                {
                    case "GetLogin":
                        GetLogin();
                        break;
                }
            }
        }

        private void GetLogin()
        {
            Username = Request.Form["username"];
            pwd = Request.Form["password"];
            Usercode = Request.Form["companycode"];
        }

    }
}