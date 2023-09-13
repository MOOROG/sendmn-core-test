using System;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.ReprintVoucher
{
    public partial class SendReceipt : Page
    {
        private readonly ReceiptDao obj = new ReceiptDao();
        private readonly SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
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
            DataSet ds = obj.GetSendReceipt(GetControlNo(), GetStatic.GetUser(), "S");
            if (ds.Tables.Count >=1)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    //Load Sender Information
                    DataRow sRow = ds.Tables[0].Rows[0];
                    tranNo.Text = sRow["tranId"].ToString();
                    sName.Text = sRow["senderName"].ToString();
                    sAddress.Text = sRow["sAddress"].ToString();
                    sCountry.Text = sRow["sCountryName"].ToString();
                    sContactNo.Text = sRow["sContactNo"].ToString();
                    sIdType.Text = sRow["sIdType"].ToString();
                    sIdNo.Text = sRow["sIdNo"].ToString();
                    if (string.IsNullOrEmpty(sRow["sMemId"].ToString()))
                        sDisMemId.Visible = false;
                    else
                    {
                        sDisMemId.Visible = true;
                        sMemId.Text = sRow["sMemId"].ToString();
                    }
                    if (string.IsNullOrEmpty(sRow["pendingBonus"].ToString()))
                    {
                        trBonus.Visible = false;
                        trBonus1.Visible = false;
                    }
                    else
                    {
                        trBonus.Visible = true;
                        trBonus1.Visible = true;
                        pBonus.Text = sRow["pendingBonus"].ToString();
                        eBonus.Text = sRow["earnedBonus"].ToString();
                    }

                    //Load Receiver Information
                    rName.Text = sRow["receiverName"].ToString();
                    rAddress.Text = sRow["rAddress"].ToString();
                    rCountry.Text = sRow["rCountryName"].ToString();
                    rContactNo.Text = sRow["rContactNo"].ToString();
                    rIdType.Text = sRow["rIdType"].ToString();
                    rIdNo.Text = sRow["rIdNo"].ToString();
                    relationship.Text = sRow["relWithSender"].ToString();
                    if (sRow["rMemId"].ToString() == "")
                        rDisMemId.Visible = false;
                    else
                    {
                        rDisMemId.Visible = true;
                        rMemId.Text = sRow["rMemId"].ToString();
                    }
                        

                    //Load Sending Agent Detail
                    sAgentName.Text = sRow["sAgentName"].ToString();
                    sBranchName.Text = sRow["sBranchName"].ToString();
                    sAgentCountry.Text = sRow["sAgentCountry"].ToString();
                    sAgentLocation.Text = sRow["sAgentLocation"].ToString();
                    sContact.Text = sRow["agentPhone1"].ToString();

                    //send remarks
                    if (sRow["payoutMsg"].ToString() != "")
                        lblRemarks.Text = "Remarks: " + sRow["payoutMsg"].ToString();

                    //Load Payout location detail
                    pAgentCountry.Text = sRow["pAgentCountry"].ToString();
                    pAgentDistrict.Text = sRow["pAgentDistrict"].ToString();
                    pAgentLocation.Text = sRow["pAgentLocation"].ToString();

                    //Load Txn Amount detail
                    modeOfPayment.Text = sRow["paymentMethod"].ToString();
                    transferAmount.Text = GetStatic.ShowDecimal(sRow["tAmt"].ToString());
                    serviceCharge.Text = GetStatic.ShowDecimal(sRow["serviceCharge"].ToString());

                    total.Text = GetStatic.ShowDecimal(sRow["cAmt"].ToString());

                    payoutAmt.Text = GetStatic.ShowDecimal(sRow["pAmt"].ToString());
                    lblDate.Text = sRow["createdDate"].ToString();
                    payoutAmtFigure.Text = GetStatic.NumberToWord(sRow["pAmt"].ToString());

                    collCurr.Text = sRow["collCurr"].ToString();
                    scCurr.Text = sRow["collCurr"].ToString();
                    transCurr.Text = sRow["collCurr"].ToString();
                    PCurr.Text = sRow["payoutCurr"].ToString();

                    if (sRow["paymentMethod"].ToString() == "Bank Deposit")
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