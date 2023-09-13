using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Administration.OnlineCustomer
{
    public partial class AuditList : System.Web.UI.Page
    {
        private const string GridName = "grid_list";
        private const string ViewFunctionId = "20130000";
        private const string AddEditFunctionId = "20130010";
        private const string ApproveFunctionId = "20130020";
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
                                     new GridFilter("toDate", "Registered To", "d"),
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),
                                      new GridColumn("email", "Email", "", "T"),
                                      new GridColumn("fullName", "Customer Name", "", "T"),
                                      new GridColumn("dob", "DOB", "", "D"),
                                      //new GridColumn("address", "Address", "", "T"),
                                      new GridColumn("nativeCountry", "Native Country", "", "T"),
                                      new GridColumn("idtype", "ID Type", "", "T"),
                                      new GridColumn("idNumber", "ID No", "", "T"),
                                      new GridColumn("createdDate","Regd. Date","","D"),
                                      new GridColumn("AuditBy","Audit By","","T"),
                                      new GridColumn("AuditDate","Audit Date","","D")  ,
                                      new GridColumn("bankName","Bank Name","","T")  ,
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
            _grid.ThisPage = "List.aspx"; ;
            _grid.InputPerRow = 4;
            _grid.AllowCustomLink = true;
            //_grid.LoadGridOnFilterOnly = true;

            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;

            _grid.CustomLinkVariables = "customerId";

            if (swiftLibrary.HasRight(ApproveFunctionId))
            {
                var link = "&nbsp;<a class=\"btn btn-xs btn-success\" title=\"Approve\" href=\"Detail.aspx?customerId=@customerId\"><i class=\"fa fa-check\"></i></a>";
                _grid.CustomLinkText = link;
            }
            string sql = "EXEC [proc_online_approve_Customer] @flag = 'AuditList' ";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
    }
}