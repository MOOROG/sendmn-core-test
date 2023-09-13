using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.DAL.BL.Remit.ServiceCharge;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.Commission.ServiceCharge
{
    public partial class List : Page
    {
        private const string GridName = "grd_ssc";

        private const string ViewFunctionId = "20131000";
        private const string AddEditFunctionId = "20131010";
        private const string DeleteFunctionId = "20131020";
        private const string ApproveFunctionId = "20131030";

        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly SscMasterDao obj = new SscMasterDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
            DeleteRow();
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

            string rCountryId = IsPostBack ? rCountry.Text : GetStatic.ReadValue(GridName, "rCountry");
            string rsAgentId = IsPostBack ? rsAgent.Text : GetStatic.ReadValue(GridName, "rsAgent");
            string rAgentId = IsPostBack ? rAgent.Text : GetStatic.ReadValue(GridName, "rAgent");

            string tranTypeId = IsPostBack ? tranType.Text : GetStatic.ReadValue(GridName, "tranType");


            if (!IsPostBack)
            {
                LoadCountry(ref sCountry, sCountryId);
                LoadCountry(ref rCountry, rCountryId);

                LoadSuperAgent(ref ssAgent, sCountryId, ssAgentId);
                LoadSuperAgent(ref rsAgent, rCountryId, rsAgentId);

                LoadAgent(ref sAgent, ssAgentId, sCountryId, sAgentId);
                LoadAgent(ref rAgent, rsAgentId, rCountryId, rAgentId);

                _sdd.SetDDL(ref tranType, "EXEC proc_serviceTypeMaster @flag = 'l2'", "serviceTypeId", "typeTitle",
                            tranTypeId, "All");
            }

            string queryString = "sCountry=" + sCountryId + "&ssAgent=" + ssAgentId + "&sAgent=" +
                                 sAgentId +
                                 "&rCountry=" + rCountryId + "&rsAgent=" + rsAgentId + "&rAgent=" +
                                 rAgentId +
                                 "&tranType=" + tranTypeId;

            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowAddButton = true;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New ";
            grid.RowIdField = "sscMasterId";
            grid.SortBy = "code";
            grid.SortOrder = "ASC";
            grid.AddPage = "Manage.aspx?" + queryString;
            grid.InputPerRow = 3;
            grid.InputLabelOnLeftSide = true;
            grid.ApproveFunctionId = ApproveFunctionId;
            grid.AllowApprove = _sdd.HasRight(ApproveFunctionId);
            grid.AlwaysShowFilterForm = true;
           // grid.AllowEdit = true;
            grid.AllowDelete = true;
            grid.DisableSorting = true;
            grid.DisableJsFilter = true;
            grid.GridMinWidth = 1000;
            grid.IsGridWidthInPercent = true;
            grid.GridWidth = 100;
            grid.EnableToolTip = true;
            grid.ToolTipField = "description";
            grid.AllowCustomLink1 = true;
            grid.CustomLinkVariables = "sscMasterId";
            grid.CustomLinkText1 = "<img id=\"showSlab_@sscMasterId\" border=\"0\" title=\"View Slab\" class=\"showHand\" src=\"" + GetStatic.GetUrlRoot() + "/Images/view-detail.gif\" onclick=\"ShowSlab(@sscMasterId);\"/>";

            string sql = "EXEC proc_sscMaster @flag = 'm'" +
                         ", @sCountry=" + grid.FilterString(sCountryId) +
                         ", @ssAgent=" + grid.FilterString(ssAgentId) +
                         ", @sAgent=" + grid.FilterString(sAgentId) +
                         ", @rCountry=" + grid.FilterString(rCountryId) +
                         ", @rsAgent=" + grid.FilterString(rsAgentId) +
                         ", @rAgent=" + grid.FilterString(rAgentId) +
                         ", @hasChanged=" + grid.FilterString(hasChanged.Text) +
                         ", @tranType=" + grid.FilterString(tranTypeId);

            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void DeleteRow()
        {
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        private void LoadCountry(ref DropDownList ddl, string defaultValue)
        {
            string sql = "EXEC proc_countryMaster @flag = 'ocl'";
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

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            SaveAsCookie();
        }

        protected void SaveAsCookie()
        {
            GetStatic.WriteValue(GridName, ref sCountry, "sCountry");
            GetStatic.WriteValue(GridName, ref rCountry, "rCountry");
            GetStatic.WriteValue(GridName, ref sAgent, "sAgent");

            GetStatic.WriteValue(GridName, ref ssAgent, "ssAgent");
            GetStatic.WriteValue(GridName, ref rsAgent, "rsAgent");
            GetStatic.WriteValue(GridName, ref rAgent, "rAgent");
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

        protected void rCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadSuperAgent(ref rsAgent, rCountry.Text, "");
            LoadAgent(ref rAgent, rsAgent.Text, rCountry.Text, "");
            rCountry.Focus();
        }

        protected void rsAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref rAgent, rsAgent.Text, rCountry.Text, "");
            rsAgent.Focus();
        }
        #endregion
    }
}