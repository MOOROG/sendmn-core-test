using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AccountReport.AccountBalance
{
    public partial class ac_balance : System.Web.UI.Page
    {
        private SwiftLibrary swft_lib = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                swft_lib.CheckSession();
                populateGrid();
            }
        }

        protected void populateGrid()
        {
            StringBuilder sb = new StringBuilder();
            int sn = 1;
            string sql = "Exec ProcBalanceCheckReport 'c'";
            DataTable dt = swft_lib.ExecuteDataTable(sql);
            if (dt.Rows.Count <= 0 || dt.Rows == null)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td colspan='6' align='center'>");
                sb.AppendLine("No Data To Display ");
                sb.AppendLine("</td>");
                sb.AppendLine("</tr>");
                tblMain.InnerHtml = sb.ToString();
                return;
            }

            foreach (DataRow item in dt.Rows)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td> " + sn + " </td>");
                sb.AppendLine("<td> " + item["acct_num"].ToString() + "</td>");
                sb.AppendLine("<td> " + item["acct_name"].ToString() + " </td>");
                sb.AppendLine("<td> " + GetStatic.ShowDecimal(item["clr_bal_amt"].ToString()) + "</td>");
                sb.AppendLine("<td> " + GetStatic.ShowDecimal(item["tran_amt"].ToString()) + " </td>");
                sb.AppendLine("<td> " + GetStatic.ShowDecimal((GetStatic.ParseDouble(item["clr_bal_amt"].ToString()) - GetStatic.ParseDouble(item["tran_amt"].ToString())).ToString()) + " </td>");
                sb.AppendLine("</tr>");
                sn++;
            }
            tblMain.InnerHtml = sb.ToString();
        }
    }
}