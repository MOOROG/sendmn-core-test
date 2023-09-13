using Swift.DAL.Remittance.CashAndVault;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;

namespace Swift.web.AgentNew.VaultTransfer
{
    public partial class TransferToVaultManage : System.Web.UI.Page
    {
        private string ViewFunctionId = "20179000";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private CashAndVaultDao cavDao = new CashAndVaultDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateDDL();
                Authenticate();
                Misc.MakeNumericTextbox(ref amount);
                transferDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                PopulateBranchDetails();
            }
        }

        private void PopulateDDL()
        {
            string sql = "EXEC PROC_VAULTTRANSFER @flag = 'VAULT-ACC-AGENT', @user = " + _sl.FilterString(GetStatic.GetUser()) + ", @agentId = " + _sl.FilterString(GetStatic.GetSettlingAgent());
            _sl.SetDDL(ref transferToDDL, sql, "ACCT_NUM", "ACCT_NAME", "", "");

            sql = "EXEC PROC_VAULTTRANSFER @flag = 'ACC-USER', @user = " + _sl.FilterString(GetStatic.GetUser());
            _sl.SetDDL(ref userAccountDDL, sql, "ACCT_NUM", "ACCT_NAME", "", "");
        }

        private void PopulateBranchDetails()
        {
            var row = cavDao.GetBranchCashDetails(GetStatic.GetUser(), GetStatic.GetBranch(), "limit-detail");

            cashAtCounter.Text = GetStatic.ShowDecimal(row["cashAtCounterUser"].ToString());
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void Transfer_Click(object sender, EventArgs e)
        {
            var amountVal = amount.Text;
            var tDateVal = transferDate.Text;
            var userIdAndAgentId = cavDao.GetUserIdAndBranch(GetStatic.GetUser(), amountVal, "counter");
            if (userIdAndAgentId["errorCode"].ToString() != "0")
            {
                GetStatic.AlertMessage(this, userIdAndAgentId["msg"].ToString());
                return;
            }
            var res = cavDao.SaveTransferToVaultNew(GetStatic.GetUser(), amountVal, tDateVal, userIdAndAgentId["userId"].ToString()
                , userIdAndAgentId["agentId"].ToString(), "C", userAccountDDL.SelectedValue, transferToDDL.SelectedValue);
            if (res == null)
            {
                var dbRes = new DbResult()
                {
                    ErrorCode = "0",
                    Msg = "Transfer to vault saved successfully and is waiting for approval!"
                };
                GetStatic.SetMessage(dbRes);
                Response.Redirect("VaultTransferList.aspx");
            }
        }
    }
}