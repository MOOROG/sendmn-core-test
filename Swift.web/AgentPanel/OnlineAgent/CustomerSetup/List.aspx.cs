using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.AgentPanel.OnlineAgent.CustomerSetup
{
    public partial class List : System.Web.UI.Page
    {
        public const string GridName = "grdCustomerSetup";
        private const string ViewFunctionId = "40120000";
        private const string AddEditFunctionId = "40120010";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        #region method

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
            {
                new GridFilter("createdDate", "Created Date", "d"),
                new GridFilter("mobile", "Mobile", "T"),
                new GridFilter("email", "Email", "T"),
                new GridFilter("custNativecountry", "Native Country", "T")
            };

            _grid.ColumnList = new List<GridColumn>
            {
                new GridColumn("fullName", "Full Name", "", "T"),
                new GridColumn("city", "City", "", "T"),
                new GridColumn("email", "Email", "", "T"),
                new GridColumn("mobile", "Mobile", "", "T"),
                new GridColumn("createdDate", "Created Date", "", "D"),
                new GridColumn("bankName", "Bank Name", "", "T"),
                new GridColumn("accountName", "Account Number", "", "T")
            };
            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowFilterForm = true;
            _grid.AlwaysShowFilterForm = true;
            _grid.EnableFilterCookie = false;
            _grid.ShowPagingBar = true;
            _grid.SortOrder = "desc";
            _grid.RowIdField = "id";
            _grid.InputPerRow = 2;
            _grid.AllowEdit = true;
            _grid.ShowAddButton = true;
            _grid.AddPage = "Manage.aspx";
            _grid.AllowCustomLink = true;
            string sql = "EXEC proc_online_core_customerSetup @flag = 'customer-list'";
            _grid.CustomLinkVariables = "id";
            var link = "&nbsp;<a href=\"DirectApprove.aspx?customerId=@id&verify=y\" class=\"btn btn-xs btn-success\"><i class=\"fa fa-check\"></i></a>&nbsp;<a href=\"PrintForm.aspx?customerId=@id&class=\"btn btn-xs btn-success\"><i class=\"fa fa-print\" aria-hidden=\"true\"></i></a>";
            _grid.CustomLinkText = link;
            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        #endregion method
    }
}