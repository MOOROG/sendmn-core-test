using System;
using System.Collections.Generic;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.RussiaVietnamTran {
  public partial class RussiaVietnamTran : System.Web.UI.Page {
    private const string GridName = "russViet_grid";
    private const string ViewFunctionId = "20111300, 20192001";
    private const string AddFunctionId = "20111310";
    private const string ViewFunctionIdAgent = "40120000";
    private const string AddFunctionIdAgent = "40120010";

    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private RemittanceDao swift = null;
    public string docPath;
    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
      }
      docPath = Request.Url.GetLeftPart(UriPartial.Authority);
      LoadGrid();
    }

    private void Authenticate() {
      swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
    }

    private void LoadGrid() {
      _grid.FilterList = new List<GridFilter>
                          {
                                       new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [proc_blacklistedAccount] @flg='searchCriteria', @datas = 'null'"),
                                       new GridFilter("searchValue", "Search Value", "T")
                                   };

      _grid.ColumnList = new List<GridColumn> {
        new GridColumn("docid","docid","", "T"),
        new GridColumn("dtFile","dtFile","", "T"),
        new GridColumn("trn","trn","", "T"),
        new GridColumn("code","code","", "T"),
        new GridColumn("amount","amount","", "T"),
        new GridColumn("senderName","senderName","", "T"),
        new GridColumn("recName","recName","", "T"),
        new GridColumn("ppCode","ppCode","", "T"),
        new GridColumn("bankName","bankName","", "T"),
        new GridColumn("city","city","", "T"),
        new GridColumn("country","country","", "T"),
        new GridColumn("state","state","", "T"),
        new GridColumn("stateStr","stateStr","", "T"),
        new GridColumn("_trn","_trn","", "T"),
        new GridColumn("additionalInfo","additionalInfo","", "T"),
        new GridColumn("dtFileStr","dtFileStr","", "T"),
        new GridColumn("dtTmUpd","dtTmUpd","", "T"),
        new GridColumn("fromCountryCode","fromCountryCode","", "T"),
        new GridColumn("fromCountryName","fromCountryName","", "T"),
        new GridColumn("partFee","partFee","", "T"),
        new GridColumn("trnSendPoint","trnSendPoint","", "T"),
        new GridColumn("toCountryCode","toCountryCode","", "T"),
        new GridColumn("payStatusStr","payStatusStr","", "T")
      };

      bool allowAdd = swiftLibrary.HasRight(GetFunctionIdByUserType(AddFunctionIdAgent, AddFunctionId));

      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridName = GridName;
      _grid.ShowPagingBar = true;
      _grid.AlwaysShowFilterForm = true;
      _grid.ShowFilterForm = true;
      _grid.SortOrder = "DESC";
      _grid.RowIdField = "docid";
      _grid.ThisPage = "RussiaVietnamTran.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;
      _grid.AllowCustomLink = true;
      _grid.ShowAddButton = false;
      _grid.AllowEdit = false;
      //_grid.AddPage = "BlacklistedAccountsAdd.aspx";

      _grid.SetComma();
      _grid.EnableFilterCookie = false;
      _grid.CustomLinkVariables = "docid";

      string sql = "EXEC [proc_contactRusVietRemit] @flg = 'list', @datas = 'null'";
      russViet_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }
  }
}