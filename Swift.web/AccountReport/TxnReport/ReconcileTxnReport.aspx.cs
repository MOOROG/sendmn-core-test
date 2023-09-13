using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AccountReport.TxnReport
{
    public partial class ReconcileTxnReport : System.Web.UI.Page
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
            string toDate = GetStatic.ReadQueryString("toDate", "");
            string sql = "Exec Proc_ReconcileReport @flag=a" + ",@date=" + sl.FilterString(fromDate) + ",@date2=" + sl.FilterString(toDate) + "";
            StringBuilder sb = new StringBuilder("<table class=\"table table-striped table-bordered\" cellspacing=\"0\">");

            sb.AppendLine("<td  rowspan=\"2\" ><strong>SN</strong></td>");
            sb.AppendLine("<td  rowspan=\"2\"><strong>Country</strong></td>");
            sb.AppendLine("<td  rowspan=\"2\" ><strong>Agent</strong></td>");
            sb.AppendLine("<td colspan=\"2\" align=\"right\" ><div align=\"center\"><strong>Unpaid Opening </strong></div></td>");
            sb.AppendLine("<td colspan=\"2\" align=\"right\" ><div align=\"center\"><strong>Send Transaction </strong></div></td>");
            sb.AppendLine("<td colspan=\"2\" align=\"right\" ><div align=\"center\"><strong>Paid Transacton </strong></div></td>");
            sb.AppendLine("<td colspan=\"2\" align=\"right\"><div align=\"center\"><strong>Cancel Transacton </strong></div></td>");
            sb.AppendLine("<td colspan=\"2\" align=\"right\"><div align=\"center\"><strong>Closing Un-paid </strong></div></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td align=\"right\"><div align=\"center\"><strong> TRN </strong></div></td>");
            sb.AppendLine("<td align=\"right\" ><div align=\"center\"><strong>NPR AMT</strong></div></td>");
            sb.AppendLine("<td  align=\"right\"><div align=\"center\"><strong> TRN </strong></div></td>");
            sb.AppendLine("<td align=\"right\"><div align=\"center\"><strong>NPR AMT</strong></div></td>");
            sb.AppendLine("<td align=\"right\"><div align=\"center\"><strong> TRN </strong></div></td>");
            sb.AppendLine("<td align=\"right\"><div align=\"center\"><strong>NPR AMT</strong></div></td>");
            sb.AppendLine("<td align=\"right\"><div align=\"center\"><strong> TRN </strong></div></td>");
            sb.AppendLine("<td align=\"right\"><div align=\"center\"><strong>NPR AMT</strong></div></td>");
            sb.AppendLine("<td align=\"right\"><div align=\"center\"><strong> TRN </strong></div></td>");
            sb.AppendLine("<td align=\"right\"><div align=\"center\"><strong>NPR AMT</strong></div></td>");
            sb.AppendLine("</tr>");

            DataTable dt = sl.ExecuteDataTable(sql);
            if (dt.Rows.Count == 0 || dt.Rows == null)
            {
                sb.AppendLine("<tr><td colspan=\"12\" align=\"center\">No Data to display</td></tr></table>");
                tblRpt.InnerHtml = sb.ToString();
                return;
            }

            int count = 0;
            string last_con_name = "";

            var GUNPAID_TOTAL_TRN = 0;
            var GUNPAID_TOTAL_AMT = 0;
            var GSEND_TRN = 0;
            var GSEND_AMT = 0;
            var GPAID_TRN = 0;
            var GPAID_AMT = 0;
            var GCANCEL_TRN = 0;
            var GCANCEL_AMT = 0;
            var GCLOSING_UNPAID_TRN = 0;
            var GCLOSING_UNPAID_AMT = 0;

            int UNPAID_TOTAL_TRN = 0;
            int UNPAID_TOTAL_AMT = 0;
            int SEND_TRN = 0;
            int SEND_AMT = 0;
            int PAID_TRN = 0;
            int PAID_AMT = 0;
            int CANCEL_TRN = 0;
            int CANCEL_AMT = 0;
            int CLOSING_UNPAID_AMT = 0;
            int CLOSING_UNPAID_TRN = 0;
            int i = 0;
            while (i != dt.Rows.Count)
            {
                count += 1;

                string conName = dt.Rows[i]["curr_name"].ToString();
                if (conName != last_con_name && count != 1)
                {
                    sb.AppendLine("<tr>");
                    sb.AppendLine("<td colspan='3'  align='right'><strong> SUB TOTAL (" + last_con_name + ")</strong></td>");
                    sb.AppendLine("<td align='right'><strong>" + UNPAID_TOTAL_TRN + "</strong></td>");
                    sb.AppendLine("<td align='right'><strong>" + UNPAID_TOTAL_AMT + "</strong></td>");
                    sb.AppendLine("<td align='right'><strong>" + SEND_TRN + "</strong></td>");
                    sb.AppendLine("<td align='right'><strong>" + SEND_AMT + "</strong></td>");
                    sb.AppendLine("<td align='right'><strong>" + PAID_TRN + "</strong></td>");
                    sb.AppendLine("<td align='right'><strong>" + PAID_AMT + "</strong></td>");
                    sb.AppendLine("<td align='right'><strong>" + CANCEL_TRN + "</strong></td>");
                    sb.AppendLine("<td align='right'><strong>" + CANCEL_AMT + "</strong></td>");
                    sb.AppendLine("<td align='right'><strong>" + CLOSING_UNPAID_TRN + "</strong></td>");
                    sb.AppendLine("<td align='right'><strong>" + CLOSING_UNPAID_AMT + "</strong></td>");
                    sb.AppendLine("</tr>");

                    UNPAID_TOTAL_TRN = 0;
                    UNPAID_TOTAL_AMT = 0;
                    SEND_TRN = 0;
                    SEND_AMT = 0;
                    PAID_TRN = 0;
                    PAID_AMT = 0;
                    CANCEL_TRN = 0;
                    CANCEL_AMT = 0;
                    CLOSING_UNPAID_AMT = 0;
                    CLOSING_UNPAID_TRN = 0;
                }

                CLOSING_UNPAID_TRN = CLOSING_UNPAID_TRN + Convert.ToInt32(dt.Rows[i]["CLOSING_UNPAID_TRN"]);
                CLOSING_UNPAID_AMT = CLOSING_UNPAID_AMT + Convert.ToInt32(dt.Rows[i]["CLOSING_UNPAID_AMT"]);

                UNPAID_TOTAL_TRN = UNPAID_TOTAL_TRN + Convert.ToInt32(dt.Rows[i]["UNPAID_TOTAL_TRN"]);
                UNPAID_TOTAL_AMT = UNPAID_TOTAL_AMT + Convert.ToInt32(dt.Rows[i]["UNPAID_NPR_AMT"]);

                SEND_TRN = SEND_TRN + Convert.ToInt32(dt.Rows[i]["SEND_TRN"]);
                SEND_AMT = SEND_AMT + Convert.ToInt32(dt.Rows[i]["SEND_AMT"]);

                PAID_TRN = PAID_TRN + Convert.ToInt32(dt.Rows[i]["PAID_TRN"]);
                PAID_AMT = PAID_AMT + Convert.ToInt32(dt.Rows[i]["PAID_AMT"]);

                CANCEL_TRN = CANCEL_TRN + Convert.ToInt32(dt.Rows[i]["CANCEL_TRN"]);
                CANCEL_AMT = CANCEL_AMT + Convert.ToInt32(dt.Rows[i]["CANCEL_AMT"]);

                GUNPAID_TOTAL_TRN = GUNPAID_TOTAL_TRN + Convert.ToInt32(dt.Rows[i]["UNPAID_TOTAL_TRN"]);
                GUNPAID_TOTAL_AMT = GUNPAID_TOTAL_AMT + Convert.ToInt32(dt.Rows[i]["UNPAID_NPR_AMT"]);

                GSEND_TRN = GSEND_TRN + Convert.ToInt32(dt.Rows[i]["SEND_TRN"]);
                GSEND_AMT = GSEND_AMT + Convert.ToInt32(dt.Rows[i]["SEND_AMT"]);

                GPAID_TRN = GPAID_TRN + Convert.ToInt32(dt.Rows[i]["PAID_TRN"]);
                GPAID_AMT = GPAID_AMT + Convert.ToInt32(dt.Rows[i]["PAID_AMT"]);

                GCANCEL_TRN = GCANCEL_TRN + Convert.ToInt32(dt.Rows[i]["CANCEL_TRN"]);
                GCANCEL_AMT = GCANCEL_AMT + Convert.ToInt32(dt.Rows[i]["CANCEL_AMT"]);

                GCLOSING_UNPAID_TRN = GCLOSING_UNPAID_TRN + Convert.ToInt32(dt.Rows[i]["CLOSING_UNPAID_TRN"]);
                GCLOSING_UNPAID_AMT = GCLOSING_UNPAID_AMT + Convert.ToInt32(dt.Rows[i]["CLOSING_UNPAID_AMT"]);

                last_con_name = dt.Rows[i]["curr_name"].ToString();
                sb.AppendLine(" <tr>");
                sb.AppendLine("<td ><div align='left'>" + count + "</div></td>");
                sb.AppendLine("<td nowrap=\"nowrap\" ><div align=\"left\"><strong>" + dt.Rows[i]["curr_name"] + "</strong></div></td>");
                sb.AppendLine("<td nowrap=\"nowrap\" ><div align=\"left\" >" + dt.Rows[i]["AGENT_NAME"] + "</div></td>");
                sb.AppendLine("<td align=\"right\" >" + dt.Rows[i]["UNPAID_TOTAL_TRN"] + "</td>");
                sb.AppendLine("<td align=\"right\" >" + dt.Rows[i]["UNPAID_NPR_AMT"] + "</td>");
                sb.AppendLine("<td align=\"right\" >" + dt.Rows[i]["SEND_TRN"] + "</td>");
                sb.AppendLine("<td align=\"right\" >" + dt.Rows[i]["SEND_AMT"] + "</td>");
                sb.AppendLine("<td align=\"right\" >" + dt.Rows[i]["PAID_TRN"] + "</td>");
                sb.AppendLine("<td align=\"right\" >" + dt.Rows[i]["PAID_AMT"] + "</td>");
                sb.AppendLine("<td align=\"right\" >" + dt.Rows[i]["CANCEL_TRN"] + "</td>");
                sb.AppendLine("<td align=\"right\" >" + dt.Rows[i]["CANCEL_AMT"] + "</td>");
                sb.AppendLine("<td align=\"right\" >" + dt.Rows[i]["CLOSING_UNPAID_TRN"] + "</td>");
                sb.AppendLine("<td align=\"right\" >" + dt.Rows[i]["CLOSING_UNPAID_AMT"] + "</td>");
                sb.AppendLine("</tr>");
                i++;
            }

            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"3\"  align=\"right\"><strong>Total</strong></td>");
            sb.AppendLine("<td  align=\"right\"><strong>" + GUNPAID_TOTAL_TRN + "</strong></td>");
            sb.AppendLine("<td  align=\"right\"><strong>" + GUNPAID_TOTAL_AMT + "</strong></td>");
            sb.AppendLine("<td align=\"right\"><strong>" + GSEND_TRN + "</strong></td>");
            sb.AppendLine("<td align=\"right\"><strong>" + GSEND_AMT + "</strong></td>");
            sb.AppendLine("<td align=\"right\"><strong>" + GPAID_TRN + "</strong></td>");
            sb.AppendLine("<td align=\"right\"><strong>" + GPAID_AMT + "</strong></td>");
            sb.AppendLine("<td align=\"right\"><strong>" + GCANCEL_TRN + "</strong></td>");
            sb.AppendLine("<td align=\"right\"><strong>" + GCANCEL_AMT + "</strong></td>");
            sb.AppendLine("<td align=\"right\"><strong>" + GCLOSING_UNPAID_TRN + "</strong></td>");
            sb.AppendLine("<td align=\"right\"><strong>" + GCLOSING_UNPAID_AMT + "</strong></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            tblRpt.InnerHtml = sb.ToString();
        }
    }
}