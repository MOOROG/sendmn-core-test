using Swift.DAL.AccountReport;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AccountReport.BalanceSheet
{
    public partial class GL : System.Web.UI.Page
    {
        private readonly SwiftLibrary _s1 = new SwiftLibrary();
        private readonly AccountStatementDAO st = new AccountStatementDAO();

        protected void Page_Load(object sender, EventArgs e)
        {
            _s1.CheckSession();
            GenerateReport();
        }

        private void GenerateReport()
        {
            string mapcode = GetMapCode();
            string date = GetDate();
            string head = GetHead();
      var toDt = GetStatic.ReadQueryString("bsDtl", "");
      var sb = new StringBuilder("");

            var dt = st.GetGLReport(mapcode, date, toDt);
            int sno = 0;
            double total = 0, DR = 0, CR = 0;
            foreach (DataRow item in dt.Rows)
            {
                sno++;

                total = total + Convert.ToDouble(item["Total"].ToString());
                DR = DR + Convert.ToDouble(item["DR"].ToString());
                CR = CR + Convert.ToDouble(item["CR"].ToString());
                var drcrMode = " (DR)";
                if (Convert.ToDouble(item["DR"].ToString()) + Convert.ToDouble(item["CR"].ToString()) > 0)
                {
                    drcrMode = " (CR)";
                }
                sb.AppendLine("<tr>");
        if (string.IsNullOrEmpty(toDt)) {
          sb.AppendLine("<td nowrap='nowrap'>" + sno.ToString() + "</td>");
        } else {
          sb.AppendLine("<td nowrap='nowrap'>" + item["OnDate"].ToString() + "</td>");
        }
                sb.AppendLine("<td nowrap='nowrap'>" + item["acct_name"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'>" + GetStatic.ShowAbsDecimal(item["DR"].ToString()) + "</td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'>" + GetStatic.ShowAbsDecimal(item["CR"].ToString()) + "</td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'> <a href='SubLedger.aspx?company_id=1&dt=" + date.ToString() + "&dt1=&mapcode=" + item["acct_num"].ToString() + "&head =" + head.ToString() + "&treeSape=" + item["tree_sape"].ToString() + "' title='Account Statement' >" + GetStatic.ShowAbsDecimal(item["Total"].ToString()) + drcrMode + " </a></td>");

                sb.AppendLine("</tr>");

            }
            sb.AppendLine("<tr class='bg-gray-light'>");
            sb.AppendLine("<td colspan='2' nowrap='nowrap' align='right'><strong>TOTAL:</strong></td>");
            sb.AppendLine("<td nowrap='nowrap' align='right'> <strong>" + GetStatic.ShowAbsDecimal(DR.ToString()) + "</strong></td>");
            sb.AppendLine("<td nowrap='nowrap' align='right'> <strong>" + GetStatic.ShowAbsDecimal(CR.ToString()) + "</strong></td>");
            sb.AppendLine("<td nowrap='nowrap' align='right'> <strong>" + GetStatic.ShowAbsDecimal(total.ToString()) + "</strong></td>");

            sb.AppendLine("</tr>");

            rptBody.InnerHtml = sb.ToString();


        }

        protected string GetMapCode()
        {
            return GetStatic.ReadQueryString("mapcode", "");
        }

        protected string GetDate()
        {
            return GetStatic.ReadQueryString("dt", "");
        }

        protected string GetHead()
        {
            return GetStatic.ReadQueryString("head", "");
        }
    }
}