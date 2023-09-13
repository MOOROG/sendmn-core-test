using Swift.DAL.Remittance.BonusManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;

namespace Swift.web.Remit.BonusManagement.OperationStartSetup
{
	public partial class Manage : System.Web.UI.Page
	{
		private readonly RemittanceLibrary _sl = new RemittanceLibrary();
		private readonly PrizeSetupDao _psdao = new PrizeSetupDao();
		private const string ViewFunctionId = "20821000";
		private const string AddEditFunctionId = "20821010";
		private void Page_Load(object sender, EventArgs e)
		{
			Misc.MakeNumericTextbox(ref unit);
			Misc.MakeNumericTextbox(ref points);
			Misc.MakeNumericTextbox(ref maxPointPerTxn);
			Misc.MakeNumericTextbox(ref minTxnForRedeem);
			Misc.DisableInput(ref schemeStartDate);
			Misc.DisableInput(ref schemeEndDate);
			if (!IsPostBack)
			{
				if (GetId() > 0)
				{
					PopulateDataById();
				}
				else
				{
					LoadDDl(null);
				}
				Authenticate();
			}
		}

		private void LoadDDl(DataRow dr)
		{
			_sl.SetDDL(ref basis, "EXEC proc_dropDownLists @flag= 'basis'", "valueId", "detailTitle", GetStatic.GetRowData(dr, "basis"), "Select");
		}


		private void Update()
		{

			lblSendingCountry.Text = "";
			if (string.IsNullOrWhiteSpace(sendingCountry.Text))
			{
				return;
			}

			DbResult dbResult = _psdao.BonusSetupUpdate
								(
									 GetStatic.GetUser()
									, GetId().ToString()
									, schemeName.Text
									, sendingCountry.Value
									, sendingAgent.Value
									, sendingBranch.Value
									, receivingCountry.Value
									, receivingAgent.Value
									, schemeStartDate.Text
									, schemeEndDate.Text
									, basis.SelectedValue
									, unit.Text
									, points.Text
									, isActive.Text
									, maxPointPerTxn.Text
									, minTxnForRedeem.Text
								);
			GetStatic.PrintMessage(Page, dbResult);
			ManageMessage(dbResult);

		}
		private long GetId()
		{
			return GetStatic.ReadNumericDataFromQueryString("bonusSchemeId");
		}
		private void ManageMessage(DbResult dbResult)
		{
			GetStatic.SetMessage(dbResult);
			if (dbResult.ErrorCode == "0")
			{
				Response.Redirect("List.aspx");
			}

			GetStatic.PrintMessage(Page, dbResult);

		}
		private void PopulateDataById()
		{
			DataRow dr = _psdao.SelectById(GetStatic.GetUser(), GetId().ToString());
			if (dr == null)
				return;
			schemeName.Text = dr["schemeName"].ToString();
			sendingCountry.Text = dr["sendingCountry"].ToString();
			sendingCountry.Value = dr["sendingCountryVal"].ToString();
			sendingAgent.Text = dr["sendingAgent"].ToString();
			sendingAgent.Value = dr["sendingAgentVal"].ToString();
			sendingBranch.Text = dr["sendingBranch"].ToString();
			sendingBranch.Value = dr["sendingBranchVal"].ToString();
			receivingCountry.Text = dr["receivingCountry"].ToString();
			receivingCountry.Value = dr["receivingCountryVal"].ToString();
			receivingAgent.Text = dr["receivingAgent"].ToString();
			receivingAgent.Value = dr["receivingAgentVal"].ToString();
			schemeStartDate.Text = dr["schemeStartDate"].ToString();
			schemeEndDate.Text = dr["schemeEndDate"].ToString();
			unit.Text = dr["unit"].ToString();
			points.Text = dr["points"].ToString();
			isActive.Text = dr["isActive"].ToString();
			maxPointPerTxn.Text = dr["maxPointsPerTxn"].ToString();
			minTxnForRedeem.Text = dr["minTxnForRedeem"].ToString();

			LoadDDl(dr);
		}
		private void Authenticate()
		{
			_sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
		}
		protected void btnSave_Click(object sender, EventArgs e)
		{
			Update();

		}
	}
}