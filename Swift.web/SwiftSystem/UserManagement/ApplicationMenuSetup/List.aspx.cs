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

namespace Swift.web.SwiftSystem.UserManagement.ApplicationMenuSetup {
  public partial class List : System.Web.UI.Page {
    private const string GridName = "grid_list";
    private const string ViewFunctionId = "10232900";
    private const string AddFunctionId = "10232901";
    private const string DeleteFunctionId = "10232902";
    private const string DetailFunctionId = "10232903";

    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private readonly ApplicationRoleDao _obj = new ApplicationRoleDao();
    protected void Page_Load(object sender, EventArgs e) {
      if(!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
      }
      detailFunction.Text = swiftLibrary.HasRight(DetailFunctionId).ToString();
      LoadGrid();
      DeleteRow();
    }

    private void Authenticate() {
      swiftLibrary.CheckAuthentication(ViewFunctionId);
    }

    private void LoadGrid() {
      _grid.FilterList = new List<GridFilter>
                          {
                                       new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [proc_Menus] @flag='searchCriteria'"),
                                       new GridFilter("searchValue", "Search Value", "T")
                                   };
      _grid.ColumnList = new List<GridColumn>
                          {
                                       new GridColumn("Module", "Module", "", "T"),
                                       new GridColumn("moduleName", "Module Name", "", "T"),
                                       new GridColumn("menuGroup", "Menu Group", "", "T"),
                                       new GridColumn("functiondet", "Function ID", "", "T"),
                                       new GridColumn("menuName", "Menu Name", "", "T"),
                                       new GridColumn("menuDescription", "Menu Description", "", "T"),
                                       new GridColumn("linkPage", "Link", "", "T"),
                                       new GridColumn("AgentMenuGroup", "Agent MenuGroup", "", "T")
                                   };
      bool allowAdd = swiftLibrary.HasRight(AddFunctionId);

      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridName = GridName;
      _grid.ShowPagingBar = true;
      _grid.AlwaysShowFilterForm = true;
      _grid.ShowFilterForm = true;
      _grid.RowIdField = "functionId";
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
      _grid.CustomLinkVariables = "functionId";

      string sql = "EXEC [proc_Menus] @flag = 'list'";
      list_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }
    private void DeleteRow() {
      string id = _grid.GetCurrentRowId(GridName);
      if(string.IsNullOrEmpty(id))
        return;
      DbResult dbResult = _obj.MenuDelete(GetStatic.GetUser(), id);
      ManageMessage(dbResult);
      LoadGrid();
    }
    private void ManageMessage(DbResult dbResult) {
      GetStatic.SetMessage(dbResult);
      GetStatic.AlertMessage(Page);
    }
  }
}