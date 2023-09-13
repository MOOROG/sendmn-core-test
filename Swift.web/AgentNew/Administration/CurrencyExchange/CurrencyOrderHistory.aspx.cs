using Swift.web.Component.Grid.gridHelper;
using Swift.web.Component.Grid;
using System;
using System.Collections.Generic;
using Swift.web.Library;
using Swift.DAL.BL.LoadMoneyWalletDao;
using Swift.DAL.SwiftDAL;
using Swift.API.ThirdPartyApiServices;
using Swift.API.Common;
using Swift.DAL.OnlineAgent;
using System.Web;

namespace Swift.web.AgentNew.Administration.CurrencyExchange {
  public partial class CurrencyOrderHistory : System.Web.UI.Page {

    private const string ViewFunctionId = "10233100";
    protected const string GridName = "report";
    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly SwiftLibrary _sl = new SwiftLibrary();
    private RemittanceDao swiftDao = new RemittanceDao();
    private readonly ThirdPartyAPI _tpApi = new ThirdPartyAPI();
    private string fcmServerKey = GetStatic.ReadWebConfig("fcmServerKey", "");
    WalletDao _dao = new WalletDao();
    protected void Page_Load(object sender, EventArgs e) {
      _sl.CheckSession();
      if(!IsPostBack) {
        Authenticate();
      }
      string reqMethod = Request.Form["MethodName"];
      switch (reqMethod) {
        case "cancel":
          DeclineRow();
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
        new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [mobile_proc_OrderCurrency] @flag = 'searchCriteria'"),
        new GridFilter("searchValue", "Search Value", "T"),
      };

      _grid.ColumnList = new List<GridColumn>
      {
        new GridColumn("SN", "№", "", "T"),
        new GridColumn("orderId", "Захиалгын дугаар", "", "T"),
        new GridColumn("customerMobile", "Утас", "", "T"),
        new GridColumn("fromCurrency", "Дүн /MNT/", "", "M"),
        new GridColumn("toCurrency", "Дүн /Валют/", "", "M"),
        new GridColumn("rate", "Ханш", "", "T"),
        new GridColumn("createdDate", "Захиалсан огноо", "", "T"),
        new GridColumn("statusDate", "Дуусах огноо", "", "T"),
        new GridColumn("state", "Төлөв", "", "T"),
        new GridColumn("customerMail", "И-мэйл", "", "T"),
        new GridColumn("bankAccountNo", "Данс", "", "T"),
        new GridColumn("confirmationNo", "Баталгаажуулах код", "", "T"),
        new GridColumn("isActive", "", "", "T"),
      };
      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridName = GridName;
      _grid.ShowPagingBar = true;
      _grid.AlwaysShowFilterForm = true;
      _grid.ShowFilterForm = true;
      _grid.SortOrder = "DESC";
      _grid.RowIdField = "orderId";
      _grid.ThisPage = "OrderHistory.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;
      _grid.AllowCustomLink = true;
      _grid.CustomLinkVariables = "orderId";
      string sql = "EXEC [mobile_proc_OrderCurrency] @flag = 'orderCurrency-list' ";
      _grid.SetComma();
      table_grid.InnerHtml = _grid.CreateGrid(sql);
    }
    private void DeclineRow() {
      if (!isRefresh) {
        string id = Request.Form["id"];
        if (string.IsNullOrEmpty(id))
          return;
        APIJsonResponse _apiJsonResponse = new APIJsonResponse();
        OrderCancel model = new OrderCancel() {
          orderId = id
        };

        var result = _tpApi.ThirdPartyApiGetDataOnly<OrderCancel, APIJsonResponse>(model, "TP/cancelOrderCurrency", out _apiJsonResponse);

        DbResult dbResult = DeclineRow(id);
        ManageMessage(dbResult);
      }
    }

    public DbResult DeclineRow(string id) {
      string sql = "Exec [mobile_proc_OrderCurrency]";
      sql += " @flag ='decline-order-admin'";
      sql += ", @orderId=" + swiftDao.FilterString(id);
      sql += ", @USER=" + GetStatic.GetUser();
      return swiftDao.ParseDbResult(swiftDao.ExecuteDataset(sql).Tables[0]);
    }

    private void ManageMessage(DbResult dbResult) {
      GetStatic.SetMessage(dbResult.Id, dbResult.Msg);
      GetStatic.PrintMessage(Page);
    }

    #region Browser Refresh
    private bool refreshState;
    private bool isRefresh;

    protected override void LoadViewState(object savedState) {
      object[] AllStates = (object[])savedState;
      base.LoadViewState(AllStates[0]);
      refreshState = bool.Parse(AllStates[1].ToString());
      if (Session["ISREFRESH"] != null && Session["ISREFRESH"] != "")
        isRefresh = (refreshState == (bool)Session["ISREFRESH"]);
    }

    protected override object SaveViewState() {
      Session["ISREFRESH"] = refreshState;
      object[] AllStates = new object[3];
      AllStates[0] = base.SaveViewState();
      AllStates[1] = !(refreshState);
      return AllStates;
    }

    #endregion
  }
}