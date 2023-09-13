using Swift.DAL.BL.Remit.CreditRiskManagement.CreditSecurity;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.CreditRiskManagement.CreditSecurity.FixedDeposit
{
    public partial class List : Page
    {
        private const string GridName = "grid_fixedDeposit";
        private const string ViewFunctionId = "20181400";
        private const string AddEditFunctionId = "20181410";
        private const string ApproveFunctionId = "20181430";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly FixedDepositDao obj = new FixedDepositDao();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            DeleteRow();
            LoadGrid();
        }

        #region method

        protected string GetAgentName()
        {
            return "Agent Name : " + sl.GetAgentName(GetAgentId().ToString());
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("fixedDepositNo", "Fixed Deposit No", "T"),
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("fixedDepositNo", "Fixed Deposit No", "", "T"),
                                      new GridColumn("amount", "Amount", "", "M"),
                                      new GridColumn("currency", "Currency", "", "T"),
                                      new GridColumn("bankName", "Bank", "", "T"),
                                      new GridColumn("issuedDate", "Issued Date", "", "D"),
                                      new GridColumn("expiryDate", "Expiry Date", "", "D"),
                                      new GridColumn("followUpDate", "Follow Up Date", "", "D")
                                  };

            bool allowAddEdit = sl.HasRight(AddEditFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = true;
            grid.AllowEdit = allowAddEdit;
            grid.ShowAddButton = allowAddEdit;
            grid.RowIdField = "fdId";
            grid.AddPage = "Manage.aspx?agentId=" + GetAgentId();
            grid.AllowApprove = sl.HasRight(ApproveFunctionId);
            grid.ApproveFunctionId = ApproveFunctionId;

            string sql = "[proc_fixedDeposit] @flag = 's', @agentId=" + grid.FilterString(GetAgentId().ToString());
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
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        #endregion method
    }
}