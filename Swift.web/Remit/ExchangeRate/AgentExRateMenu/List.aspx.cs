using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.ExchangeRate.AgentExRateMenu
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20101000";
        protected const string GridName = "gExRateMenu";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly StaticDataDdl _sl = new StaticDataDdl();
        private readonly AgentExRateMenuDao obj = new AgentExRateMenuDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                PopulateDdl();
            }
            DeleteRow();
            LoadGrid();
        }

        #region method

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("countryName", "Country", "T"),
                                      new GridFilter("agentName", "Agent", "T")
                                  };
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("countryName", "Country", "", "T"),
                                      new GridColumn("agentName", "Agent", "", "T"),
                                      new GridColumn("menuName", "Menu", "", "T"),
                                      new GridColumn("modifiedBy", "Last Modified By", "", "T"),
                                      new GridColumn("modifiedDate", "Last Modified Date", "", "T")
                                  };

            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowFilterForm = true;
            grid.AlwaysShowFilterForm = true;
            grid.InputPerRow = 3;
            grid.ShowPagingBar = true;
            grid.RowIdField = "rowId";
            grid.ThisPage = "List.aspx";
            grid.MultiSelect = false;
            grid.ShowCheckBox = true;
            grid.DisableSorting = true;
            grid.DisableJsFilter = true;
            grid.CallBackFunction = "GridCallBack()";
            grid.SelectionCheckBoxList = grid.GetRowId();
            grid.AllowDelete = true;

            string sql = "[proc_agentExRateMenu] @flag = 's'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDdl()
        {
            _sl.SetDDL(ref country, "EXEC proc_countryMaster @flag = 'scl', @user = " + _sl.FilterString(GetStatic.GetUser()), "countryId", "countryName", "", "Select");
            LoadAgent(ref agent, country.Text, "");
            _sl.SetStaticDdl(ref exRateMenu, "1400", "", "Select");
        }

        private void LoadAgent(ref DropDownList ddl, string countryId, string defaultValue)
        {
            var sql = "EXEC proc_agentMaster @flag = 'alc', @agentCountryId = " + _sl.FilterString(countryId);
            _sl.SetDDL(ref ddl, sql, "agentId", "agentName", defaultValue, "All");
        }

        private void PopulateDataById()
        {
            var dr = obj.SelectById(GetStatic.GetUser(), hdnId.Value);
            if (dr == null)
                return;
            country.Text = dr["countryId"].ToString();
            LoadAgent(ref agent, country.Text, GetStatic.GetRowData(dr, "agentId"));
            exRateMenu.Text = dr["menuId"].ToString();
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
            if (dbResult.ErrorCode == "0")
            {
                LoadGrid();
            }
        }

        #endregion method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser(), hdnId.Value, country.Text, agent.Text, exRateMenu.Text);
            ManageMessage(dbResult);
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            string id = grid.GetRowId();
            hdnId.Value = id;
            PopulateDataById();
        }

        protected void country_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref agent, country.Text, "");
            country.Focus();
        }
    }
}