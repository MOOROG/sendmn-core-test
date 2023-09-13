﻿using System;
using Swift.web.Library;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;

namespace Swift.web.Remit.Transaction.ModifyPayoutLocation
{
    public partial class Modify : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20122400";
        private readonly StaticDataDdl sd = new StaticDataDdl();
        private readonly ModifyTransactionDao mtd = new ModifyTransactionDao();
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!IsPostBack)
                {
                    Authenticate();
                }
                DisplayLabel();
                lblOldValue.Text = getOldValue();
            }
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
        private void DisplayLabel()
        {
            lblFieldName.Text = GetLabel();
            if (getFieldName() == "pAgentLocation")//paying agent location
            {
                sd.SetDDL(ref ddlNewValue, "EXEC proc_apiLocation @flag='l'", "districtCode", "districtName", "", "Select");
            }

            if (getFieldName() == "accountNo")// bank account number
            {
                rptShowOther.Visible = false;
                rptAccountNo.Visible = true;
            }

            if (getFieldName() == "BankName")// bank & branch 
            {
                showBranch.Visible = true;
                rptShowOther.Visible = false;
                sd.SetDDL(ref ddlBank, "EXEC proc_agentMaster @flag = 'bankList'", "agentId", "agentName", "", "Select");
            }

            if (getFieldName() == "BranchName")//bank branch
            {
                string BankId = mtd.SelectBankNameById(GetStatic.GetUser(), GetTranId().ToString());
                sd.SetDDL(ref ddlNewValue, "EXEC proc_agentMaster @flag = 'bbl', @parentId = " + BankId + "", "agentId", "agentName", "", "Select");
            }
            if (getFieldName() == "pBranchName")//paying Branch
            {
                rptShowOther.Visible = false;
                rptAccountNo.Visible = false;
                rptBranch.Visible = true;
            }
        }

        private string GetLabel()
        {
            return GetStatic.ReadQueryString("label", "");
        }

        private string getFieldName()
        {
            return GetStatic.ReadQueryString("fieldName", "");
        }

        private string getOldValue()
        {
            return GetStatic.ReadQueryString("oldValue", "");
        }
        protected long GetTranId()
        {
            return GetStatic.ReadNumericDataFromQueryString("tranId");
        }
        private void PopulateDll()
        {
           
        }
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            OnUpdate();
        }
        private void OnUpdate()
        {
            string newValue = "";

            if (getFieldName() == "accountNo")
                newValue = txtNewValue.Text;
            else if (getFieldName() == "pBranchName")
                newValue = hdnBranchId.Value;
            else
                newValue = ddlNewValue.Text;

            /*
            if (GetStatic.GetIsApiFlag() == "Y")
            {
                if (getFieldName() == "pAgentLocation")
                {
                    var ds = mtd.UpdatePayoutLocationApi(GetStatic.GetUser(), GetTranId().ToString(), newValue);
                    if (ds == null)
                        return;
                    if(ds.Tables.Count > 1)
                    {
                        
                    }
                }
            }
             * */
            DbResult dbResult = mtd.UpdateTransactionPayoutLocation(GetStatic.GetUser()
                                               , GetTranId().ToString()
                                               , getFieldName()
                                               , getOldValue()
                                               , newValue
                                               , ddlBank.Text
                                               , ddlBranch.Text
                                               , GetStatic.GetIsApiFlag()
                                               , GetStatic.GetSessionId()
                                               );
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            var mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");

            var scriptName = "CallBack";
            var functionName = "CallBack('" + mes + "');";
            GetStatic.CallBackJs1(Page, scriptName, functionName);
        }

        protected void ddlBank_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlBank.Text!="")
            {
                sd.SetDDL(ref ddlBranch, "EXEC proc_agentMaster @flag = 'bbl', @parentId = " + ddlBank.Text + "", "agentId", "agentName", "", "Select");
            }
        }
    }
}