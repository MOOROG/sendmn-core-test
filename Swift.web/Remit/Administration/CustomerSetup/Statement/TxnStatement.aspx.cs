using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.DAL.Common;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace Swift.web.Remit.Administration.CustomerSetup.Statement
{
    public partial class TxnStatement : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20111600";
        private SwiftLibrary _sl = new SwiftLibrary();
        private readonly CustomersDao _obj = new CustomersDao();
        protected int rowSpan = 23;

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (ReportType().ToUpper() == "A")
            {
                GenerateAccountStatement();
            }
            else
            {
                GenerateReport();
            }
        }

        protected string StartDate()
        {
            return GetStatic.ReadQueryString("startDate", "");
        }

        protected string EndDate()
        {
            return GetStatic.ReadQueryString("endDate", "");
        }

        protected string IdNumber()
        {
            return GetStatic.ReadQueryString("acNum", "");
        }

        protected string ReportType()
        {
            return GetStatic.ReadQueryString("type", "T");
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void GenerateAccountStatement()
        {
            startDate.Text = StartDate();
            endDate.Text = EndDate();
            lblToday.Text = DateTime.Now.ToString("yyyy-MM-dd");
            idNumber.Text = IdNumber();
            var dt = _obj.GetCustomerAccountStatement(IdNumber(), StartDate(), EndDate(), GetStatic.GetUser());
            if (dt == null || dt.Rows.Count == 0)
            {
                return;
            }
            CustomerStatement walletResponse = null;
            List<CustomerStatement> lstWalletResponse = new List<CustomerStatement>();
            foreach (DataRow dr in dt.Rows)
            {
                walletResponse = new CustomerStatement()
                {
                    TransactionDate = Convert.ToString(dr["TrnDate"]),
                    Particular = Convert.ToString(dr["Tran_rmks"]),
                    WalletIn = Convert.ToString(dr["CrTotal"]),
                    WalletOut = Convert.ToString(dr["DRTotal"]),
                    ClosingAmount = Convert.ToString(dr["end_clr_balance"])
                };
                lstWalletResponse.Add(walletResponse);
            }
            if (lstWalletResponse == null)
            {
                divStmt.InnerHtml = "No wallet statement found.";
                return;
            }

            double OpenBalnce = 0.0;
            foreach (var item in lstWalletResponse)
            {
                if (item.Particular.ToString().ToUpper() == "BALANCE BROUGHT FORWARD")
                {
                    OpenBalnce = GetStatic.ParseDouble(item.ClosingAmount.ToString());
                }
                else
                {
                    item.ClosingAmount = (OpenBalnce + GetStatic.ParseDouble(item.WalletIn) - GetStatic.ParseDouble(item.WalletOut)).ToString();
                    OpenBalnce = GetStatic.ParseDouble(item.ClosingAmount);
                }
            }
            if (lstWalletResponse[0].Particular.ToString().ToUpper() == "BALANCE BROUGHT FORWARD")
            {
                lstWalletResponse.RemoveAt(0);
            }
            lstWalletResponse.Add(new CustomerStatement()
            {
                Particular = "BALANCE BROUGHT FORWARD",
                ClosingAmount = OpenBalnce.ToString(),
                WalletIn = "0",
                WalletOut = "0",
                TransactionDate = EndDate()
            });
            List<CustomerStatement> list = new List<CustomerStatement>();

            for (int i = lstWalletResponse.Count - 1; i >= 0; i--)
            {
                list.Add(new CustomerStatement()
                {
                    Particular = lstWalletResponse[i].Particular,
                    TransactionDate = lstWalletResponse[i].TransactionDate,
                    WalletIn = lstWalletResponse[i].WalletIn,
                    WalletOut = lstWalletResponse[i].WalletOut,
                    ClosingAmount = lstWalletResponse[i].ClosingAmount
                });
            }

            senderName.Text = GetStatic.ReadQueryString("acName", "");
            var sb = new StringBuilder("");

            sb.AppendLine("  <div class=\"table-responsive\" style='font-size:11px !important;'><table class=\"table table-striped table-bordered\" >");
            sb.AppendLine("<tr>");
            sb.AppendLine("<th nowrap='nowrap'>Tran Date</th>");
            sb.AppendLine("<th nowrap='nowrap'>Particulars</th>");
            sb.AppendLine("<th nowrap='nowrap'>Wallet In Amt</th>");
            sb.AppendLine("<th nowrap='nowrap'>Wallet Out Amt</th>");
            sb.AppendLine("<th nowrap='nowrap'>Closing Amt<br></th>");
            sb.AppendLine("</tr>");

            double sending = 0, paying = 0;
            foreach (var item in list)
            {
                sending += GetStatic.ParseDouble(item.WalletIn);
                paying += GetStatic.ParseDouble(item.WalletOut);
                sb.AppendLine("<tr>");
                sb.AppendLine("<td nowrap='nowrap'>" + item.TransactionDate.ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap'>" + item.Particular.ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap'>" + GetStatic.ShowFormatedCommaAmt(item.WalletIn) + "</td>");
                sb.AppendLine("<td nowrap='nowrap'>" + GetStatic.ShowFormatedCommaAmt(item.WalletOut) + "</td>");
                sb.AppendLine("<td nowrap='nowrap'>" + GetStatic.ShowFormatedCommaAmt(item.ClosingAmount) + "</td>");
                sb.AppendLine("</tr>");
            }
            //sb.AppendLine("<tr>");
            //sb.AppendLine("<td colspan='2' align='right'><strong>Total : </td>");
            //sb.AppendLine("<td align='right'>" + GetStatic.ShowFormatedCommaAmt(sending.ToString()) + "</td>");
            //sb.AppendLine("<td align='right'>" + GetStatic.ShowFormatedCommaAmt(paying.ToString()) + "</td>");
            //sb.AppendLine("</tr>");
            //sb.AppendLine("</table></div>");

            divStmt.InnerHtml = sb.ToString();
        }

        private void GenerateReport()
        {
            startDate.Text = StartDate();
            endDate.Text = EndDate();
            lblToday.Text = DateTime.Now.ToString("yyyy-MM-dd");
            idNumber.Text = IdNumber();
            var dt = _obj.GetCustomerTxnStatement(IdNumber(), StartDate(), EndDate(), GetStatic.GetUser());
            if (dt == null || dt.Rows.Count == 0)
            {
                return;
            }
            senderName.Text = dt.Rows[0]["senderName"].ToString();
            var sb = new StringBuilder("");

            sb.AppendLine("  <div class=\"table-responsive\" style='font-size:12px !important;'><table class=\"table table-striped table-bordered\" >");
            sb.AppendLine("<tr>");
            sb.AppendLine("<th nowrap='nowrap'>Tran Date</th>");
            sb.AppendLine("<th nowrap='nowrap'>Control Number</th>");
            sb.AppendLine("<th nowrap='nowrap'>Receiver's Name</th>");
            sb.AppendLine("<th nowrap='nowrap'>Sending Amount<br>("+ GetStatic.ReadWebConfig("currencyMN", "") +")</th>");
            sb.AppendLine("<th nowrap='nowrap'>Payout Amount<br></th>");
            sb.AppendLine("</tr>");

            double sending = 0, paying = 0;

            foreach (DataRow item in dt.Rows)
            {
                rowSpan--;
                sending += GetStatic.ParseDouble(item["cAmt"].ToString());
                paying += GetStatic.ParseDouble(item["pAmt"].ToString());

                sb.AppendLine("<tr>");
                sb.AppendLine("<td nowrap='nowrap'>" + item["createdDate"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap'>" + item["controlNo"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap'>" + item["receiverName"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'>" + GetStatic.GetNegativeFigureOnBrac(item["cAmt"].ToString()) + "</td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'>" + GetStatic.GetNegativeFigureOnBrac(item["pAmt"].ToString()) + " (" + item["payoutCurr"].ToString() + ")</td>");
                sb.AppendLine("</tr>");
            }
            string br = "";
            for (int i = 0; i < rowSpan; i++)
            {
                br += "<br/>";
            }
            rowSpanDiv.InnerHtml = br;
            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan='3' align='right'><strong>Total : </td>");
            sb.AppendLine("<td align='right'>" + GetStatic.GetNegativeFigureOnBrac(sending.ToString()) + "</td>");
            sb.AppendLine("<td align='right'> </td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table></div>");

            divStmt.InnerHtml = sb.ToString();
        }
    }
}