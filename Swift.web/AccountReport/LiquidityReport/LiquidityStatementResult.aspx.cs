using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AccountReport.LiquidityReport
{
    public partial class LiquidityStatementResult : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                PopulateGrid();

            startDate.Text = DateTime.Now.ToString("d");
            toDate.Text = DateTime.Now.ToString("d");
        }

        private void PopulateGrid()
        {
            string stDate = startDate.Text;
            string endDate = toDate.Text;
            string company_id = GetStatic.ReadQueryString("company_id", "");
            string acNum = GetStatic.ReadQueryString("ac_num", "");
            string query = "select acct_name from ac_master WITH (NOLOCK) where acct_num=" + sl.FilterString(acNum) + "";
            string sql = "Exec spa_branchstatement @flag=a" + ",@startDate=" + sl.FilterString(stDate) + ",@endDate=" + sl.FilterString(endDate) + ",@acnum=" + sl.FilterString(acNum) + ",@company_id=" + sl.FilterString(company_id) + "";
            DataTable acdt = sl.ExecuteDataTable(query);
            accNum.Text = acNum;
            if (acdt != null && acdt.Rows.Count > 0)
            {
                acct_name.Text = acdt.Rows[0]["acct_name"].ToString();
            }
            StringBuilder sb = new StringBuilder("<table class=\"table table-striped table-bordered\" cellspacing=\"0\"><tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td nowrap><strong>Tran Date</strong></td>");
            sb.AppendLine("<td nowrap><strong>Description</strong></td>");
            sb.AppendLine("<td  nowrap ><div align=\"right\"><strong>Dr Amount&nbsp;</strong></div></td>");
            sb.AppendLine("<td  nowrap ><div align=\"right\"><strong>Cr Amount</strong></div></td>");
            sb.AppendLine("<td colspan=\"2\"><div align=\"right\"><strong>Balance</strong></div></td>");
            sb.AppendLine("</tr>");

            DataTable dt = sl.ExecuteDataTable(sql);

            if (dt.Rows.Count == 0 || dt.Rows == null)
            {
                sb.AppendLine("<tr><td colspan=\"12\" align=\"center\">No Data to display</td></tr></table>");
                tblRpt.InnerHtml = sb.ToString();
                return;
            }
            int count = 0;
            int i = 0;
            int balance = 0;
            int drTotal = 0;
            int crTotal = 0;
            int openBalance = 0;
            int cntDR = 0;
            int cntCR = 0;
            while (i != dt.Rows.Count)
            {
                drTotal += Convert.ToInt32(dt.Rows[i]["DRTotal"]);
                crTotal += Convert.ToInt32(dt.Rows[i]["cRTotal"]);
                balance += Convert.ToInt32(dt.Rows[i]["end_clr_balance"]) + Convert.ToInt32(dt.Rows[i]["cRTotal"]) - Convert.ToInt32(dt.Rows[i]["DRTotal"]);
                if (count == 1)
                    openBalance = Convert.ToInt32(dt.Rows[i]["end_clr_balance"]);

                if (Convert.ToInt32(dt.Rows[i]["DRTotal"]) > 0)
                    cntDR = cntDR + 1;
                if (Convert.ToInt32(dt.Rows[i]["cRTotal"]) > 0)
                    cntCR = cntCR + 1;
                count++;

                sb.AppendLine("<tr>");

                if (dt.Rows[i]["TRNDate"].ToString() != "1900.01.01")
                {
                    sb.AppendLine("<td nowrap>" + dt.Rows[i]["TRNDate"] + "</td>");
                }
                sb.AppendLine(" <td>" + dt.Rows[i]["tran_rmks"] + "</td>");
                sb.AppendLine("<td nowrap>");
                sb.AppendLine("<div align=\"right\">");
                sb.AppendLine("<a href=\"UserReportResult.aspx?company_id=" + sl.FilterString(company_id) + "&vouchertype=" + sl.FilterString(dt.Rows[i]["tran_type"].ToString()) + "&type=trannumber&trn_date=" + sl.FilterString(dt.Rows[i]["TRNDate"].ToString()) + "&tran_num=" + dt.Rows[i]["ref_num"] + "&title=\"Transaction info\">");
                if (Convert.ToInt32(dt.Rows[i]["DRTotal"]) != 0)
                    sb.AppendLine(dt.Rows[i]["DRTotal"] + "</a></div></td>");
                else
                    sb.AppendLine("</a></div></td>");
                sb.AppendLine("<td nowrap>");
                sb.AppendLine("<div align=\"right\">");
                sb.AppendLine("<a href=\"UserReportResult.asp?company_id=" + sl.FilterString(company_id) + "&vouchertype=" + sl.FilterString(dt.Rows[i]["tran_type"].ToString()) + "&type=trannumber&trn_date=" + sl.FilterString(dt.Rows[i]["TRNDate"].ToString()) + "&tran_num=" + sl.FilterString(dt.Rows[i]["ref_num"].ToString()) + "&title=\"Transaction info\">");
                if (Convert.ToInt32(dt.Rows[i]["cRTotal"]) != 0)
                    sb.AppendLine(dt.Rows[i]["cRTotal"] + "</a></div></td>");
                else
                    sb.AppendLine("</a></div></td>");
                sb.AppendLine("<td nowrap>");
                sb.AppendLine("<div align=\"right\">" + balance + "</div></td>");
                sb.AppendLine("<td nowrap>");
                if (balance < 0)
                    sb.AppendLine("DR");
                else if (balance > 0)
                    sb.AppendLine("CR");
                sb.AppendLine("</td>");
                sb.AppendLine("</tr>");
                i++;
            }

            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"6\"><br>");
            sb.AppendLine("<table  border=\"0\" align=\"right\" cellpadding=\"2\" cellspacing=\"1\">");
            sb.AppendLine(" <tr>");
            sb.AppendLine("<td  nowrap><div align=\"right\"><strong>Opening Balance: </strong></div></td>");
            sb.AppendLine("<td  nowrap>&nbsp;</td>");
            sb.AppendLine("<td nowrap>&nbsp;</td>");
            sb.AppendLine("<td  nowrap><div align=\"right\">" + openBalance + "</div></td></tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td nowrap><div align=\"right\"><strong>DR: </strong></div></td>");
            sb.AppendLine("<td nowrap><%=cntDR%></td>");
            sb.AppendLine("<td nowrap>&nbsp;</td>");
            sb.AppendLine("<td nowrap><div align=\"right\"><%=ShowDecimal(DRTotal)%></div></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td nowrap><div align=\"right\"><strong>CR:</strong></div></td>");
            sb.AppendLine("<td nowrap><%=cntCR%></td>");
            sb.AppendLine("<td nowrap>&nbsp;</td>");
            sb.AppendLine(" <td nowrap><div align=\"right\"><%=ShowDecimal(cRTotal)%></div></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td nowrap><div align=\"right\"><strong>Closing Balance:</strong></div></td>");
            sb.AppendLine(" <td nowrap>&nbsp;</td>");
            sb.AppendLine("<td nowrap>");
            if (balance < 0)
                sb.AppendLine("DR");
            else if (balance > 0)
                sb.AppendLine("CR");
            sb.AppendLine("</td>");
            sb.AppendLine("<td nowrap><div align=\"right\">");
            sb.AppendLine("<a href=\"BillBybillStatement.asp?acct_num=" + sl.FilterString(acNum) + "&date=" + sl.FilterString(endDate) + "@title=\"Bill by Bill Outstanding\">" + balance + "</a></div></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine(" </table>");
            tblRpt.InnerHtml = sb.ToString();
        }
    }
}