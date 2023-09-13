using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.CashAndVault.CashHoldLimitTopUp
{
	public partial class History : System.Web.UI.Page
	{
		private const string GridName = "gridBalTopUpHistory";
		private const string ViewFunctionId = "30011100";
		private readonly SwiftGrid grid = new SwiftGrid();
		private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				Authenticate();
				GetStatic.PrintMessage(Page);
			}
			LoadGrid();
		}
		#region method

		protected string GetAgentName()
		{
			return "Agent Name : " + swiftLibrary.GetAgentName(GetAgentId().ToString());
		}

		protected long GetAgentId()
		{
			return GetStatic.ReadNumericDataFromQueryString("agentId");
		}

		private void LoadGrid()
		{
			grid.FilterList = new List<GridFilter>
								  {
									  new GridFilter("createdBy", "Created By", "LT"),
									  new GridFilter("approvedBy", "Approved By", "LT"),
									  new GridFilter("approvedFromDate", "Approved Date From", "z"),
									  new GridFilter("approvedToDate", "To", "z")
								  };

			grid.ColumnList = new List<GridColumn>
								  {
									  new GridColumn("amount", "Amount", "", "M"),
									  new GridColumn("btStatus", "Status", "", "T"),
									  new GridColumn("createdBy", "Created By", "", "T"),
									  new GridColumn("createdDate", "Created Date", "", "T"),
									  new GridColumn("approvedBy", "Approved By", "", "T"),
									  new GridColumn("approvedDate", "Approved Date", "", "T")
								  };


			grid.GridType = 1;
			grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
			grid.GridName = GridName;
			grid.ShowFilterForm = true;
			grid.AlwaysShowFilterForm = true;
			grid.EnableFilterCookie = false;
			grid.LoadGridOnFilterOnly = false;
			grid.ShowPagingBar = true;
			grid.SortBy = "approvedDate";
			grid.SortOrder = "DESC";
			grid.RowIdField = "sn";
			grid.InputPerRow = 4;
			grid.GridWidth = 650;
			string sql = "[Proc_CashHoldLimitTopUp] @flag = 'history',@agentId='" + GetAgentId() + "'";
			grid.SetComma();

			rpt_grid.InnerHtml = grid.CreateGrid(sql);
		}

		private void Authenticate()
		{
			swiftLibrary.CheckAuthentication(ViewFunctionId);
		}

		#endregion
	}
}