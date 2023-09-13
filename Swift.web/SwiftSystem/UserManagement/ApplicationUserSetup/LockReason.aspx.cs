using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.BL.System.UserManagement;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationUserSetup
{
    public partial class LockReason : System.Web.UI.Page
    {
        ApplicationUserDao _obj = new ApplicationUserDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadLockReason();
        }

        private string GetUserName()
        {
            return GetStatic.ReadQueryString("userName", "");
        }
        private void LoadLockReason()
        {
            if (GetUserName() == "")
                return;
            var dr = _obj.GetLockReason(GetUserName());
            if(dr == null)
                return;
            var html = new StringBuilder("<table border=\"0\" class=\"table table-striped table-bordered\" cellpadding=\"0\" cellspacing=\"0\" align=\"left\">");
            html.Append("<tr>");
            html.Append("<th colspan = \"2\">User Lock Reason</th>");
            html.Append("</tr>");
            html.Append("<tr><td>Locked By:</td><td>" + dr["createdBy"] + "</td></tr>");
            html.Append("<tr><td>Locked Date:</td><td>" + dr["createdDate"] + "</td></tr>");
            html.Append("<tr><td>Locked Reason:</td><td>" + dr["lockReason"] + "</td></tr>");
            Response.Write(html.ToString());
        }
    }
}