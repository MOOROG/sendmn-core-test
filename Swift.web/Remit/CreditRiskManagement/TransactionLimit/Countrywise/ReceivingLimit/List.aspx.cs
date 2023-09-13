using System;
using System.Collections.Generic;
using System.Web.UI;
using Swift.DAL.BL.Remit.CreditRiskManagement.TransactionLimit;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.CreditRiskManagement.TransactionLimit.Countrywise.ReceivingLimit
{
    public partial class List : Page
    {
        private const string GridName = "grid_receiveTran";
        private const string ViewFunctionId = "30011400";
        private const string AddEditFunctionId = "30011410";
        private const string DeleteFunctionId = "30011420";
        private const string ApproveFunctionId = "30011430";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly ReceiveTranLimitDao obj = new ReceiveTranLimitDao();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //Authenticate();
                GetStatic.PrintMessage(Page);
            }
            DeleteRow();
            LoadGrid();
        }

        #region method

        protected string GetCountryName()
        {
            return "Country : " + GetCountry();
        }

        private string GetCountry()
        {
            return GetStatic.ReadQueryString("countryName", "");
        }

        protected string GetCountryId()
        {
            return GetStatic.ReadQueryString("countryId", "");
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
                                      new GridColumn("tranTypeText", "Receiving Mode", "", "T"),
                                      new GridColumn("maxLimitAmt", "Max Limit", "", "M"),
                                      new GridColumn("agMaxLimitAmt", "Max Limit for Agent",  "", "M"),
                                      new GridColumn("currencyName", "Currency", "", "T"),
                                      new GridColumn("customerType", "Customer Type", "", "T")
                                  };

            bool allowAddEdit = sl.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.ShowAddButton = allowAddEdit;
            grid.GridDataSource = Component.Grid.SwiftGrid.GridDS.RemittanceDB;
            grid.InputPerRow = 2;
            grid.RowIdField = "rtlId";
            grid.AddPage = "Manage.aspx?countryId=" + GetCountryId() + "&countryName=" + GetCountry();
            grid.AllowEdit = allowAddEdit;
            grid.AllowDelete = sl.HasRight(DeleteFunctionId);
            grid.AllowApprove = sl.HasRight(ApproveFunctionId);
            grid.ApproveFunctionId = ApproveFunctionId;

            string sql = "[proc_receiveTranLimit] @flag = 's', @countryId = " + grid.FilterString(GetCountryId());
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), id);
            PrintMessage(dbResult);
        }

        private void PrintMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        #endregion
    }
}