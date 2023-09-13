using System;
using System.Collections.Generic;
using System.Web.UI;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.Notification.ApplicationLogs {
  public partial class List : Page {
    private readonly SwiftGrid grid = new SwiftGrid();
    private readonly RemittanceLibrary _swiftLibrary = new RemittanceLibrary();
    private const string ViewFunctionId = "10121100";
    private const string GridName = "grdAppLog";

    protected void Page_Load(object sender, EventArgs e) {
      Authenticate();
      LoadGrid();
    }

    private void LoadGrid() {
      grid.FilterList = new List<GridFilter>
                             {
                                       new GridFilter("logType", "Log Type", "1:EXEC proc_staticDataValue @flag = 'ltt', @typeId = 6100"),
                                       new GridFilter("tableName", "Menu", "T"),
                                       new GridFilter("createdBy", "User", "T"),
                                       new GridFilter("createdDate", "Date", "z")
                                   };
      grid.ColumnList = new List<GridColumn>
                             {
                                       new GridColumn("logType", "Log Type", "", "T"),
                                       new GridColumn("tableName", "Menu", "", "T"),
                                       new GridColumn("createdBy", "User", "", "T"),
                                       new GridColumn("createdDate", "Date", "", "T"),
                                       new GridColumn("Edit", " ", "", "nosort")
                                   };
      grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      grid.GridName = GridName;
      grid.GridType = 1;
      grid.ShowFilterForm = true;
      grid.AlwaysShowFilterForm = true;
      grid.InputPerRow = 3;
      grid.LoadGridOnFilterOnly = true;
      grid.GridMinWidth = 700;
      grid.IsGridWidthInPercent = true;
      grid.GridWidth = 100;
      grid.ShowPagingBar = true;
      grid.RowIdField = "id";
      grid.ThisPage = "List.aspx";

      grid.AllowEdit = false;

      var sql = "exec [proc_applicationLogs] @flag = 's'";
      grid.SetComma();

      rpt_grid.InnerHtml = grid.CreateGrid(sql);
    }
    private void Authenticate() {
      _swiftLibrary.CheckAuthentication(ViewFunctionId);
    }
  }
}