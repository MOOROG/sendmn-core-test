using System;
using System.Data;
using System.Text;
using System.Web.UI;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationUserSetup
{
    public partial class UserRole : Page
    {
        private const string ViewFunctionId = "10101300";
        private const string ViewAgentUserFunctionId = "10101100";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                LoadGrid();
            }
        }

        protected string GetUserName()
        {
            return GetStatic.ReadQueryString("userName", "");
        }
        protected long GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode");
        }

        protected string GetAgent()
        {
            return GetStatic.ReadQueryString("agentId", "");
        }

        public void LoadGrid()
        {
            string userId = GetStatic.ReadQueryString("userId", "");
            var roleDao = new ApplicationRoleDao();
            DataTable dt = roleDao.GetRoleList(userId, GetStatic.GetUser());

            if (dt.Rows.Count == 0)
            {
                rpt_grid.InnerHtml = "<center><b></b><center>";
                return;
            }
            var str =
                new StringBuilder(
                    "<table width = \"300px\" border=\"0\" class=\"TBL\" cellpadding=\"0\" cellspacing=\"0\" align=\"left\">");
            str.Append("<tr>");
            str.Append("<th align=\"left\">" + dt.Columns[0].ColumnName + "</th>");
            str.Append("</tr>");

            foreach (DataRow dr in dt.Rows)
            {
                str.Append("<tr>");
                str.Append("<td align=\"left\">" + dr[0] + "</td>");
                str.Append("</tr>");
            }
            str.Append("</table>");
            rpt_grid.InnerHtml = str.ToString();
        }

        private void Authenticate()
        {
            var role = _sl.HasRight(ViewFunctionId);
            if (!role)
            {
                _sl.CheckAuthentication(ViewAgentUserFunctionId);
                btnSave.Visible = _sl.HasRight(ViewAgentUserFunctionId);
                return;
            }
            else
            {
                _sl.CheckAuthentication(ViewFunctionId);
                btnSave.Visible = _sl.HasRight(ViewFunctionId);
            }
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("../AgentUserSetup/List.aspx?agentId=" + GetAgent() + "&mode=" + GetMode());
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string userId = GetStatic.ReadQueryString("userId", "");
            string roleId = GetStatic.ReadFormData("roleId", "NULL");
            var roleDao = new ApplicationRoleDao();
            DbResult dbResult = roleDao.SaveUserRole(roleId, userId, GetStatic.GetUser());
            ManageMessage(dbResult);
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("../AgentUserSetup/List.aspx?agentId=" + GetAgent() + "&mode=" + GetMode());
        }
    }
}