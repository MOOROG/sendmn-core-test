using Swift.DAL.AccountReport;
using Swift.DAL.Remittance.CashAndVault;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;

namespace Swift.web.AgentNew.CashTransfer
{
    public partial class Transfer : System.Web.UI.Page
    {
        private string ViewFunctionId = "20210000";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private AccountStatementDAO cavDao = new AccountStatementDAO();
        private CashAndVaultDao cashDao = new CashAndVaultDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                PopulateDDL();
                Misc.MakeNumericTextbox(ref amount);
                transferDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                PopulateAvailableBalance();
            }
        }

        private void PopulateAvailableBalance()
        {
            var row = cashDao.GetBranchCashDetails(GetStatic.GetUser(), GetStatic.GetSettlingAgent(), "limit-detail-a");

            availableBalance.Text = GetStatic.ShowDecimal(row["cashAtBranch"].ToString());
        }

        public void PopulateDDL()
        {
            string sql = "EXEC PROC_VAULTTRANSFER @flag = 'VAULT-ACC-AGENT', @user = " + _sl.FilterString(GetStatic.GetUser()) + ", @agentId = " + _sl.FilterString(GetStatic.GetSettlingAgent());
            _sl.SetDDL(ref fromAccountDDL, sql, "ACCT_NUM", "ACCT_NAME", "", "");
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void transferButton_Click(object sender, EventArgs e)
        {
            var amountVal = amount.Text;
            var tDateVal = transferDate.Text;
            var userIdAndAgentId = cashDao.GetUserIdAndBranch(GetStatic.GetUser(), amountVal, "vault");
            if (userIdAndAgentId["errorCode"].ToString() != "0")
            {
                GetStatic.AlertMessage(this, userIdAndAgentId["msg"].ToString());
                return;
            }
            var res = cashDao.TransferFromVault(GetStatic.GetUser(), amountVal, tDateVal, userIdAndAgentId["userId"].ToString()
                , userIdAndAgentId["agentId"].ToString(), paymentModeDDL.SelectedValue, fromAccountDDL.SelectedValue, toAccDDL.SelectedValue);

            var dbres = new DbResult();
            if (paymentModeDDL.SelectedValue != "cv")
            {
                if (res != null)
                {
                    dbres = _sl.ParseDbResult(res);
                }
                else
                {
                    dbres.SetError("1", "Error saving data!", "");
                }
            }
            if (res == null && paymentModeDDL.SelectedValue == "cv")
            {
                dbres.SetError("0", "Transfer to vault saved successfully", "");
            }
            GetStatic.SetMessage(dbres);
            Response.Redirect("CashTransferList.aspx");
        }

        protected void paymentModeDDL_SelectedIndexChanged(object sender, EventArgs e)
        {
            string paymentMode = paymentModeDDL.SelectedValue;
            if (!string.IsNullOrEmpty(paymentMode))
            {
                string sql = "EXEC PROC_VAULTTRANSFER @flag = 'VAULT-ADMIN', @AGENTID = " + _sl.FilterString(GetStatic.GetSettlingAgent()) + ", @user = " + _sl.FilterString(GetStatic.GetUser()) + ", @param1 = " + _sl.FilterString(paymentMode);
                _sl.SetDDL(ref toAccDDL, sql, "ACCT_NUM", "ACCT_NAME", "", "Select Account");
            }
            else
            {
                toAccDDL.Items.Clear();
            }
        }
    }
}