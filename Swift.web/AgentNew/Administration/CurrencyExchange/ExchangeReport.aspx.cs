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
  public partial class ExchangeReport : System.Web.UI.Page {

    private const string ViewFunctionId = "2023100";
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
        new GridFilter("startDate", "From Date", "z",System.DateTime.Now.ToString("yyyy-MM-dd")),
        new GridFilter("endDate", "To Date", "z",System.DateTime.Now.ToString("yyyy-MM-dd")),
        new GridFilter("cCur", "Валют", "1:EXEC proc_online_dropDownList @flag='defaultCurrency'"),
      };

      _grid.ColumnList = new List<GridColumn>
      {
        new GridColumn("createdDate", "Он сар өдөр", "", "T"),
        new GridColumn("nationality", "Иргэншил", "", "T"),
        new GridColumn("ovog", "Харилцагчийн овог", "", "T"),
        new GridColumn("ner", "Харилцагчийн нэр", "", "T"),
        new GridColumn("rd", "РД дугаар", "", "T"),
        new GridColumn("phones", "Утасны дугаар", "", "T"),
        new GridColumn("type", "Авсан/Зарсан", "", "T"),
        new GridColumn("createdBy", "Теллер", "", "T"),
        new GridColumn("cpType", "Гүйлгээний төрөл", "", "T"),
        new GridColumn("cpCurr", "Валют", "", "T"),
        new GridColumn("cpAmnt", "Тоо хэмжээ", "", "T"),
        new GridColumn("cpRate", "Ханш", "", "T"),
        new GridColumn("sumAmnt", "Нийт дүн", "", "T"),
      }; 

      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridName = GridName;
      _grid.ShowPagingBar = true;
      _grid.AlwaysShowFilterForm = true;
      _grid.ShowFilterForm = true;
      _grid.SortOrder = "Desc";
      _grid.RowIdField = "createdDate";
      _grid.ThisPage = "ExchangeReport.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;
      _grid.SetComma();
      _grid.EnableFilterCookie = false;
      const string sql = "EXEC [currency_Exchenge_Report] @flag = 'exList'";
      table_grid.InnerHtml = _grid.CreateGrid(sql);
    }

  }
}