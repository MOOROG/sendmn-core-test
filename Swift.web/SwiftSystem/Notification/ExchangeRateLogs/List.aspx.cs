using System;
using System.Collections.Generic;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;


namespace Swift.web.SwiftSystem.Notification.ExchangeRateLogs
{
    public partial class List : System.Web.UI.Page
    {
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary _swiftLibrary = new RemittanceLibrary();
        private const string ViewFunctionId = "10122400";
        private const string GridName = "grdTrnLog";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            LoadGrid();
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("updatedDate", "Date", "z"),
                                       new GridFilter("userName", "User", "T")                                       
                                   };

            grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("countryName", "Country", "", "T"),
                                       new GridColumn("agentName", "Agent Name", "", "T"),
                                       new GridColumn("cCurrency", "Currency (Cost Rate)", "", "T"),
                                       new GridColumn("pCurrency", "Currency (Pay Rate)", "", "T"),
                                       new GridColumn("updatedBy", "Updated By", "", "T"),
                                       new GridColumn("updatedDate", "Updated Date", "", "T"),
                                       new GridColumn("approvedBy", "Approved By", "", "T"),
                                       new GridColumn("approvedDate", "Approved Date", "", "T")
                                   };
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.InputLabelOnLeftSide = true;
            grid.InputPerRow = 2;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "rowId";
            grid.ThisPage = "List.aspx";
            grid.AlwaysShowFilterForm = true;
            grid.LoadGridOnFilterOnly = true;
            grid.AllowEdit = false;

            var sql = "exec [proc_ExchangeRateLog] @flag = 's'";
            grid.SetComma();
            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _swiftLibrary.CheckAuthentication(ViewFunctionId);
        }
    }
}