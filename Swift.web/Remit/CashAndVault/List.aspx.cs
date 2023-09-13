using Swift.DAL.Remittance.CashAndVault;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.CashAndVault
{
    public partial class List : System.Web.UI.Page
    {
        protected const string GridName = "cashAndVault";
        private string ViewFunctionId = "20178000";
        private const string AddFunctionId = "20178030";
        private const string EditFunctionId = "20178010";
        private const string ApproveFunctionId = "20178020";
        private const string ActiveInActiveFunctionId = "20178040";

        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private CashAndVaultDao CAVDao = new CashAndVaultDao();
        private readonly SwiftGrid _grid = new SwiftGrid();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
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
                                      new GridColumn("agentName", "Agent/Branch", "", "T"),
                                      new GridColumn("RULE_TYPE", "Rule Type", "", "T"),
                                      new GridColumn("IS_ACTIVE", "Active Status", "", "T"),
                                      new GridColumn("cashHoldLimit", "Cash Hold Limit", "", "M"),
                                  };
            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.AllowApprove = _sl.HasRight(ApproveFunctionId);
            _grid.ApproveFunctionId = ApproveFunctionId;
            _grid.AlwaysShowFilterForm = false;
            _grid.ShowFilterForm = false;
            _grid.RowIdField = "cashHoldLimitId";
            _grid.ThisPage = "List.aspx";
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.AllowEdit = false;
            _grid.IsGridWidthInPercent = true;
            _grid.AddPage = "ManageBranchWiseLimit.aspx";
            _grid.AllowCustomLink = true;

            string userWiseLink = "";
            if (_sl.HasRight(EditFunctionId))
            {
                userWiseLink += "<a href =\"ManageBranchWiseLimit.aspx?cashHoldLimitId=@cashHoldLimitId&agentId=@agentId\"><span class=\"action-icon\"> <btn class=\"btn btn-xs btn-primary\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Edit\"> <i class=\"fa fa-pencil\" ></i></btn></span></a>&nbsp;&nbsp;";
            }
            userWiseLink += "<span class=\"action-icon\"> <btn class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Assign Limit User Wise\"> <a href =\"UserWiseLimitList.aspx?cashHoldLimitId=@cashHoldLimitId&agentId=@agentId&selectedAgentName=@agentName\"><i class=\"fa fa-list\" ></i></a></btn></span>";

            //userWiseLink += "&nbsp;&nbsp;<a class=\"btn btn-xs btn-danger\" title=\"In-Active\" href=\"javascript:void(0);\" onclick=\"ActiveInActive('@cashHoldLimitId')\"><i class=\"fa fa-times\"></i></a>";
            _grid.CustomLinkText = userWiseLink;
            _grid.CustomLinkVariables = "cashHoldLimitId,agentId,agentName";
            string sql = "EXEC PROC_CASHANDVAULT @flag = 's' ";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin)
        {
            return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            var status = hddisActive.Value.ToString();
            var cashholdLimitIdVal = hddcashHoldLimitId.Value.ToString();
            var res = CAVDao.UpdateActiveInActiveStatus(GetStatic.GetUser(), status, cashholdLimitIdVal, "B");
            if (res.ErrorCode == "0")
            {
                GetStatic.AlertMessage(this.Page, res.Msg);
                Response.Redirect("List.aspx");
            }
            else
            {
                GetStatic.AlertMessage(this.Page, res.Msg);
            }
        }
    }
}