using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationRoleSetup
{
    public partial class ViewRoleFunction : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                LoadGrid();
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication("10101000");
        }

        protected string GetRoleName()
        {
            return "Role : " + GetStatic.ReadQueryString("roleName", "");
        }

        protected string GetRoleId()
        {
            return GetStatic.ReadQueryString("roleId", "");
        }
        private void LoadGrid()
        {
            string roleId = GetRoleId();
            var roleDao = new ApplicationRoleDao();
            DataTable dt = roleDao.ViewRoleFunctionList(roleId, GetStatic.GetUser());

            if (dt.Rows.Count == 0)
            {
                rpt_grid.InnerHtml = "<center><center>";
                return;
            }
            var str =
                new StringBuilder(
                    "<table border=\"0\" class=\"table table-bordered table-striped table-condensed table-responsive\" cellpadding=\"0\" cellspacing=\"0\" align=\"center\">");
            str.Append("<tr>");
            foreach (DataColumn dc in dt.Columns)
            {
                str.Append("<th align=\"left\" class = \"formLabel\">" + dc.ColumnName + "</th>");
            }

            str.Append("</tr>");

            foreach (DataRow dr in dt.Rows)
            {
                str.Append("<tr>");

                foreach (DataColumn dc in dt.Columns)
                {
                    str.Append("<td align=\"left\">" + dr[dc.ColumnName] + "</td>");
                }
                str.Append("</tr>");
            }
            str.Append("</table>");
            rpt_grid.InnerHtml = str.ToString();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Save();
        }

        private void Save()
        {
            string roleId = GetStatic.ReadQueryString("roleId", "");
            string function = GetStatic.ReadFormData("functionId", "NULL");
            var roleDao = new ApplicationRoleDao();
            DbResult dbResult = roleDao.SaveRoleFunction(function, roleId, GetStatic.GetUser());

            ManageMessage(dbResult);
        }
        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx");
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }
    }
}