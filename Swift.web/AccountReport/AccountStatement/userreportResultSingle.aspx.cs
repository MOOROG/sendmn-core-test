using Swift.DAL.AccountReport;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AccountReport.AccountStatement
{
    public partial class userreportResultSingle : System.Web.UI.Page
    {
        private SwiftLibrary _sl = new SwiftLibrary();
        private AccountStatementDAO st = new AccountStatementDAO();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (GetStatic.ReadQueryString("r", "") == "Y")
            {
                divReverse.Visible = _sl.HasRight("20101110");
            }
            GenerateReport();
        }

        protected string TransactionNumber()
        {
            return GetStatic.ReadQueryString("tran_num", "");
        }

        protected string TransactionDate()
        {
            return GetStatic.ReadQueryString("trn_date", "");
        }

        protected string VoucherType()
        {
            return GetStatic.ReadQueryString("vouchertype", "");
        }

        private void GenerateReport()
        {
            string tranNum = TransactionNumber();
            string tranactionDate = TransactionDate();
            string vType = VoucherType();

            tranNumber.Text = tranNum;
            tranDate.Text = tranactionDate;
            voucherType.Text = GetStatic.GetVoucherType(vType, "");

            letterHead.InnerHtml = GetStatic.getCompanyHead();

            var dt = st.GetUserReportResultSingle(tranNum, tranactionDate, vType);

            var sb = new StringBuilder("");

            sb.AppendLine("<div class=\"table-responsive\"><table class=\"table table-striped table-bordered\" width=\"100%\" cellspacing=\"0\" class=\"TBLReport\">");
            sb.AppendLine("<tr>");
            sb.AppendLine("<th nowrap='nowrap' width='4%' >SN </th>");
            sb.AppendLine("<th nowrap='nowrap' width='10%'> AC No </th>");
            sb.AppendLine("<th nowrap='nowrap' > Name </th>");

            string fcyCurr = dt.Rows[0]["fcy_Curr"].ToString();
            int totalSpan = 3;
            if (!string.IsNullOrWhiteSpace(fcyCurr))
            {
                sb.AppendLine("<th nowrap='nowrap' width='10%'>FCY</th>");
                sb.AppendLine("<th nowrap='nowrap' width='10%'>Rate </th>");
                sb.AppendLine("<th nowrap='nowrap' width='10%'>FCY Amount </th>");
                totalSpan = 6;
            }
            sb.AppendLine("<th nowrap='nowrap' width='10%'> Dr Amount </th>");
            sb.AppendLine("<th nowrap='nowrap' width='10%'> Cr Amount </th>");
            sb.AppendLine("</tr>");

            int sno = 0;
            double drTotal = 0, crTotal = 0;
            foreach (DataRow item in dt.Rows)
            {
                sno++;
                drTotal = drTotal + GetStatic.ParseDouble(item["DRTotal"].ToString());
                crTotal = crTotal + GetStatic.ParseDouble(item["cRTotal"].ToString());

                sb.AppendLine("<tr>");

                sb.AppendLine("<td nowrap='nowrap'> " + sno.ToString() + " </td>");
                sb.AppendLine("<td nowrap='nowrap'> " + item["acc_num"].ToString() + " </td>");
                sb.AppendLine("<td nowrap='nowrap'> " + item["acct_name"].ToString() + "</td>");
                if (!string.IsNullOrWhiteSpace(fcyCurr))
                {
                    sb.AppendLine("<td nowrap='nowrap'>" + item["fcy_Curr"].ToString() + "</td>");
                    sb.AppendLine("<td nowrap='nowrap'>" + item["usd_rate"].ToString() + "</td>");
                    sb.AppendLine("<td nowrap='nowrap' align='right'>" + GetStatic.ShowDecimal(item["usd_amt"].ToString()) + "</td>");
                }
                sb.AppendLine("<td nowrap='nowrap' align='right'> " + GetStatic.ShowDecimal(item["DRTotal"].ToString()) + " </td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'> " + GetStatic.ShowDecimal(item["cRTotal"].ToString()) + " </td>");

                sb.AppendLine("</tr>");
            }

            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan='" + totalSpan + "' width='70%' nowrap='nowrap'><div align='right'><strong>Total&nbsp;&nbsp;</strong> </div> </td>");
            sb.AppendLine("<td nowrap='nowrap' width='15%' align='right'> <strong>" + GetStatic.ShowDecimal(drTotal.ToString()) + " </strong> </td>");
            sb.AppendLine("<td nowrap='nowrap' width='15%' align='right'> <strong>" + GetStatic.ShowDecimal(crTotal.ToString()) + "</strong> </td>");

            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td nowrap='nowrap' colspan='" + (totalSpan + 3) + "'><strong>Narration:&nbsp;&nbsp;</strong> " + dt.Rows[0]["tran_particular"].ToString() + " </td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("</table></div>");

            if (!string.IsNullOrWhiteSpace(dt.Rows[0]["voucher_image"].ToString()))
            {
                voucherImg.Visible = true;
                voucherImg.ImageUrl = "~/doc/VoucherDoc/" + dt.Rows[0]["voucher_image"].ToString();
            }

            userId.Text = dt.Rows[0]["entry_user_id"].ToString();
            reportTable.InnerHtml = sb.ToString();
        }

        protected void pdf_Click(object sender, EventArgs e)
        {
            //GetStatic.GetPDF(HttpUtility.UrlDecode(hidden.Value));
        }

        protected void btnReversal_Click(object sender, EventArgs e)
        {
            var vouchertype = GetStatic.ReadQueryString("vouchertype", "");
            var tran_num = GetStatic.ReadQueryString("tran_num", "");
            if (string.IsNullOrWhiteSpace(date.Text))
            {
                GetStatic.AlertMessage(this, "Please Choose Reversal Date");
                return;
            }
            if (!string.IsNullOrWhiteSpace(vouchertype) && !string.IsNullOrWhiteSpace(tran_num))
            {
                var dbResult = st.GetVoucherReverse(tran_num, vouchertype, GetStatic.GetUser(), date.Text, Narration.Text);
                if (dbResult.ErrorCode == "0")
                {
                    btnReversal.Visible = false;
                }
                reportTable.InnerHtml = dbResult.Msg;
            }
            else
            {
                GetStatic.AlertMessage(this, "Voucher Detail not found! Go back to Statement and try again");
                return;
            }
        }
    }
}