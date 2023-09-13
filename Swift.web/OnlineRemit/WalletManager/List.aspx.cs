using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.OnlineRemit.WalletManager
{
	public partial class List : System.Web.UI.Page
	{
		private const string GridName = "grid_wallet";
		private const string ViewFunctionId = "20131000";
		private const string ApproveRejectFunctionId = "20131030";
		private readonly SwiftGrid _grid = new SwiftGrid();
		private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
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
			_grid.FilterList = new List<GridFilter>
								  {
									 new GridFilter("fromDate", "From", "d"),
									 new GridFilter("toDate",  "To", "d")
								  };

			_grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SNO", "", "T"),
                                      new GridColumn("Date", "Date", "", "D"),
                                      new GridColumn("Particular", "Particulars", "", "T"),
                                      new GridColumn("Debit", "Withdraw", "", "T"),
                                      new GridColumn("Credit", "Deposit", "", "T"),
                                      new GridColumn("Balance", "Balance", "", "T")                                     
                                  };

			_grid.GridType = 1;
			_grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
			_grid.GridName = GridName;
			_grid.ShowPagingBar = true;
			_grid.AllowEdit = false;
			_grid.AllowDelete = false;
			_grid.AlwaysShowFilterForm = true;
			_grid.ShowFilterForm = true;
			_grid.SortOrder = "ASC";
			_grid.RowIdField = "id";
			_grid.ThisPage = "List.aspx"; ;
			_grid.InputPerRow = 4;
			_grid.AllowCustomLink = true;
			_grid.CustomLinkVariables = "customerId,id";
			_grid.GridMinWidth = 700;
			_grid.GridWidth = 100;
			_grid.IsGridWidthInPercent = true;
			_grid.SetComma();
			if (swiftLibrary.HasRight(ApproveRejectFunctionId))
			{
			var link = "&nbsp;<a class=\"btn btn-xs btn-primary\" title=\"Approve/Reject\" href=\"Manage.aspx?id=@id&customerId=@customerId&opType=approve\"><i class=\"fa fa-pencil\"></i></a>&nbsp;<a class=\"btn btn-xs btn-success\" title=\"Edit\" href=\"Manage.aspx?id=@id&customerId=@customerId&opType=reject\"><i class=\"fa fa-check\"></i></a>";
			_grid.CustomLinkText = link;
			}
			var sql = "EXEC proc_online_customerWalletManager @flag = 's'";
			sql += ", @customerId = " + swiftLibrary.FilterString(customer.Value);
			rpt_grid.InnerHtml = _grid.CreateGrid(sql);
		}
	}
}