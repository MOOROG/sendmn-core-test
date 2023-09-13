using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.CreditRiskManagement.BalanceTopUp
{
    public partial class History : Page
    {
        private const string GridName = "gridBalTopUpHistory";
        private const string ViewFunctionId = "20181500";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary remitLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                lblAgentName.Text = GetAgentName();
            }
            LoadGrid();
        }

        #region method

        protected string GetAgentName()
        {
            return "Agent Name : " + remitLibrary.GetAgentName(GetAgentId().ToString());
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("createdBy", "Created By", "LT"),
                                      new GridFilter("approvedBy", "Approved By", "LT"),
                                      new GridFilter("approvedFromDate", "Approved Date From", "z"),
                                      new GridFilter("approvedToDate", "To", "z")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("amount", "Amount", "", "M"),
                                      new GridColumn("btStatus", "Status", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate", "Created Date", "", "T"),
                                      new GridColumn("approvedBy", "Approved By", "", "T"),
                                      new GridColumn("approvedDate", "Approved Date", "", "T")
                                  };

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowFilterForm = true;
            grid.AlwaysShowFilterForm = true;
            grid.EnableFilterCookie = false;
            grid.LoadGridOnFilterOnly = true;
            grid.ShowPagingBar = true;
            grid.SortBy = "approvedDate";
            grid.SortOrder = "DESC";
            grid.RowIdField = "sn";
            grid.InputPerRow = 2;
            grid.GridWidth = 650;
            string sql = "[proc_balanceTopUp] @flag = 'history',@agentId='" + GetAgentId() + "'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            remitLibrary.CheckAuthentication(ViewFunctionId);
        }

        #endregion method
    }
}