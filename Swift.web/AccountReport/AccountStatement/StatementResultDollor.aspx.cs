using Swift.DAL.AccountReport;
using Swift.web.Library;
using System;
using System.Data;
using System.Web;

namespace Swift.web.AccountReport.AccountStatement
{
    public partial class StatementResultDollor : System.Web.UI.Page
    {
        private SwiftLibrary _sl = new SwiftLibrary();
        private AccountStatementDAO st = new AccountStatementDAO();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                //startDate.ReadOnly = true;
                //endDate.ReadOnly = true;

                startDate.Text = GetStatic.ReadQueryString("startDate", "");
                endDate.Text = GetStatic.ReadQueryString("endDate", "");
                acNumber.Text = GetStatic.ReadQueryString("acNum", "");
                acName.Text = GetStatic.ReadQueryString("acName", "");
                GenerateReport();
            }
        }

        private void GenerateReport()
        {
            var dt = st.GetStatementResultDollor(acNumber.Text, startDate.Text, endDate.Text);
            if (dt == null || dt.Rows.Count == 0)
            {
                return;
            }
            var sb = new System.Text.StringBuilder("");

            sb.AppendLine("<table width='100%' class='TBLReport'>");
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
                string amt = (GetStatic.ParseDouble(item["DRTotal"].ToString()) != 0 ? item["DRTotal"].ToString() : "");

                string drLink = "<a href='userreport_result_single.asp?company_id=1&vouchertype=" + item["tran_type"].ToString();
                drLink += "&type=trannumber&trn_date=" + item["TRNDate"].ToString() + "&tran_num=" + item["ref_num"].ToString() + "' title='Transaction info' >";
                drLink += amt + "</a>";

                string cramt = (GetStatic.ParseDouble(item["cRTotal"].ToString()) != 0 ? item["cRTotal"].ToString() : "");

                string crLink = "<a href='userreport_result_single.asp?company_id=1&vouchertype=" + item["tran_type"].ToString();
                crLink += "&type=trannumber&trn_date=" + item["TRNDate"].ToString() + "&tran_num=" + item["ref_num"].ToString() + "' title='Transaction info' >";
                crLink += amt + "</a>";

                sb.AppendLine("<td nowrap align='center' >" + (item["TRNDate"].ToString() == "1900.01.01" ? "&nbsp;" : item["TRNDate"]) + " </td>");
                sb.AppendLine("<td nowrap >" + item["tran_rmks"] + " </td>");
                sb.AppendLine("<td nowrap align='right' >" + GetStatic.ShowDecimal(item["DRTotal"].ToString()) + " </td>");
                sb.AppendLine("<td nowrap align='right' >" + GetStatic.ShowDecimal(item["cRTotal"].ToString()) + " </td>");
                sb.AppendLine("<td nowrap align='right' >" + GetStatic.ShowDecimal(BAlance.ToString()) + " " + (BAlance < 0 ? "DR" : "CR") + " </td>");

                sb.AppendLine("</tr>");
            }

            sb.AppendLine("</table>");

            tableBody.InnerHtml = sb.ToString();
            openingBalance.Text = GetStatic.ShowDecimal(OpenBalnce.ToString());
            crCount.Text = cntCR.ToString();
            drCount.Text = cntDR.ToString();
            drAmt.Text = GetStatic.ShowDecimal(DRTotal.ToString());
            crAmt.Text = GetStatic.ShowDecimal(cRTotal.ToString());
            drOrCr.Text = (BAlance < 0 ? "DR" : "CR");
            closingBalanceAmt.Text = GetStatic.ShowDecimal(BAlance.ToString());
        }

        protected void goBtn_Click(object sender, EventArgs e)
        {
            GenerateReport();
        }

        protected void pdf_Click(object sender, EventArgs e)
        {
            GetStatic.GetPDF(HttpUtility.UrlDecode(hidden.Value));
        }
    }
}