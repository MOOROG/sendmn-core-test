using Swift.DAL.Remittance.BonusManagement;
using Swift.web.Component.Grid;
using Swift.web.Library;
using System;

namespace Swift.web.AgentPanel.Bonus_Management
{
	public partial class RedeemRequest : System.Web.UI.Page
	{
		private const string ViewFunctionId = "40122500";
		private const string AddEditFunctionId = "40122510";
		protected const string GridName = "grid_Redeem";
		private readonly SwiftLibrary _swiftLibrary = new SwiftLibrary();
		readonly BonusManagementDao _redeemDao = new BonusManagementDao();
		private readonly SwiftGrid _grid = new SwiftGrid();
		protected void Page_Load(object sender, EventArgs e)
		{
			_swiftLibrary.CheckSession();
			if (!IsPostBack)
			{
				Authenticate();
				userName.Focus();
				infoImg.ImageUrl = GetStatic.GetUrlRoot() + "/images/icon_info.png";

			}
			LoadGrid();

		}

		private void Authenticate()
		{
			_swiftLibrary.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
		}

		protected void btnSearchCustomer_Click(object sender, EventArgs e)
		{
			//OTPDiv.Visible = false;
			if (string.IsNullOrWhiteSpace(userName.Text))
			{
				TBLData.Visible = false;
				return;
			}

			var tables = _redeemDao.GetCustomerDetail(userName.Text);
			var dbRes = _redeemDao.ParseDbResult(tables.Tables[0]);

			if (dbRes.ErrorCode.Equals("1"))
			{
				GetStatic.PrintErrorMessage(this, dbRes.Msg);
				TBLData.Visible = false;
				return;
			}

			else if (dbRes.ErrorCode.Equals("2"))
			{
				GetStatic.PrintErrorMessage(this, dbRes.Msg);
				TBLData.Visible = false;
				return;
			}

			if(tables.Tables[1].Rows.Count<1)
			{
				GetStatic.PrintErrorMessage(this, "Record Not Found.");
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
			address.Text = dr["address"].ToString();
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
			//if (Convert.ToInt32(bonusPoint.Text) >= Convert.ToInt32(dr["minBonus"].ToString()))
			//{
			//	//btnReddem.Enabled = true;
			//	//hlRedeem.Enabled = true;
			//}
			//else
			//{
			//	//btnReddem.Enabled = false;
			//	//hlRedeem.Enabled = false;
			//}

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

		protected void btnTxnHistory_Click(object sender, EventArgs e)
		{
			Response.Redirect("BonusTransaction/List.aspx");
		}

		protected void btnReddem_Click(object sender, EventArgs e)
		{
			string pin = hdnPin.Value;
			var dbRes = _redeemDao.SentOTPData(hdnCustomerId.Value, pin, GetStatic.GetUser(), hdnGiftItem.Value);
			if (dbRes.ErrorCode.Equals("0"))
			{
				//oMemebershipId.Text = customerId.Text;
				//oTotalBonus.Text = bonusPoint.Text;
				//oRedeemed.Text = hdnProductBonusPoint.Value;
				//ogift.Text = hdnGiftItem.Value;

				hdnId.Value = dbRes.Id;
				hdnMessage.Value = dbRes.Extra;
				string subject = "Bonus Redeem: " + userName.Text;

				//var dbResult = GetStatic.SendSMS(mobileNo.Text, dbRes.Extra);
				//if (dbResult.ErrorCode.Equals("0"))
				//{
				//	OTPDiv.Visible = true;
				//	_redeemDao.SentOTPDataToSMSQueue(hdnCustomerId.Value, pin, GetStatic.GetUser(), mobileNo.Text, hdnMessage.Value, subject);
				//}
				//else
				//{
				//	GetStatic.PrintErrorMessage(this, dbResult.Msg);
				//	OTPDiv.Visible = false;
				//}

			}
		}

		private void LoadGrid()
		{
			
		}

		protected void btnHandedOver_Click(object sender, EventArgs e)
		{

		}

		protected void btnFinalRedeem_Click(object sender, EventArgs e)
		{
			string agentId = !string.IsNullOrEmpty(GetStatic.GetAgentId()) ? GetStatic.GetAgentId() : GetStatic.GetAgent();
			var dbRes = _redeemDao.BonusRedemRequest(hdnCustomerId.Value, country.Text, hdnPrizeId.Value, hdnProductBonusPoint.Value, GetStatic.GetUser(), agentId, hdnId.Value);

			if (dbRes.ErrorCode.Equals("0"))
			{
				GetStatic.SetMessage(dbRes);
				Response.Redirect("RedeemRequestList.aspx");
			}
			else
			{
				GetStatic.PrintErrorMessage(this, dbRes.Msg);
				//btnReddem.Enabled = false;
				//hlRedeem.Enabled = false;
			}

		}

		protected void hlRedeem_Click(object sender, EventArgs e)
		{
			//oMemebershipId.Text = customerId.Text;
			//oTotalBonus.Text = bonusPoint.Text;
			//oRedeemed.Text = hdnProductBonusPoint.Value;
			//ogift.Text = hdnGiftItem.Value;
			//OTPDiv.Visible = true;
		}
	}
}