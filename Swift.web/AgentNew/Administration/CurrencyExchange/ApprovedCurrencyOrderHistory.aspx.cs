using Swift.web.Component.Grid.gridHelper;
using Swift.web.Component.Grid;
using System;
using System.Collections.Generic;
using Swift.web.Library;
using Swift.DAL.BL.LoadMoneyWalletDao;
using Swift.DAL.SwiftDAL;
using System.Linq;
using System.Text;
using static iText.StyledXmlParser.Jsoup.Select.Evaluator;
using System.Net.Http;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Data;
using System.Diagnostics;
using Swift.web.Component.Tab;

namespace Swift.web.AgentNew.Administration.CurrencyExchange {
  public partial class ApprovedCurrencyOrderHistory : System.Web.UI.Page {

    private const string ViewFunctionId = "20230104";
    private const string ApproveFunctionId = "20130010";
    protected const string GridName = "report";
    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly SwiftLibrary _sl = new SwiftLibrary();
    private RemittanceDao swiftDao = new RemittanceDao();
    private string fcmServerKey = GetStatic.ReadWebConfig("fcmServerKey", "");
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
        new GridFilter("fromDate", "From Date", "z",System.DateTime.Now.ToString("yyyy-MM-dd")),
        new GridFilter("toDate", "To Date", "z",System.DateTime.Now.ToString("yyyy-MM-dd")),
        new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [mobile_proc_OrderCurrency] @flag = 'searchCriteria'"),
        new GridFilter("searchValue", "Search Value", "T"),
      };

      _grid.ColumnList = new List<GridColumn>
      {
        new GridColumn("orderId", "Захиалгын дугаар", "", "T"),
        new GridColumn("customerMobile", "Утас", "", "T"),
        new GridColumn("fromCurrency", "Дүн /MNT/", "", "T"),
        new GridColumn("toCurrency", "Дүн /Валют/", "", "T"),
        new GridColumn("rate", "Ханш", "", "T"),
        new GridColumn("createdDate", "Захиалсан огноо", "", "T"),
        new GridColumn("statusDate", "Дууссан огноо", "", "T"),
        new GridColumn("state", "Төлөв", "", "T"),
        new GridColumn("customerMail", "И-мэйл", "", "T")
      };

      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridName = GridName;
      _grid.ShowPagingBar = true;
      _grid.AlwaysShowFilterForm = true;
      _grid.ShowFilterForm = true;
      _grid.SortOrder = "Desc";
      _grid.RowIdField = "orderId";
      _grid.ThisPage = "OrderHistory.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;

      _grid.SetComma();
      _grid.EnableFilterCookie = false;
      const string sql = "EXEC [mobile_proc_OrderCurrency] @flag = 'orderCurrency-al'";
      table_grid.InnerHtml = _grid.CreateGrid(sql);
    }
  }
}