using System;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Agent.ReprintReceipt
{
    public partial class SendIntlReceipt : System.Web.UI.Page
    {
        private readonly ReceiptDao obj = new ReceiptDao();
        private readonly SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {

            sl.CheckSession();
            GetStatic.AlertMessage(this.Page);
            ShowData();
            ShowMultipleReceipt();

        }
        private void ShowMultipleReceipt()
        {
            DataRow dr = obj.GetInvoiceMode(GetStatic.GetUser());
            if (dr == null)
                return;

            if (dr["mode"].ToString().Equals("Single"))
                return;
            var sb = new StringBuilder();
            Printreceiptdetail.RenderControl(new HtmlTextWriter(new StringWriter(sb)));
            //Printreceiptdetail.ID = "receiptdt";
            multreceipt.InnerHtml = sb.ToString();
        }

        private string GetControlNo()
        {
            return GetStatic.ReadQueryString("controlNo", "");
        }

        protected void ShowData()
        {
            lblControlNo.Text = GetStatic.GetTranNoName();
            DataSet ds = obj.GetSendIntlReceipt(GetControlNo(), GetStatic.GetUser(), "S");
            if (ds.Tables.Count >= 1)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    //Load Sender Information
                    DataRow sRow = ds.Tables[0].Rows[0];
                    sName.Text = sRow["senderName"].ToString();
                    sAddress.Text = sRow["sAddress"].ToString();
                    sCountry.Text = sRow["sCountryName"].ToString();
                    sContactNo.Text = sRow["sContactNo"].ToString();
                    sIdType.Text = sRow["sIdType"].ToString();
                    sIdNo.Text = sRow["sIdNo"].ToString();
                    //sEmail.Text = sRow["email"].ToString();

                    //Load Receiver Information
                    rName.Text = sRow["receiverName"].ToString();
                    rAddress.Text = sRow["rAddress"].ToString();
                    rCountry.Text = sRow["rCountryName"].ToString();
                    rContactNo.Text = sRow["rContactNo"].ToString();
                    rIdType.Text = sRow["rIdType"].ToString();
                    rIdNo.Text = sRow["rIdNo"].ToString();
                    relationship.Text = sRow["relWithSender"].ToString();

                    //Load Sending Agent Detail
                    sAgentName.Text = sRow["sAgentName"].ToString();
                    sBranchName.Text = sRow["sBranchName"].ToString();
                    sAgentCountry.Text = sRow["sAgentCountry"].ToString();
                    sAgentLocation.Text = sRow["sAgentLocation"].ToString();
                    sContact.Text = sRow["agentPhone1"].ToString();

                    //Load Payout location detail
                    pAgentCountry.Text = sRow["pAgentCountry"].ToString();
                    pAgentDistrict.Text = sRow["pAgentDistrict"].ToString();
                    pAgentLocation.Text = sRow["pAgentLocation"].ToString();

                    //Load Txn Amount detail
                    modeOfPayment.Text = sRow["paymentMethod"].ToString();
                    transferAmount.Text = GetStatic.ShowDecimal(sRow["tAmt"].ToString());
                    serviceCharge.Text = GetStatic.ShowDecimal(sRow["serviceCharge"].ToString());
                    handling.Text = GetStatic.ShowDecimal(sRow["handlingFee"].ToString());
                    exRate.Text = sRow["exRate"].ToString();

                    total.Text = GetStatic.ShowDecimal(sRow["cAmt"].ToString());
                    //exchangeRate.Text = aRow["exRate"].ToString();

                    payoutAmt.Text = GetStatic.ShowDecimal(sRow["pAmt"].ToString());
                    lblDate.Text = sRow["createdDate"].ToString();
                    //payoutAmtFigure.Text = GetStatic.NumberToWord(sRow["pAmt"].ToString());
                    payoutAmtFigure.Text = NumberToWordsConverter.NumberToWord(GetStatic.ParseDouble(sRow["pAmt"].ToString()));

                    collCurr.Text = sRow["collCurr"].ToString();
                    scCurr.Text = sRow["collCurr"].ToString();
                    transCurr.Text = sRow["collCurr"].ToString();
                    PCurr.Text = sRow["payoutCurr"].ToString();

                    if (sRow["paymentMethod"].ToString().ToLower() == "bank deposit")
                    {
                        bankShowHide.Visible = true;
                        accNum.Text = sRow["accountNo"].ToString();
                        bankName.Text = sRow["BankName"].ToString();
                        BranchName.Text = sRow["BranchName"].ToString();
                    }

                }
                userFullName.Text = GetStatic.ReadSession("fullname", "");
                controlNo.Text = GetControlNo();

                //Load Message
                if (ds.Tables[1].Rows.Count > 0)
                {
                    DataRow mRow = ds.Tables[1].Rows[0];
                    userFullName.Text = mRow["sUserFullName"].ToString();
                    headMsg.InnerHtml = "";
                    commonMsg.InnerHtml = "";
                    countrySpecificMsg.InnerHtml = "";

                    headMsg.InnerHtml = mRow["headMsg"].ToString();
                    commonMsg.InnerHtml = mRow["commonMsg"].ToString();
                    countrySpecificMsg.InnerHtml = mRow["countrySpecificMsg"].ToString();
                }
            }
        }
    }
}