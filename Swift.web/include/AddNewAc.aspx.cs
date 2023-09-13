using Swift.DAL.ExchangeSystem;
using Swift.web.Library;
using System;

namespace Swift.web.include
{
    public partial class AddNewAc : System.Web.UI.Page
    {
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private readonly AccountStatementDao _asd = new AccountStatementDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Misc.MakeAmountTextBox(ref lienAmt);
                Misc.MakeAmountTextBox(ref systemResAmt);
                Misc.MakeAmountTextBox(ref drBalLimit);
                breadCrumb.InnerHtml = "Add Account Ledger Group";
                frmTitle.InnerHtml = "Add Account Ledger Group";
                PopulateDdl();
                btnUpdate.Visible = false;
                if (!string.IsNullOrEmpty(GetId()) && GetFlag() != "g")
                {
                    breadCrumb.InnerHtml = "Edit Account Ledger Group";
                    frmTitle.InnerHtml = "Edit Account Ledger Group";
                    PopulateData();
                }
                else
                    GenerateAccountNum();
            }
        }

        private void GenerateAccountNum()
        {
            string sql = "Exec spa_createAccountNumber 'a','" + GetId() + "'";
            string acNumber = _asd.GetSingleResult(sql);
            accNum.Text = acNumber.ToString();
            accNum.Attributes.Add("readonly", "readonly");
        }

        private void PopulateData()
        {
            var dr = _asd.PupulateDataById(GetId());
            if (dr == null)
                return;
            GLCode.SelectedValue = dr["gl_code"].ToString();
            GLCode.Enabled = false;
            accNum.Text = dr["acct_num"].ToString();
            accNum.Enabled = false;
            acBalance.Text = dr["available_amt"].ToString();
            accName.Text = dr["acct_name"].ToString();
            accReportCode.Text = dr["acct_rpt_code"].ToString();
            accOwnership.Text = dr["acct_ownership"].ToString();
            agentName.SelectedValue = dr["agent_id"].ToString();
            lienAmt.Text = dr["lien_amt"].ToString();
            lienRemarks.Text = dr["lien_remarks"].ToString();
            systemResAmt.Text = dr["system_reserved_amt"].ToString();
            systemResRem.Text = dr["system_reserver_remarks"].ToString();
            drBalLimit.Text = dr["dr_bal_lim"].ToString();
            limitExp.Text = dr["lim_expiry"].ToString();
            accCurrency.Text = dr["ac_currency"].ToString();
            accSubGroup.Text = dr["ac_sub_group"].ToString();
            accGroup.Text = dr["ac_group"].ToString();
            createdBy.Text = dr["created_By"].ToString();
            createdDate.Text = dr["created_Date"].ToString();
            modifiedBy.Text = dr["modified_By"].ToString();
            modifiedDate.Text = dr["modified_Date"].ToString();
            addNewAccount.Visible = false;
            acBalance.Visible = true;
            populate.Visible = true;
            btnUpdate.Visible = true;
        }

        protected void addNewAccount_Click(object sender, EventArgs e)
        {
            Update();
        }

        private void Update()
        {
            string gl_code = GLCode.SelectedValue;
            string accountNum = accNum.Text;
            string accountName = accName.Text;
            if (accountNum == "" || accountName == "")
            {
                GetStatic.AlertMessage(this, "* fields are required !");
                return;
            }
            string accountReportCode = accReportCode.Text;
            string BankLetterRefNo = accBankLetterRefNo.Text;
            string accountOwnership = accOwnership.Text;
            string agent = agentName.SelectedValue;
            string lAmt = lienAmt.Text;
            string lRemarks = lienRemarks.Text;
            string sysResAmt = systemResAmt.Text;
            string sysResRemarks = systemResRem.Text;
            string debitBalanceLimit = drBalLimit.Text;
            string limitExpiry = limitExp.Text;
            string accountCurrency = accCurrency.Text;
            string accountSubGroup = accSubGroup.Text;
            string accountGroup = accGroup.Text;
            string user = GetStatic.GetUser();
            string id = "";
            if (GetFlag() != "g")
                id = GetId();

            string branch = GetStatic.GetAgentId();

            var dbResult = _asd.UpdateStatement(user, id, gl_code, accountNum, accountName, accountReportCode, accountOwnership, "",
                                                     "", agent, lAmt, lRemarks, sysResAmt, sysResRemarks, debitBalanceLimit
                                                     , limitExpiry, accountCurrency, accountSubGroup, accountGroup, "", BankLetterRefNo, branch);

            if (dbResult.ErrorCode == "0")
            {
                GetStatic.AlertMessage(this, dbResult.Msg);
                return;
            }
            else
            {
                GetStatic.AlertMessage(this, dbResult.Msg);
                return;
            }
        }

        private string GetId()
        {
            string id = GetStatic.ReadQueryString("ID", "");
            return id;
        }

        private string GetFlag()
        {
            string a = GetStatic.ReadQueryString("flag", "");
            return a;
        }

        private void PopulateDdl()
        {
            RemittanceLibrary r = new RemittanceLibrary();
            _sl.SetDDL(ref agentName, "EXEC proc_dropDownList @flag='branchList'", "BRANCH_ID", "BRANCH_NAME", "", "Select..");
            _sl.SetDDL(ref GLCode, "SELECT gl_code,gl_name FROM GL_Group WITH(NOLOCK) WHERE gl_code = " + GetId() + "", "gl_code", "gl_name", "", "");
            r.SetDDL(ref accCurrency, "EXEC Proc_dropdown_remit @FLAG='Currency'", "val", "Name", "", "Select Currency");
            _sl.SetDDL(ref accSubGroup, "EXEC spa_refmaster @flag='c',@ref_rec_type='7'", "ref_code", "refDesc", "", "Select..");
            _sl.SetDDL(ref accGroup, "EXEC spa_refmaster @flag='c',@ref_rec_type='8'", "ref_code", "refDesc", "", "Select..");
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            Update();
        }
    }
}