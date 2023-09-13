using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.Administration.AgentSetup
{
    public partial class AgentCurrency : Page
    {
        private const string ViewFunctionId = "20111000";
        private const string AddEditFunctionId = "20111010";
        private const string DeleteFunctionId = "20111020";

        protected const string GridName = "grd_agentCurr";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly AgentCurrencyDao obj = new AgentCurrencyDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary remitLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnl1.Visible = GetMode().ToString() == "1";
                Authenticate();
                PopulateDdl(null);
                if (GetAgentId() > 0)
                {
                    //PopulateDataById();
                }
                else
                {
                    //Your code goes here
                }
            }
            DeleteRow();
            LoadGrid();
        }

        #region QueryString

        protected string GetAgentName()
        {
            return remitLibrary.GetAgentBreadCrumb(GetAgentId().ToString());
        }

        protected long GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode");
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        protected long GetParentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("parent_id");
        }

        protected string GetAgentType()
        {
            return GetStatic.ReadNumericDataFromQueryString("aType").ToString();
        }

        protected string GetActAsBranchFlag()
        {
            return GetStatic.ReadQueryString("actAsBranch", "");
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("countryCurrencyId");
        }

        #endregion QueryString

        #region Method

        private void Authenticate()
        {
            remitLibrary.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateDdl(DataRow dr)
        {
            sdd.SetDDL(ref currency, "EXEC proc_agentCurrency @flag = 'acl', @agentId = " + GetAgentId(), "currencyId",
                       "currencyCode", GetStatic.GetRowData(dr, "currencyId"), "Select");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), agentCurrencyId.Value);
            if (dr == null)
                return;

            currency.Text = dr["currencyId"].ToString();
            spFlag.Text = dr["spFlag"].ToString();
            isDefault.Text = dr["isDefault"].ToString();
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser(), agentCurrencyId.Value, GetAgentId().ToString(),
                                           currency.Text, spFlag.Text, isDefault.Text);
            ManageMessage(dbResult);
            LoadGrid();
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (GetMode() == 2)
                GetStatic.AlertMessage(Page);
            else
                GetStatic.PrintMessage(Page);
        }

        private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("currencyCode", "Currency Code", "", "T"),
                                      new GridColumn("currencyName", "Currency Name", "", "T"),
                                      new GridColumn("spFlag", "Applies For", "", "T"),
                                      new GridColumn("isDefault", "Is Default", "", "T")
                                  };

            bool allowAddEdit = remitLibrary.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = false;
            grid.GridWidth = 450;
            grid.RowIdField = "agentCurrencyId";
            grid.CallBackFunction = "GridCallBack()";
            grid.DisableSorting = false;
            grid.ThisPage = "AgentCurrency.aspx";
            grid.MultiSelect = false;
            grid.ShowCheckBox = true;
            grid.SelectionCheckBoxList = grid.GetRowId();
            grid.AllowEdit = false;
            grid.AllowDelete = remitLibrary.HasRight(DeleteFunctionId);

            string sql = "EXEC proc_agentCurrency @flag = 's', @agentId = " + GetAgentId();

            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
            LoadGrid();
        }

        private void Edit()
        {
            string id = grid.GetRowId();
            agentCurrencyId.Value = id;
            PopulateDataById();
        }

        #endregion Method

        #region Element Method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Edit();
        }

        #endregion Element Method
    }
}