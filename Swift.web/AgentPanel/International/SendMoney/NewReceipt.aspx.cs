using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AgentPanel.Send.SendTransactionIRH
{
    public partial class NewReceipt : System.Web.UI.Page
    {
        private readonly ReceiptDao obj = new ReceiptDao();
        private readonly SwiftLibrary sl = new SwiftLibrary();
        private const string ViewFunctionId = "40101400";
        private string payMode = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            ShowData();
            ShowMultipleReceipt();
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        private string GetInvoicePrintMode()
        {
            return GetStatic.ReadQueryString("invoicePrintMode", "");
        }

        private void ShowMultipleReceipt()
        {
            /*
            DataRow dr = obj.GetInvoiceMode(GetStatic.GetAgent());
            if (dr == null)
                return;

            if (!dr["mode"].ToString().Equals("Single"))
            {
                var sb = new StringBuilder();
                multreceipt.Visible = true;
            }
            */

            if (GetInvoicePrintMode().ToLower() == "s")
            {
                multreceipt.Visible = false;
            }
            else
            {
                multreceipt.Visible = true;
            }

            spnMsg.Visible = true;
            if (payMode.ToUpper() == "BANK DEPOSIT")
            {
                trAccno.Visible = true;
            }
        }

        private string GetControlNo()
        {
            return GetStatic.ReadQueryString("controlNo", "");
        }

        protected void ShowData()
        {
            ////controlNo.Text = GetStatic.GetTranNoName();
            DataSet ds = obj.GetSendIntlReceipt(GetControlNo(), GetStatic.GetUser(), "S");
            if (ds.Tables.Count >= 1)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    //Load Sender Information
                    DataRow sRow = ds.Tables[0].Rows[0];

                    payMode = sRow["paymentMethod"].ToString();
                    tPaymentMode.InnerText = sRow["paymentMethod"].ToString();
                    tPaymentMode1.InnerText = sRow["paymentMethod"].ToString();
                    preparedBy.InnerText = sRow["createdBy"].ToString().ToUpper();
                    preparedBy1.InnerText = sRow["createdBy"].ToString().ToUpper();
                    approvedBy.InnerText = sRow["approvedBy"].ToString().ToUpper();

                    sCustomerId.InnerText = sRow["sMemId"].ToString();
                    sCustomerId1.InnerText = sRow["sMemId"].ToString();
                    idExpiry.Text = sRow["idExpiry"].ToString();
                    sName.InnerText = sRow["senderName"].ToString();
                    sName1.InnerText = sRow["senderName"].ToString();
                    sCompanyName.InnerText = sRow["companyName"].ToString();
                    sCompanyName1.InnerText = sRow["companyName"].ToString();
                    sAddress.InnerText = sRow["sAddress"].ToString();
                    sAddress1.InnerText = sRow["sAddress"].ToString();
                    sNativeCountry.InnerText = sRow["sNativeCountry"].ToString();
                    sNativeCountry1.InnerText = sRow["sNativeCountry"].ToString();
                    sContactNo.InnerText = sRow["sContactNo"].ToString();
                    sContactNo1.InnerText = sRow["sContactNo"].ToString();
                    sIdType.InnerText = sRow["sIdType"].ToString().ToUpper();
                    sIdType1.InnerText = sRow["sIdType"].ToString().ToUpper();
                    sIdNo.InnerText = sRow["sIdNo"].ToString();
                    sIdNo1.InnerText = sRow["sIdNo"].ToString();
                    sEmail.InnerText = sRow["email"].ToString();
                    sEmail1.InnerText = sRow["email"].ToString();

                    //Load Receiver Information
                    rName.InnerText = sRow["receiverName"].ToString();
                    rName1.InnerText = sRow["receiverName"].ToString();
                    rAddress.InnerText = sRow["rAddress"].ToString();
                    rAddress1.InnerText = sRow["rAddress"].ToString();
                    rCountry.InnerText = sRow["rCountryName"].ToString();
                    rCountry1.InnerText = sRow["rCountryName"].ToString();
                    rPhone.InnerText = sRow["rContactNo"].ToString();
                    rPhone1.InnerText = sRow["rContactNo"].ToString();

                    //Load Payout location detail
                    bankName.InnerText = sRow["pBankName"].ToString() == "[Any Where]" ? sRow["rCountryName"].ToString() : sRow["pBankName"].ToString();
                    bankName1.InnerText = sRow["pBankName"].ToString() == "[Any Where]" ? sRow["rCountryName"].ToString() : sRow["pBankName"].ToString();
                    BranchName.InnerText = string.IsNullOrWhiteSpace(sRow["pBranchName"].ToString()) ? "" : sRow["pBranchName"].ToString();
                    BranchName1.InnerText = string.IsNullOrWhiteSpace(sRow["pBranchName"].ToString()) ? "" : sRow["pBranchName"].ToString();
                    accountNo.Text = sRow["accountNo"].ToString();
                    accountNo1.Text = sRow["accountNo"].ToString();

                    Occupation.Text = sRow["occupation"].ToString();
                    sof.Text = sRow["sourceOfFund"].ToString();
                    purpose.Text = sRow["purpose"].ToString();

                    tReceivingCountry.InnerText = sRow["pCountry"].ToString();
                    tReceivingCountry1.InnerText = sRow["pCountry"].ToString();
                    controlNo.InnerText = sRow["controlNo"].ToString();
                    controlNo1.InnerText = sRow["tranId"].ToString();
                    tDate.InnerText = sRow["createdDate"].ToString();
                    tDate1.InnerText = sRow["createdDate"].ToString();

                    dAmt.InnerText = sRow["cAmt"].ToString();
                    dAmt1.InnerText = sRow["cAmt"].ToString();
                    sCurr1.InnerText = "[" + sRow["collCurr"] + "]";
                    sCurr11.InnerText = "[" + sRow["collCurr"] + "]";
                    netServiceCharge.InnerText = GetStatic.ShowDecimal(sRow["netServiceCharge"].ToString());
                    netServiceCharge1.InnerText = GetStatic.ShowDecimal(sRow["netServiceCharge"].ToString());
                    sCurr2.InnerText = sRow["collCurr"].ToString();
                    sCurr21.InnerText = sRow["collCurr"].ToString();

                    sAmt.InnerText = sRow["tAmt"].ToString();
                    sAmt1.InnerText = sRow["tAmt"].ToString();
                    sCurr5.InnerText = sRow["collCurr"].ToString();
                    sCurr51.InnerText = sRow["collCurr"].ToString();
                    pCurr1.InnerText = sRow["payoutCurr"].ToString();
                    pCurr11.InnerText = sRow["payoutCurr"].ToString();
                    exRate.InnerText = sRow["exRate"].ToString();
                    exRate1.InnerText = sRow["exRate"].ToString();

                    pAmt.InnerText = GetStatic.ShowDecimal(sRow["pAmt"].ToString());
                    pAmt1.InnerText = GetStatic.ShowDecimal(sRow["pAmt"].ToString());
                    pCurr3.InnerText = "[" + sRow["payoutCurr"] + "]";
                    pCurr31.InnerText = "[" + sRow["payoutCurr"] + "]";

                    if (payMode.ToUpper() == "BANK DEPOSIT")
                    {
                        ////bankShowHide.Visible = true;
                        accountNo.Text = sRow["accountNo"].ToString();
                        accountNo1.Text = sRow["accountNo"].ToString();
                        bankName.InnerText = sRow["BankName"].ToString();
                        bankName1.InnerText = sRow["BankName"].ToString();
                        BranchName.InnerText = sRow["BranchName"].ToString();
                        BranchName1.InnerText = sRow["BranchName"].ToString();
                    }
                }

                //Load Message
                if (ds.Tables[1].Rows.Count > 0)
                {
                    DataRow mRow = ds.Tables[1].Rows[0];
                    HeadAddress.InnerHtml = mRow["headMsg"].ToString().Replace("|", "<br/>");
                    HeadAddress1.InnerHtml = mRow["headMsg"].ToString().Replace("|", "<br/>");
                    spnMsg.InnerHtml = mRow["countrySpecificMsg"].ToString();
                }
                if (ds.Tables[2].Rows.Count > 0)
                {
                    var sb = new StringBuilder("");
                    sb.AppendLine("<table width='100%;'><tr>");
                    sb.AppendLine("<th nowrap='nowrap' align='left'>Bank/Cash</th>");
                    sb.AppendLine("<th nowrap='nowrap' align='left'>V.No</th>");
                    sb.AppendLine("<th nowrap='nowrap' align='left'>Amount</th>");
                    sb.AppendLine("<th nowrap='nowrap' align='left'>Deposit Date </th>");
                    sb.AppendLine("<th nowrap='nowrap' align='left'>Narration</th></tr>");
                    for (int a = 0; a < ds.Tables[2].Rows.Count; a++)
                    {
                        sb.AppendLine("<tr>");
                        sb.AppendLine("<td align='left' style='font-size:11px;'>" + ds.Tables[2].Rows[a]["bankName"] + "</td>");
                        sb.AppendLine("<td align='left' style='font-size:11px;'>" + ds.Tables[2].Rows[a]["voucherNo"] + "</td>");
                        sb.AppendLine("<td align='left' style='font-size:11px;'>" + GetStatic.ShowDecimal(ds.Tables[2].Rows[a]["Amt"].ToString()) + "</td>");
                        sb.AppendLine("<td align='left' style='font-size:11px;'>" + ds.Tables[2].Rows[a]["collDate"] + "</td>");
                        sb.AppendLine("<td align='left' style='font-size:11px;'>" + ds.Tables[2].Rows[a]["narration"] + "</td>");
                        sb.AppendLine("</tr>");
                    }
                    sb.AppendLine("</table>");
                    Ddetail.InnerHtml = sb.ToString();
                }
            }
        }
    }
}