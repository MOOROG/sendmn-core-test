using System;
using System.Collections.Generic;
using System.Web.UI;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.CommonCode {
  public partial class List : Page {
    private const string GridName = "grid_sdtTyp";
    private const string ViewFunctionId = "10111001";
    private const string AddEditFunctionId = "10111011";
    private const string DeleteFunctionId = "10111021";
    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly RemittanceLibrary _sl = new RemittanceLibrary();
    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        Authenticate();
        GetStatic.PrintMessage(Page);
        GetStatic.SetActiveMenu(ViewFunctionId);
      }
      LoadGrid();
    }

    private void LoadGrid() {
      _grid.FilterList = new List<GridFilter>
                             {
                                       new GridFilter("TypeTitle", "Type Name", "LT")
                                   };

      _grid.ColumnList = new List<GridColumn>
                             {
                                       new GridColumn("code", "Code", "", "T"),
                                       new GridColumn("message", "Mongolia", "", "T"),
                                       new GridColumn("type", "English", "", "T"),
                                       new GridColumn("evalPoint", "Point", "", "T")
                                   };
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridType = 2;
      _grid.GridName = GridName;
      _grid.ShowAddButton = false;
      _grid.ShowFilterForm = true;
      _grid.ShowPagingBar = true;
      _grid.RowIdField = "code";
      _grid.MultiSelect = true;
      _grid.AllowEdit = true;
      _grid.AllowDelete = true;
      _grid.AddPage = "Manage.aspx";
      _grid.EditText = "Edit";
      const string sql = "select * from commonCode where code like 'OC0%'";
      _grid.SetComma();

      rpt_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    private void Authenticate() {
      _sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
    }

  }
}