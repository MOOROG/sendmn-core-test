using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AccountReport.CompileReport
{
    public partial class CompileReportShow : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            if (!IsPostBack)
                PopulateGrid();
        }

        private void PopulateGrid()
        {
            string user = GetStatic.GetUser();
            string mode = GetStatic.ReadQueryString("mode", "").ToLower();
            string reportName = GetStatic.ReadQueryString("reportName", "").ToLower();

            if (mode == "download")
            {
                string format = GetStatic.ReadQueryString("format", "xls");
                Response.Clear();
                Response.ClearContent();
                Response.ClearHeaders();
                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("Content-Disposition", "attachment; filename=" + reportName + "." + format);
                exportDiv.Visible = false;
                hide.Visible = false;
            }
            string reportJobId = GetStatic.ReadQueryString("reportJobId", "");
            string sql = "Exec PROC_REPORT_JOB @flag=r" + ",@job_name ='CompileReport'" + ",@job_user=" + sl.FilterString(user) + ",@reportJobId=" + sl.FilterString(reportJobId) + "";
            string sql1 = "select distinct BANKCODE from agentTable where BANKCODE is not null AND isnull(AcDepositBank,'') <> 'Y'order by BANKCODE";

            StringBuilder sb = new StringBuilder("<table class=\"table table-striped table-bordered\" cellspacing=\"0\">");
            DataTable dt = sl.ExecuteDataTable(sql);
            DataTable dt1 = sl.ExecuteDataTable(sql1);
            if (dt.Rows.Count == 0 || dt.Rows == null)
            {
                sb.AppendLine("<tr><td colspan=\"12\" align=\"center\">No Data to display</td></tr></table>");
                tblRpt.InnerHtml = sb.ToString();
                return;
            }
            sb.AppendLine("<tr>");
            sb.AppendLine("<th><span>SN </span></th>");
            sb.AppendLine("<th>Branch ID </th>");
            sb.AppendLine("<th>Branch Code </th>");
            sb.AppendLine("<th>A/C Holder Name </th>");
            sb.AppendLine("<th>Bank Name</th>");
            sb.AppendLine("<th>Branch Name</th>");
            sb.AppendLine("<th>A/C Number</th>");
            sb.AppendLine("<th>DR</th>");
            sb.AppendLine("<th>CR</th>");
            sb.AppendLine("</tr>");

            int count = 1;
            int totCR = 0;
            int totDR = 0;
            int grandTotDR = 0;
            int grandTotCR = 0;

            int i = 0;
            int j = 0;
            string prevBankCode = string.Empty;
            while (j != dt.Rows.Count)
            {
                string bankCode = dt.Rows[j]["BANKCODE"].ToString();
                if (prevBankCode != bankCode)
                {
                    sb.AppendLine("<tr>");
                    sb.AppendLine("<td  colspan=\"7\" nowrap><div align=\"right\"><strong><span>Balance</span>&nbsp;</strong></div></td>");
                    sb.AppendLine("<td  nowrap><div align=\"right\"><strong>" + GetStatic.ShowDecimal(totDR.ToString()) + "</strong></div></td>");
                    sb.AppendLine("<td  nowrap><div align=\"right\"><strong>" + GetStatic.ShowDecimal(totCR.ToString()) + "</strong></div></td>");
                    sb.AppendLine("</tr>");
                    totDR = 0;
                    totCR = 0;
                    count = 1;
                }
                sb.AppendLine("<tr><td><div align=\"center\">" + count + "</div></td>");
                sb.AppendLine("<td><div align=\"left\">" + dt.Rows[j]["bank_id"] + "</div></td>");
                sb.AppendLine("<td><div align=\"left\">" + dt.Rows[j]["branch_Code"] + "</div></td>");
                sb.AppendLine("<td><div align=\"left\">" + dt.Rows[j]["agent_name"] + "</div></td>");
                sb.AppendLine("<td><div align=\"left\">" + dt.Rows[j]["bankcode"] + "</div></td>");
                sb.AppendLine("<td><div align=\"left\">" + dt.Rows[j]["bankbranch"] + "</div></td>");
                sb.AppendLine("<td><div align=\"left\">" + dt.Rows[j]["bankaccountnumber"] + "</div></td>");
                sb.AppendLine("<td><div align=\"right\">" + GetStatic.ShowDecimal(dt.Rows[j]["DR"].ToString()) + "</div></td>");
                sb.AppendLine("<td><div align=\"right\">" + GetStatic.ShowDecimal(dt.Rows[j]["CR"].ToString()) + "</div></td>");
                sb.AppendLine("</tr>");
                count++;
                totDR = totDR + Convert.ToInt32(dt.Rows[j]["DR"]);
                totCR = totCR + Convert.ToInt32(dt.Rows[j]["CR"]);
                grandTotDR = grandTotDR + Convert.ToInt32(dt.Rows[j]["DR"]);
                grandTotCR = grandTotCR + Convert.ToInt32(dt.Rows[j]["CR"]);
                prevBankCode = dt.Rows[j]["BANKCODE"].ToString();
                j++;
            }
            i++;
            if (j == dt.Rows.Count)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td  colspan=\"7\" nowrap><div align=\"right\"><strong><span>Balance</span>&nbsp;</strong></div></td>");
                sb.AppendLine("<td  nowrap><div align=\"right\"><strong>" + GetStatic.ShowDecimal(totDR.ToString()) + "</strong></div></td>");
                sb.AppendLine("<td  nowrap><div align=\"right\"><strong>" + GetStatic.ShowDecimal(totCR.ToString()) + "</strong></div></td>");
                sb.AppendLine("</tr>");
            }
            sb.AppendLine("<tr>");
            sb.AppendLine("<td  colspan=\"7\" nowrap><div align=\"right\"><strong><span>Total Balance</span>&nbsp;</strong></div></td>");
            sb.AppendLine("<td  nowrap><div align=\"right\"><strong>" + GetStatic.ShowDecimal(grandTotDR.ToString()) + "</strong></div></td>");
            sb.AppendLine("<td  nowrap><div align=\"right\"><strong>" + GetStatic.ShowDecimal(grandTotCR.ToString()) + "</strong></div></td>");
            sb.AppendLine("</tr></table>");
            tblRpt.InnerHtml = sb.ToString();
        }
    }
}