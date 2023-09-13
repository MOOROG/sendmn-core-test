using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.BL.System.UserManagement;
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

namespace Swift.web.Coupon {
  public partial class List : System.Web.UI.Page {
    private const string GridName = "grid_list";
    private const string ViewFunctionId = "10233000";
    private const string AddFunctionId = "10233001";
    private const string DeleteFunctionId = "10233002";

    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private readonly AdminDao _dao = new AdminDao();
    protected void Page_Load(object sender, EventArgs e) {
      if(!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
      }
      LoadGrid();
      DeleteRow();
    }

    private void Authenticate() {
      swiftLibrary.CheckAuthentication(ViewFunctionId);
    }

    private void LoadGrid() {
      _grid.FilterList = new List<GridFilter>
                          {
                                       new GridFilter("startFromDate", "Start From Date", "z"),
                                       new GridFilter("startToDate", "Start To Date", "z"),
                                       new GridFilter("endFromDate", "End From Date", "z"),
                                       new GridFilter("endToDate", "End To Date", "z"),
                                       new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [proc_Menus] @flag='searchCriteria'"),
                                       new GridFilter("searchValue", "Search Value", "T")
                                   };
      _grid.ColumnList = new List<GridColumn>
                          {
                                       new GridColumn("partnerId", "Partner", "", "T"),
                                       new GridColumn("code", "Coupon Code", "", "T"),
                                       new GridColumn("name", "Coupon Name", "", "T"),
                                       new GridColumn("description", "Description", "", "T"),
                                       new GridColumn("couponPrice", "Coupon Price", "", "T"),
                                       new GridColumn("couponQuantity", "Coupon Quantity", "", "T"),
                                       new GridColumn("discountType", "Discount Type", "", "T"),
                                       new GridColumn("discountAmount", "Discount Amount", "", "T"),
                                       new GridColumn("discountCurrency", "Discount Currency", "", "T"),
                                       new GridColumn("startDate", "Start Date", "", "T"),
                                       new GridColumn("endDate", "End Date", "", "T")
                                   };
      bool allowAdd = swiftLibrary.HasRight(AddFunctionId);

      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridName = GridName;
      _grid.ShowPagingBar = true;
      _grid.AlwaysShowFilterForm = true;
      _grid.ShowFilterForm = true;
      _grid.RowIdField = "id";
      _grid.ThisPage = "List.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;
      _grid.AllowCustomLink = true;
      _grid.ShowAddButton = allowAdd;
      _grid.AllowEdit = allowAdd;
      _grid.AllowDelete = swiftLibrary.HasRight(DeleteFunctionId);
      _grid.AddPage = "Edit.aspx";
      _grid.SetComma();
      _grid.EnableFilterCookie = false;
      _grid.CustomLinkVariables = "id";

      string sql = "EXEC [proc_coupon_list] @flag = 'list'";
      list_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }
    private void DeleteRow() {
      string id = _grid.GetCurrentRowId(GridName);
      if(string.IsNullOrEmpty(id))
        return;
      DbResult dbResult = _dao.CouponDelete(id);
      ManageMessage(dbResult);
      LoadGrid();
    }
    private void ManageMessage(DbResult dbResult) {
      GetStatic.SetMessage(dbResult);
      GetStatic.AlertMessage(Page);
    }
  }
}