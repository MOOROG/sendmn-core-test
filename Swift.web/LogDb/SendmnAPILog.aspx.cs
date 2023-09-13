using Swift.web.Component.Grid.gridHelper;
using Swift.web.Component.Grid;
using System;
using System.Collections.Generic;
using Swift.web.Library;

namespace Swift.web.LogDb {
  public partial class SendmnAPILog : System.Web.UI.Page {

    private const string ViewFunctionId = "10121300";
    protected const string GridName = "sendAPILog";
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
        new GridFilter("level", "Level", "T"),
        new GridFilter("logger", "Logger", "T"),
        new GridFilter("message", "Message", "T"),
        new GridFilter("exception", "Exception", "T"),
        new GridFilter("logBy", "Log By", "T"),
        new GridFilter("provider", "ClientIpAddress", "T"),
        new GridFilter("userName", "UserName", "T"),
        new GridFilter("controlNo", "Control No", "T"),
        new GridFilter("clientIpAddress", "IP Address", "T"),
      };

      _grid.ColumnList = new List<GridColumn>
      {
        new GridColumn("date", "Date", "50", "DT"),
        new GridColumn("level", "Level", "", "T"),
        new GridColumn("processId", "Process ID", "", "T"),
        new GridColumn("logger", "Logger", "15", "T"),
        new GridColumn("message", "Message", "150", "T"),
        new GridColumn("exception", "Exception", "", "T"),
        new GridColumn("logBy", "Log By", "", "T"),
        new GridColumn("Provider", "Provider", "", "T"),
        new GridColumn("ClientIpAddress", "Client IP", "", "T"),
        new GridColumn("UserName", "UserName", "", "T"),
        new GridColumn("ControlNo", "ControlNo", "", "T"),
      };

      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.InputPerRow = 3;
      _grid.GridName = GridName;
      _grid.ShowFilterForm = true;
      _grid.ShowPagingBar = true;
      _grid.RowIdField = "rowId";
      _grid.AlwaysShowFilterForm = true;
      _grid.ThisPage = "SendmnAPILog.aspx";
      _grid.SetComma();
      _grid.InputLabelOnLeftSide = true;

      _grid.GridMinWidth = 700;
      _grid.IsGridWidthInPercent = true;
      _grid.GridWidth = 100;

      const string sql = "EXEC [Proc_LogDb] @flag = 'SendmnAPILog'";

      sendApiLog_grid.InnerHtml = _grid.CreateGrid(sql);
    }
  }
}