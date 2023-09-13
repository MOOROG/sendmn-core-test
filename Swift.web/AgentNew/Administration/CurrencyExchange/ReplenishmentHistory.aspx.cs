using Swift.web.Component.Grid.gridHelper;
using Swift.web.Component.Grid;
using System;
using System.Collections.Generic;
using Swift.web.Library;
using Swift.DAL.BL.LoadMoneyWalletDao;
using Swift.DAL.SwiftDAL;
using System.Linq;
using System.Text;

namespace Swift.web.AgentNew.Administration.CurrencyExchange {
  public partial class ReplenishmentHistory : System.Web.UI.Page {

    private const string ViewFunctionId = "20234001";
    protected const string GridName = "report";
    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly SwiftLibrary _sl = new SwiftLibrary();
    WalletDao _dao = new WalletDao();
    protected void Page_Load(object sender, EventArgs e) {
      _sl.CheckSession();
      if(!IsPostBack) {
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
        new GridFilter("tellerId", "Sender Employee", "1:EXEC proc_dropDownLists @flag='NubiaUser'",""),
        new GridFilter("startDate", "From Date", "z",System.DateTime.Now.ToString("yyyy-MM-dd")),
        new GridFilter("endDate", "To Date", "z",System.DateTime.Now.ToString("yyyy-MM-dd")),
      };

      _grid.ColumnList = new List<GridColumn>
      {
        new GridColumn("code", "Төрөл", "", "T"),
        new GridColumn("acc_num", "Данс", "", "T"),
        new GridColumn("fcy_Curr", "Валют", "", "T"),
        new GridColumn("openBalance", "Эхний үлдэгдэл", "", "T"),
        new GridColumn("drAmnt", "Орсон", "", "T"),
        new GridColumn("crAmnt", "Гарсан", "", "T"),
        new GridColumn("closeBalance", "Эцсийн үлдэгдэл", "", "T")
      };

      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridName = GridName;
      _grid.ShowPagingBar = true;
      _grid.AlwaysShowFilterForm = true;
      _grid.ShowFilterForm = true;
      _grid.SortOrder = "Desc";
      _grid.RowIdField = "acc_num";
      _grid.ThisPage = "ReplenishmentHistory.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;
      _grid.SetComma();
      _grid.EnableFilterCookie = false;
      const string sql = "EXEC [currency_Exchenge_Report] @flag = 'balance'";
      table_grid.InnerHtml = _grid.CreateGrid(sql);
    }

  }
}