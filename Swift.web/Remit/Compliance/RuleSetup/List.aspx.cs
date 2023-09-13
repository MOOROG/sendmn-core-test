using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Compliance.RuleSetup
{
    public partial class List : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        private const string GridName = "grd_cs";
        private const string ViewFunctionId = "20192100";
        private const string AddEditFunctionId = "20192101";
        private const string ApproveFunctionId = "20192102";
        private readonly SwiftGrid grid = new SwiftGrid();

        protected void Page_Load(object sender, EventArgs e)
        {
            GetStatic.PrintMessage(Page);
            Authenticate();
            LoadGrid();
        }

        private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                              {
                                  new GridColumn("sCountryName",            "S Country",      "",         "T"),
                                  new GridColumn("sAgentName",              "Agent",                "",         "T"),
                                  new GridColumn("sStateName",              "State",                "",         "T"),
                                  new GridColumn("sZip",                    "Zip",                  "",         "T"),
                                  new GridColumn("sGroup",                  "Group",                "",         "T"),
                                  new GridColumn("rCountryName",            "R Country",    "",         "T"),
                                  new GridColumn("rAgentName",              "Agent",                "",         "T"),
                                  new GridColumn("rStateName",              "State",                "",         "T"),
                                  new GridColumn("rZip",                    "Zip",                  "",         "T"),
                                  new GridColumn("rGroup",                  "Group",                "",         "T"),
                                  new GridColumn("isDisabled",                  "Status",                "",         "T"),
                                  new GridColumn("ruleScope",                  "Rule Scope",                "",         "T")
                              };

            var allowAddEdit = _sdd.HasRight(AddEditFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;

            var sCountryId = IsPostBack ? sCountry.Text : GetStatic.ReadValue(GridName, "sCountry");
            var sAgentId = IsPostBack ? sAgent.Text : GetStatic.ReadValue(GridName, "sAgent");
            var sStateId = IsPostBack ? sState.Text : GetStatic.ReadValue(GridName, "sState");
            var sZipId = IsPostBack ? sZip.Text : GetStatic.ReadValue(GridName, "sZip");
            var sGroupId = IsPostBack ? sGroup.Text : GetStatic.ReadValue(GridName, "sGroup");
            var sCustTypeId = IsPostBack ? sCustType.Text : GetStatic.ReadValue(GridName, "sCustType");

            var rCountryId = IsPostBack ? rCountry.Text : GetStatic.ReadValue(GridName, "rCountry");
            var rAgentId = IsPostBack ? rAgent.Text : GetStatic.ReadValue(GridName, "rAgent");
            var rStateId = IsPostBack ? rState.Text : GetStatic.ReadValue(GridName, "rState");
            var rZipId = IsPostBack ? rZip.Text : GetStatic.ReadValue(GridName, "rZip");
            var rGroupId = IsPostBack ? sGroup.Text : GetStatic.ReadValue(GridName, "rGroup");
            var rCustTypeId = IsPostBack ? rCustType.Text : GetStatic.ReadValue(GridName, "rCustType");
            var currencyId = IsPostBack ? currency.Text : GetStatic.ReadValue(GridName, "currency");

            if (!IsPostBack)
            {
                LoadSendCountry(ref sCountry, sCountryId);
                LoadCountry(ref rCountry, rCountryId);
                LoadAgent(ref sAgent, sCountryId, sAgentId);
                LoadAgent(ref rAgent, rCountryId, rAgentId);
                LoadCurrency(ref currency, currencyId);

                LoadStaticData(ref sCustType, "4700", sCustTypeId);
                LoadStaticData(ref rCustType, "4700", rCustTypeId);
                LoadStaticData(ref sGroup, "4300", sGroupId);
                LoadStaticData(ref rGroup, "4300", rGroupId);
            }

            var queryString = "sCountry=" + sCountryId +
                              "&sAgent=" + sAgentId +
                              "&sState=" + sStateId +
                              "&sZip=" + sZipId +
                              "&sGroup=" + sGroupId +
                              "&sCustTypeId=" + sCustTypeId +
                              "&rCountry=" + rCountryId +
                              "&rAgent=" + rAgentId +
                              "&rState=" + rStateId +
                              "&rZip=" + rZipId +
                              "&rGroup=" + rGroupId +
                              "&rCustTypeId=" + rCustTypeId +
                              "&currency=" + currencyId;

            grid.GridType = 1;

            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New ";
            grid.RowIdField = "csMasterId";
            grid.AddPage = "Manage.aspx?" + queryString;
            grid.InputPerRow = 3;
            grid.InputLabelOnLeftSide = true;
            grid.ApproveFunctionId = ApproveFunctionId;
            grid.AllowApprove = _sdd.HasRight(ApproveFunctionId);
            grid.AlwaysShowFilterForm = true;
            grid.AllowEdit = allowAddEdit;
            grid.DisableSorting = true;
            grid.AllowCustomLink = true;
            grid.CustomLinkVariables = "csMasterId";
            grid.CustomLinkText = "<a href=\"Detail.aspx?csMasterId=@csMasterId\"><img src = \"" + GetStatic.GetUrlRoot() + "/images/rule.gif\" border=0 alt = \"Rule Setup\" title=\"Rule Setup\" /></a>";

            grid.GridWidth = 1000;

            var sql = "EXEC proc_csMaster @flag = 'm'" +
                      ", @sCountry=" + grid.FilterString(sCountryId) +
                      ", @sAgent=" + grid.FilterString(sAgentId) +
                      ", @sState=" + grid.FilterString(sStateId) +
                      ", @sZip=" + grid.FilterString(sZipId) +
                      ", @sGroup=" + grid.FilterString(sGroupId) +
                      ", @sCustType=" + grid.FilterString(sCustTypeId) +
                      ", @rCountry=" + grid.FilterString(rCountryId) +
                      ", @rAgent=" + grid.FilterString(rAgentId) +
                      ", @rState=" + grid.FilterString(rStateId) +
                      ", @rZip=" + grid.FilterString(rZipId) +
                      ", @rGroup=" + grid.FilterString(rGroupId) +
                      ", @rCustType=" + grid.FilterString(rCustTypeId) +
                      ", @currency=" + grid.FilterString(currencyId);

            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        #region Control Methods

        protected void sCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref sAgent, sCountry.Text, "");
            LoadState(ref sState, sCountry.Text, "");
            sCountry.Focus();
        }

        protected void rCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref rAgent, rCountry.Text, "");
            LoadState(ref rState, rCountry.Text, "");
            rCountry.Focus();
        }

        #endregion Control Methods

        private void LoadCountry(ref DropDownList ddl, string defaultValue)
        {
            var sql = "EXEC proc_dropDownLists @flag = 'pCountry'";
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, "All");
        }

        private void LoadSendCountry(ref DropDownList ddl, string defaultValue)
        {
            var sql = " EXEC proc_dropDownLists @flag = 'sCountry'";
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, "All");
        }

        private void LoadAgent(ref DropDownList ddl, string countryId, string defaultValue)
        {
            var sql = "EXEC proc_agentMaster @flag = 'alc', @agentCountryId=" + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", defaultValue, "All");
        }

        private void LoadState(ref DropDownList ddl, string countryId, string defaultValue)
        {
            var sql = "EXEC proc_countryStateMaster @flag = 'csl', @countryId = " + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "stateId", "stateName", defaultValue, "All");
        }

        private void LoadCurrency(ref DropDownList ddl, string defaultValue)
        {
            var sql = "EXEC proc_currencyMaster 'l'";
            _sdd.SetDDL(ref ddl, sql, "currencyId", "currencyCode", defaultValue, "All");
        }

        private void LoadStaticData(ref DropDownList ddl, string typeId, string defaultValue)
        {
            _sdd.SetStaticDdl(ref ddl, typeId, defaultValue, "All");
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            SaveAsCookie();
        }

        protected void SaveAsCookie()
        {
            GetStatic.WriteValue(GridName, ref sCountry, "sCountry");
            GetStatic.WriteValue(GridName, ref sAgent, "sAgent");
            GetStatic.WriteValue(GridName, ref sState, "sState");
            GetStatic.WriteValue(GridName, ref sZip, "sZip");
            GetStatic.WriteValue(GridName, ref sGroup, "sGroup");
            GetStatic.WriteValue(GridName, ref sCustType, "sCustType");

            GetStatic.WriteValue(GridName, ref rCountry, "rCountry");
            GetStatic.WriteValue(GridName, ref rAgent, "rAgent");
            GetStatic.WriteValue(GridName, ref rState, "sState");
            GetStatic.WriteValue(GridName, ref rZip, "rZip");
            GetStatic.WriteValue(GridName, ref rGroup, "rGroup");
            GetStatic.WriteValue(GridName, ref rCustType, "rCustType");

            GetStatic.WriteValue(GridName, ref currency, "currency");
        }

        protected void btnFileter_Click(object sender, EventArgs e)
        {
            SaveAsCookie();
        }
    }
}