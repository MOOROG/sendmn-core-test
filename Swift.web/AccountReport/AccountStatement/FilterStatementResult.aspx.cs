using Swift.DAL.AccountReport;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;
using System.Web;

namespace Swift.web.AccountReport.AccountStatement
{
    public partial class FilterStatementResult : System.Web.UI.Page
    {
        private SwiftLibrary _sl = new SwiftLibrary();
        private AccountStatementDAO st = new AccountStatementDAO();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                GenerateReport();
            }
        }

        private void GenerateReport()
        {
            string startDate = GetStatic.ReadQueryString("startDate", "");
            string endDate = GetStatic.ReadQueryString("endDate", "");
            string acNumber = GetStatic.ReadQueryString("acNum", "");
            string condition = GetStatic.ReadQueryString("filterContion", "");
            string having = GetStatic.ReadQueryString("having", "");

            var dt = st.GetACStatementConditional(acNumber, startDate, endDate, condition, having);
            if (dt == null || dt.Rows.Count == 0)
            {
                return;
            }
            var sb = new StringBuilder("");

            sb.AppendLine("  <div class=\"table-responsive\"><table class=\"table table-striped table-bordered\" width=\"100%\" cellspacing=\"0\" class=\"TBLReport\">");
            sb.AppendLine("<tr>");
            sb.AppendLine("<th nowrap='nowrap'>Tran Date</th>");
            sb.AppendLine("<th nowrap='nowrap'>Description</th>");
            sb.AppendLine("<th nowrap='nowrap'>Dr Amount</th>");
            sb.AppendLine("<th nowrap='nowrap'>Cr Amount</th>");
            sb.AppendLine("<th nowrap='nowrap'>Balance</th>");
            sb.AppendLine("</tr>");

            double DRTotal = 0, cRTotal = 0, BAlance = 0, OpenBalnce = 0;
            int cntDR = 0, cntCR = 0, sn = 0;
            foreach (DataRow item in dt.Rows)
            {
                sb.AppendLine("<tr>");
                if (sn == 0)
                {
                    OpenBalnce = GetStatic.ParseDouble(item["end_clr_balance"].ToString());
                }
                sn++;
                DRTotal += GetStatic.ParseDouble(item["DRTotal"].ToString());
                cRTotal += GetStatic.ParseDouble(item["cRTotal"].ToString());
                BAlance += GetStatic.ParseDouble(item["end_clr_balance"].ToString()) + GetStatic.ParseDouble(item["cRTotal"].ToString()) - GetStatic.ParseDouble(item["DRTotal"].ToString());

                if (GetStatic.ParseDouble(item["DRTotal"].ToString()) > 0)
                {
                    cntDR++;
                }
                if (GetStatic.ParseDouble(item["cRTotal"].ToString()) > 0)
                {
                    cntCR++;
                }
                string amt = (GetStatic.ParseDouble(item["DRTotal"].ToString()) != 0 ? GetStatic.ShowDecimal(item["DRTotal"].ToString()) : "");

                string drLink = "<a href='userreportResultSingle.aspx?company_id=1&vouchertype=" + item["tran_type"].ToString();
                drLink += "&type=trannumber&trn_date=" + item["TRNDate"].ToString() + "&tran_num=" + item["ref_num"].ToString() + "' title='Transaction info' >";
                drLink += amt + "</a>";

                string cramt = (GetStatic.ParseDouble(item["cRTotal"].ToString()) != 0 ? GetStatic.ShowDecimal(item["cRTotal"].ToString()) : "");

                string crLink = "<a href='userreportResultSingle.aspx?company_id=1&vouchertype=" + item["tran_type"].ToString();
                crLink += "&type=trannumber&trn_date=" + item["TRNDate"].ToString() + "&tran_num=" + item["ref_num"].ToString() + "' title='Transaction info' >";
                crLink += cramt + "</a>";

                sb.AppendLine("<td nowrap align='center' >" + (item["TRNDate"].ToString() == "1900.01.01" ? "&nbsp;" : item["TRNDate"]) + " </td>");
                sb.AppendLine("<td nowrap >" + item["tran_rmks"] + " </td>");
                sb.AppendLine("<td nowrap align='right' >" + drLink + " </td>");
                sb.AppendLine("<td nowrap align='right' >" + crLink + " </td>");
                sb.AppendLine("<td nowrap align='right' >" + GetStatic.ShowDecimal(BAlance.ToString()) + " " + (BAlance < 0 ? "DR" : "CR") + " </td>");

                sb.AppendLine("</tr>");
            }

            sb.AppendLine("</table></div>");

            tableBody.InnerHtml = sb.ToString();
            openingBalance.Text = GetStatic.ShowDecimal(OpenBalnce.ToString());
            crCount.Text = cntCR.ToString();
            drCount.Text = cntDR.ToString();
            drAmt.Text = GetStatic.ShowDecimal(DRTotal.ToString());
            crAmt.Text = GetStatic.ShowDecimal(cRTotal.ToString());
            drOrCr.Text = (BAlance < 0 ? "DR" : "CR");
            closingBalanceAmt.Text = GetStatic.ShowDecimal(BAlance.ToString());
        }

        protected void button_Click(object sender, EventArgs e)
        {
            GetStatic.GetPDF(HttpUtility.UrlDecode(hidden.Value));
        }
    }
}