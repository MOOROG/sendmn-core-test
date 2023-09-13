using Swift.API;
using Swift.API.Common.SyncModel.Bank;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.Helper.ThirdParty;
using Swift.DAL.Remittance.SyncDao;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.TPSetup.BankAndBranchSetup {
  public partial class BranchList : System.Web.UI.Page {
    private const string GridName = "grid_list";
    private const string ViewFunctionId = "20400000";
    private const string AddEditFunctionId = "20400010";
    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private RemittanceDao obj = new RemittanceDao();
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

    private string GetBankId() {
      return GetStatic.ReadQueryString("bankId", "");
    }

    private string GetBankCode() {
      return GetStatic.ReadQueryString("bankCode", "");
    }

    private string GetPartnerId() {
      return GetStatic.ReadQueryString("partnerId", "");
    }
    private string GetCountryCode() {
      return GetStatic.ReadQueryString("countryCode", "");
    }
    private string GetCountryName() {
      return GetStatic.ReadQueryString("bankCountry", "");
    }

    private void LoadGrid() {
      _grid.FilterList = new List<GridFilter>
                            {
                                     new GridFilter("BRANCH_NAME", "BRANCH NAME", "T"),
                                  };

      _grid.ColumnList = new List<GridColumn>
                            {
                                      new GridColumn("SN", "SN", "", "T"),
                                      new GridColumn("BRANCH_CODE1", "BRANCH ID", "100", "T"),
                                      new GridColumn("BRANCH_NAME", "BRANCH NAME", "", "T"),
                                      new GridColumn("BRANCH_STATE", "BRANCH STATE", "", "T"),
                                      new GridColumn("BRANCH_ADDRESS", "BRANCH ADDRESS", "", "T"),
                                      new GridColumn("BRANCH_PHONE", "BRANCH PHONE", "", "T"),
                                      new GridColumn("countryName", "BRANCH COUNTRY", "", "T"),
                                      new GridColumn("IS_ACTIVE", "IS ACTIVE", "", "T"),
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
      _grid.RowIdField = "BRANCH_ID";
      _grid.ThisPage = "BranchList.aspx";

      var link = "<a href=\"javascript:void(0);\" onclick=\"EnableDisable('@BRANCH_ID','@BRANCH_NAME','@IS_ACTIVE');\" class=\"btn btn-xs btn-primary\">Enable/Disable</a>";
      _grid.CustomLinkVariables = "BRANCH_ID,BRANCH_NAME,IS_ACTIVE";
      _grid.CustomLinkText = link;
      _grid.InputPerRow = 5;

      string sql = "EXEC [PROC_API_BANK_BRANCH_SETUP] @flag = 'S-BankBranch',@bankId='" + GetBankId() + "'";

      _grid.SetComma();

      rpt_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    protected void btnUpdate_Click(object sender, EventArgs e) {
      BankBranchDao _dao = new BankBranchDao();
      if (!string.IsNullOrEmpty(isActive.Value)) {
        var dbResult = _dao.EnableDisableBankBranch(rowId.Value, GetStatic.GetUser(), isActive.Value);
        GetStatic.SetMessage(dbResult);
        Response.Redirect("BranchList.aspx?bankId=" + GetBankId() + "");
      }
    }

    protected void btnSyncBank_Click(object sender, EventArgs e) {
      //DataSet ds = null;
      //string sql = "select distinct bank_id, bank_code1 from API_BANK_LIST where bank_country = '" + GetCountryName() + "' and api_partner_id = " + GetPartnerId();
      //ds = obj.ExecuteDataset(sql);
      //if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
      //  int ii = 0;
      //  foreach (DataRow row in ds.Tables[0].Rows) {
      BankRequest requestObj = new BankRequest() {
        CountryCode = GetCountryCode(),
        ProviderId = GetPartnerId(),
        CityId = 0/*48932*/,
        //BankName = row["bank_code1"].ToString(),
        BankName = GetBankCode(),
        IsBranch = true,
        //bankId = row["bank_id"].ToString()
        bankId = GetBankId()
          };
          SyncBankAndBranchService serviceObj = new SyncBankAndBranchService();
          var response = serviceObj.GetBankBranchList(requestObj);
          if (response.ResponseCode == "0") {
            BankBranchDao _dao = new BankBranchDao();
            var responseData = response.Data;
            var xml = ApiUtility.ObjectToXML(responseData);
            var res = _dao.SyncBankBranch(GetStatic.GetUser(), requestObj.BankName, xml, GetCountryCode(), GetPartnerId());
            if (res.ErrorCode == "0") {
              GetStatic.AlertMessage(this, res.Msg);
              GetStatic.CallBackJs1(Page, "Call Back", "CallBack('" + res + "');");
              return;
            }
          }
        //  ii++;
        //  if (ii == ds.Tables[0].Rows.Count) {
        //    GetStatic.AlertMessage(this, ii.ToString());
        //    return;
        //  }
        //}
      //}
      GetStatic.AlertMessage(this, "Bank Branch Sycn Failed!!!!");
    }
  }
}