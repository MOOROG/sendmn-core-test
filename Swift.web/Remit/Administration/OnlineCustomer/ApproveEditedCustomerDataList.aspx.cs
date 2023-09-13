using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Administration.OnlineCustomer
{
    public partial class ApproveEditedCustomerDataList : System.Web.UI.Page
    {
        private const string GridName = "grid_editedlist";
        private const string ViewFunctionId = "20130030";
        private const string AddEditFunctionId = "20130020";
        private const string ApproveFunctionId = "20130020";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private readonly SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
            }
            LoadGrid();
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                  {
                                     //new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [proc_online_approve_Customer] @flag = 'searchCriteria'"),
                                     //new GridFilter("searchValue", "Search Value", "T"),
                                     new GridFilter("fromDate", "Registered From", "d"),
                                     new GridFilter("toDate", "Registered To", "d"),
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),
                                      new GridColumn("fullName", "Customer Name", "", "T"),
                                      new GridColumn("customerId", "Customer Id", "", "T"),
                                      new GridColumn("membershipId", "Membership Id", "", "T"),
                                      new GridColumn("mobile", "Mobile No", "", "T"),
                                      new GridColumn("city","City","","T"),
                                      new GridColumn("createdDate","Modified Date","","D"),
                                  };
            _grid.GridType = 1;
            _grid.LoadGridOnFilterOnly = false;
            _grid.GridName = GridName;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.RowIdField = "customerId";
            _grid.MultiSelect = false;
            _grid.AllowApprove = sl.HasRight(ApproveFunctionId);
            _grid.ApproveFunctionId = ApproveFunctionId;
            _grid.AddPage = "ApproveEditedCustomerDataList.aspx";
            _grid.InputPerRow = 4;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;

            string sql = "EXEC [proc_online_approve_Customer] @flag = 's-customereditedata' ";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
    }
}