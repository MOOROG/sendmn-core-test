using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.Commission.CommissionDomestic
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "grd_sc";

        private const string ViewFunctionId = "20131300";
        private const string AddEditFunctionId = "20131310";
        private const string ApproveFunctionId = "20131330";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftGrid grid = new SwiftGrid();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
            LoadGrid();
        }

        private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("code", "Code", "", "T"),
                                      new GridColumn("sAgentName", "S. Agent", "", "T"),
                                      new GridColumn("sBranchName", "S. Branch", "", "T"),
                                      new GridColumn("sStateName", "S. State", "", "T"),
                                      new GridColumn("sGroupName", "S. Group", "", "T"),
                                      new GridColumn("rAgentName", "R. Agent", "", "T"),
                                      new GridColumn("rBranchName", "R. Branch", "", "T"),
                                      new GridColumn("rStateName", "R. State", "", "T"),
                                      new GridColumn("rGroupName", "R. Group", "", "T"),
                                      new GridColumn("tranTypeName", "Service Type", "", "T"),
                                      new GridColumn("fromAmt", "From", "", "M"),
                                      new GridColumn("toAmt", "To", "", "M")
                                  };

            bool allowAddEdit = _sdd.HasRight(AddEditFunctionId);

            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            string sAgentId = IsPostBack ? sAgent.Text : GetStatic.ReadValue(GridName, "sAgent");
            string sBranchId = IsPostBack ? sBranch.Text : GetStatic.ReadValue(GridName, "sBranch");
            string sStateId = IsPostBack ? sState.Text : GetStatic.ReadValue(GridName, "sState");
            string sGroupId = IsPostBack ? sGroup.Text : GetStatic.ReadValue(GridName, "sGroup");

            string rAgentId = IsPostBack ? rAgent.Text : GetStatic.ReadValue(GridName, "rAgent");
            string rBranchId = IsPostBack ? rBranch.Text : GetStatic.ReadValue(GridName, "rBranch");
            string rStateId = IsPostBack ? rState.Text : GetStatic.ReadValue(GridName, "rState");
            string rGroupId = IsPostBack ? rGroup.Text : GetStatic.ReadValue(GridName, "rGroup");


            string tranTypeId = IsPostBack ? tranType.Text : GetStatic.ReadValue(GridName, "tranType");


            if (!IsPostBack)
            {
                LoadAgent(ref sAgent, GetStatic.GetDomesticSuperAgentId(), GetStatic.GetDomesticCountryId(), sAgentId);
                LoadAgent(ref rAgent, GetStatic.GetDomesticSuperAgentId(), GetStatic.GetDomesticCountryId(), rAgentId);

                LoadBranch(ref sBranch, sAgentId, sBranchId);
                LoadBranch(ref rBranch, rAgentId, rBranchId);

                _sdd.SetDDL(ref tranType,
                            "SELECT serviceTypeId, typeTitle FROM serviceTypeMaster WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') <> 'Y'",
                            "serviceTypeId", "typeTitle", tranTypeId, "All");

                _sdd.SetStaticDdl(ref sGroup, "6300", sGroupId, "Any");
                _sdd.SetStaticDdl(ref rGroup, "6300", rGroupId, "Any");
                LoadState(ref sState, GetStatic.GetDomesticCountryId(), sStateId);
                LoadState(ref rState, GetStatic.GetDomesticCountryId(), rStateId);
            }

            string queryString = "sAgent=" + sAgentId + "&sBranch=" + sBranchId +
                                 "&sState=" + sStateId + "&sGroup=" + sGroupId +
                                 "&rAgent=" + rAgentId + "&rBranch=" + rBranchId +
                                 "&rState=" + rStateId + "&rGroup=" + rGroupId +
                                 "&tranType=" + tranTypeId;


            grid.GridType = 1;

            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New";
            grid.RowIdField = "scMasterId";
            grid.SortBy = "code";
            grid.SortOrder = "ASC";
            grid.AddPage = "Manage.aspx?" + queryString;
            grid.InputPerRow = 3;
            grid.InputLabelOnLeftSide = true;
            grid.ApproveFunctionId = ApproveFunctionId;
            grid.AllowApprove = _sdd.HasRight(ApproveFunctionId);
            grid.AlwaysShowFilterForm = true;
            grid.AllowEdit = allowAddEdit;
            grid.DisableSorting = true;
            grid.DisableJsFilter = true;
            grid.GridMinWidth = 1000;
            grid.IsGridWidthInPercent = true;
            grid.GridWidth = 100;
            grid.EnableToolTip = true;
            grid.ToolTipField = "description";
            grid.AllowCustomLink1 = true;
            grid.CustomLinkVariables = "scMasterId";
            grid.CustomLinkText1 = "<img id=\"showSlab_@scMasterId\" border=\"0\" title=\"View Slab\" class=\"showHand\" src=\"" + GetStatic.GetUrlRoot() + "/Images/view-detail.gif\" onclick=\"ShowSlab(@scMasterId);\"/>";

            string sql = "EXEC proc_scMaster @flag = 'm'" +
                         ", @sAgent=" + grid.FilterString(sAgentId) +
                         ", @sBranch=" + grid.FilterString(sBranchId) +
                         ", @sState=" + grid.FilterString(sStateId) +
                         ", @sGroup=" + grid.FilterString(sGroupId) +
                         ", @rAgent=" + grid.FilterString(rAgentId) +
                         ", @rBranch=" + grid.FilterString(rBranchId) +
                         ", @rState=" + grid.FilterString(rStateId) +
                         ", @rGroup=" + grid.FilterString(rGroupId) +
                         ", @tranType=" + grid.FilterString(tranTypeId) +
                         ", @hasChanged=" + grid.FilterString(hasChanged.Text);

            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void LoadCountry(ref DropDownList ddl, string hubId, string defaultValue)
        {
            string sql = "EXEC proc_agentMaster @flag = 'cal', @agentId=" + _sdd.FilterString(hubId);
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, "All");
        }

        private void LoadSuperAgent(ref DropDownList ddl, string hubId, string defaultValue)
        {
            string sql = "EXEC proc_agentMaster @flag = 'sal', @parentId=" + _sdd.FilterString(hubId);

            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", defaultValue, "All");
        }

        private void LoadAgent(ref DropDownList ddl, string parentId, string countryId, string defaultValue)
        {
            string sql = "EXEC proc_agentMaster @flag = 'al', @parentId=" + _sdd.FilterString(parentId) +
                         ", @agentCountry=" + _sdd.FilterString(countryId);

            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", defaultValue, "All");
        }

        private void LoadBranch(ref DropDownList ddl, string parentId, string defaultValue)
        {
            string sql = "EXEC proc_agentMaster @flag = 'bl', @parentId=" + _sdd.FilterString(parentId);

            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", defaultValue, "All");
        }

        private void LoadState(ref DropDownList ddl, string countryId, string defaultValue)
        {
            string sql = "EXEC proc_countryStateMaster @flag = 'csl', @countryId=" + _sdd.FilterString(countryId);

            _sdd.SetDDL(ref ddl, sql, "stateId", "stateName", defaultValue, "All");
        }

        protected void SaveAsCookie()
        {
            GetStatic.WriteValue(GridName, ref sAgent, "sAgent");
            GetStatic.WriteValue(GridName, ref sBranch, "sBranch");
            GetStatic.WriteValue(GridName, ref sState, "sState");
            GetStatic.WriteValue(GridName, ref sGroup, "sGroup");

            GetStatic.WriteValue(GridName, ref rAgent, "rAgent");
            GetStatic.WriteValue(GridName, ref rBranch, "rBranch");
            GetStatic.WriteValue(GridName, ref rState, "rState");
            GetStatic.WriteValue(GridName, ref rGroup, "rGroup");

            GetStatic.WriteValue(GridName, ref tranType, "tranType");
        }

        #region Control Methods

        protected void sAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadBranch(ref sBranch, sAgent.Text, "");
            sAgent.Focus();
        }

        protected void rAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadBranch(ref rBranch, rAgent.Text, "");
            rAgent.Focus();
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            SaveAsCookie();
        }

        #endregion
    }
}