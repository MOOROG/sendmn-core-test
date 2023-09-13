using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.OtherServices.SendMNAPI {
  public partial class BranchTransaction : System.Web.UI.Page {
    private const string GridName = "grid_list";
    private const string ViewFunctionId = "40102000";
    private const string ViewFunctionIdAgent = "40102000";
    private const string AddFunctionId = "20111310";
    private const string AddFunctionIdAgent = "40120010";
    private const string DeleteFunctionId = "10101320";

    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private RemittanceDao swiftDao = new RemittanceDao();
    string custId = "";
    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
      }
      custId = GetStatic.ReadQueryString("customerId", "");
      LoadGrid();
      DeleteRow();
    }

    private void Authenticate() {
      swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
    }
    private void DeleteRow() {
      if (!isRefresh) {
        string id = _grid.GetCurrentRowId(GridName);
        if (string.IsNullOrEmpty(id))
          return;
        string sql = "EXEC [proc_branchTransaction] @flg = 'd'";
        sql += ", @id=" + swiftDao.FilterString(id);
        DbResult dbResult = swiftDao.ParseDbResult(swiftDao.ExecuteDataset(sql).Tables[0]);
        GetStatic.SetMessage(dbResult);
        GetStatic.AlertMessage(Page);
        LoadGrid();
      }
    }
    private void LoadGrid() {
      _grid.FilterList = new List<GridFilter>
                          {
                                       new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [proc_branchTransaction] @flg='searchCriteria'")
                                   };

      _grid.ColumnList = new List<GridColumn> {
        new GridColumn("sn", "Д/Д", "", "T"),
        new GridColumn("id", "id", "", "T", "0"),
        new GridColumn("inOut","Төрөл","","T"),
        new GridColumn("systemName","Систем","","T"),
        new GridColumn("controlNumber","Гуйвуулгын код","","T"),
        new GridColumn("recSendLastname","Хүлээн авагч / Илгээгч овог","","T"),
        new GridColumn("recSendName","Хүлээн авагч / Илгээгч нэр","","T"),
        new GridColumn("receivedCurrency","Ирсэн / Илгээх валют","","T"),
        new GridColumn("receivedAmount","Ирсэн / Илгээх дүн","","T"),
        new GridColumn("rate","Ханш","","T"),
        new GridColumn("gaveCurrency","Хүлээлгэн өгсөн валют","","T"),
        new GridColumn("gaveAmount","Хүлээлгэн өгсөн дүн","","T"),
        new GridColumn("tranType","Гүйлгээний Төрөл","","T"),
        new GridColumn("gaveTookAmount","Олгосон / Авсан төгрөг","","T"),
        new GridColumn("serviceFee","Үйлчилгээний хураамж / Шимтгэл","","T"),
        new GridColumn("sendRecLastName","Илгээгч / Хүлээн авагч овог","","T"),
        new GridColumn("sendRecName","Илгээгч / Хүлээн авагч нэр","","T"),
        new GridColumn("country","Илгээсэн улс","","T"),
        new GridColumn("operatorName","Теллер","","T"),
        new GridColumn("customer", "Who","","T"),
        new GridColumn("tranDate", "Date","","T")
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
      _grid.ThisPage = "BranchTransaction.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;
      _grid.AllowCustomLink = true;
      _grid.AllowDelete = swiftLibrary.HasRight(DeleteFunctionId);
      _grid.ShowAddButton = allowAdd;
      _grid.AllowEdit = allowAdd;
      _grid.AddPage = "BranchTranAdd.aspx";
      var listLink = "&nbsp;<span class='action-icon'><btn class='btn btn-xs btn-default' data-toggle='tooltip' data-placement='top' title='Гүйлгээ засах' onclick=OpenInNewWindow('../SendMNAPI/BranchTranAdd.aspx?id=@id') ><i class='fa fa-pencil'></i></btn></span>";
      _grid.CustomLinkText = listLink;

      _grid.SetComma();
      _grid.EnableFilterCookie = false;
      _grid.CustomLinkVariables = "id";
      string sql = "";
      string usrAccLvl = GetStatic.GetUserAccessLevel();
      if (custId.Equals("")) {
        if (GetStatic.GetUserType().Equals("HO") && usrAccLvl.Equals("M")) {
          sql = "EXEC [proc_branchTransaction] @flg = 'listAdmin',@customerId = '', @datas = ''";
        } else {
          sql = "EXEC [proc_branchTransaction] @flg = 'listOperator',@customerId = '" + GetStatic.GetUser() + "', @datas = ''";
        }
      } else {
        sql = "EXEC [proc_branchTransaction] @flg = 'list',@customerId = '" + custId + "', @datas = ''";
      }
      rpt_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
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