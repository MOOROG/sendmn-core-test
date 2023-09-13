using System;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using Swift.DAL.BL.System.Utilities;
using System.Web.Script.Serialization;
using System.Collections.Generic;

namespace Swift.web.Remit.Transaction.Agent.ReprintReceipt
{
    public partial class SendReceipt : System.Web.UI.Page
    {
        private readonly ReceiptDao obj = new ReceiptDao();
        private readonly SwiftLibrary sl = new SwiftLibrary();
        //private const string FreeSimFunctionId = "40103000";
        private const string DocUploadFunctionId = "40122100";
        private readonly ScannerSetupDao _scanner = new ScannerSetupDao();

        protected void Page_Load(object sender, EventArgs e)
        {           

            Authenticate();
            ShowData();
            ShowMultipleReceipt();
            //if (sl.HasRight(FreeSimFunctionId))
            //    ShowCallBackFunction();

           hdnAgentId.Value=GetStatic.GetAgent();          
           hdnTranId.Value = tranNo.Text;
           hdnIcn.Value = controlNo.Text;        
           if (!IsPostBack)
           {
               string reqMethod = Request.Form["MethodName"];
               if (reqMethod == "docCheck")
               {
                   CheckDocument();
               }
               var sc = _scanner.GetUserScanner(GetStatic.GetUser());
               hdnscanner.Value = sc;
           }

           btnUpload.Visible = sl.HasRight(DocUploadFunctionId);
          btnScan.Visible = sl.HasRight(DocUploadFunctionId);


        }

        //private void ShowCallBackFunction()
        //{
        //    divFreeSim.Visible = true;
        //    string url = "";
        //    url = "../../../Campaign/FreeNcellSim/Manage.aspx?controlNo=" + controlNo.Text + "&tranType=Send&mode=flow";
        //    string scriptName = "CallBackForFreeSim";
        //    string functionName = "CallBackForFreeSim('" + url + "')";
        //    GetStatic.CallBackJs1(Page, scriptName, functionName);
        //}
        private void Authenticate()
        {
            sl.CheckSession();
           // btnFreeSim.Visible = sl.HasRight(FreeSimFunctionId);
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

        protected void ShowData()
        {
            lblControlNo.Text = GetStatic.GetTranNoName();
            DataSet ds = obj.GetSendReceipt(GetControlNo(), GetStatic.GetUser(), "S");
            if (ds.Tables.Count >= 1)
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

        //protected void btnFreeSim_Click(object sender, EventArgs e)
        //{
        //    Response.Redirect("../../../Campaign/FreeNcellSim/Manage.aspx?controlNo=" + controlNo.Text + "&tranType=Send");
        //}
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