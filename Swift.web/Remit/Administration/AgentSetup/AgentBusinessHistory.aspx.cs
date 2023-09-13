using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.Administration.AgentSetup
{
    public partial class AgentBusinessHistory : Page
    {
        private const string ViewFunctionId = "20111000";
        private const string AddEditFunctionId = "20111010";
        private const string DeleteFunctionId = "20111020";

        private const string GridName = "grd_abhList";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly AgentDao obj = new AgentDao();
        private readonly RemittanceLibrary remitLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                pnl1.Visible = GetMode().ToString() == "1";
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
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
            return GetStatic.ReadNumericDataFromQueryString("abhId");
        }

        #endregion QueryString

        #region method

        private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("remitCompany", "Remit Company", "", "T"),
                                      new GridColumn("fromDate", "From(mm/yy)", "", "T"),
                                      new GridColumn("toDate", "To(mm/yy)", "", "T"),
                                      new GridColumn("status", "Status", "", "T")
                                  };

            bool allowAddEdit = remitLibrary.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = false;
            grid.RowIdField = "abhId";
            grid.DisableSorting = false;
            grid.SortBy = "status";
            grid.SortOrder = "ASC";
            grid.ThisPage = "AgentBusinessHistory.aspx";
            grid.MultiSelect = false;
            grid.ShowCheckBox = false;
            grid.AllowEdit = false;
            grid.AllowDelete = remitLibrary.HasRight(DeleteFunctionId);

            string sql = "EXEC proc_agentBusinessHistory @flag = 's', @agentId = " + GetAgentId();

            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            remitLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void DeleteRow()
        {
            var obj = new AgentDao();
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.DeleteABH(GetStatic.GetUser(), id);
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

        #endregion method

        #region Element Method

        protected void bntSubmit_Click(object sender, EventArgs e)
        {
            lblMsg.Text = "Record Saved Successfully";
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            if (GetAgentId() > 0)
            {
                DbResult dbResult = obj.UpdateABH(GetStatic.GetUser(), GetAgentId().ToString(), remitCompany.Text,
                                                  fromDate.Text, toDate.Text);
                ManageMessage(dbResult);
                LoadGrid();
            }
        }

        #endregion Element Method
    }
}