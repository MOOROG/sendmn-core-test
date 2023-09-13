using System;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System.Data;
using System.Web.UI;
using System.IO;
using System.Text;

namespace Swift.web.Remit.Transaction.ThirdPartyTXN.Pay
{
    public partial class PayReceipt : System.Web.UI.Page
    {
        private readonly ReceiptDao obj = new ReceiptDao();
        private readonly SwiftLibrary sl = new SwiftLibrary();
        private const string FreeSimFunctionId = "40103000";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            ShowDataLocal();
            ShowMultipleReceipt();
        }
        private void Authenticate()
        {
            sl.CheckSession();
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
                    if (sRow["sMemId"].ToString() == "")
                        sDisMemId.Visible = false;
                    else
                    {
                        sDisMemId.Visible = true;
                        sMemId.Text = sRow["sMemId"].ToString();
                    }


                    rName.Text = sRow["receiverName"].ToString();
                    rAddressCountry.Text = string.IsNullOrWhiteSpace(sRow["rAddress"].ToString()) 
                                           ? sRow["rCountryName"].ToString() 
                                           : sRow["rAddress"].ToString() + "," + sRow["rCountryName"].ToString();
                    rContactNo.Text = sRow["rContactNo"].ToString();
                    rIdType.Text = sRow["rIdType"].ToString();
                    rIdNo.Text = sRow["rIdNo"].ToString();
                    if (sRow["rMemId"].ToString() == "")
                        rDisMemId.Visible = false;
                    else
                    {
                        rDisMemId.Visible = true;
                        sMemId.Text = sRow["rMemId"].ToString();
                    }

                    agentName.Text = sRow["pAgentName"].ToString();
                    branchName.Text = sRow["pBranchName"].ToString();
                    agentLocation.Text = sRow["pAgentAddress"].ToString();
                    agentCountry.Text = sRow["pAgentCountry"].ToString();

                    if (sRow["relationship"].ToString() == "")
                        sRel.Visible = false;
                    else
                    {
                        sRel.Visible = true;
                        sMemId.Text = sRow["relationship"].ToString();
                    }

                    relationship.Text = sRow["relationship"].ToString();
                    agentContact.Text = sRow["pAgentPhone"].ToString();
                    payoutCurr.Text = sRow["payoutCurr"].ToString();
                    modeOfPayment.Text = sRow["paymentMethod"].ToString();
                    if (modeOfPayment.Text.ToUpper() == "BANK DEPOSIT")
                    {
                        bankShowHide.Visible = true;
                        pBankName.Text = sRow["pBankName"].ToString();
                        pBankBranchName.Text = sRow["pBranchName"].ToString();
                        accNum.Text = sRow["accountNo"].ToString();
                    }
                    payoutAmt.Text = GetStatic.ShowDecimal(sRow["pAmt"].ToString());
                    lblDate.Text = sRow["paidDate"].ToString();
                    payoutAmtFigure.Text = GetStatic.NumberToWord(sRow["pAmt"].ToString());
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

        protected void btnFreeSim_Click(object sender, EventArgs e)
        {
            Response.Redirect("../../../Campaign/FreeNcellSim/Manage.aspx?controlNo=" + controlNo.Text + "&tranType=Paid");
        }
    }
}