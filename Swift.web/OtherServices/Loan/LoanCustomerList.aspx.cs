using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.OtherServices.Loan {
  public partial class LoanCustomerList : System.Web.UI.Page {
    private const string GridName = "loanList_grid";
    private const string ViewFunctionId = "20111300, 20192001";
    private const string AddFunctionId = "20111310";
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
                                       new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [proc_loanDataList] @flg='searchCriteria'"),
                                       new GridFilter("searchValue", "Search Value", "T")
                                   };

      _grid.ColumnList = new List<GridColumn> {
        new GridColumn("sn", "№", "", "T"),
        new GridColumn("loanNumber","Зээлийн Дугаар","","T"),
        new GridColumn("fullName","Овог Нэр","","T"),
        new GridColumn("idNumber","Регистр","","T"),
        new GridColumn("mobile","Утас","","T"),
        new GridColumn("email","И-мэйл","","T"),
        new GridColumn("loanAmount","Хэмжээ","","T"),
        new GridColumn("loanTime","Хугацаа","","T"),
        new GridColumn("interestRate","Хүү","","T"),
        new GridColumn("createdDate","Хүсэлт гаргасан огноо","","D"),
        new GridColumn("extendedDate","Сунгасан огноо","","D"),
        new GridColumn("cusFiles","Файл","","T"),
        new GridColumn("stateName","Төлөв","","LNSTATE")
      };

      bool allowAdd = swiftLibrary.HasRight(GetFunctionIdByUserType(AddFunctionIdAgent, AddFunctionId));

      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridName = GridName;
      _grid.ShowPagingBar = true;
      _grid.AlwaysShowFilterForm = true;
      _grid.ShowFilterForm = true;
      _grid.SortOrder = "ASC";
      _grid.Downloadable = true;
      _grid.RowIdField = "loanId";
      _grid.ThisPage = "LoanCustomerList.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;
      _grid.AllowCustomLink = true;
      _grid.AllowEdit = allowAdd;
      _grid.AddPage = "LoanCustomerListEdit.aspx";

      var paymentListLink = "&nbsp;<span class='action-icon'><btn class='btn btn-xs btn-default' data-toggle='tooltip' data-placement='top' title='Payment History' onclick=OpenInNewWindow('../Loan/LoanMortgagePayment.aspx?loanId=@loanId') ><i class='fa fa-list'></i></btn></span>";

      _grid.CustomLinkText = paymentListLink;

      _grid.SetComma();
      _grid.EnableFilterCookie = false;
      _grid.CustomLinkVariables = "loanId"; 
      
      string sql = "EXEC [proc_loanDataList] @flg = 'list'";
      loanList_grid.InnerHtml = _grid.CreateGrid(sql); 
    }


    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }
  }
}