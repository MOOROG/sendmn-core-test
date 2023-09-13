using System;
using System.Data;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Library;


namespace Swift.web.SwiftSystem.UserManagement.UserLockDetail
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20101000";
        protected const string GridName = "grd_userLock";
        private readonly SwiftLibrary swiftLibrary = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                PopulateAgentName();
                if (GetUserLock() > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    //Your code goes here 
                }
            }
        }

        #region QueryString
        protected string GetUserName()
        {
            return GetStatic.ReadQueryString("userName", "");
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        protected long GetUserId()
        {
            return GetStatic.ReadNumericDataFromQueryString("userId");
        }

        protected long GetUserLock()
        {
            return GetStatic.ReadNumericDataFromQueryString("userLockId");
        }

        protected string GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode").ToString();
        }
        #endregion

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateAgentName()
        {
            ////DataRow dr = userLimit.SelectById(GetUserId().ToString());
            ////if (dr == null)
            ////    return;

            //lblAgentName.Text = dr["agentName"].ToString();
            //lblUserName.Text = dr["userName"].ToString();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode != "0")
            {
                if (GetMode() == "2")
                    GetStatic.AlertMessage(Page);
                else
                    GetStatic.PrintMessage(Page);
            }
            else
            {
                Response.Redirect("List.aspx?userId=" + GetUserId() + "&userName=" + GetUserName() + "&agentId=" + GetAgentId() + "&mode=" + GetMode());
            }
        }

        private void Update()
        {

            
        }

        private void DeleteRow()
        {
            
        }

        private void PopulateDataById()
        {
            
        }

    }
}