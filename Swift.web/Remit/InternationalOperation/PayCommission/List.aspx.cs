using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.Commission.CommissionAgent.Pay
{
    public partial class List : Page
    {
        private const string GridName = "grdScPay";

        private const string ViewFunctionId = "20131200";
        private const string AddEditFunctionId = "20131210";
        private const string ApproveFunctionId = "20131230";
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
                                      new GridColumn("sCountryName", "Sending Country", "", "T"),
                                      new GridColumn("ssAgentName", "S. Super Agent", "", "T"),
                                      new GridColumn("sAgentName", "S. Agent", "", "T"),
                                      new GridColumn("sBranchName", "S. Branch", "", "T"),
                                      new GridColumn("rCountryName", "Receiving Country", "", "T"),
                                      new GridColumn("rsAgentName", "R. Super Agent", "", "T"),
                                      new GridColumn("rAgentName", "R. Agent", "", "T"),
                                      new GridColumn("rBranchName", "R. Branch", "", "T"),
                                      new GridColumn("tranTypeName", "Service Type", "", "T"),
                                      new GridColumn("fromAmt", "From", "", "M"),
                                      new GridColumn("toAmt", "To", "", "M")
                                  };

            bool allowAddEdit = _sdd.HasRight(AddEditFunctionId);

            grid.GridName = GridName;

            string sCountryId = IsPostBack ? sCountry.Text : GetStatic.ReadValue(GridName, "sCountry");
            string ssAgentId = IsPostBack ? ssAgent.Text : GetStatic.ReadValue(GridName, "ssAgent");
            string sAgentId = IsPostBack ? sAgent.Text : GetStatic.ReadValue(GridName, "sAgent");
            string sBranchId = IsPostBack ? sBranch.Text : GetStatic.ReadValue(GridName, "sBranch");

            string rCountryId = IsPostBack ? rCountry.Text : GetStatic.ReadValue(GridName, "rCountry");
            string rsAgentId = IsPostBack ? rsAgent.Text : GetStatic.ReadValue(GridName, "rsAgent");
            string rAgentId = IsPostBack ? rAgent.Text : GetStatic.ReadValue(GridName, "rAgent");
            string rBranchId = IsPostBack ? rBranch.Text : GetStatic.ReadValue(GridName, "rBranch");

            string stateId = IsPostBack ? state.Text : GetStatic.ReadValue(GridName, "state");
            string zipId = IsPostBack ? zip.Text : GetStatic.ReadValue(GridName, "zip");
            string agentGroupId = IsPostBack ? agentGroup.Text : GetStatic.ReadValue(GridName, "agentGroup");


            string tranTypeId = IsPostBack ? tranType.Text : GetStatic.ReadValue(GridName, "tranType");


            if (!IsPostBack)
            {
                LoadCountry(ref sCountry, sCountryId, "sCountry");
                LoadCountry(ref rCountry, rCountryId, "rCountry");

                LoadSuperAgent(ref ssAgent, sCountryId, ssAgentId);
                LoadSuperAgent(ref rsAgent, rCountryId, rsAgentId);

                LoadAgent(ref sAgent, ssAgentId, sCountryId, sAgentId);
                LoadAgent(ref rAgent, rsAgentId, rCountryId, rAgentId);

                LoadBranch(ref sBranch, sAgentId, sBranchId);
                LoadBranch(ref rBranch, rAgentId, rBranchId);

                LoadState(ref state, rCountryId, stateId);
                _sdd.SetDDL(ref tranType,
                            "SELECT serviceTypeId, typeTitle FROM serviceTypeMaster WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') <> 'Y'",
                            "serviceTypeId", "typeTitle", tranTypeId, "All");
                _sdd.SetStaticDdl(ref agentGroup, "4300", agentGroupId, "Select");

                LoadZip();
                LoadAgentGroup(ref agentGroup, agentGroupId);
            }

            string queryString = "sCountry=" + sCountryId + "&ssAgent=" + ssAgentId + "&sAgent=" +
                                 sAgentId +
                                 "&sBranch=" + sBranchId +
                                 "&rCountry=" + rCountryId + "&rsAgent=" + rsAgentId + "&rAgent=" +
                                 rAgentId +
                                 "&rBranch=" + rBranchId + "&state=" + stateId +
                                 "&zip=" + zipId + "&agentGroup=" + agentGroupId + "&tranType=" + tranTypeId;


            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New ";
            grid.RowIdField = "scPayMasterId";
            grid.SortBy = "code";
            grid.SortOrder = "ASC";
            grid.AddPage = "manage.aspx?" + queryString;
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
            grid.CustomLinkVariables = "scPayMasterId";
            grid.CustomLinkText1 = "<img id=\"showSlab_@scPayMasterId\" border=\"0\" title=\"View Slab\" class=\"showHand\" src=\"" + GetStatic.GetUrlRoot() + "/Images/view-detail.gif\" onclick=\"ShowSlab(@scPayMasterId);\"/>";

            string sql = "EXEC proc_scPayMaster @flag = 'm'" +
                         ", @sCountry=" + grid.FilterString(sCountryId) +
                         ", @ssAgent=" + grid.FilterString(ssAgentId) +
                         ", @sAgent=" + grid.FilterString(sAgentId) +
                         ", @sBranch=" + grid.FilterString(sBranchId) +
                         ", @rCountry=" + grid.FilterString(rCountryId) +
                         ", @rsAgent=" + grid.FilterString(rsAgentId) +
                         ", @rAgent=" + grid.FilterString(rAgentId) +
                         ", @rBranch=" + grid.FilterString(rBranchId) +
                         ", @tranType=" + grid.FilterString(tranTypeId) +
                         ", @hasChanged=" + grid.FilterString(hasChanged.Text) +
                         ", @agentGroup=" + grid.FilterString(agentGroupId);

            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void LoadCountry(ref DropDownList ddl, string defaultValue,string country)
        {
            string sql = "EXEC proc_countryMaster @flag = 'ocl'";
            sql = sql + ",@countryType=" + _sdd.FilterString(country);
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, "All");
        }

        private void LoadSuperAgent(ref DropDownList ddl, string countryId, string defaultValue)
        {
            string sql = "EXEC proc_agentMaster @flag = 'sal', @agentCountry = " + _sdd.FilterString(countryId);

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

        private void LoadZip()
        {
        }

        private void LoadAgentGroup(ref DropDownList ddl, string defaultValue)
        {
            _sdd.SetStaticDdl(ref ddl, "4300", defaultValue, "All");
        }

        protected void SaveAsCookie()
        {
            GetStatic.WriteValue(GridName, ref sCountry, "sCountry");
            GetStatic.WriteValue(GridName, ref rCountry, "rCountry");
            GetStatic.WriteValue(GridName, ref sAgent, "sAgent");
            GetStatic.WriteValue(GridName, ref sBranch, "sBranch");

            GetStatic.WriteValue(GridName, ref ssAgent, "ssAgent");
            GetStatic.WriteValue(GridName, ref rsAgent, "rsAgent");
            GetStatic.WriteValue(GridName, ref rAgent, "rAgent");
            GetStatic.WriteValue(GridName, ref rBranch, "rBranch");

            GetStatic.WriteValue(GridName, ref state, "state");
            GetStatic.WriteValue(GridName, ref zip, "zip");
            GetStatic.WriteValue(GridName, ref agentGroup, "agentGroup");
            GetStatic.WriteValue(GridName, ref tranType, "tranType");
        }

        #region Control Methods
        protected void sCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadSuperAgent(ref ssAgent, sCountry.Text, "");
            LoadAgent(ref sAgent, ssAgent.Text, sCountry.Text, "");
            sCountry.Focus();
        }

        protected void ssAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref sAgent, ssAgent.Text, sCountry.Text, "");
            ssAgent.Focus();
        }

        protected void sAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadBranch(ref sBranch, sAgent.Text, "");
            sAgent.Focus();
        }

        protected void rCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadSuperAgent(ref rsAgent, rCountry.Text, "");
            LoadAgent(ref rAgent, rsAgent.Text, rCountry.Text, "");
            LoadState(ref state, rCountry.Text, "");
            rCountry.Focus();
        }

        protected void rsAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref rAgent, rsAgent.Text, rCountry.Text, "");
            rsAgent.Focus();
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