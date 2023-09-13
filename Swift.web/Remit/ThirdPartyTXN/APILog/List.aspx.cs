using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.ThirdPartyTXN.APILog
{
    public partial class List : System.Web.UI.Page
    {
        protected const string GridName = "apiLog";
        private const string ViewFunctionId = "20172000";
        private string sql;
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
            LoadGrid();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
                string ddlSql = "EXEC [PROC_API_ROUTE_PARTNERS] @flag = 'agent-list'";
                string ddlSql1 = "EXEC [PROC_API_ROUTE_PARTNERS] @flag = 'logType'";

            _grid.FilterList = new List<GridFilter>
                {
                    new GridFilter("agentId", "Partner", "1:"+ddlSql, "0")
                    ,new GridFilter("logType", "Log Type", "1:"+ddlSql1, "0")
                    ,new GridFilter("date", "Log date", "D")                   
                    ,new GridFilter("logby", "Log By(username)", "T")                   
                    ,new GridFilter("controlno", "Control Number", "T")                   
                };
            _grid.ColumnList = new List<GridColumn>
                {
                    new GridColumn("SN","SN","","T"),
                    new GridColumn("provider","Provider","","T"),
                    new GridColumn("logby", "Logged By", "", "T"),
                    new GridColumn("date", "Date", "", "D"),
                    new GridColumn("message", "Message", "", "T"),
                    new GridColumn("processid", "logType", "", "T"),
                    new GridColumn("controlno","controlno","","T"),
                };
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.RowIdField = "rowId";
            _grid.InputPerRow = 5;

            _grid.AlwaysShowFilterForm = true;
            _grid.LoadGridOnFilterOnly = true;

            _grid.AllowCustomLink = true;
            _grid.CustomLinkText = Misc.GetIcon("vd", "OpenInNewWindow('Manage.aspx?id=@rowId')");
            _grid.CustomLinkVariables = "rowId";

            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;

            _grid.ThisPage = "List.aspx";
            sql = "EXEC proc_ApiLogs @flag = 's'";
            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
    }
}