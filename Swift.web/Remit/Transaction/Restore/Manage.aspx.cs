using Swift.web.Library;
using System;
using System.Collections.Generic;
using Swift.DAL.Remittance.Transaction.ThirdParty.XPressMoney;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.DAL.SwiftDAL;
using Swift.DAL.BL.System.Utility;

namespace Swift.web.Remit.Transaction.Restore
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "20123600";
        protected void Page_Load(object sender, EventArgs e)
        {
            _sdd.CheckSession();
            if (!IsPostBack)
            {
                //Authenticate();
                ShowData2();
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        protected void Pay_Click(object sender, EventArgs e)
        {
            Save();
        }

        private string GetRowId()
        {
            return GetStatic.ReadNumericDataFromQueryString("rowId").ToString();
        }

        private string GetProvider()
        {
            return GetStatic.ReadQueryString("provider", "");
        }

        private void Save()
        {
            var rowId = GetRowId();
            var branchId = agentId.Value;
            var provider = GetProvider();
            if (string.IsNullOrWhiteSpace(provider))
            {
                GetStatic.AlertMessage(this, "Something is missing,Re-load the Agent Details");
                return;
            }
            DbResult dr = null;
            //if (provider.Equals(Utility.GetgblAgentId()))
            //{
            //    var glbDao = new GlobalBankDao();
            //    dr = glbDao.RestoreTransaction(branchId, branchName.Text, GetStatic.GetUser(), rowId, GetStatic.ReadWebConfig("gblBranchMapCode"));
            //}
            ////else if (provider.Equals(Utility.GetCEAgentId()))
            //{
            //    var ceDao = new CashExpressDao();
            //    dr = ceDao.RestoreTransaction(branchId, branchName.Text, GetStatic.GetUser(), rowId);
            //}
            if (dr != null && !dr.ErrorCode.Equals("0"))
            {
                GetStatic.AlertMessage(Page, dr.Msg);
            }
            else
            {
                Response.Redirect("List.aspx");
            }

        }

        private void LoadAgentDetails(string branchId)
        {
            var xpd = new XpressPayDao();
            LoadAgentDetails(xpd.GetAgentDetail(branchId));
        }

        private void LoadAgentDetails(DataRow row)
        {
            if (row == null)
            {
                var dbr = new DbResult();
                dbr.SetError("1", "Could not load the Agent Details", "");
                GetStatic.PrintMessage(Page, dbr);
                btnPay.Enabled = false;
                return;
            }
            else
            {
                agentName.Text = row["parentName"].ToString();
                branchName.Text = row["agentName"].ToString();
                agentLocation.Text = row["agentLocation"].ToString();
                agentCountry.Text = row["agentCountry"].ToString();
                agentContact.Text = row["Phone"].ToString();
                agentId.Value = row["agentId"].ToString();
                agentId.Text = row["agentName"].ToString();
            }
        }

        private void ShowData()
        {
            var xpd = new XpressPayDao();
            lblControlNo.Text = GetStatic.GetTranNoName();
            var rowId = GetRowId();
            var rows = xpd.GetTXNDetails(rowId);

            if (rows == null || rows.Count < 2)
            {
                GetStatic.AlertMessage(Page, "Could not load the details. Server error.");
                return;
            }

            LoadAgentDetails(rows[1]);

            var row = rows[0];
            hddRowId.Value = row["rowId"].ToString();

            lblControlNo.Text = row["xpin1"].ToString();
            sName.Text = row["customerFirstName"].ToString() + " " + row["customerMiddleName"].ToString() + " " + row["customerLastName"].ToString();
            sAddress.Text = row["customerAddress1"].ToString() + " " + row["customerAddress2"].ToString();
            sCity.Text = row["customerAddressCity"].ToString();
            sCountry.Text = row["customerAddressCountry"].ToString();
            sContactNo.Text = row["customerMobile"].ToString() + (row["customerMobile"].ToString() != "" ? ", " : "") + row["customerPhone"].ToString();

            sAgentCountry.Text = row["sendingCountry"].ToString();
            sendAgent.Text = row["sendingAgentName"].ToString();

            rName.Text = row["beneficiaryFirstName"].ToString() + " " + row["beneficiaryMiddleName"].ToString() + " " + row["beneficiaryLastName"].ToString();
            rAddress.Text = row["beneficiaryAddress1"].ToString() + " " + row["beneficiaryAddress2"].ToString();
            rCity.Text = row["beneficiaryAddressCity"].ToString();
            rCountry.Text = row["receiveCountry"].ToString();
            recIdType.Text = row["beneficiaryID"].ToString();
            recIdNo.Text = row["beneficiaryID"].ToString();
            rContactNo.Text = row["beneficiaryMobile"].ToString() + (row["beneficiaryMobile"].ToString() != "" ? ", " : "") + row["beneficiaryPhone"].ToString();

            payoutAmount.Text = row["payoutAmount"].ToString();
            payoutAmount.Text = GetStatic.FormatData(row["payoutAmount"].ToString(), "M");
            pAmtFigure.Text = GetStatic.NumberToWord(row["payoutAmount"].ToString());

            payoutCurr.Text = row["payoutCcyCode"].ToString();
            paymentType.Text = row["transactionMode"].ToString();
            rIdType.Text = row["rIdType"].ToString();
            rIdNumber.Text = row["rIdNumber"].ToString();
            placeOfIssue.Text = row["PlaceOfIssue"].ToString();
            relativeName.Text = row["rRelativeName"].ToString();
            relationType.Text = row["RelationType"].ToString();
            mobileNo.Text = row["rContactNo"].ToString();
        }
        private void ShowData2()
        {
            lblControlNo.Text = GetStatic.GetTranNoName();
            var rowId = GetRowId();
            var provider = GetProvider();
            List<DataRow> rows = null;
            DataRow row = null;
            //if (provider.Equals(Utility.GetgblAgentId()))
            //{
            //    var glbDao = new GlobalBankDao();
            //    row = glbDao.GetTxnDetail(GetStatic.GetUser(), rowId);
            //}
            //else if (provider.Equals(Utility.GetCEAgentId()))
            //{
            //    var ceDao = new CashExpressDao();
            //    row = ceDao.GetTxnDetail(GetStatic.GetUser(), rowId);
            //}
            
            if (row == null || row.Table.Rows.Count == 0)
            {
                GetStatic.AlertMessage(Page, "Could not load the details. Server error.");
                return;
            }

            LoadAgentDetails(row["branchId"].ToString());
            hddRowId.Value = row["rowId"].ToString();

            lblControlNo.Text = row["controlNo"].ToString();
            sName.Text = row["sName"].ToString();// +" " + row["customerMiddleName"].ToString() + " " + row["customerLastName"].ToString();
            sAddress.Text = row["sAddress"].ToString();// +" " + row["customerAddress2"].ToString();
            sCity.Text = row["sCity"].ToString();
            sCountry.Text = row["sCountry"].ToString();
            sContactNo.Text = row["sMobile"].ToString();

            sAgentCountry.Text = row["sCountry"].ToString();
            sendAgent.Text = row["sAgentName"].ToString();

            rName.Text = row["rName"].ToString();// +" " + row["beneficiaryMiddleName"].ToString() + " " + row["beneficiaryLastName"].ToString();
            rAddress.Text = row["rAddress"].ToString();// +" " + row["beneficiaryAddress2"].ToString();
            rCity.Text = row["rCity"].ToString();
            rCountry.Text = row["rCountry"].ToString();
            recIdType.Text = row["rIdType"].ToString();
            recIdNo.Text = row["rIdNumber"].ToString();
            rContactNo.Text = row["rPhone"].ToString();// +(row["beneficiaryMobile"].ToString() != "" ? ", " : "") + row["beneficiaryPhone"].ToString();

            //payoutAmount.Text = row["pAmt"].ToString();
            payoutAmount.Text = GetStatic.FormatData(row["pAmt"].ToString(), "M");
            pAmtFigure.Text = GetStatic.NumberToWord(row["pAmt"].ToString());

            payoutCurr.Text = row["pCurr"].ToString();
            paymentType.Text = row["transactionMode"].ToString();
            rIdType.Text = row["rIdType"].ToString();
            rIdNumber.Text = row["rIdNumber"].ToString();
            placeOfIssue.Text = row["PlaceOfIssue"].ToString();
            relativeName.Text = row["rRelativeName"].ToString();
            relationType.Text = row["RelationType"].ToString();
            mobileNo.Text = row["rContactNo"].ToString();
        }

        protected void btnLoad_Click(object sender, EventArgs e)
        {
            LoadAgentDetails(agentId.Value);
        }
    }
}