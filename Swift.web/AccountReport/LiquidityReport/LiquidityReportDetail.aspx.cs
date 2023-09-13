using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AccountReport.LiquidityReport
{
    public partial class LiquidityReportDetail : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                PopulateGrid();
        }

        private void PopulateGrid()
        {
            string fromDate = GetStatic.ReadQueryString("fromDate", "");

            string sql = "Exec PROC_LIQUIDITY_REPORT @flag='LIQ-S', @date=" + sl.FilterString(fromDate) + "";

            StringBuilder sb = new StringBuilder("<table class=\"table table-striped table-bordered\" cellspacing=\"0\">");
            DataRow dt = sl.ExecuteDataRow(sql);
            if (null == dt)
            {
                sb.AppendLine("<tr><td colspan=\"12\" align=\"center\">No Data to display</td></tr></table>");
                tblRpt.InnerHtml = sb.ToString();
                return;
            }
            sb.AppendLine("<tr><td colspan=\"2\"><strong> Liquidity Report as on "+ fromDate + "  </strong></td></tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td>Cash Balance</td>");
            sb.AppendLine("<td><div align=\"right\">" + GetStatic.ShowDecimal(dt["CASH_BALANCE"].ToString()) + "</div></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td>Bank Balance</td>");
            sb.AppendLine("<td><div align=\"right\">" + GetStatic.ShowDecimal(dt["BANK_BALANCE"].ToString()) + "</div></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td>Receivables below 4 days</td>");
            sb.AppendLine("<td><div align=\"right\">" + GetStatic.ShowDecimal(dt["BELOW_FOUR_DAYS"].ToString()) + "</div></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td>Correspondents Receivables</td>");
            sb.AppendLine("<td><div align=\"right\">" + GetStatic.ShowDecimal(dt["CORRESPONDENT_RECEIVABLES"].ToString()) + "</div></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td>Customer Liabilities</td>");
            sb.AppendLine("<td><div align=\"right\">" + GetStatic.ShowDecimal(dt["CUSTOMER_LIAB"].ToString()) + "</div></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><strong>Net Liquidity Position</strong></td>");
            sb.AppendLine("<td><div align=\"right\"><strong>" + GetStatic.ShowDecimal(dt["TOTAL"].ToString()) + "</strong></div></td>");
            sb.AppendLine("</tr>");
            
            tblRpt.InnerHtml = sb.ToString();
        }
    }
}