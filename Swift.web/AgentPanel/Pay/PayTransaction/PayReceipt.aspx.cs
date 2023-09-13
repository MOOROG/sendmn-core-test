using Swift.DAL.BL.Remit.Reconciliation;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.BL.System.Utilities;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace Swift.web.AgentPanel.Pay.PayTransaction
{
    public partial class PayReceipt : System.Web.UI.Page
    {
        private readonly ReceiptDao obj = new ReceiptDao();
        private readonly SwiftLibrary sl = new SwiftLibrary();
        private TxnDocumentsDao _Dao = new TxnDocumentsDao();
        private const string DocUploadFunctionId = "40122100";
        private readonly ScannerSetupDao _scanner = new ScannerSetupDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();

            if (!IsPostBack)
            {
                string reqMethod = Request.Form["MethodName"];
                if (reqMethod == "docCheck")
                {
                    CheckDocument();
                }
                else if (reqMethod == "CheckAuth")
                {
                    CheckAuth();
                }
                ShowDataLocal();
                ShowMultipleReceipt();
                hdnAgentId.Value = GetStatic.GetAgent();
                hdnTranId.Value = tranNo.Text;
                hdnIcn.Value = controlNo.Text;
                var sc = _scanner.GetUserScanner(GetStatic.GetUser());
                hdnscanner.Value = sc;
            }
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
                    hdnTxnType.Value = sRow["tranType"].ToString();
                    if (sRow["rMemId"].ToString() == "")
                        rDisMemId.Visible = false;
                    else
                    {
                        rDisMemId.Visible = true;
                        rMemId.Text = sRow["rMemId"].ToString();
                    }

                    agentName.Text = sRow["pAgentName"].ToString();
                    branchName.Text = sRow["pBranchName"].ToString();
                    agentLocation.Text = sRow["pAgentAddress"].ToString();
                    agentCountry.Text = sRow["pAgentCountry"].ToString();

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

                    var rchequeNo = sRow["rChqNo"].ToString();
                    if (rchequeNo.Trim() == "")
                        trChequeNo.Visible = false;
                    else
                    {
                        chequeNo.Text = sRow["rChqNo"].ToString();
                        trChequeNo.Visible = true;
                    }

                    double pAmt = double.Parse(sRow["pAmt"].ToString());
                    var limitAmount = GetStatic.GetPayAmountLimit(GetControlNo());
                    if (pAmt > limitAmount && !string.IsNullOrEmpty(sRow["rBank"].ToString()))
                    {
                        divCompliance.Visible = true;
                        trRBank.Visible = true;
                        rBank.Text = sRow["rBank"].ToString();
                        rBankBranch.Text = sRow["rBankBranch"].ToString();
                        rChequeNo.Text = sRow["rChqNo"].ToString();
                    }
                    if (pAmt > limitAmount && string.IsNullOrEmpty(sRow["rBank"].ToString())
                            && (!string.IsNullOrEmpty(sRow["rAccountNo"].ToString()) || !string.IsNullOrEmpty(sRow["rChqNo"].ToString())))
                    {
                        divCompliance.Visible = true;
                        trRBank1.Visible = true;
                        rAccountNo.Text = sRow["rAccountNo"].ToString();
                        rChqNo.Text = sRow["rChqNo"].ToString();
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

        private void CheckDocument()
        {
            string agentId = Request.Form["agentId"];
            string icn = Request.Form["icn"];
            string tranId = Request.Form["tranId"];
            string vouType = Request.Form["vouType"];
            DataTable dt = _scanner.CheckDocument(agentId, tranId, icn, vouType);
            Response.ContentType = "text/plain";
            string json = DataTableToJSON(dt);
            Response.Write(json);
            Response.End();
        }

        private void CheckAuth()
        {
            var up = sl.HasRight(DocUploadFunctionId);
            var sc = sl.HasRight(DocUploadFunctionId);
            var er = 0;
            Response.ContentType = "text/plain";
            string json = "[{\"errorCode\":\"" + er + "\",\"upload\":\"" + up + "\",\"scan\":\"" + sc + "\"}]";
            Response.Write(json);
            Response.End();
        }

        public static string DataTableToJSON(DataTable table)
        {
            List<Dictionary<string, object>> list = new List<Dictionary<string, object>>();
            foreach (DataRow row in table.Rows)
            {
                Dictionary<string, object> dict = new Dictionary<string, object>();
                foreach (DataColumn col in table.Columns)
                {
                    dict[col.ColumnName] = row[col];
                }
                list.Add(dict);
            }
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            return serializer.Serialize(list);
        }
    }
}