using Swift.DAL.BL.Remit.CreditRiskManagement.TransactionLimit;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.CreditRiskManagement.TransactionLimit.Agentwise.ReceivingLimit
{
    public partial class List : Page
    {
        private const string GridName = "grid_receiveTran";
        private const string ViewFunctionId = "20181100";
        private const string AddEditFunctionId = "20181110";
        private const string DeleteFunctionId = "20181120";
        private const string ApproveFunctionId = "20181130";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly ReceiveTranLimitDao obj = new ReceiveTranLimitDao();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //Authenticate();
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
                                      new GridFilter("sendingCountry", "Sending Country",
                                                     "LT"),
                                      new GridFilter("tranType", "Transaction Type",
                                                     "1:EXEC [proc_serviceTypeMaster] @flag='l'")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("sCountryName", "Sending Country", "", "T"),
                                      new GridColumn("tranTypeText", "Txn Type", "", "T"),
                                      new GridColumn("maxlimitAmt", "Max Limit", "", "M"),
                                      new GridColumn("currencyName", "Currency", "", "T"),
                                      new GridColumn("customerType", "Customer Type", "", "T")
                                  };

            bool allowAddEdit = sl.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.ShowAddButton = allowAddEdit;
            grid.RowIdField = "rtlId";
            grid.AddPage = "Manage.aspx?agentId=" + GetAgentId();
            grid.AllowEdit = allowAddEdit;
            grid.AllowDelete = sl.HasRight(DeleteFunctionId);
            grid.AllowApprove = sl.HasRight(ApproveFunctionId);
            grid.ApproveFunctionId = ApproveFunctionId;

            string sql = "[proc_receiveTranLimit] @flag = 's', @agentId = " + GetAgentId();
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