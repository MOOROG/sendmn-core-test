using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AccountReport.BillByBillBalanceChecking
{
    public partial class List : System.Web.UI.Page
    {
        private SwiftLibrary swft_lib = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                populateGrid();
            }
        }

        private void populateGrid()
        {
            StringBuilder sb = new StringBuilder();
            int sno = 1;
            string sql = "ProcBillByBillExReport";
            DataTable dt = swft_lib.ExecuteDataTable(sql);

            if (dt.Rows.Count <= 0 || dt.Rows == null)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td colspan='5' align='center'> No Record To Display </td>");
                sb.AppendLine("</tr>");
                tblMain.InnerHtml = sb.ToString();
                return;
            }

            foreach (DataRow dr in dt.Rows)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + sno + "</td>");
                sb.AppendLine("td>" + dr["acct_name"].ToString() + "</td>");
                sb.AppendLine("td>" + dr["acct_num"].ToString() + "</td>");
                sb.AppendLine("td>" + GetStatic.ShowDecimal(dr["As_per_txn"].ToString()) + "</td>");
                sb.AppendLine("td>" + GetStatic.ShowDecimal(dr["As_per_bill_by_bill"].ToString()) + "</td>");
                sb.AppendLine("</tr>");
                sno++;
                tblMain.InnerHtml = sb.ToString();
            }

            tblMain.InnerHtml = sb.ToString();
        }
    }
}