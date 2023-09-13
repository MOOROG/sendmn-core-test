using System;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Agent.ReprintReceipt
{
    public partial class PayReceipt : System.Web.UI.Page
    {
        private readonly ReceiptDao obj = new ReceiptDao();
        private readonly SwiftLibrary sl = new SwiftLibrary();
       // private const string FreeSimFunctionId = "40103000";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            ShowDataLocal();
            ShowMultipleReceipt();
            //if (sl.HasRight(FreeSimFunctionId))
            //    ShowCallBackFunction();
        }

        private void ShowCallBackFunction()
        {
           // divFreeSim.Visible = true;
            string url = "";
            url = "../../../Campaign/FreeNcellSim/Manage.aspx?controlNo=" + controlNo.Text + "&tranType=Paid&mode=flow";
            string scriptName = "CallBackForFreeSim";
            string functionName = "CallBackForFreeSim('" + url + "')";
            GetStatic.CallBackJs1(Page, scriptName, functionName);
        }

        private void Authenticate()
        {
            sl.CheckSession();
            //btnFreeSim.Visible = sl.HasRight(FreeSimFunctionId);
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
            DataSet ds = obj.GetPayReceiptLocal(GetControlNo(), GetStatic.GetUser(), "P");
            if (ds.Tables.Count >= 0)
            {
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

                    var rchequeNo = sRow["chequeNo"].ToString();
                    if (rchequeNo.Trim() == "")
                        trChequeNo.Visible = false;
                    else
                    {
                        chequeNo.Text = sRow["chequeNo"].ToString();
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

        //protected void btnFreeSim_Click(object sender, EventArgs e)
        //{
        //    Response.Redirect("../../../Campaign/FreeNcellSim/Manage.aspx?controlNo=" + controlNo.Text + "&tranType=Paid");
        //}
    }
}