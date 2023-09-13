using Swift.DAL.OnlineAgent;
using Swift.DAL.Remittance.Amendment;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.RemittanceSystem.RemittanceReports.AmendmentReport
{
    public partial class AmendmentReport : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private readonly AmendmentDao _ado = new AmendmentDao();
        private const string GridName = "grid_AmendmentList";
        private string ViewFunctionId = "20302000";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                from.Text = DateTime.Now.ToString("yyyy-MM-dd");
                to.Text = DateTime.Now.ToString("yyyy-MM-dd");
                PopulateDDL();
            }
            LoadGrid();
        }
        private void PopulateDDL()
        {
            _sl.SetDDL(ref ddlSearchBy, "exec proc_sendPageLoadData @flag='search-cust-by'", "VALUE", "TEXT", "", "");
        }

        protected void amendmentReport_Click(object sender, EventArgs e)
        {
            LoadGrid();
        }
        private void LoadGrid()
        {
            string customerId = hdnCustomerId.Value;
            var result = _cd.GetCustomerDetails(customerId, GetStatic.GetUser());
            if (result != null)
            {
                txtMembershipId.InnerText = result["membershipId"].ToString();
                customerName.InnerText = result["firstName"].ToString() + ' ' + result["middleName"].ToString() + ' ' + result["lastName1"].ToString();
            }

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("customerId", "Customer Id", "", "T"),
                                      new GridColumn("fullName", "Customer Name", "", "T"),
                                      new GridColumn("changeType", "Change Type", "", "T"),
                                      new GridColumn("ModifiedDate", "Modified Date", "", "T")
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.AllowEdit = false;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = false;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "RowId";
            _grid.ThisPage = "List.aspx";
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            _grid.AddPage = "Manage.aspx?customerId=" + customerId;
            _grid.AllowCustomLink = true;
            _grid.CustomLinkText = "<input type=\"button\" value=\"View Detail\" onclick=showReport('@customerId','@RowId','@changeType','@modifiedDate',@receiverId) />";
            //_grid.CustomLinkText = "<span class=\"action-icon\"> <btn type=\"button\" class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Edit\"> <a href =\"AmendmentReportPage.aspx?customerId=@customerId&amendmentId=@amendmentId&modifiedDate=@modifiedDate\">View Detail Report</a></btn></span>";
            _grid.CustomLinkVariables = "RowId,changeType,customerId,modifiedDate,receiverId";
            string sql = "EXEC [PROC_AMENDMENTLIST] @flag = 's',@customerId='" + customerId + "',@fromDate='" + from.Text + "',@toDate='" + to.Text + "'";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}