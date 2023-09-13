using Swift.DAL.AccountReport;
using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.VaultTransfer
{
    public partial class Transfer : System.Web.UI.Page
    {
        private string ViewFunctionId = "20210000";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private AccountStatementDAO cavDao = new AccountStatementDAO();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                Misc.MakeNumericTextbox(ref amount);
                transferDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void transferButton_Click(object sender, EventArgs e)
        {
            var amountVal = amount.Text;
            var tDateVal = transferDate.Text;

            var res = cavDao.TransitCashManagement(GetStatic.GetUser(), amountVal, tDateVal
                , paymentModeDDL.SelectedValue, bankOrBranchDDL.SelectedValue, introducerTxt.Text);

            if (res.ErrorCode == "0")
            {
                amount.Text = "";
                paymentModeDDL.SelectedValue = "";
                bankOrBranchDDL.Items.Clear();
                introducerTxt.Text = "";

                GetStatic.AlertMessage(this, res.Msg);
            }
            else
            {
                GetStatic.AlertMessage(this, res.Msg);
            }
        }

        protected void paymentModeDDL_SelectedIndexChanged(object sender, EventArgs e)
        {
            string paymentMode = paymentModeDDL.SelectedValue;
            if (!string.IsNullOrEmpty(paymentMode))
            {
                string sql = "EXEC PROC_VAULTTRANSFER @flag = 'VAULT-ADMIN', @user = " + _sl.FilterString(GetStatic.GetUser()) + ", @param1 = " + _sl.FilterString(paymentMode);
                _sl.SetDDL(ref bankOrBranchDDL, sql, "ACCT_ID", "ACCT_NAME", "", "Select Bank/Branch");
            }
            else
            {
                bankOrBranchDDL.Items.Clear();
            }
        }
    }
}