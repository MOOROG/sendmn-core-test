using Swift.DAL.Remittance.BonusManagement;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.BonusManagement.ApproveRedeem
{
	public partial class Receipt : System.Web.UI.Page
	{
		private readonly SwiftLibrary _swiftLibrary = new SwiftLibrary();
		readonly RedeemProcessDao _redeemDao = new RedeemProcessDao();
		protected void Page_Load(object sender, EventArgs e)
		{
			LoadGrid();
		}

		private void LoadGrid()
		{
			string refNo = Request.QueryString["redeemId"].ToString();
			string customerId = Request.QueryString["customerId"].ToString();
			var branch = GetStatic.GetBranchName();
			var dr = _redeemDao.RedeemReceipt(refNo, customerId, GetStatic.GetUser(), GetStatic.GetBranchName()).Rows[0];
			lblRefNo.Text = dr["refNo"].ToString().Trim();
			lblCustomerName.Text = dr["customerName"].ToString();
			lblDateTime.Text = dr["dateTime"].ToString();
			lblPassport.Text = dr["idNumber"].ToString();
			lblBonusPoint.Text = dr["bonusPoint"].ToString();
			lblRemainingBonus.Text = dr["bonusRemaining"].ToString();
			lblPreparedBy.Text = dr["preparedBy"].ToString();
			lblItemRedeemed.Text = dr["detailTitle"].ToString() + " " + dr["redeemed"].ToString();
			lblBranch.Text = dr["branch"].ToString();
		}
	}
}