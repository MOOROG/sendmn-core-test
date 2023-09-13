using System;
using System.Collections.Generic;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.Notification.ApplicationLogs
{
    public partial class TransactionViewLog : System.Web.UI.Page
    {
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary _swiftLibrary = new RemittanceLibrary();
        private const string ViewFunctionId = "10121000";
        private const string GridName = "grdTrnLog";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            LoadGrid();
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("tranViewType", "View Type", "T"),
                                       new GridFilter("AgentName", "Branch", "LT"),
                                       new GridFilter("controlNumber", "Control No", "T"),
                                       new GridFilter("createdBy", "User", "T"),
                                       new GridFilter("createdDate", "Date", "D"),
                                       new GridFilter("tranId", "Tran Id", "T")
                                   };

            grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("tranViewType", "View Type", "", "T"),
                                       new GridColumn("tranId", "Tran Id", "", "T"),
                                       new GridColumn("controlNumber", "Control No", "", "T"),
                                       new GridColumn("agentName", "Branch Name", "", "T"),
                                       new GridColumn("createdBy", "User", "", "T"),
                                       new GridColumn("createdDate", "Date", "", "T")
                                   };
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.InputPerRow = 4;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "id";
            grid.ThisPage = "TransactionViewLog.aspx";
            grid.AlwaysShowFilterForm = true;
            grid.LoadGridOnFilterOnly = true;
            grid.AllowEdit = false;

            var sql = "exec [proc_TransactionviewLogs] @flag = 's'";
            grid.SetComma();
            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _swiftLibrary.CheckAuthentication(ViewFunctionId);
        }
    }
}