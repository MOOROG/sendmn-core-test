using Swift.web.Component.Grid.gridHelper;
using Swift.web.Component.Grid;
using System;
using System.Collections.Generic;
using Swift.web.Library;

namespace Swift.web.LogDb {
  public partial class VoucherLog : System.Web.UI.Page {

    private const string ViewFunctionId = "10121300";
    protected const string GridName = "grdVoucherLog";
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
        new GridFilter("message", "Message", "T"),
        new GridFilter("logBy", "Created By", "T"),
        new GridFilter("controlNo", "Control No", "T"),
      };

      _grid.ColumnList = new List<GridColumn>
      {
        new GridColumn("createdDate", "Date", "", "DT"),
        new GridColumn("tranId", "TranID", "", "T"),
        new GridColumn("Msg", "Message", "", "T"),
        new GridColumn("createdBy", "Created By", "", "T"),
        new GridColumn("controlNo", "ControlNo", "", "T"),
      };

      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.InputPerRow = 3;
      _grid.GridName = GridName;
      _grid.ShowFilterForm = true;
      _grid.ShowPagingBar = true;
      _grid.RowIdField = "rowId";
      _grid.AlwaysShowFilterForm = true;
      _grid.ThisPage = "VoucherLog.aspx";
      _grid.SetComma();
      _grid.InputLabelOnLeftSide = true;



      const string sql = "EXEC [Proc_LogDb] @flag = 'VoucherLog'";

      sendApiLog_grid.InnerHtml = _grid.CreateGrid(sql);
    }
  }
}