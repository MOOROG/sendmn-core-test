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
  public partial class FunctionDetail : System.Web.UI.Page {
    private const string GridName = "grid_listDet";
    private const string ViewFunctionId = "10232903";
    private readonly StaticDataDdl _sl = new StaticDataDdl();
    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly RemittanceDao obj = new RemittanceDao();
    protected void Page_Load(object sender, EventArgs e) {
      if(!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
      }
      LoadGrid();
      DeleteRow();
    }

    private void Authenticate() {
      _sl.CheckAuthentication(ViewFunctionId);
    }
    protected string GetParam() {
      return GetStatic.ReadQueryString("parentId", "");
    }

    private void LoadGrid() {
      _grid.FilterList = new List<GridFilter>
                          {
                                       new GridFilter("searchValue", "Function ID", "T")
                                   };
      _grid.ColumnList = new List<GridColumn>
                          {
                                       new GridColumn("menuGroup", "Menu Group", "", "T"),
                                       new GridColumn("menuName", "Menu Name", "", "T"),
                                       new GridColumn("parentFunctionId", "Parent FunctionId", "", "T"),
                                       new GridColumn("functionId", "Function ID", "", "T"),
                                       new GridColumn("functionName", "Function Name", "", "T")
                                   };

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
      _grid.ShowAddButton = true;
      _grid.AllowEdit = true;
      _grid.AllowDelete = true;
      _grid.AddPage = "SubFunction.aspx?parentId=" + GetParam();
      _grid.SetComma();
      _grid.EnableFilterCookie = false;
      _grid.CustomLinkVariables = "functionId";

      string sql = "EXEC [proc_Menus] @flag = 'functionDetail', @id="+GetParam();
      function_grid.InnerHtml = _grid.CreateGrid(sql);
    }
    private void DeleteRow() {
      string id = _grid.GetCurrentRowId(GridName);
      if(string.IsNullOrEmpty(id))
        return;
      string sql = "DELETE FROM applicationFunctions WHERE functionId='" + id + "'";
      obj.ExecuteDataset(sql);
      GetStatic.AlertMessage(this, id + " number function: Deleted!");
      LoadGrid();
    }
  }
}