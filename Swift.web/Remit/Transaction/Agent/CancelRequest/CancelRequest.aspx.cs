using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Agent.CancelRequest
{
    public partial class CancelRequest : Page
    {
        protected const string GridName = "grid_canceltrn";

        private const string ViewFunctionId = "40101200";
        private const string ProcessFunctionId = "40101210";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly CancelTransactionDao obj = new CancelTransactionDao();
        private StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                controlNo.Focus();
            }
            GetStatic.ResizeFrame(Page);
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
            btnCancel.Visible = _sdd.HasRight(ProcessFunctionId);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            //LoadGrid("");
            LoadByControlNo(controlNo.Text);
        }

        protected void btnTranSelect_Click(object sender, EventArgs e)
        {
            string id = grid.GetRowId(GridName);
            //LoadGrid(id);
            LoadByTranId(id);
        }

        private void LoadByTranId(string id)
        {
        }

        private void LoadByControlNo(string cNo)
        {
            //if (string.IsNullOrEmpty(cNo))
            //{
            //    cNo = grid.GetRowId(GridName);
            //}
            DataSet ds = obj.SelectTransactionAgent(cNo, GetStatic.GetUser());
            DbResult dbResult = obj.ParseDbResult(ds.Tables[0]);
            if (dbResult.ErrorCode != "0")
            {
                ManageMessage(dbResult);
                if(dbResult.ErrorCode == "1000")
                    _sdd.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "N");
                return;
            }
            DataRow row = ds.Tables[1].Rows[0];
            if (row == null)
            {
                divTranDetails.Visible = false;
                lblControlNo.Text = "";
                return;
            }
            tblSearch.Visible = false;
            divTranDetails.Visible = true;
            _sdd.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "Y");
            tranNoName.Text = GetStatic.GetTranNoName();
            lblControlNo.Text = row["controlNo"].ToString();
            lblStatus.Text = row["tranStatus"].ToString();
            createdBy.Text = row["createdBy"].ToString();
            createdDate.Text = row["createdDate"].ToString();
            approvedBy.Text = row["approvedBy"].ToString();
            approvedDate.Text = row["approvedDate"].ToString();

            sName.Text = row["senderName"].ToString();
            sAddress.Text = row["sAddress"].ToString();
            sCountry.Text = row["sCountryName"].ToString();
            sContactNo.Text = row["sContactNo"].ToString();
            sIdType.Text = row["sIdType"].ToString();
            sIdNo.Text = row["sIdNo"].ToString();
            sEmail.Text = row["sEmail"].ToString();

            rName.Text = row["receiverName"].ToString();
            rAddress.Text = row["rAddress"].ToString();
            rCountry.Text = row["rCountryName"].ToString();
            rContactNo.Text = row["rContactNo"].ToString();
            rIdType.Text = row["rIdType"].ToString();
            rIdNo.Text = row["rIdNo"].ToString();

            sAgentName.Text = row["sAgentName"].ToString();
            sBranchName.Text = row["sBranchName"].ToString();
            sAgentCountry.Text = row["sAgentCountry"].ToString();
            sAgentCity.Text = row["sAgentCity"].ToString();
            sAgentDistrict.Text = row["sAgentDistrict"].ToString();
            sAgentLocation.Text = row["sAgentLocation"].ToString();

            pAgentName.Text = row["pAgentName"].ToString();
            pBranchName.Text = row["pBranchName"].ToString();
            pAgentCountry.Text = row["pAgentCountry"].ToString();
            pAgentCity.Text = row["pAgentCity"].ToString();
            pAgentDistrict.Text = row["pAgentDistrict"].ToString();
            pAgentLocation.Text = row["pAgentLocation"].ToString();

            total.Text = GetStatic.FormatData(row["cAmt"].ToString(), "M");
            totalCurr.Text = row["collCurr"].ToString();
            serviceCharge.Text = GetStatic.FormatData(row["serviceCharge"].ToString(), "M");
            scCurr.Text = row["collCurr"].ToString();
            transferAmount.Text = GetStatic.FormatData(row["tAmt"].ToString(), "M");
            tAmtCurr.Text = row["collCurr"].ToString();
            payoutAmt.Text = GetStatic.FormatData(row["pAmt"].ToString(), "M");
            pAmtCurr.Text = row["payoutCurr"].ToString();

            tranStatus.Text = row["tranStatus"].ToString();
            modeOfPayment.Text = row["paymentMethod"].ToString();
            payoutMsg.Text = row["payoutMsg"].ToString();

            string defCurrency = "";

            string scriptName = "";
            string functionName = "";
            GetStatic.CallBackJs1(Page, scriptName, functionName);
        }

        private void CancelRequestTran()
        {
            DbResult dbResult = obj.CancelRequest(GetStatic.GetUser(), lblControlNo.Text, cancelReason.Text);
            ManageMessage(dbResult);
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            CancelRequestTran();
        }

        private void ManageMessage(DbResult dbResult)
        {
            var url = "CancelRequest.aspx";
            string mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");

            string scriptName = "CallBack";
            string functionName = "CallBack('" + mes + "','" + url + "');";
            GetStatic.CallBackJs1(Page, scriptName, functionName);
        }
    }
}