using Swift.DAL.BL.Remit.CreditRiskManagement.BalanceTopUp;
using Swift.DAL.BL.Remit.CreditRiskManagement.CreditLimit;
using Swift.DAL.Remittance.CashAndVault;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.CashAndVault.CashHoldLimitTopUp
{
	public partial class List : System.Web.UI.Page
	{
		private const string GridName = "cashHoldLimitTopUp";
		private const string ViewFunctionId = "20199000";
		private const string ApproveFunctionId = "20199010";
		private readonly SwiftGrid grid = new SwiftGrid();
		private readonly RemittanceLibrary sl = new RemittanceLibrary();

		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				Authenticate();
				WriteCookie();
				GetStatic.PrintMessage(Page);
			}

			LoadGrid();
		}
		private void WriteCookie()
		{
			string key = GridName + "_hasLimit" + "_c_" + GetStatic.GetUser();
			string value = "Y";
			var httpCookie = new HttpCookie(key, value);
			httpCookie.Expires = DateTime.Now.AddDays(1);
			HttpContext.Current.Response.Cookies.Add(httpCookie);
		}
		#region method

		//private void LoadCreditLimitAuthority()
		//{
		//	var ds = obj.SelectCreditLimitAuthority(GetStatic.GetUser());
		//	if (ds == null)
		//		return;
		//	if (ds.Tables[1].Rows.Count > 0)
		//	{
		//		var dr = ds.Tables[1].Rows[0];
		//		ilimit.Text = GetStatic.FormatData(dr["limitPerDay"].ToString(), "M");
		//		iperTopUpLimit.Text = GetStatic.FormatData(dr["perTopUpLimit"].ToString(), "M");
		//	}
		//}

		private void LoadGrid()
		{
			grid.FilterList = new List<GridFilter>
								  {
									  new GridFilter("agentName", "Agent Name", "a"),
								
								  };

			grid.ColumnList = new List<GridColumn>
								  {	  new GridColumn("SN", "SN", "", "T"),
									  new GridColumn("agentCountry", "Country", "", "T"),
									  new GridColumn("agentName", "Agent", "", "T"),
									  new GridColumn("limitAmt", "Base Limit", "", "M"),
									  new GridColumn("limitToppedUp", "Limit Topped Up", "", "M"),
									  new GridColumn("topUp", "Top Up", "", "T")

								  };

			grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
			grid.GridType = 1;
			grid.GridName = GridName;
			grid.ShowFilterForm = true;
			grid.AlwaysShowFilterForm = true;
			grid.DisableSorting = true;
			grid.DisableJsFilter = true;
			grid.SortBy = "agentName,agentCountry";
			grid.RowIdField = "agentId";
			grid.AddPage = "Manage.aspx";
			grid.AllowCustomLink = true;
			grid.InputPerRow = 5;
			grid.AllowApprove = sl.HasRight(ApproveFunctionId);
			var customLinkText = new StringBuilder();
			customLinkText.Append("<input id=\"btnTopUp_@agentId\" type=\"button\" class='btn btn-primary m-t-25' value=\"Top Up\" onclick=\"TopUp(@agentId);\"></a>&nbsp;");
			customLinkText.Append(
				"<a href = '#' onclick=\"OpenInNewWindow('" + GetStatic.GetUrlRoot() + "/Remit/CashAndVault/CashHoldLimitTopUp/History.aspx?agentId=@agentId')\"><img src=\"" + GetStatic.GetUrlRoot() + "/Images/view-detail-icon.png\" border=0 title = \"View History\" /></a>");

			grid.CustomLinkText = customLinkText.ToString();
			
			grid.CustomLinkVariables = "agentId,cashHoldLimitId";
			grid.AllowCustomLink1 = true;
			//grid.CustomLinkText1 = "<img   class=\"showHand\" src=\"" + GetStatic.GetUrlRoot() + "/Images/minus.gif\" onclick=\"ShowSlab(@agentId);\"/>";
			grid.GridMinWidth = 1000;
			grid.GridWidth = 100;
			grid.IsGridWidthInPercent = true;

			string sql = "[Proc_CashHoldLimitTopUp] @flag = 's'";

			grid.SetComma();
			rpt_grid.InnerHtml = grid.CreateGrid(sql);
		}

		private void Authenticate()
		{
			sl.CheckAuthentication(ViewFunctionId);
		}

		#endregion

		protected void btnTopUp_Click(object sender, EventArgs e)
		{
			if (!isRefresh)
			{
				var obj2 = new CashHoldLimitTopUpDao();
				var dbResult = obj2.UpdateTopUP(GetStatic.GetUser(), hdnAgentId.Value, hdnAmount.Value);
				ManageMessage(dbResult);
			}
		}

		private void ManageMessage(DbResult dbResult)
		{
			if (dbResult.ErrorCode != "0")
			{
				GetStatic.AlertMessage(Page, dbResult.Msg);
				return;
			}
			GetStatic.PrintMessage(Page);
		}

		#region Browser Refresh
		private bool refreshState;
		private bool isRefresh;

		protected override void LoadViewState(object savedState)
		{
			object[] AllStates = (object[])savedState;
			base.LoadViewState(AllStates[0]);
			refreshState = bool.Parse(AllStates[1].ToString());
			if (Session["ISREFRESH"] != null && Session["ISREFRESH"] != "")
				isRefresh = (refreshState == (bool)Session["ISREFRESH"]);
		}

		protected override object SaveViewState()
		{
			Session["ISREFRESH"] = refreshState;
			object[] AllStates = new object[3];
			AllStates[0] = base.SaveViewState();
			AllStates[1] = !(refreshState);
			return AllStates;
		}
		#endregion
	}
}