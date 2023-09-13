using Swift.DAL.Remittance.BonusManagement;
using Swift.web.Component.Grid;
using Swift.web.Library;
using System;

namespace Swift.web.Remit.BonusManagement.ApproveRedeem
{
	public partial class ViewTransaction : System.Web.UI.Page
	{
		private readonly SwiftLibrary _swiftLibrary = new SwiftLibrary();
		readonly BonusManagementDao _redeemDao = new BonusManagementDao();
		private readonly SwiftGrid _grid = new SwiftGrid();
		protected void Page_Load(object sender, EventArgs e)
		{

		}

		protected void btnSearchCustomer_Click(object sender, EventArgs e)
		{
			if (string.IsNullOrWhiteSpace(usrName.Text))
			{
				TBLData.Visible = false;
				return;
			}

			var tables = _redeemDao.GetCustomerDetail(usrName.Text);
			var dbRes = _redeemDao.ParseDbResult(tables.Tables[0]);

			if (dbRes.ErrorCode.Equals("1"))
			{
				GetStatic.PrintErrorMessage(this, dbRes.Msg);
				TBLData.Visible = false;
				return;
			}

			if (dbRes.ErrorCode.Equals("2"))
			{
				GetStatic.PrintErrorMessage(this, dbRes.Msg);
				TBLData.Visible = false;
				return;
			}

			var dr = tables.Tables[1].Rows[0];

			fullName.Text = dr["firstName"].ToString().Trim() + " " + dr["middleName"].ToString().Trim() + " " + dr["lastName"].ToString().Trim();
			dob.Text = dr["dob"].ToString();
			gender.Text = dr["gender"].ToString();
			nativeCountry.Text = dr["nativeCountry"].ToString();
			idType.Text = dr["idType"].ToString();
			idNumber.Text = dr["idNumber"].ToString();
			country.Text = dr["country"].ToString();
			state.Text = dr["state"].ToString();
			city.Text = dr["city"].ToString();
			address.Text = dr["pTole"].ToString().Trim() + " " + dr["pHouseNo"].ToString().Trim() + " " + dr["pMunicipality"].ToString().Trim() + " " + dr["pWardNo"].ToString().Trim();
			mobileNo.Text = dr["mobile"].ToString();
			email.Text = dr["email"].ToString();
			memberIDissuedDate.Text = dr["memberIDissuedDate"].ToString();
			bonusPoint.Text = dr["bonusPoint"].ToString().Substring(0, dr["bonusPoint"].ToString().LastIndexOf(".") + 1);

			hdnPrizeId.Value = dr["productId"].ToString();
			hdnAgentId.Value = dr["agentId"].ToString();
			hdnCustomerId.Value = dr["customerId"].ToString();
			hdnProductBonusPoint.Value = dr["productBonusPoint"].ToString();
			hdnGiftItem.Value = dr["availableProduct"].ToString();

			if (bonusPoint.Text.Contains("."))
			{
				bonusPoint.Text = bonusPoint.Text.TrimEnd('.');

			}


			if (dr["availableProduct"].ToString() == "" || dr["availableProduct"].ToString() == null)
			{
				redeemAvailableProducts.Text = "Insufficient Bonus Points";
			}
			else
			{
				redeemAvailableProducts.Text = dr["availableProduct"].ToString() + " (" + dr["productBonusPoint"].ToString() + " )";
			}

			TBLData.Visible = true;
		}
	}
}