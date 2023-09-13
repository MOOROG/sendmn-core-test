using Swift.web.Component.Grid.gridHelper;
using Swift.web.Component.Grid;
using System;
using System.Collections.Generic;
using Swift.web.Library;

namespace Swift.web.LogDb {
  public partial class SystemHealthLog : System.Web.UI.Page {
    private const string ViewFunctionId = "10121300";
    protected const string GridName = "grdSystemHpLog";
    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly SwiftLibrary _sl = new SwiftLibrary();
    protected void Page_Load(object sender, EventArgs e) {
      _sl.CheckSession();
      if (!IsPostBack) {
        Authenticate();
        GetStatic.PrintMessage(Page);
      }
      LoadGrid();
    }

    private void Authenticate() {
      _sl.CheckAuthentication(ViewFunctionId);
    }

    private void LoadGrid() {
      _grid.FilterList = new List<GridFilter>
      {
        new GridFilter("fromDate", "From Date", "z"),
        new GridFilter("toDate", "To Date", "z"),
        new GridFilter("projectName", "Project Name", "T"),
      };

      _grid.ColumnList = new List<GridColumn> {
        new GridColumn("Solution", "Solution", "100px", "T"),
        new GridColumn("project", "Project", "100px", "T"),
        new GridColumn("exception", "Exception", "", "T"),
        new GridColumn("count", "Frequency", "50px", "T"),
        new GridColumn("logger", "Logger", "", "T"),
        new GridColumn("stackTrace", "stackTrace", "", "T")
      };

      _grid.GridType = 1;
      //_grid.GridDataSource = SwiftGrid.GridDS.LogDb;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.InputPerRow = 3;
      _grid.GridName = GridName;
      _grid.ShowFilterForm = false;
      _grid.ShowPagingBar = true;
      _grid.RowIdField = "rowId";
      _grid.AlwaysShowFilterForm = false;
      _grid.ThisPage = "SystemHealthLog.aspx";
      _grid.SetComma();
      _grid.InputLabelOnLeftSide = true;



      const string sql = "EXEC [Proc_LogDb] @flag = 'SystemHealthLog'";

      grdSystemHpLog.InnerHtml = _grid.CreateGrid(sql);
    }
  }
}