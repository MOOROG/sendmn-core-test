using Swift.DAL.Remittance.CashAndVault;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.CashAndVault
{
    public partial class ManageUserWiseLimit : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        protected const string GridName = "cashAndVault";
        private string ViewFunctionId = "20178000";
        private const string AddFunctionId = "20178030";
        private const string EditFunctionId = "20178010";
        private const string ApproveFunctionId = "20178050";
        private const string ActiveInActiveFunctionId = "20178040";

        //private const string AddFunctionId = "20111310";
        //private const string EditFunctionId = "20111320";
        //private const string ApproveFunctionId = "20178040";
        private readonly SwiftGrid _grid = new SwiftGrid();

        private CashAndVaultDao cavDao = new CashAndVaultDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
                H4.InnerText = "Assign Limit Userwise: " + GetSelectedAgentName();
            }
            LoadGrid();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
            {
            };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),
                                      new GridColumn("UserName", "Username", "", "T"),
                                      new GridColumn("IS_ACTIVE", "Is Active", "", "T"),
                                      new GridColumn("RULE_TYPE", "Rule Type", "", "T"),
                                      new GridColumn("cashHoldLimit", "Cash Hold Limit", "", "M"),
                                  };
            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.AllowApprove = true;
            _grid.ShowPagingBar = false;
            _grid.ShowAddButton = _sl.HasRight(AddFunctionId);
            _grid.AllowEdit = _sl.HasRight(EditFunctionId);
            _grid.AlwaysShowFilterForm = false;
            _grid.AllowApprove = _sl.HasRight(ApproveFunctionId);
            _grid.ApproveFunctionId = ApproveFunctionId;
            _grid.ShowFilterForm = false;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "cashHoldLimitId";
            _grid.ThisPage = "UserWiseLimitList.aspx";
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            _grid.AllowEdit = false;
            _grid.AddPage = "ManageUserWiseLimit.aspx";
            _grid.CustomLinkVariables = "cashHoldLimitId";
            var userWiseLink = "<span class=\"action-icon\"> <btn class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Assign Limit User Wise\"> <a href =\"ManageUserWiseLimit.aspx?cashHoldLimitId=" + GetBranchRuleId() + "&cashHoldLimitUserId=@cashHoldLimitId&agentId=" + GetAgentId() + "&userId=@userId&selectedUserName=@UserName\"><i class=\"fa fa-pencil\"></i></a></btn></span>";
            _grid.CustomLinkText = userWiseLink;
            _grid.AllowCustomLink = true;
            _grid.CustomLinkVariables = "cashHoldLimitId,userId,UserName";
            string sql = "EXEC PROC_CASHANDVAULT_USERWISE @flag = 'getBranchUser',@agentId='" + GetAgentId() + "',@cashHoldLimitBranchId='" + GetBranchRuleId() + "'";
            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        protected string GetBranchRuleId()
        {
            string id = GetStatic.ReadQueryString("cashHoldLimitId", "");
            if (!string.IsNullOrEmpty(id))
            {
                return id;
            }
            else
            {
                var res = cavDao.InsertBranchRuleId(GetStatic.GetUser(), GetAgentId());
                return res.Id;
            }
        }

        protected string GetAgentId()
        {
            return GetStatic.ReadQueryString("agentId", "");
        }

        protected string GetSelectedAgentName()
        {
            return GetStatic.ReadQueryString("selectedAgentName", "");
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            var status = hddisActive.Value.ToString();
            var cashholdLimitIdVal = hddcashHoldLimitId.Value.ToString();
            var res = cavDao.UpdateActiveInActiveStatus(GetStatic.GetUser(), status, cashholdLimitIdVal, "U");
            if (res.ErrorCode == "0")
            {
                GetStatic.AlertMessage(this.Page, res.Msg);
                Response.Redirect("UserWiseLimitList.aspx?cashHoldLimitId=" + GetCashHoldLimitId() + "&agentId=" + GetAgentId() + "&selectedAgentName=" + GetselectedAgentName());
            }
            else
            {
                GetStatic.AlertMessage(this.Page, res.Msg);
            }
        }

        private string GetCashHoldLimitId()
        {
            return GetStatic.ReadQueryString("cashHoldLimitId", "");
        }

        private string GetagentId()
        {
            return GetStatic.ReadQueryString("agentId", "");
        }

        private string GetselectedAgentName()
        {
            return GetStatic.ReadQueryString("selectedAgentName", "");
        }
    }
}