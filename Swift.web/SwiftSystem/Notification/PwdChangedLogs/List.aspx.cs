using System;
using System.Collections.Generic;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.Notification.PwdChangedLogs
{
    public partial class List : System.Web.UI.Page
    {
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string ViewFunctionId = "10121900";
        private const string GridName = "grdPwdLogs";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("branchName", "Agent Name", "LT"),
                                       new GridFilter("userName", "User Name", "LT"),
                                       new GridFilter("fromDate", "From Date", "z"),
                                       new GridFilter("toDate", "To Date", "z")
                                   };

            grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("agentName", "Agent", "", "T"),
                                       new GridColumn("userName", "User", "", "T"),
                                       new GridColumn("pwdChangedDate", "Pwd Changed Date", "", "DT"),
                                       new GridColumn("pwdChangedBy", "Pwd Changed By", "", "T"),
                                       new GridColumn("lastPwdChangedDate", "Last Pwd Changed Date", "", "DT")
                                   };
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.InputPerRow = 2;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "userName";
            grid.ThisPage = "List.aspx";
            grid.AlwaysShowFilterForm = true;
            grid.LoadGridOnFilterOnly = true;

            grid.AllowEdit = false;

            var sql = "exec [proc_pwdChangedLogs] @flag = 's'";
            grid.SetComma();
            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}