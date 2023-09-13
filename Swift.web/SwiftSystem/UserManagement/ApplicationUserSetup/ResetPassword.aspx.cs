using System;
using System.Web.UI;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationUserSetup
{
    public partial class ResetPassword : Page
    {
        private const string ResetPasswordFunctionId = "10101170";
        private const string ResetPasswordFunctionId1 = "10101670";
     

        private readonly ApplicationUserDao _obj = new ApplicationUserDao();
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private SmtpMailSetting smtpMailSetting = new SmtpMailSetting();

        protected void Page_Load(object sender, EventArgs e)
        {
            PopulateUserName();
            if (!IsPostBack)
            {
                Authenticate();
                //LoadTab();
            }
        }

        //private void LoadTab()
        //{
        //    pnlBreadCrumb.Visible = true;
        //}

        protected long GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode");
        }

        protected string GetAgent()
        {
            return GetStatic.ReadQueryString("agentId", "");
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            Update();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ResetPasswordFunctionId + "," + ResetPasswordFunctionId1);
            btnReset.Visible = _sl.HasRight(ResetPasswordFunctionId + "," + ResetPasswordFunctionId1);
        }

        protected string GetUserName()
        {
            return GetStatic.ReadQueryString("userName", "");
        }

        protected void PopulateUserName()
        {
            userName.Text = GetUserName();
            userName.Enabled = false;
        }

        private void Update()
        {
            DbResult dbResult = _obj.ResetPassword(GetStatic.GetUser(), GetUserName(), pwd.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx?agentId=" + GetAgent() + "&mode=" + GetMode());
            }
            else
            {
                if (GetMode() == 1)
                    GetStatic.AlertMessage(Page);
                else
                    GetStatic.PrintMessage(Page);
            }
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("List.aspx?agentId=" + GetAgent() + "&mode=" + GetMode());
        }
    }
}