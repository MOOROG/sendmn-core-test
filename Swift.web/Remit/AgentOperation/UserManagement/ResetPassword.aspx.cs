using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;

namespace Swift.web.Remit.AgentOperation.UserManagement
{
    public partial class ResetPassword : System.Web.UI.Page
    {
        private const string AddEditFunctionId = "40112510";
        private readonly ApplicationUserDao _obj = new ApplicationUserDao();
        private readonly SwiftLibrary _sl = new SwiftLibrary();

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
            _sl.CheckAuthentication(AddEditFunctionId);
            btnReset.Visible = _sl.HasRight(AddEditFunctionId);
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

        private void Update()
        {
            DbResult dbResult = _obj.ResetPassword(GetStatic.GetUser(), GetUserName(), pwd.Text);
            ManageMessage(dbResult);
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("List.aspx?agentId=" + GetAgent() + "&mode=" + GetMode());
        }
    }
}