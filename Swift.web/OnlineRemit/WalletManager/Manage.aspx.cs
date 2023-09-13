using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;

namespace Swift.web.OnlineRemit.WalletManager
{
	public partial class Manage : System.Web.UI.Page
	{
		private const string ViewFunctionId = "20131000";
		private const string ApproveRejectFunctionId = "20131030";
		private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
		OnlineCustomerDao onlineCustomerDao = new OnlineCustomerDao();
		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				Authenticate();
				string customerId = GetStatic.ReadQueryString("customerId", "");
				string walletTxnId = GetStatic.ReadQueryString("id", "");
				string opType = GetStatic.ReadQueryString("opType", "");
				if (opType == "approve")
				{
					btnApprove.Visible = true;
					btnApprove.Enabled = true;
					btnReject.Enabled = false;
				}
				else
				{
					btnReject.Visible = true;
					btnReject.Enabled = true;
					btnApprove.Enabled = false;
				}
				LoadCustomerWalletInfo(customerId, walletTxnId);
			}
		}

		private void Authenticate()
		{
			swiftLibrary.CheckAuthentication(ViewFunctionId + "," + ApproveRejectFunctionId);
		}

		private void LoadCustomerWalletInfo(string customerId, string walletTxnId)
		{
			//var dt = onlineCustomerDao.LoadCustomerWalletInfo(customerId, walletTxnId);
			//if (dt != null && dt.Rows.Count > 0)
			//{
			//	customer.Text = dt.Rows[0]["firstName"].ToString();
			//	remarks.Text = dt.Rows[0]["remarks"].ToString();
			//	amount.Text = dt.Rows[0]["amount"].ToString();
			//}
		}

		protected void btnApprove_Click(object sender, EventArgs e)
		{
			ApproveReject();
		}

		protected void btnReject_Click(object sender, EventArgs e)
		{
			ApproveReject();
		}

		private DbResult ApproveReject()
		{
			//string customerId = GetStatic.ReadQueryString("customerId", "");
			//string walletTxnId = GetStatic.ReadQueryString("id", "");
			//string opType = GetStatic.ReadQueryString("opType", "");
			//var res = onlineCustomerDao.ApproveRejectWallet(customerId, walletTxnId, opType);
			//return res;
			return new DbResult();
		} 
	}
}