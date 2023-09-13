using Swift.web.Component.Grid.gridHelper;
using Swift.web.Component.Grid;
using System;
using System.Collections.Generic;
using Swift.web.Library;
using Swift.DAL.BL.LoadMoneyWalletDao;
using Swift.DAL.SwiftDAL;
using System.Linq;
using System.Text;
using Swift.DAL.ExchangeSystem;

namespace Swift.web.AgentNew.Administration.CurrencyExchange {
  public partial class CurrencyExchangeReport : System.Web.UI.Page {

    private const string ViewFunctionId = "20230104";
    protected const string GridName = "report";
    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly SwiftLibrary _sl = new SwiftLibrary();
    ExchangeDao _dao = new ExchangeDao();
    protected void Page_Load(object sender, EventArgs e) {
      _sl.CheckSession();
      if(!IsPostBack) {
        Authenticate();
        GetStatic.PrintMessage(Page);
      }
      string reqMethod = Request.Form["MethodName"];
      switch(reqMethod) {
        case "cancel":
          cancel_click();
          break;
      }
      LoadGrid();
    }

    private void Authenticate() {
      _sl.CheckAuthentication(ViewFunctionId);
    }

    private void LoadGrid() {
      _grid.FilterList = new List<GridFilter>
      {
        new GridFilter("startDate", "From Date", "z"),
        new GridFilter("endDate", "To Date", "z"),
        new GridFilter("controlNo", "ControlNo", "T"),
        new GridFilter("cCur", "Collection Currency", "1:EXEC proc_online_dropDownList @flag='defaultCurrency'"),
        new GridFilter("pCur", "Payout Currency", "1:EXEC proc_online_dropDownList @flag='defaultCurrency'"),
        new GridFilter("customerName", "Customer", "T"),
        new GridFilter("branch", "Branch", "1:EXEC proc_online_dropDownList @flag='branch'"),
      };

      _grid.ColumnList = new List<GridColumn>
      {
        new GridColumn("customerName", "Customer Name", "", "T"),
        new GridColumn("cCurr", "Collection Currency", "", "T"),
        new GridColumn("cAmt", "Collection Amount", "", "T"),
        new GridColumn("pCurr", "Payout Currency", "", "T"),
        new GridColumn("pAmt", "Payout Amount", "", "T"),
        new GridColumn("customerRate", "Customer Rate", "", "T"),
        new GridColumn("branchName", "Branch Name", "", "T"),
        new GridColumn("createdDate", "Created Date", "", "T"),
        new GridColumn("createdBy", "Created By", "", "T"),
        new GridColumn("controlNo", "Control No", "", "T"),
        new GridColumn("otherControlNo", "Other ControlNo", "", "T"),
        new GridColumn("state", "State", "", "T"),
        new GridColumn("action", "Action", "", "T"),
      }; 

      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridName = GridName;
      _grid.ShowPagingBar = true;
      _grid.AlwaysShowFilterForm = true;
      _grid.ShowFilterForm = true;
      _grid.SortOrder = "Desc";
      _grid.RowIdField = "id";
      _grid.ThisPage = "CurrencyExchangeReport.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;
      _grid.SetComma();
      _grid.EnableFilterCookie = false;
      const string sql = "EXEC [currency_Exchenge_Report] @flag = 'exReport'";
      table_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    private void cancel_click() {
      string id = Request.Form["id"];
      var _dbRes = _dao.ExchangeControl("cancel",id,GetStatic.GetUser());
      GetStatic.JsonResponse(_dbRes, Page);
    }
  }
}