using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Responsive.customerSetup
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "grid_list";
        private const string ViewFunctionId = "20111300";
        private const string AddEditFunctionId = "20111310";
        private const string ApproveFunctionId = "20111330";
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
                                      new GridColumn("membershipId", "Customer Id", "", "T"),
                                      new GridColumn("email", "Email", "", "T"),
                                      new GridColumn("fullName", "Name", "", "T"),
                                      new GridColumn("dob", "DOB", "", "D"),
                                      //new GridColumn("address", "Address", "", "T"),
                                      new GridColumn("mobile", "Mobile", "", "T"),
                                      new GridColumn("countryName", "Native Country", "", "T"),
                                      new GridColumn("idtype", "ID Type", "", "T"),
                                      new GridColumn("idNumber", "ID No", "", "T"),
                                      new GridColumn("createdDate","Regd. Date","","D"),
                                      //new GridColumn("bankName","Bank Name","","T")  ,
                                      //new GridColumn("bankAccountNo","Account Number","","T")
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.ShowAddButton = true;
            _grid.AllowEdit = true;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "customerId";
            _grid.ThisPage = "List.aspx";
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            _grid.AddPage = "Manage.aspx";
            _grid.AllowCustomLink = true;
            _grid.CustomLinkText = "<span class=\"action-icon\"> <btn class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Update KYC\"> <a href =\"UpdateKYC.aspx?customerId=@customerId\"><i class=\"fa fa-list\" ></i></a></btn></span> <a href=\"CustomerDocument.aspx?customerId=@customerId\"><i class=\"fa fa-file\" title=\"Document Upload\"></i> &nbsp;<a href=\"Benificiar\\List.aspx?customerId=@customerId\"><i class=\"fa fa-subway\" title=\"Benificiary\"></i>";
            _grid.CustomLinkVariables = "customerId";
            string sql = "EXEC [proc_online_core_customerSetup] @flag = 's' ";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
    }
}