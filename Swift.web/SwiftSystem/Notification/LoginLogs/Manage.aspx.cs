using System;
using System.Data;
using System.Text;
using System.Web.UI;
using Swift.DAL.BL.System.Notification;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.Notification.LoginLogs
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly ApplicationLogsDao _apllicationLogsDao = new ApplicationLogsDao();
        private readonly RemittanceLibrary _swiftLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                if (GetLogId() > 0)
                {
                    PopulateOperation();
                }
            }
        }

        private long GetLogId()
        {
            return (Request.QueryString["log_Id"] != null ? long.Parse(Request.QueryString["log_Id"]) : 0);
        }

        private void PopulateOperation()
        {
            DataTable dt = _apllicationLogsDao.PopulateLoginLogById(GetLogId().ToString());
            if (dt == null || dt.Rows.Count < 1)
                return;

            DataRow dr = dt.Rows[0];
            createdDate.Text = dr["createdDate"].ToString();
            lblReason.Text = dr["Reason"].ToString();
            dataId.Text = dr["log_id"].ToString();
            lblInput.Text = dr["UserData"].ToString();
            createdBy.Text = dr["createdBy"].ToString();
            logType.Text = dr["logType"].ToString();

            if (dr["logType"].ToString().ToLower() != "logout")
            {
                changeDetails.Visible = true;
                PrintChanges(dt);
            }
            else
            {
                changeDetails.Visible = false;
            }
        }

        private void PrintChanges(DataTable dt)
        {

            if (dt.Rows.Count == 0)
            {
                rpt_grid.InnerHtml = "<center><b></b><center>";
                return;
            }
            DataRow dr = dt.Rows[0];
            DataTable dt2 = GetStatic.GetStringToTable(dr["fieldvalue"].ToString());


            var str =new StringBuilder("<table border=\"0\" class=\"table table-bordered table-striped\" cellpadding=\"0\" cellspacing=\"0\" >");
            str.Append("<tr>");
            str.Append("<th align=\"left\">Category</th>");
            str.Append("<th align=\"left\">Value</th>");
            str.Append("</tr>");

            foreach (DataRow dr2 in dt2.Rows)
            {
                str.Append("<tr>");

                    str.Append("<td align=\"left\">" + dr2[0] + "</td>");
                    str.Append("<td align=\"left\">" + dr2[1] + "</td>");

                str.Append("</tr>");
            }

            str.Append("</table>");
            rpt_grid.InnerHtml = str.ToString();
        }

        private void Authenticate()
        {
            _swiftLibrary.CheckAuthentication("10121100");
        }
    }
}