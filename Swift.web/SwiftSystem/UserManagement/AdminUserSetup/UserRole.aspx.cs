using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.AdminUserSetup
{
    public partial class UserRole : System.Web.UI.Page
    {
        private const string ViewFunctionId = "10101350";
        private readonly SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            btnBack.Visible = false;
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
                    "<table border=\"0\" class=\"table table-responsive table-bordered\" cellpadding=\"0\" cellspacing=\"0\" align=\"left\">");
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
            _sl.CheckAuthentication(ViewFunctionId);
            btnSave.Visible = _sl.HasRight(ViewFunctionId);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("../ApplicationUserSetup/List.aspx");
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
            Response.Redirect("List.aspx");
        }
    }
}