using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AccountReport.InternationalTranReport.ReconciliationReport
{
    public partial class ReconcileReport : System.Web.UI.Page
    {
        SwiftLibrary sl = new SwiftLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadReport();
            }
        }

        public string startDate()
        {
            return GetStatic.ReadQueryString("fromDate", "");
        }
        public string endDate()
        {
            return GetStatic.ReadQueryString("toDate", "");
        }
        public void LoadReport()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine(" <table class=\"table table-responsive table-bordered table-striped\">");
            sb.AppendLine("<tr>");
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


            var sDate = startDate();
            var eDate = endDate();
            int sn = 1;
            var last_curr_name = "";
            var sql = "Exec Proc_ReconcileReport flag=a";
            sql += ",@date=" + sl.FilterString(sDate);
            sql += ",@date2=" + sl.FilterString(eDate);
            DataSet ds = sl.ExecuteDataset(sql);
            DataTable dt = ds.Tables[0];

            if (dt.Rows.Count == 0 || dt.Rows == null)
            {
                sb.AppendLine("<tr><td colspan=\"13\" align=\"center\"> No Data To Display </td>");
                sb.AppendLine("</tr></table>");
                rpt.InnerHtml = sb.ToString();
                return;
            }


          

            if (sn != 1 && last_curr_name != dt.Rows[0]["curr_name"].ToString())
            {
            
            }
            sb.AppendLine("</table>");



        }
    }
}