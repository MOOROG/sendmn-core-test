using Swift.DAL.Remittance.SyncDao;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.TPSetup.StateCityTownSetup
{
	public partial class StateList : System.Web.UI.Page
	{
		private const string GridName = "grid_list";
		private const string ViewFunctionId = "20500000";
		private const string AddEditFunctionId = "20500010";
		private readonly SwiftGrid _grid = new SwiftGrid();
		private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				GetStatic.PrintMessage(Page);
				Authenticate();
			}
			LoadGrid();

		}
		private void Authenticate()
		{
			swiftLibrary.CheckAuthentication(ViewFunctionId);
		}
		private void LoadGrid()
		{

			string ddlSql = "EXEC [PROC_API_BANK_BRANCH_SETUP] @flag = 'API-PARTNER'";
			string ddlSql1 = "EXEC [PROC_API_BANK_BRANCH_SETUP] @flag = 'PAYOUT-METHOD'";

			_grid.FilterList = new List<GridFilter>
								  {
									 new GridFilter("API_PARTNER", "API PARTNER", "1:"+ddlSql, "0"),
									 new GridFilter("PAYMENT_TYPE", "PAYMENT TYPE", "1:"+ddlSql1, "0"),
								  };

			_grid.ColumnList = new List<GridColumn>
								  {
									 new GridColumn("SN", "SN", "", "T"),
									 new GridColumn("STATE_NAME", "STATE_NAME", "", "T"),
									  new GridColumn("API_PARTNER", "API_PARTNER ", "100", "T"),
									  new GridColumn("STATE_CODE", "STATE_CODE", "", "T"),
									  new GridColumn("STATE_COUNTRY", "STATE_COUNTRY", "", "T"),
									  new GridColumn("PAYMENT_TYPE", "PAYMENT_TYPE", "", "T"),
									  new GridColumn("IS_ACTIVE", "IS ACTIVE", "", "T"),
								  };

			_grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
			_grid.GridType = 1;
			_grid.GridName = GridName;
			_grid.ShowPagingBar = true;
			_grid.ShowAddButton = false;
			_grid.AllowEdit = false;
			_grid.AllowDelete = false;
			_grid.AddPage = "AddApiPartner.aspx";
			_grid.AlwaysShowFilterForm = true;
			_grid.ShowFilterForm = true;
			_grid.AllowCustomLink = true;
			_grid.SortOrder = "ASC";
			_grid.RowIdField = "STATE_ID";
			_grid.ThisPage = "StateList.aspx";

			var CityLink = "<span class=\"action-icon\"> <btn class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"City\"> <a href =\"CityList.aspx?stateCode=@STATE_CODE&stateRowId=@STATE_ID&apiPartner=@API_PARTNER_ID\"><i class=\"fa fa-building-o\" ></i></a></btn></span>";
			var link = "&nbsp;<a href=\"javascript:void(0);\" onclick=\"EnableDisable('@STATE_ID','@STATE_NAME','@IS_ACTIVE');\" class=\"btn btn-xs btn-primary\">Enable/Disable</a>";

			_grid.CustomLinkVariables = "STATE_CODE,STATE_NAME,IS_ACTIVE,STATE_ID,API_PARTNER_ID";
			_grid.CustomLinkText = CityLink + link;
			_grid.InputPerRow = 5;

			string sql = "EXEC [PROC_API_STATE_SETUP] @flag = 'S'";

			_grid.SetComma();

			rpt_grid.InnerHtml = _grid.CreateGrid(sql);
		}

		protected void btnUpdate_Click(object sender, EventArgs e)
		{
			StateCityTownDao _dao = new StateCityTownDao();
			if (!string.IsNullOrEmpty(isActive.Value))
			{
				var dbResult = _dao.EnableDisableState(rowId.Value, GetStatic.GetUser(), isActive.Value);
				GetStatic.SetMessage(dbResult);
				Response.Redirect("StateList.aspx");
			}
		}
	}
}