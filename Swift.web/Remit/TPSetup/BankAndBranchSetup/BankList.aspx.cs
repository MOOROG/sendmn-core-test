using Swift.DAL.Remittance.SyncDao;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.TPSetup.BankAndBranchSetup {
  public partial class BankList : Page {
    private const string GridName = "grid_list";
    private const string ViewFunctionId = "10112202";
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
      swiftLibrary.CheckAuthentication(ViewFunctionId);
    }

    private void LoadGrid() {
      string ddlSql = "EXEC [PROC_API_BANK_BRANCH_SETUP] @flag = 'API-PARTNER'";
      string ddlSql1 = "EXEC [PROC_API_BANK_BRANCH_SETUP] @flag = 'PAYOUT-METHOD'";
      string ddlSqlCountry = "EXEC [PROC_API_BANK_BRANCH_SETUP] @flag = 'OPERATIVE-COUNTRY'";

      _grid.FilterList = new List<GridFilter> {
        new GridFilter("API_PARTNER", "API PARTNER", "1:"+ddlSql, "0"),
        new GridFilter("PAYMENT_TYPE", "PAYMENT TYPE", "1:"+ddlSql1, "0"),
        new GridFilter("BANK_COUNTRY", "COUNTRY", "1:"+ddlSqlCountry, "T"),
        new GridFilter("BANK_NAME", "Bank Name", "T"),
        new GridFilter("BANK_CODE", "Bank Code", "T")
      };

      _grid.ColumnList = new List<GridColumn> {
        new GridColumn("API_PARTNER", "API PARTNER", "", "T"),
        new GridColumn("BANK_NAME", "BANK NAME", "100", "T"),
        new GridColumn("BANK_CODE1", "BANK CODE1", "", "T"),
        new GridColumn("BANK_CODE2", "BANK CODE2", "", "T"),
        new GridColumn("BANK_COUNTRY", "BANK COUNTRY", "", "T"),
        new GridColumn("IS_ACTIVE", "IS ACTIVE", "", "T"),
        new GridColumn("PAYMENT_TYPE", "PAYMENT TYPE", "", "T"),
      };

      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridType = 1;
      _grid.GridName = GridName;
      _grid.ShowPagingBar = true;
      _grid.ShowAddButton = false;
      _grid.AllowEdit = false;
      _grid.AllowDelete = false;
      _grid.AddPage = "AddApiPartner.aspx";
      _grid.AlwaysShowFilterForm = true;
      _grid.ShowFilterForm = true;
      _grid.AllowCustomLink = true;
      _grid.SortOrder = "ASC";
      _grid.RowIdField = "BANK_ID";
      _grid.ThisPage = "BankList.aspx";
      var branchLink = "<span class=\"action-icon\"> <btn class=\"btn btn-xs btn-success\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Bank Branch\"> <a href =\"BranchList.aspx?bankId=@BANK_ID&bankCode=@BANK_CODE1&partnerId=@API_PARTNER_ID&countryCode=@COUNTRYCODE&bankCountry=@BANK_COUNTRY\"><i class=\"fa fa-building-o\" ></i></a></btn></span>";
      var link = "&nbsp;<a href=\"javascript:void(0);\" onclick=\"EnableDisable('@BANK_ID','@BANK_NAME','@IS_ACTIVE');\" class=\"btn btn-xs btn-primary\">Enable/Disable</a>";
      _grid.CustomLinkVariables = "BANK_ID,BANK_CODE1,API_PARTNER_ID,BANK_NAME,IS_ACTIVE,COUNTRYCODE,BANK_COUNTRY";
      _grid.CustomLinkText = branchLink + link;

      _grid.InputPerRow = 5;

      string sql = "EXEC [PROC_API_BANK_BRANCH_SETUP] @flag = 'S'";

      _grid.SetComma();

      rpt_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    protected void btnUpdate_Click(object sender, EventArgs e) {
      BankBranchDao _dao = new BankBranchDao();
      if (!string.IsNullOrEmpty(isActive.Value)) {
        var dbResult = _dao.EnableDisableBank(rowId.Value, GetStatic.GetUser(), isActive.Value);
        GetStatic.SetMessage(dbResult);
        Response.Redirect("BankList.aspx");
      }
    }
  }
}