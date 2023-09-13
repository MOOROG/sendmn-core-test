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
  public partial class CustomerRankingList : System.Web.UI.Page {
    private const string GridName = "grid_list";
    private const string ViewFunctionId = "20111300";
    private const string ViewFunctionIdAgent = "40120000";

    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
      }
      LoadGrid();
    }

    private void Authenticate() {
      swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
    }

    private void LoadGrid() {
      _grid.FilterList = new List<GridFilter> {
        new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [proc_customerRanking] @flg ='searchCriteria'"),
        new GridFilter("searchValue", "Search Value", "T")
      };

      _grid.ColumnList = new List<GridColumn> {
        new GridColumn("id", "id", "", "T"),
        new GridColumn("username","Хэрэглэгч","","T"),
        new GridColumn("tranid","Гүйлгээний дугаар","","T"),
        new GridColumn("reviewText","Үнэлгээ","","T"),
        new GridColumn("description","Тайлбар","","T")
      };

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

      _grid.SetComma();
      _grid.EnableFilterCookie = false;
      _grid.CustomLinkVariables = "id";

      string sql = "EXEC [proc_customerRanking] @flg = 'list'";
      blacklist_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }
  }
}