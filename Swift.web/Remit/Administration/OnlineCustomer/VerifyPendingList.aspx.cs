using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Administration.OnlineCustomer
{
    public partial class VerifyPendingList : System.Web.UI.Page
    {
        private const string GridName = "grid_pl";
        private const string ViewFunctionId = "20130000";
        private const string AddEditFunctionId = "20130010";
        private const string ApproveFunctionId = "20130010";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

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
                                     new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [proc_online_approve_Customer] @flag = 'searchCriteria'"),
                                     new GridFilter("searchValue", "Search Value", "T"),
                                     new GridFilter("fromDate", "Registered From", "d"),
                                     new GridFilter("toDate", "Registered To", "d")
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SNO", "", "T"),
                                      new GridColumn("email", "Email", "", "T"),
                                      new GridColumn("fullName", "Customer Name", "", "T"),
                                      new GridColumn("dob", "DOB", "", "D"),
                                      //new GridColumn("address", "Address", "", "T"),
                                      //new GridColumn("country", "Country", "", "T"),
                                      //new GridColumn("ipAddress", "Ip Address", "", "T"),
                                      new GridColumn("nativeCountry", "Native Country", "", "T"),
                                      new GridColumn("idtype", "Id Type", "", "T"),
                                      new GridColumn("idNumber", "Id No", "", "T"),
                                      //new GridColumn("telNo", "Telephone", "", "T"),
                                      new GridColumn("mobile", "Mobile No", "", "T"),
                                      new GridColumn("createdDate","DOR","","D"),
                                      new GridColumn("bankName","Bank Name","","T"),
                                      new GridColumn("bankAccountNo","Account Number","","T")
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.AllowEdit = false;
            _grid.AllowDelete = false;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "customerId";
            _grid.ThisPage = "ApprovedList.aspx"; ;
            _grid.InputPerRow = 4;
            _grid.CustomLinkVariables = "customerId,onlineUser";
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;

            _grid.AllowCustomLink = true;
            _grid.CustomLinkVariables = "customerId";

            if (swiftLibrary.HasRight(AddEditFunctionId))
            {
                var link = "&nbsp;<a class=\"btn btn-xs btn-primary\" title=\"Approve\" href=\"Manage.aspx?id=@customerId\"><i class=\"fa fa-pencil\"></i></a>&nbsp;<a class=\"btn btn-xs btn-success\" title=\"Edit\" href=\"Detail.aspx?customerId=@customerId&m=vp\"><i class=\"fa fa-check\"></i></a>";
                _grid.CustomLinkText = link;
            }

            string sql = "EXEC [proc_online_approve_Customer] @flag = 'p'";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
    }
}