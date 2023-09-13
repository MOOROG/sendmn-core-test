using System;
using System.Collections.Generic;
using Swift.DAL.BL.Remit.Commission;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.Commission.AgentCommissionRule
{
    public partial class RuleAdd : System.Web.UI.Page
    {
        private string GridName = "";
        private const string ViewFunctionId = "20131500";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private AgentCommissionDao _commGrp = new AgentCommissionDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                PrintMsg();
            }

            SetGrid(GetFlag());
        }
        private void SetGrid(string flag)
        {
            if (flag == "sc")
            {
                GridName = "grid_scAdd";
            }
            if (flag == "cp")
            {
                GridName = "grid_cpAdd";
            }
            if (flag == "cs")
            {
                GridName = "grid_csAdd";
            }
            LoadGrid(flag);
        }
        private string GetRowIdField(string flag)
        {
            string rowId = null;
            if (flag == "sc")
            {
                rowId = "sscMasterId";
            }
            if (flag == "cp")
            {
                rowId = "scPayMasterId";
            }
            if (flag == "cs")
            {
                rowId = "scSendMasterId";
            }
            return rowId;
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        private string GetFlag()
        {
            return GetStatic.ReadQueryString("flag", "ds");
        }
        private string GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId").ToString();
        }
        private string GetAgentName()
        {
            return GetStatic.ReadQueryString("agentName", "");
        }

        private string GetMode()
        {
            return GetStatic.ReadQueryString("mode", "");
        }

        private void LoadGrid(string flag)
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("Code", "Code", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("Code", "Code", "", "T"),
                                      new GridColumn("description", "Description", "", "T")
                                  };

            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = true;
            grid.AlwaysShowFilterForm = false;
            grid.MultiSelect = true;
            grid.ShowCheckBox = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = GetRowIdField(flag);
            grid.ThisPage = "RuleAdd.aspx";

            grid.AllowEdit = false;
            grid.GridWidth = 800;

            string sql = "[proc_agentCommissionRuleAdd] @flag =" + grid.FilterString(flag) + ",@agentId=" + GetAgentId();
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            string rsList = grid.GetRowId(GridName);
            DbResult dbResult = _commGrp.AddCommissionRule(GetStatic.GetUser(), GetAgentId(), rsList, GetFlag());
            ManageMessage(dbResult);
        }
        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);

            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("AgentCommission.aspx?agentId=" + GetAgentId() + "&agentName=" + GetAgentName() + "&mode=" + GetMode());
            }
            else
            {
                PrintMsg();
            }

        }

        private void PrintMsg()
        {
            if (GetMode() == "1")
                GetStatic.AlertMessage(Page);
            else
                GetStatic.PrintMessage(Page);
        }
    }
}