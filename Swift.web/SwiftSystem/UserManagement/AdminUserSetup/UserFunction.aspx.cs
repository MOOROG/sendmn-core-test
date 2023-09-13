using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.AdminUserSetup
{
    public partial class UserFunction : System.Web.UI.Page
    {
        private const string ViewFunctionId = "10101300";
        private readonly SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_PreInit(object sender, EventArgs e)
        {
            //MasterPageFile = GetMode().ToString() != "1" ? "~/Swift.Master" : "~/ProjectMaster.Master";
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                //LoadTab();
                LoadGrid();
            }
        }

        //private void LoadTab()
        //{
        //    pnlBreadCrumb.Visible = GetMode() != 1;
        //}
        protected string GetUserName()
        {
            return GetStatic.ReadQueryString("userName", "");
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
            btnSave.Visible = _sl.HasRight(ViewFunctionId);
        }

        public void LoadGrid()
        {
            string userId = GetStatic.ReadQueryString("userId", "");
            var roleDao = new ApplicationRoleDao();
            DataTable dt = roleDao.GetUserFunctionList(userId, GetStatic.GetUser());

            if (dt.Rows.Count == 0)
            {
                rpt_grid.InnerHtml = "<center><b>No function available</b><center>";
                return;
            }
            var str =
                new StringBuilder(
                    "<table border=\"0\" class=\"TBL\" cellpadding=\"0\" cellspacing=\"0\" align=\"left\">");
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

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string userId = GetStatic.ReadQueryString("userId", "");
            string function = GetStatic.ReadFormData("functionId", "NULL");
            var roleDao = new ApplicationRoleDao();
            DbResult dbResult = roleDao.SaveUserFunction(function, userId, GetStatic.GetUser());
            ManageMessage(dbResult);
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("List.aspx");
        }
    }
}