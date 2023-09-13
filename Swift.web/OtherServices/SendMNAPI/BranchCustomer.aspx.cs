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
  public partial class BranchCustomer : System.Web.UI.Page {
    private const string GridName = "grid_list";
    private const string ViewFunctionId = "20230106";
    private const string AddFunctionId = "20230206";

    private const string ViewFunctionIdAgent = "40120000";
    private const string AddFunctionIdAgent = "40120010";

    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
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
                                       new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [proc_branchCustomer] @flg='searchCriteria'"),
                                       new GridFilter("searchValue", "Search Value", "T")
                                   };
      _grid.ColumnList = new List<GridColumn>
                          {
                                       new GridColumn("sn", "SN", "", "T"),
                                       new GridColumn("rd", "RD", "", "T"),
                                       new GridColumn("ovog", "Овог", "", "T"),
                                       new GridColumn("ner", "Нэр", "", "T"),
                                       new GridColumn("phones", "Утас", "", "T"),
                                       new GridColumn("huis", "Хүйс", "", "T"),
                                       new GridColumn("aimag", "Аймаг", "", "T"),
                                       new GridColumn("sum", "Сум", "", "T"),
                                       new GridColumn("hayag", "Хаяг", "", "T"),
                                       new GridColumn("email", "Email", "", "T"),
                                       new GridColumn("birthday", "Birthday", "", "T"),
                                       new GridColumn("occupType", "Салбар", "", "T"),
                                       new GridColumn("photo1", "photo1", "", "T"),
                                       new GridColumn("complianceEval","Эрсдэл","","T")
                                   };
      bool allowAdd = swiftLibrary.HasRight(GetFunctionIdByUserType(AddFunctionIdAgent, AddFunctionId));

      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridName = GridName;
      _grid.ShowPagingBar = true;
      _grid.AlwaysShowFilterForm = true;
      _grid.ShowFilterForm = true;
      _grid.SortOrder = "ASC";
      _grid.RowIdField = "customerId";
      _grid.ThisPage = "List.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;
      _grid.AllowCustomLink = true;
      _grid.ShowAddButton = allowAdd;
      _grid.AllowEdit = allowAdd;
      _grid.AddPage = "ManageBranchCustomer.aspx";
      _grid.RowColoredByColValue1 = new string[] { "complianceEval:high:#fd5e53", "complianceEval:medium:#f1f794" };

      var addLink = "&nbsp;<span class='action-icon'><btn class='btn btn-xs btn-default' data-toggle='tooltip' data-placement='top' title='Гүйлгээ нэмэх' onclick=OpenInNewWindow('../SendMNAPI/BranchTranAdd.aspx?customerId=@customerId') ><i class='fa fa-plus'></i></btn></span>";
      var listLink = "&nbsp;<span class='action-icon'><btn class='btn btn-xs btn-default' data-toggle='tooltip' data-placement='top' title='Гүйлгээ жагсаалт' onclick=OpenInNewWindow('../SendMNAPI/BranchTransaction.aspx?customerId=@customerId') ><i class='fa fa-list'></i></btn></span>";

      _grid.CustomLinkText = addLink + listLink;

      _grid.SetComma();
      _grid.EnableFilterCookie = false;
      _grid.CustomLinkVariables = "customerId";

      string sql = "EXEC [proc_branchCustomer] @flg = 's'";
      rpt_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }
  }
}