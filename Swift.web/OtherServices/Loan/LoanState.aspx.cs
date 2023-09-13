using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.OtherServices.Loan {
  public partial class LoanState : System.Web.UI.Page {
    private const string GridName = "grid_list";
    private const string ViewFunctionId = "20111300";
    private const string AddFunctionId = "20111310";

    private const string ViewFunctionIdAgent = "40120000";
    private const string AddFunctionIdAgent = "40120010";
    private const string DeleteEditFunctionId = "20150520";

    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private RemittanceDao swiftDao = new RemittanceDao();
    public string docPath;

    protected void Page_Load(object sender, EventArgs e) {

      if (!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
      }
      docPath = Request.Url.GetLeftPart(UriPartial.Authority);
      DeleteRow();
      LoadGrid();
    }

    private void Authenticate() {
      swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
    }

    private void LoadGrid() {
      _grid.FilterList = new List<GridFilter>
                    {
                                       new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [proc_loanState] @flg='searchCriteria'"),
                                       new GridFilter("searchValue", "Search Value", "T")
                                   };
      _grid.ColumnList = new List<GridColumn>
                    {
                                       new GridColumn("stateID", "ID", "", "T"),
                                       new GridColumn("stateName", "Төлөв", "", "T"),
                                       new GridColumn("isActive", "Active", "", "T"),
                                       new GridColumn("isDeleted", "Deleted", "", "T")
                                   };
      bool allowAdd = swiftLibrary.HasRight(GetFunctionIdByUserType(AddFunctionIdAgent, AddFunctionId));

      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridName = GridName;
      _grid.ShowPagingBar = true;
      _grid.AlwaysShowFilterForm = true;
      _grid.ShowFilterForm = true;
      _grid.SortOrder = "ASC";
      _grid.RowIdField = "stateID";
      _grid.ThisPage = "LoanState.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;
      _grid.AllowCustomLink = true;
      _grid.ShowAddButton = allowAdd;

      _grid.AllowEdit = allowAdd;

      _grid.AddPage = "ManageLoanState.aspx";
      _grid.SetComma();
      _grid.EnableFilterCookie = false;
      _grid.CustomLinkVariables = "stateID";
      _grid.AllowDelete = true;


      string sql = "EXEC [proc_loanState] @flg = 's'";
      rpt_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    private void DeleteRow() {
      string id = _grid.GetCurrentRowId(GridName);

      if (id == "")
        return;

      DbResult dbResult = swiftDao.DeleteLoanState(id);
      ManageMessage(dbResult);
    }

    private void ManageMessage(DbResult dbResult) {
      GetStatic.SetMessage(dbResult);
      GetStatic.PrintMessage(Page);
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }
  }
}