using System;
using System.Collections.Generic;
using System.Web.UI;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.OtherServices;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationRoleSetup {
  public partial class ListCashCode : Page {
    protected const string GridName = "grdRole";
    private const string ViewFunctionId = "20111300";
    //private const string AddEditFunctionId = "10101010";
    //private const string DeleteFunctionId = "10101020";
    //private const string AssignFunctionId = "10101040";
    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly LuckyDrawDao _roleDao = new LuckyDrawDao();
    private readonly RemittanceLibrary _sl = new RemittanceLibrary();
    private readonly RemittanceDao obj = new RemittanceDao();
    public string docPath;

    protected void Page_Load(object sender, EventArgs e) {

      if(!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
      }
      docPath = Request.Url.GetLeftPart(UriPartial.Authority);
      DeleteRow();
      LoadGrid();
    }

    private void LoadGrid() {
      _grid.FilterList = new List<GridFilter>
                          {
                                       new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [proc_cashcodelist] @flg='searchCriteria'"),
                                       new GridFilter("searchValue", "Search Value", "T"),
                                       new GridFilter("fromDate", "Paid From", "z"),
                                       new GridFilter("toDate", "Paid To", "z")
                                   };

      _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("controlNo", "ControlNo", "", "T"),
                                       new GridColumn("firstName", "Нэр", "", "T"),
                                       new GridColumn("LastName", "Овог", "", "T"),
                                       new GridColumn("register", "Регистер", "", "T"),
                                       new GridColumn("phone", "Утас", "", "T"),
                                       new GridColumn("bank", "Банк", "", "T"),
                                       new GridColumn("accountNo", "Данс", "", "T"),
                                       new GridColumn("photo1", "photo1", "", "T"),
                                       new GridColumn("createdDate", "Хүсэлтийн огноо", "", "T"),
                                       new GridColumn("paidBy", "Оператор", "", "T"),
                                       new GridColumn("paidDate", "Төлсөн огноо", "", "T"),
                                       new GridColumn("amount", "Дүн", "", "T"),
                                       new GridColumn("state", "Төлөв", "", "T"),
                                       new GridColumn("minuteDiff","Minute Diff","","T"),
                                   };


      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridName = GridName;
      _grid.AlwaysShowFilterForm = true;
      _grid.ShowFilterForm = true;
      _grid.ShowPagingBar = true;
      _grid.SortOrder = "DESC";
      _grid.SortBy = "createdDate";
      _grid.RowIdField = "id";
      _grid.ThisPage = "List.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;
      _grid.AllowCustomLink = true;
      _grid.SetComma();
      _grid.EnableFilterCookie = false;
      _grid.AllowCustomLink = true;
      _grid.AllowDelete = true;
      _grid.RowIdField = "id";
      _grid.ThisPage = "ListCashCode.aspx";
      var link = "&nbsp;<a href=\"javascript:void(0);\" onclick=\"EnableDisable('@id','@controlNo','@state');\" class=\"btn btn-xs btn-primary @state\">Pay</a>";
      _grid.CustomLinkText = link;
      _grid.CustomLinkVariables = "id,controlNo,state";

      const string sql = "exec [proc_cashcodelist] @flg = 's'";

      rpt_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    protected void btnUpdate_Click(object sender, EventArgs e) {
      string id = rowId.Value;
      string user = GetStatic.GetUser();
      string state = isActive.Value;

      string sql = "update cashPaymentCode set paidDate = getDate(), paidBy = '"+user+"', state = '"+state+"' where id = '"+id+"' ";
      obj.ExecuteDataset(sql);
      Response.Redirect("ListCashCode.aspx");
      return;
    }

    private void Authenticate() {
      _sl.CheckAuthentication(ViewFunctionId);
    }

    private void DeleteRow() {
      string id = _grid.GetCurrentRowId(GridName);

      if(id == "")
        return;

      DbResult dbResult = _roleDao.DeleteCashCode(id, GetStatic.GetUser());
      ManageMessage(dbResult);
    }

    private void ManageMessage(DbResult dbResult) {
      GetStatic.SetMessage(dbResult);
      GetStatic.PrintMessage(Page);
    }
  }
}