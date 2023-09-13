using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AccountReport.CompileReport
{
    public partial class CompileReportSearch : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();
        private const string ViewFunctionId = "20140600";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateGrid();
                sl.CheckAuthentication(ViewFunctionId);
                asOnDate.Text = DateTime.Now.ToString("d");
            }
        }

        private void PopulateGrid()
        {
            string user = GetStatic.GetUser();
            string deletedJob = GetStatic.ReadQueryString("DeleteJobId", "");
            if (deletedJob != "")
            {
                string query = "EXEC PROC_REPORT_JOB @flag=d" + ",@job_name =\"CompileReport\", @job_user =" + sl.FilterString(user) + ", @reportJobId =" + sl.FilterString(deletedJob) + "";
                DataTable dtq = sl.ExecuteDataTable(query);
            }

            if (GetStatic.ReadQueryString("createJOb", "") == "y")
            {
                string asOnDate = GetStatic.ReadQueryString("asOnDate", "");
                string agentCode = GetStatic.ReadQueryString("agentCode", "");
                string includeZeroValue = GetStatic.ReadQueryString("includeZeroValue", "");
                string bankCode = GetStatic.ReadQueryString("bankCode", "");
                string fromDrAmt = GetStatic.ReadQueryString("fromDrAmt", "");
                string toDrAmt = GetStatic.ReadQueryString("toDrAmt", "");
                string fromCrAmt = GetStatic.ReadQueryString("fromCrAmt", "");
                string toCrAmt = GetStatic.ReadQueryString("toCrAmt", "");

                string jobSql = "Exec proc_compileReport @flag=A" + ",@DATE=" + sl.FilterString(asOnDate) + ",@SAGENT=" + sl.FilterString(agentCode) + ",@INCLUDEZERO=" + sl.FilterString(includeZeroValue) + ",@BANKCODE=" + sl.FilterString(bankCode) + ",@DR1= " + sl.FilterString(fromDrAmt) + ",@DR2= " + sl.FilterString(toDrAmt) + ",@CR1= " + sl.FilterString(fromCrAmt) + ",@CR2= " + sl.FilterString(toCrAmt) + "";
                string sql1 = "Exec PROC_REPORT_JOB @flag=c,@job_name =\"CompileReport\",@job_user =" + sl.FilterString(user) + ", @date1=" + sl.FilterString(asOnDate) + ", @date2=" + sl.FilterString(asOnDate) + ", @SQL= " + sl.FilterString(jobSql) + "";
                DataTable dt1 = sl.ExecuteDataTable(sql1);
            }

            string sql = "Exec PROC_REPORT_JOB @flag=v" + ",@job_name ='CompileReport'" + ",@job_user=" + sl.FilterString(user) + "";

            StringBuilder sb = new StringBuilder("<table class=\"table table-striped table-bordered\" cellspacing=\"0\"><tr>");
            sb.AppendLine("<td><div align=\"left\"><strong>SN</strong></div></td>");
            sb.AppendLine("<td nowrap=\"nowrap\">");
            sb.AppendLine("<div align=\"left\"><strong>Date</strong></div>");
            sb.AppendLine("</td>");
            sb.AppendLine("<td nowrap=\"nowrap\">");
            sb.AppendLine("<div align=\"left\"><strong>User</strong></div>");
            sb.AppendLine("</td>");
            sb.AppendLine("<td  nowrap=\"nowrap\">");
            sb.AppendLine("<div align=\"left\"><strong>As On Date</strong></div>");
            sb.AppendLine("</td>");
            sb.AppendLine("<td nowrap=\"nowrap\">");
            sb.AppendLine("<div align=\"left\"><strong>Remarks</strong></div>");
            sb.AppendLine("</td>");
            sb.AppendLine("<td nowrap=\"nowrap\">");
            sb.AppendLine("<div align=\"right\"><strong>View</strong></div>");
            sb.AppendLine("</td></tr>");
            DataTable dt = sl.ExecuteDataTable(sql);
            if (dt.Rows.Count == 0 || dt.Rows == null)
            {
                sb.AppendLine("<tr><td colspan=\"12\" align=\"center\">No Data to display</td></tr></table>");
                tblRpt.InnerHtml = sb.ToString();
                return;
            }

            int i = 0;
            int count = 1;
            while (i != dt.Rows.Count)
            {
                sb.AppendLine("<tr><td nowrap=\"nowrap\">");
                sb.AppendLine("<div align=\"left\">" + count + "</div></td>");
                sb.AppendLine("<td nowrap=\"nowrap\">");
                sb.AppendLine("<div align=\"left\">");
                sb.AppendLine("<strong>" + dt.Rows[i]["job_date"] + "</strong></div>");
                sb.AppendLine("</td><td>");
                sb.AppendLine(" <div align=\"left\">" + dt.Rows[i]["job_user"] + "</div>");
                sb.AppendLine("</td>");
                sb.AppendLine("<td>");
                if (!(dt.Rows[i]["rdate1"] is DBNull))
                    sb.AppendLine("<div align=\"left\">" + Convert.ToDateTime(dt.Rows[i]["rdate1"]).ToString("d") + "</div>");
                else
                    sb.AppendLine("<div align=\"left\">" + dt.Rows[i]["rdate1"] + "</div>");

                sb.AppendLine("</td><td>");
                sb.AppendLine("<div align=\"left\">" + dt.Rows[i]["job_desc"] + "</div>");
                sb.AppendLine("</td><td>");
                sb.AppendLine("<div align=\"right\"><a href=\"CompileReportShow.aspx?reportView=web&reportJobId=" + dt.Rows[i]["rowid"] + "&pl_date=" + dt.Rows[i]["rdate1"] + "&pl_date2=" + dt.Rows[i]["rdate2"] + "&title=\"Report\">Report</a> |");
                sb.AppendLine("<a href=\"CompileReportShow.aspx?reportView=Excel&reportname=CompileReport&reportJobId=" + dt.Rows[i]["rowid"] + "&pl_date=" + dt.Rows[i]["rowid"] + "&pl_date2=" + dt.Rows[i]["rdate2"] + "&title=\"Excel\">Excel </a>|");
                sb.AppendLine("<a href=\"?DeleteJobId=" + dt.Rows[i]["rowid"] + "&title=\"Account Statement\">Delete </a>");
                sb.AppendLine("</div>");
                sb.AppendLine("</td>");
                sb.AppendLine("</tr>");
                i++;
                count++;
            }
            sb.AppendLine("</table>");
            tblRpt.InnerHtml = sb.ToString();
        }
    }
}