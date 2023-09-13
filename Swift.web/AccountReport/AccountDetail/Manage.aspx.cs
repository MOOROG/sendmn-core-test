using System;
using Swift.web.Library;
using Swift.DAL.ExchangeSystem;

namespace Swift.web.AccountReport.AccountDetail {
  public partial class Manage : System.Web.UI.Page {
    private SwiftLibrary _sl = new SwiftLibrary();
    private AccountStatementDao _accountStatementDao = new AccountStatementDao();
    private const string ViewFunctionId = "20150500";

    protected void Page_Load(object sender, EventArgs e) {
      _sl.CheckSession();
      if (!IsPostBack) {
        Authenticate();
        PopulateDdl();
        if (!string.IsNullOrEmpty(GetId())) {
          header.Text = "EDIT EXISTING ACCOUNT";
          // breadCrumb.Text = "EDIT EXISTING ACCOUNT";
          PopulateData();
        } else {
          header.Text = "OPEN NEW ACCOUNT";
          // breadCrumb.Text = "OPEN NEW ACCOUNT";
        }
      }
      accNum.Attributes.Add("readonly", "readonly");
    }

    private void Authenticate() {
      _sl.CheckAuthentication(ViewFunctionId);
    }

    private void PopulateData() {
      var dr = _accountStatementDao.PupulateDataById(GetId());
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
      frezRefCode.Text = dr["frez_ref_code"].ToString();
      accClsFlag.Text = dr["acct_cls_flg"].ToString();
      sendAgent.SelectedItem.Value = dr["agent_id"].ToString();
      sendAgent.SelectedItem.Text = dr["acct_name"].ToString();
      lienAmt.Text = dr["lien_amt"].ToString();
      lienRemarks.Text = dr["lien_remarks"].ToString();
      systemResAmt.Text = dr["system_reserved_amt"].ToString();
      systemResRem.Text = dr["system_reserver_remarks"].ToString();
      drBalLimit.Text = dr["dr_bal_lim"].ToString();
      limitExp.Text = dr["lim_expiry"].ToString();
      accCurrency.Text = dr["ac_currency"].ToString();
      accSubGroup.Text = dr["ac_sub_group"].ToString();
      accGroup.Text = dr["ac_group"].ToString();
      billByBill.SelectedValue = dr["bill_by_bill"].ToString();
      update.Visible = true;
      addNew.Visible = false;
      acBalance.Visible = true;
    }

    protected void addNewAccount_Click(object sender, EventArgs e) {
      Update();
    }

    private void Update() {
      string gl_code = GLCode.SelectedValue;
      string accountNum = accNum.Text;
      string accountName = accName.Text;
      string accountReportCode = accReportCode.Text;
      string BankLetterRefNo = accBankLetterRefNo.Text;
      string accountOwnership = accOwnership.Text;
      string freezeCode = frezRefCode.Text;
      string accountFlag = accClsFlag.Text;
      string agent = sendAgent.SelectedValue;
      string lAmt = lienAmt.Text;
      string lRemarks = lienRemarks.Text;
      string sysResAmt = systemResAmt.Text;
      string sysResRemarks = systemResRem.Text;
      string debitBalanceLimit = drBalLimit.Text;
      string limitExpiry = limitExp.Text;
      string accountCurrency = accCurrency.Text;
      string accountSubGroup = accSubGroup.Text;
      string accountGroup = accGroup.Text;
      string bill = billByBill.SelectedValue;
      string user = GetStatic.GetUser();
      string id = GetId();
      string branch = GetStatic.GetAgentId();

      var dbResult = _accountStatementDao.UpdateStatement(user, id, gl_code, accountNum, accountName, accountReportCode, accountOwnership, freezeCode,
                                               accountFlag, agent, lAmt, lRemarks, sysResAmt, sysResRemarks, debitBalanceLimit
                                               , limitExpiry, accountCurrency, accountSubGroup, accountGroup, bill, BankLetterRefNo, branch);

      if (dbResult.ErrorCode == "0") {
        Response.Redirect("List.aspx");
        return;
      } else {
        GetStatic.AlertMessage(this, dbResult.Msg);
        return;
      }
    }

    private string GetId() {
      return GetStatic.ReadQueryString("acct_id", "");
    }

    private void PopulateDdl() {
      //_sl.SetDDL(ref agentName, "EXEC proc_dropDownList @flag='branchList'", "BRANCH_ID", "BRANCH_NAME", "", "Select..");
      _sl.SetDDL(ref GLCode, "EXEC proc_dropDownList @flag='gl_group'", "gl_code", "gl_name", "", "Select..");
      //_sl.SetDDL(ref accCurrency, "EXEC proc_dropDownList @flag='currList'", "curr_code", "curr_name", "", "MYR");
      _sl.SetDDL(ref accSubGroup, "EXEC spa_refmaster @flag='c',@ref_rec_type='7'", "ref_code", "refDesc", "", "Select..");
      _sl.SetDDL(ref accGroup, "EXEC spa_refmaster @flag='c',@ref_rec_type='8'", "ref_code", "refDesc", "", "Select..");
      _sl.SetDDL(ref sendAgent, "exec [SendMnPro_Remit].dbo.[proc_agentMaster] @flag='al6'", "agentId", "agentName", "", "All");
    }

    protected void btnUpdate_Click(object sender, EventArgs e) {
      Update();
    }

    protected void GLCode_SelectedIndexChanged(object sender, EventArgs e) {
      string sql = "Exec spa_createAccountNumber 'a','" + GetId() + "'";
      string acNumber = _accountStatementDao.GetSingleResult(sql);
      accNum.Text = acNumber.ToString();
      //accNum.Attributes.Add("readonly", "readonly");
    }
  }
}