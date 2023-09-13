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

namespace Swift.web.AgentNew.SendTxn {
  public partial class TransactionRequestB2B : System.Web.UI.Page {
    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private RemittanceDao swift = null;
    private const string ViewFunctionId = "20102900";
    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        Authenticate();
      }
      LoadGrid();
    }
    private void Authenticate() {
      swiftLibrary.CheckAuthentication(ViewFunctionId);
    }

    private void LoadGrid() {
      _grid.FilterList = new List<GridFilter>
                          {
                                       new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [proc_transaction_request] @flag='searchCriteria'"),
                                       new GridFilter("searchValue", "Search Value", "T")
                                   };

      _grid.ColumnList = new List<GridColumn> {
        new GridColumn("id", "id", "", "T"),
        new GridColumn("customerId","Харилцагч","","T"),
        new GridColumn("sFullname", "Харилцагч нэр","","T"),
        new GridColumn("mobile","Илгээгч утас","","T"),
        new GridColumn("username","Илгээгч апп.нэр","","T"),
        new GridColumn("walletAccountNo","Илгээгч хэтэвч","","T"),
        new GridColumn("availableBalance","Хэтэвч мөнгө","","T"),
        new GridColumn("fullName","Хүл.авагч нэр","","T"),
        new GridColumn("bank_name","Хүл.авагч банк","","T"),
        new GridColumn("recAccountNumber","Хүл.авагч данс","","T"),
        new GridColumn("sendAmount","Илгээх дүн","","T"),
        new GridColumn("invoicePicture","Нэхэмжлэх","","T"),
        new GridColumn("tranNote","Гүйлгээний утга","","T"),
        new GridColumn("tranState","Төлөв","","T")
      };

      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridName = "TranRequest";
      _grid.ShowPagingBar = true;
      _grid.AlwaysShowFilterForm = true;
      _grid.ShowFilterForm = true;
      _grid.SortOrder = "DESC";
      _grid.RowIdField = "id";
      _grid.ThisPage = "TransactionRequestB2B.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;
      _grid.AllowCustomLink = true;

      _grid.SetComma();
      _grid.EnableFilterCookie = false;
      _grid.CustomLinkVariables = "id";

      string sql = "EXEC [proc_transaction_request] @flag = 'request-list'";
      transactionReq_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }
  }
}
