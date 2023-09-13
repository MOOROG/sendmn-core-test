using System;
using System.Collections.Generic;
using System.Web.UI;
using Swift.DAL.BL.LoadMoneyWalletDao;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using static Swift.web.Autocomplete;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.Rebar;

namespace Swift.web.SwiftSystem.UserManagement.PartnerWalletRequest {
  public partial class WalletRequest : Page {
    protected const string GridName = "grdWalletRequest";
    private const string ViewFunctionId = "20233001";
    private const string AssignFunctionId = "20233002";
    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly RemittanceLibrary _sl = new RemittanceLibrary();

    protected void Page_Load(object sender, EventArgs e) {
      string reqMethod = Request.Form["MethodName"];
      switch(reqMethod) {
        case "State_Click":
          State_Click();
          break;
      }
      if(!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
      }
      LoadGrid();
    }

    private void LoadGrid() {
      _grid.FilterList = new List<GridFilter>
                             {
                                      new GridFilter("fromDate", "From Date", "z"),
                                      new GridFilter("toDate", "To Date", "z"),
                                      new GridFilter("createdBy", "Name", "T"),
                                      new GridFilter("walletAccountNo", "Wallet AccountNo", "T"),
                                      new GridFilter("amount", "Amount", "T"),
                                      new GridFilter("remarks", "Remarks", "T"),
                                      new GridFilter("status", "Status", "1:EXEC Proc_dropdown_remit @flag = 'walletRequest'")
                                   };

      _grid.ColumnList = new List<GridColumn>
                             {
                                       new GridColumn("createdDate", "Created Date", "", "DT"),
                                       new GridColumn("name", "Name", "", "T"),
                                       new GridColumn("walletAccountNo", "WalletAccount Number", "", "T"),
                                       new GridColumn("amount", "Amount", "", "T"),
                                       new GridColumn("remarks", "Remarks", "", "T"),
                                       new GridColumn("status", "Status", "", "T"),
                                   };

      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridType = 1;
      _grid.InputPerRow = 4;
      _grid.GridName = GridName;
      _grid.ShowFilterForm = true;
      _grid.EnableFilterCookie = false;
      _grid.ShowPagingBar = true;
      _grid.AddButtonTitleText = "Add New Role";
      _grid.RowIdField = "id";
      _grid.AlwaysShowFilterForm = true;
      _grid.AllowCustomLink = _sl.HasRight(AssignFunctionId);

      _grid.CustomLinkText = "<a href=\"#\" onclick=\"State_Click(@id,'Accept')\">Accept</a> | <a href=\"#\" onclick=\"State_Click(@id,'Reject')\">Reject</a>";
      _grid.CustomLinkVariables = "id";
      _grid.AddPage = "WithdrawMoneyList.aspx";
      _grid.ThisPage = "WalletRequest.aspx";
      _grid.SetComma();
      _grid.InputLabelOnLeftSide = true;
      _grid.SortOrder = "DESC";
      const string sql = "exec [Proc_Partner_Wallet_Request] @flag = 'wrList'";
      rpt_grid.InnerHtml = _grid.CreateGrid(sql);
    }

    private void State_Click() {
      WalletDao _dao = new WalletDao();
      string id = Request.Form["id"];
      string status = Request.Form["status"];
      DbResult _dbRes = _dao.PartnerWalletRequestState(id,"walletRequest",status, GetStatic.GetUser(), "admin", "", GetAgentSession());
      GetStatic.JsonResponse(_dbRes, Page);
    }

    private string GetAgentSession() {
      return (DateTime.Now.Ticks + DateTime.Now.Millisecond).ToString();
    }

    private void Authenticate() {
      _sl.CheckAuthentication(ViewFunctionId);
    }
  }
}