using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.Administration.CustomerSetup.CustomerInfo
{
    public partial class List : Page
    {
        private const string GridName = "grid_customerInfo";
        private const string ViewFunctionId = "20821800,20822000";
        private const string AddEditFunctionId = "20821810,20822010";
        private const string DeleteFunctionId = "20821820,20822020";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly CustomerInfoDao obj = new CustomerInfoDao();
        private readonly RemittanceLibrary remitLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Authenticate();
                GetStatic.PrintMessage(Page);
            }
            DeleteRow();
            LoadGrid();
        }

        protected long GetCustomerId()
        {
            return GetStatic.ReadNumericDataFromQueryString("customerId");
        }

        protected string GetCustomerName()
        {
            return "Customer Name : " + remitLibrary.GetCustomerName(GetCustomerId().ToString());
        }

        #region Method

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("subject", "Subject", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("date", "Date", "80", "T"),
                                      new GridColumn("subject", "Subject", "", "T"),
                                      new GridColumn("description", "Description", "", "LT"),
                                       new GridColumn("IsPrimary", "Is Primary", "", "LT")
                                  };

            bool allowAddEdit = remitLibrary.HasRight(AddEditFunctionId);
            grid.ShowPopUpWindowOnAddButtonClick = true;
            grid.PopUpParam = "dialogHeight:400px;dialogWidth:500px;dialogLeft:300;dialogTop:100;center:yes";
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New";
            grid.RowIdField = "customerInfoId";
            grid.MultiSelect = false;

            grid.AllowEdit = allowAddEdit;
            grid.AllowDelete = remitLibrary.HasRight(DeleteFunctionId);

            grid.AddPage = "Manage.aspx?customerId=" + GetCustomerId();

            string sql = "[proc_customerInfo] @flag = 's', @customerId = " + GetCustomerId();
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            remitLibrary.CheckAuthentication(ViewFunctionId);
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

        #endregion Method
    }
}