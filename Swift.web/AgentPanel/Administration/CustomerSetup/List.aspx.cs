using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.AgentPanel.Administration.CustomerSetup
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "gdcustomerintl";
        private const string ViewFunctionId = "40133900";
        private const string AddEditFunctionId = "40133910";
        private const string DeleteFunctionId = "40133920";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private readonly CustomerSetupIntlDao _obj = new CustomerSetupIntlDao();

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

        private void DeleteRow()
        {
            string id = _grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = _obj.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("searchBy", "Search By",
                                                     "1:EXEC [proc_dropDownLists2] @flag = 'cust-filter-1'"),
                                      new GridFilter("searchValue", "Search Value", "LT"),
                                      new GridFilter("isBlackList ", "Is Black Listed",
                                                     "1:EXEC [proc_dropDownLists2] @flag = 'YNFilter'")
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("membershipId", "Membership Id", "", "T"),
                                      new GridColumn("name", "Name", "", "T"),
                                      new GridColumn("idType", "Id Type", "", "T"),
                                      new GridColumn("idNumber", "Id Number", "", "T"),
                                      new GridColumn("address", "Address", "", "T"),
                                      new GridColumn("mobile", "Mobile", "", "T"),
                                      new GridColumn("country", "Country", "", "T"),
                                      new GridColumn("city", "City", "", "T")
                                  };

            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);
            bool allowDelete = _sl.HasRight(DeleteFunctionId);
            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.GridWidth = 800;
            _grid.ShowAddButton = allowAddEdit;
            _grid.Downloadable = false;
            _grid.ShowFilterForm = true;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.AddButtonTitleText = "Add New Customer";
            _grid.RowIdField = "customerId";
            _grid.MultiSelect = false;
            _grid.InputPerRow = 4;
            _grid.AllowEdit = allowAddEdit;
            _grid.AllowDelete = allowDelete;
            _grid.LoadGridOnFilterOnly = true;
            _grid.AddPage = "Manage.aspx";
            string sql = "[proc_customers] @flag='s',@country=" + _grid.FilterString(GetStatic.GetCountryId()) + "";
            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}