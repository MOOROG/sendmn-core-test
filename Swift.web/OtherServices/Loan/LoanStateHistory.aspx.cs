using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.OtherServices.Loan {
  public partial class LoanStateHistory : System.Web.UI.Page {
    private const string GridName = "loanStateHistory_grid";
    private const string ViewFunctionId = "20111300, 20192001";
    private const string AddFunctionId = "20111310";
    private const string ViewFunctionIdAgent = "40120000";
    private const string AddFunctionIdAgent = "40120010";

    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    public string docPath;
    string loanId = "";
    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
      }
      docPath = Request.Url.GetLeftPart(UriPartial.Authority);
      loanId = GetStatic.ReadQueryString("loanId", "");
      LoadGrid();
    }

    private void Authenticate() {
      swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
    }

    private void LoadGrid() {

      _grid.ColumnList = new List<GridColumn> {
        new GridColumn("sn", "№", "", "T"),
        new GridColumn("loanNumber", "Зээлийн дугаар", "", "T"),
        new GridColumn("stateName", "Төлөв", "", "T"),
        new GridColumn("historyCreatedDate","Огноо","","D"),
        new GridColumn("historyCreatedBy","Өөрчилсөн хэрэглэгч","","T"),
        new GridColumn("stateDescription","Тайлбар","","T"),
      };


      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridName = GridName;
      _grid.SortOrder = "ASC";
      _grid.RowIdField = "stateHistoryId";
      _grid.ThisPage = "LoanStateHistory.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;

      string sql = "EXEC [proc_loanHistory] @flg = 'list', @loanId = '" + loanId + "',";
      loanStateHistory_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }
  }
}