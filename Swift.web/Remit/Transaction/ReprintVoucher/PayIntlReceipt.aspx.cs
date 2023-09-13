using System;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.ReprintVoucher
{
    public partial class PayIntlReceipt : System.Web.UI.Page
    {
        private readonly ReceiptDao obj = new ReceiptDao();
        private readonly SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            ShowDataLocal();
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

        private void ShowDataLocal()
        {
            lblControlNo.Text = GetStatic.GetTranNoName();
            DataSet ds = obj.GetPayIntlReceipt(GetControlNo(), GetStatic.GetUser(), "P");
            if (ds.Tables.Count >= 0)
            {
                //Load Sender Information
                if (ds.Tables[0].Rows.Count > 0)
                {
                    DataRow sRow = ds.Tables[0].Rows[0];
                    tranNo.Text = sRow["tranId"].ToString();
                    sName.Text = sRow["senderName"].ToString();
                    sAddress.Text = sRow["sAddress"].ToString();
                    sCountry.Text = sRow["sCountryName"].ToString();
                    sContactNo.Text = sRow["sContactNo"].ToString();
                    
                    rName.Text = sRow["receiverName"].ToString();
                    rAddress.Text = sRow["rAddress"].ToString();
                    rCountry.Text = sRow["rCountryName"].ToString();
                    rContactNo.Text = sRow["rContactNo"].ToString();
                    rIdType.Text = sRow["rIdType"].ToString();
                    rIdNo.Text = sRow["rIdNo"].ToString();

                    agentName.Text = sRow["pAgentName"].ToString();
                    branchName.Text = sRow["pBranchName"].ToString();
                    agentLocation.Text = sRow["pAgentAddress"].ToString();
                    agentCountry.Text = sRow["pAgentCountry"].ToString();


                    relationship.Text = sRow["relationship"].ToString();

                    agentContact.Text = sRow["pAgentPhone"].ToString();

                    payoutCurr.Text = sRow["payoutCurr"].ToString();
                    modeOfPayment.Text = sRow["paymentMethod"].ToString();

                    payoutAmt.Text = GetStatic.ShowDecimal(sRow["pAmt"].ToString());
                    lblDate.Text = sRow["paidDate"].ToString();
                    payoutAmtFigure.Text = GetStatic.NumberToWord(sRow["pAmt"].ToString());


                    var rchequeNo = sRow["rChqNo"].ToString();
                    if (rchequeNo.Trim() == "")
                        trChequeNo.Visible = false;
                    else
                    {
                        chequeNo.Text = sRow["rChqNo"].ToString();
                        trChequeNo.Visible = true;
                    }
                }

                userFullName.Text = GetStatic.ReadSession("fullname", "");
                controlNo.Text = GetControlNo();

                //Load Message
                if (ds.Tables[1].Rows.Count > 0)
                {
                    DataRow mRow = ds.Tables[1].Rows[0];
                    userFullName.Text = mRow["pUserFullName"].ToString();
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