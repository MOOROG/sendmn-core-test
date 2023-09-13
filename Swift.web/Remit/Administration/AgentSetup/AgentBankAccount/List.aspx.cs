using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.Administration.AgentSetup.AgentBankAccount
{
    public partial class List : Page
    {
        private const string GridName = "grid_bankAcs";
        private const string ViewFunctionId = "20111000";
        private const string AddEditFunctionId = "20111010";
        private const string DeleteFunctionId = "20111020";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary remitLibrary = new RemittanceLibrary();

        public string GetGridName()
        {
            return GridName;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnl1.Visible = GetMode().ToString() == "1";
                Authenticate();
                if (GetMode() == 2)
                    GetStatic.AlertMessage(Page);
                else
                    GetStatic.PrintMessage(Page);
            }
            DeleteRow();
            LoadGrid();
        }

        #region QueryString

        protected string GetAgentName()
        {
            return remitLibrary.GetAgentBreadCrumb(GetAgentId().ToString());
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        protected long GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode");
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

        #endregion QueryString

        #region method

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("bankName", "Inter. Bank", "LT"),
                                      new GridFilter("bankNameB", "Benef. Bank", "LT"),
                                      new GridFilter("accountNo", "Inter. Account No.", "LT"),
                                      new GridFilter("accountNoB", "Benef. Account No.", "LT"),
                                      new GridFilter("accountName", "Inter. Account Name", "LT"),
                                      new GridFilter("accountNameB", "Benef. Account Name", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("bankName", "Inter. Bank", "", "T"),
                                      new GridColumn("bankBranch", "Inter. Branch", "", "T"),
                                      new GridColumn("accountNo", "Inter. Account No.", "", "T"),
                                      new GridColumn("accountName","Inter. Account Name","","T"),
                                      new GridColumn("bankNameB", "Benef. Bank", "", "T"),
                                      new GridColumn("bankBranchB", "Benef. Branch", "", "T"),
                                      new GridColumn("accountNoB", "Benef. Account No.", "", "T"),
                                      new GridColumn("accountNameB","Benef. Account Name","","T"),
                                      new GridColumn("isDefault", "Is Default A/C", "", "T")
                                  };

            bool allowAddEdit = remitLibrary.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New Bank Account";
            grid.RowIdField = "abaId";
            grid.ThisPage = "List.aspx";
            grid.SortBy = "abaId";

            grid.AllowEdit = allowAddEdit;
            grid.AllowDelete = remitLibrary.HasRight(DeleteFunctionId);

            grid.EditText = "<img src = \"../../../images/edit.gif\" border=0 alt = \"Edit\" />";
            grid.DeleteText = "<img src = \"../../../images/delete.gif\" border=0 alt = \"Delete\" />";
            grid.AddPage = "Manage.aspx?agentId=" + GetAgentId() + "&mode=" + GetMode() + "&parent_id=" + GetParentId() +
                           "&aType=" + GetAgentType();

            string sql = "[proc_agentBankAccount] @flag = 's', @agentId = " + GetAgentId();
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            remitLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void DeleteRow()
        {
            var abf = new AgentBankAccountDao();
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = abf.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
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
    }
}