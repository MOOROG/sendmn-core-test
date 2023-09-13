using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.OtherServices.Loan {
  public partial class LoanMortgagePayment : System.Web.UI.Page {

      private const string GridName = "loanPayment_grid";
      private const string ViewFunctionId = "20111300, 20192001";
      private const string ViewFunctionIdAgent = "40120000";

      private readonly SwiftGrid _grid = new SwiftGrid();
      private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
      public string docPath;
      string loanId = "";
      public string loanNumber;
      protected void Page_Load(object sender, EventArgs e) {
        if (!IsPostBack) {
          GetStatic.PrintMessage(Page);
          Authenticate();
        }
        docPath = Request.Url.GetLeftPart(UriPartial.Authority);
        loanId = GetStatic.ReadQueryString("loanId", "");
        LoadGrid();
      }

      private void Authenticate() {
        swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
      }

      private void LoadGrid() {

        _grid.ColumnList = new List<GridColumn> {
        new GridColumn("sn", "№", "", "T"),
        new GridColumn("loanPayDate", "Зээл төлөх огноо", "", "D"),
        new GridColumn("principal", "Үндсэн зээл", "", "T"),
        new GridColumn("monthInterestRate","Зээлийн хүү","","T"),
        new GridColumn("interestDays","Хүү тооцсон хоног","","T"),
        new GridColumn("totalPayment","Нийт төлөх төлбөр","","T"),
        new GridColumn("loanRepayDate","Зээл төлсөн огноо","","D"),
        new GridColumn("loanPrincipal","Зээлийн үлдэгдэл","","T"),
        new GridColumn("stateName","Төлөлтийн төлөв","","T"),
        new GridColumn("paymentLate","Төлөлтийн хоцролт","","T"),

      };


        _grid.GridType = 1;
        _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
        _grid.GridName = GridName;
        _grid.SortOrder = "ASC";
        _grid.RowIdField = "mortgageId";
        _grid.ThisPage = "LoanMortgagePayment.aspx";
        _grid.InputPerRow = 4;
        _grid.GridMinWidth = 700;
        _grid.GridWidth = 100;
        _grid.IsGridWidthInPercent = true;

        string sql = "EXEC [proc_loanMortgagePayment] @flg = 'list', @loanId = '" + loanId + "',";
        loanPayment_grid.InnerHtml = _grid.CreateGrid(sql);
      }

      public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
        return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
      }
    }
  }
