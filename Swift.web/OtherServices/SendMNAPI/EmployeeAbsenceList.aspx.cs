using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.OtherServices.SendMNAPI {
  public partial class EmployeeAbsenceList : System.Web.UI.Page {
    private const string GridName = "grid_list";
    private const string ViewFunctionId = "20111300";
    private const string AddFunctionId = "20111310";
    private const string ViewFunctionIdAgent = "40120000";
    private const string AddFunctionIdAgent = "40120010";

    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private RemittanceDao swift = null;
    public string docPath;
    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
      }
      docPath = Request.Url.GetLeftPart(UriPartial.Authority);
      LoadGrid();
    }

    private void Authenticate() {
      swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
    }

    private void LoadGrid() {
      _grid.FilterList = new List<GridFilter>
                          {
                                       new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [proc_employeeAbsence] @flg='searchCriteria'"),
                                       new GridFilter("searchValue", "Search Value", "T")
                                   };

      _grid.ColumnList = new List<GridColumn>
                          {
        new GridColumn("id", "id", "", "T"),
                                       new GridColumn("uid", "Username", "", "T"),
                                       new GridColumn("fromDt", "Хэзээнээс", "", "T"),
                                       new GridColumn("toDt", "Хүртэл", "", "T"),
                                       new GridColumn("reason", "Шалтгаан", "", "T"),
                                       new GridColumn("approve", "Зөвшөөрөх", "", "T")
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
      _grid.ThisPage = "List.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;
      _grid.AllowCustomLink = true;
      _grid.ShowAddButton = allowAdd;
      _grid.AllowEdit = allowAdd;
      _grid.AddPage = "EmployeeAbsence.aspx";

      

      _grid.SetComma();
      _grid.EnableFilterCookie = false;
      _grid.CustomLinkVariables = "id";

      string sql = "EXEC [proc_employeeAbsence] @flg = 's'";
      rpt_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }
  }
}