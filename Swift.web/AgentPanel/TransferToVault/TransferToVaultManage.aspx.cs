using Swift.DAL.Remittance.CashAndVault;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;

namespace Swift.web.AgentPanel.TransferToVault
{
    public partial class TransferToVault : System.Web.UI.Page
    {
        protected const string GridName = "TransferToVault";
        private string ViewFunctionId = "20179000";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private CashAndVaultDao cavDao = new CashAndVaultDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                Misc.MakeNumericTextbox(ref amount);
                transferDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                PopulateBranchDetails();
            }
        }

        private void PopulateBranchDetails()
        {
            var row = cavDao.GetBranchCashDetails(GetStatic.GetUser(), GetStatic.GetBranch(), "");

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
            var res = cavDao.SaveTransferToVault(GetStatic.GetUser(), amountVal, tDateVal, userIdAndAgentId["userId"].ToString(), userIdAndAgentId["agentId"].ToString());
            if (res == null)
            {
                var dbRes = new DbResult()
                {
                    ErrorCode = "0",
                    Msg = "Transfer to vault saved successfully"
                };
                GetStatic.SetMessage(dbRes);
                Response.Redirect("RequestedTransferToVaultList.aspx");
            }
        }
    }
}