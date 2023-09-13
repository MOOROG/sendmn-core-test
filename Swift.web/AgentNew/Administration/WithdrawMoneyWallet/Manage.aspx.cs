using Swift.DAL.BL.LoadMoneyWalletDao;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.Administration.WithdrawMoneyWallet {
    public partial class Manage : System.Web.UI.Page
    {
        private readonly RemittanceLibrary obj = new RemittanceLibrary();
        private const string ViewFunctionId = "20102900";
        private readonly WalletDao _wallet = new WalletDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
        }

        private void Authenticate()
        {
            obj.CheckAuthentication(ViewFunctionId);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string walletId = walletNo.Text;

            if (string.IsNullOrWhiteSpace(walletId))
            {
                GetStatic.AlertMessage(this, "Please Enter Wallet No!!");
                return;
            }

            DataTable dt = _wallet.LoadWalletDetails(walletId);

            if (dt == null || dt.Rows.Count == 0)
            {
                GetStatic.AlertMessage(this, "No result found for provided Wallet No!!");
                return;
            }

            if (dt.Rows[0]["errorcode"].ToString() != "0")
            {
                GetStatic.AlertMessage(this, dt.Rows[0]["errorMsg"].ToString());
                return;
            }

            PopulateData(dt);

            divTranDetails.Visible = true;
            divControlno.Visible = false;
        }

        public void PopulateData(DataTable dt)
        {
            DataRow dr = dt.Rows[0];
            mobNo.Text = dr["mobileNo"].ToString();
            fullName.Text = dr["fullName"].ToString();
            hddWalletNo.Value = dr["walletNo"].ToString();
        }

        protected void btnLoadMoney_Click(object sender, EventArgs e)
        {
            WalletDao _dao = new WalletDao();
            string walletId = hddWalletNo.Value;
            string amount = string.IsNullOrEmpty(amountUpload.Text.Replace(",", "")) ? "0" : amountUpload.Text.Replace(",", "");
            string c = GetAgentSession();

            if (Convert.ToInt32(amount) <= 0)
            {
                GetStatic.AlertMessage(this, "Please Enter Valid Amount!!");
                return;
            }
            var dbResult = _dao.WithdrawMoneyWallet(GetStatic.GetUser(), walletId, amount);
            GetStatic.AlertMessage(this, dbResult.Msg);
            divTranDetails.Visible = false;
            divControlno.Visible = true;
        }

        private string GetAgentSession()
        {
            return (DateTime.Now.Ticks + DateTime.Now.Millisecond).ToString();
        }

        protected void clearData_Click(object sender, EventArgs e)
        {
            divTranDetails.Visible = false;
            divControlno.Visible = true;
        }
    }
}