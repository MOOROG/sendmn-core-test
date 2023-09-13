using Swift.DAL.OnlineAgent;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.AgentPanel.OnlineAgent.CustomerControls
{
    public partial class ManageList : System.Web.UI.Page
    {
        public const string GridName = "grdCustomerSetup";
        private const string ViewFunctionId = "20111500";
        private const string AddEditFunctionId = "20111510";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
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
                new GridFilter("idNumber", "ID Number", "T")
            };

            _grid.ColumnList = new List<GridColumn>
            {
                new GridColumn("fullName", "Full Name", "", "T"),
                new GridColumn("idType", "Id Type", "", "T"),
                new GridColumn("idNumber", "Id Number", "", "T"),
                new GridColumn("email", "Email", "", "T"),
                new GridColumn("mobile", "Mobile", "", "T"),
                new GridColumn("createdDate", "Created Date", "", "D"),
                new GridColumn("bankName", "Bank Name", "", "T"),
                new GridColumn("accountName", "Account Number", "", "T"),
                new GridColumn("isEnabled", "Is Enabled", "", "T"),
                new GridColumn("status", "Status", "", "T")
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
            _grid.EditText = "Edit Data";
            _grid.AllowEdit = true;
            _grid.ShowAddButton = false;
            _grid.AddPage = "ManageCustomer.aspx";
            _grid.AllowCustomLink = true;
            string sql = "EXEC proc_online_core_customerManage @flag = 'customer-modify-list'";
            _grid.CustomLinkVariables = "id,email,isActive";
            //var link = "&nbsp;<button class=\"btn btn-xs btn-success\" title=\"Verify Customer\" onclick=\"OpenInNewWindow('" + GetStatic.GetUrlRoot() + "/AgentPanel/OnlineAgent/CustomerSetup/VerifyUser.aspx?customerId=@id');\"><i class=\"fa fa-check\"></i></button>";
            var link = "&nbsp;<a href=\"javascript:void(0);\" onclick=\"EnableDisable('@id','@email','@isActive');\" class=\"btn btn-xs btn-primary\">Enable/Disable</a>";
            _grid.CustomLinkText = link;
            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        #endregion method

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(isActive.Value))
            {
                var dbResult = _cd.EnableDisable(customerId.Value, GetStatic.GetUser(), isActive.Value);
                GetStatic.SetMessage(dbResult);
                Response.Redirect("ManageList.aspx");
            }
        }
    }
}