using System;
using System.Data;
using System.Text;
using System.Web.UI;
using Swift.DAL.BL.System.Notification;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.Notification.ApplicationLogs
{
    public partial class Manage : Page
    {
        private readonly ApplicationLogsDao _apllicationLogsDao = new ApplicationLogsDao();
        private readonly SwiftLibrary _swiftLibrary = new SwiftLibrary();

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
            DataTable dt = _apllicationLogsDao.PopulateAppLogById(GetLogId().ToString());
            if (dt == null || dt.Rows.Count < 1)
                return;

            DataRow dr = dt.Rows[0];
            createdDate.Text = dr["createdDate"].ToString();
            tableName.Text = dr["tableName"].ToString();
            dataId.Text = dr["dataId"].ToString();
            createdBy.Text = dr["createdBy"].ToString();
            logType.Text = dr["logType"].ToString();
            if (dr["logType"].ToString().ToLower() != "log out")
            {
                changeDetails.Visible = true;
                PrintChanges(dr["tableName"].ToString(), dr["logType"].ToString(), dr["oldData"].ToString(),
                             dr["newData"].ToString());
            }
            else
            {
                changeDetails.Visible = false;
            }
        }

        private void PrintChanges(string tableName, string logType, string oldData, string newData)
        {
            DataTable dt = null;
            if (tableName.ToLower() == "user functions" || tableName.ToLower() == "role functions")
            {
                dt = GetStatic.GetHistoryChangedListForFunction(oldData, newData);
            }
            else if (tableName.ToLower() == "user roles")
            {
                dt = GetStatic.GetHistoryChangedListForRole(oldData, newData);
            }
            else
            {
                dt = GetStatic.GetHistoryChangedList(logType, oldData, newData);
            }

            if (dt.Rows.Count == 0)
            {
                rpt_grid.InnerHtml = "<center><b></b><center>";
                return;
            }
            var str =
                new StringBuilder(
                    "<table border=\"0\" class=\"table table-bordered table-striped\" cellpadding=\"0\" cellspacing=\"0\" align=\"center\">");
            str.Append("<tr>");
            str.Append("<th   align=\"left\">" + dt.Columns[0].ColumnName + "</th>");
            str.Append("<th align=\"left\">" + dt.Columns[1].ColumnName + "</th>");
            str.Append("<th  align=\"left\">" + dt.Columns[2].ColumnName + "</th>");
            str.Append("</tr>");
            foreach (DataRow dr in dt.Rows)
            {
                str.Append("<tr>");
                str.Append("<td align=\"left\">" + dr[0] + "</td>");
                if (dr[3].ToString() == "Y")
                {
                    if (logType.ToLower() == "insert")
                    {
                        str.Append("<td align=\"left\">" + dr[1] + "</td>");
                    }
                    else
                    {
                        str.Append("<td align=\"left\"><div class=\"oldValue\">" + dr[1] + "</div></td>");
                    }

                    if (logType.ToLower() == "delete")
                    {
                        str.Append("<td align=\"left\">" + dr[2] + "</td>");
                    }
                    else
                    {
                        str.Append("<td align=\"left\"><div class=\"newValue\">" + dr[2] + "</div></td>");
                    }
                }
                else
                {
                    str.Append("<td align=\"left\">" + dr[1] + "</td>");
                    str.Append("<td align=\"left\">" + dr[2] + "</td>");
                }
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