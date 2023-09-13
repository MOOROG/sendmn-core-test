using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.OtherServices.SendMNAPI {
  public partial class BlacklistedAccounts : System.Web.UI.Page {
    private const string GridName = "grid_list";
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
        new GridColumn("id", "id", "", "T"),
        new GridColumn("account_number","Данс","","T"),
        new GridColumn("bankname","Банк","","T"),
        new GridColumn("amount","Дүн","","T"),
        new GridColumn("receiverName","Хүлээн авагч","","T"),
        new GridColumn("receiverPhone","Дугаар","","T"),
        new GridColumn("description","Тайлбар","","T"),
        new GridColumn("is_active","Идэвхтэй","","T"),
        new GridColumn("senderName","Илгээгч","","T"),
        new GridColumn("senderPhone","Дугаар","","T"),
        new GridColumn("senderBankName","Банк","","T"),
        new GridColumn("senderAccountNumber","Данс","","T"),
        new GridColumn("tnxAgentName","Агент","","T"),
        new GridColumn("tnxDate","Гүйл/Өдөр","","T"),
        new GridColumn("remainingAmount","Үлдсэн дүн","","T"),
        new GridColumn("remainingComment","Тайлбар","","T"),
        new GridColumn("tnxControlNo","Гүйл/дугаар","","T"),
        new GridColumn("isActive","Идэвхитэй эсэх","","T"),
      };

      bool allowAdd = swiftLibrary.HasRight(GetFunctionIdByUserType(AddFunctionIdAgent, AddFunctionId));

      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridName = GridName;
      _grid.ShowPagingBar = true;
      _grid.AlwaysShowFilterForm = true;
      _grid.ShowFilterForm = true;
      _grid.SortOrder = "DESC";
      _grid.RowIdField = "id";
      _grid.ThisPage = "List.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;
      _grid.AllowCustomLink = true;
      _grid.ShowAddButton = allowAdd;
      _grid.AllowEdit = allowAdd;
      _grid.AddPage = "BlacklistedAccountsAdd.aspx";

      _grid.SetComma();
      _grid.EnableFilterCookie = false;
      _grid.CustomLinkVariables = "id";

      string sql = "EXEC [proc_blacklistedAccount] @flg = 'list', @datas = 'null'";
      blacklist_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }
  }

  public class BlacklistMdl {
    public string account_number { get; set; }
    public string bankname { get; set; }
    public double amount { get; set; }
    public string receiverName { get; set; }
    public DateTime? close_date { get; set; }
    public string description { get; set; }
    public string senderName { get; set; }
    public string senderPhone { get; set; }
    public string receiverPhone { get; set; }
    public string senderBankName { get; set; }
    public string senderAccountNumber { get; set; }
    public string tnxAgentName { get; set; }
    public DateTime? tnxDate { get; set; }
    public double remainingAmount { get; set; }
    public string remainingComment { get; set; }
    public string tnxControlNo { get; set; }
    public int is_active { get; set; }
    public string cusid { get; set; }
  }
}