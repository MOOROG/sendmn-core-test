using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AccountReport.NRBReport
{
    public partial class NrbReportDetail : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateGrid();
            }
        }

        private void PopulateGrid()
        {
            string agentId = GetStatic.ReadQueryString("agentId", "");
            string fromDate = GetStatic.ReadQueryString("fromDate", "");
            string toDate = GetStatic.ReadQueryString("toDate", "");
            string flag = GetStatic.ReadQueryString("flag", "");

            //string sql = "Exec procNRBDetailReport @flag=" + sl.FilterString(flag) + ",@agent=" + sl.FilterString(agentId) + ",@dateform=" + sl.FilterString(fromDate) + ",@dateto=" + sl.FilterString(toDate) + "";
            string sql = "Exec procNRBDetailReport @flag=" + sl.FilterString(flag) + ",@dateform=" + sl.FilterString(fromDate) + ",@dateto=" + sl.FilterString(toDate) + "";

            StringBuilder sb = new StringBuilder("<table class=\"table table-striped table-bordered\" cellspacing=\"0\"><tr>");
            sb.AppendLine("<td rowspan=\"2\"><div align=\"center\"><strong>SN</strong></div></td>");
            sb.AppendLine("<td rowspan=\"2\"><div align=\"center\"><strong> Name of the Remitter</strong></div></td>");
            sb.AppendLine("<td rowspan=\"2\"><div align=\"center\"><strong> Country</strong></div></td>");
            sb.AppendLine("<td colspan=\"2\"><div align=\"center\"><strong>Remittance Received in USD</strong></div></td>");
            sb.AppendLine("<td colspan=\"2\"><div align=\"center\"><strong>Remittace Received in Rs </strong></div></td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td><div align=\"center\"><strong>Transactions </strong></div></td>");
            sb.AppendLine("<td><div align=\"center\"><strong>Amount (US $)</strong></div></td>");
            sb.AppendLine("<td><div align=\"center\"><strong>No. of Transactions</strong></div></td>");
            sb.AppendLine("<td><div align=\"center\"><strong>Amount</strong></div></td>");
            sb.AppendLine("</tr>");

            DataTable dt = sl.ExecuteDataTable(sql);
            if (dt.Rows.Count == 0 || dt.Rows == null)
            {
                sb.AppendLine("<tr><td colspan=\"12\" align=\"center\">No Data to display</td></tr></table>");
                tblRpt.InnerHtml = sb.ToString();
                return;
            }
            string last_con_name = "";
            int count = 0;
            var totalUsdAmt = 0;
            var totalNprAmt = 0;
            var grandTotalUsd = 0;
            var granTotalNpr = 0;
            int i = 0;
            var subtotal_usd_amt = 0;
            var subtotal_npr_amt = 0;
            while (i != dt.Rows.Count)
            {
                count++;
                string conName = dt.Rows[i]["curr_name"].ToString();
                if (conName != last_con_name && count != 1)
                {
                    sb.AppendLine("<tr>");
                    sb.AppendLine("<td align='right'>&nbsp;</td>");
                    sb.AppendLine("<td colspan='2' align='left'><strong> TOTAL</strong></td>");
                    sb.AppendLine("<td align='right'>-</td>");
                    sb.AppendLine("<td align='right'><strong>" + subtotal_usd_amt + "</strong></td>");
                    sb.AppendLine("<td align='right'>-</td>");
                    sb.AppendLine("<td align='right'><strong>" + subtotal_npr_amt + "</strong></td>");
                    sb.AppendLine("</tr>");

                    subtotal_usd_amt = 0;
                    subtotal_npr_amt = 0;
                }

                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + count + "</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["PARTICULAR"].ToString() + "</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["curr_name"].ToString() + "</td>");
                sb.AppendLine("<td align=\"right\">-</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["USD_AMT"] + "</td>");
                sb.AppendLine("<td align=\"right\">-</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["NPR_AMT"] + "</td>");
                sb.AppendLine("</tr>");

                grandTotalUsd += Convert.ToInt32(dt.Rows[i]["USD_AMT"]);
                granTotalNpr += Convert.ToInt32(dt.Rows[i]["NPR_AMT"]);

                subtotal_usd_amt = subtotal_usd_amt + Convert.ToInt32(dt.Rows[i]["USD_AMT"]);
                subtotal_npr_amt = subtotal_npr_amt + Convert.ToInt32(dt.Rows[i]["NPR_AMT"]);

                last_con_name = dt.Rows[i]["curr_name"].ToString();
                i++;
            }
            sb.AppendLine("<tr>");
            sb.AppendLine("<td  align='right'>&nbsp;</td>");
            sb.AppendLine("<td  colspan='2' align='left'><strong> TOTAL</strong></td>");
            sb.AppendLine("<td  align='right'>-</td>");
            sb.AppendLine("<td  align='right'><strong>" + subtotal_usd_amt + "</strong></td>");
            sb.AppendLine("<td  align='right'>-</td>");
            sb.AppendLine("<td  align='right'><strong>" + subtotal_npr_amt + "</strong></td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td>&nbsp;</td>");
            sb.AppendLine("<td  colspan=\"2\"><div align=\"left\"><strong>Grand Total</strong></div></td>");
            sb.AppendLine("<td><div align=\"right\">-</div></td>");
            sb.AppendLine("<td ><div align=\"right\"><strong>" + grandTotalUsd + "</strong></div></td>");
            sb.AppendLine("<td ><div align=\"right\">-</div></td>");
            sb.AppendLine("<td ><div align=\"right\"><strong>" + granTotalNpr + "</strong></div></td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"7\">&nbsp;</td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td  colspan=\"7\"><strong>Authorized Signature : </strong></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"7\"><strong>Name : </strong></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"7\"><strong>Designation : </strong></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td  colspan=\"7\"><strong>Date : </strong></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</tr></table>");
            tblRpt.InnerHtml = sb.ToString();
        }
    }
}