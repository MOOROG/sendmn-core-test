using System;
using System.Collections.Generic;
using Swift.web.Component.Grid;
using Swift.web.Library;
using Swift.web.Component.Grid.gridHelper;

namespace Swift.web.SwiftSystem.Notification.FraudAccessMonitoring
{
    public partial class List : System.Web.UI.Page
    {
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary _swiftLibrary = new RemittanceLibrary();
        private const string ViewFunctionId = "10122000";
        private const string GridName = "grd_fa_monotring";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }
        
        private void Authenticate()
        {
            _swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                     new GridFilter("ip", " IP Address", "T"),
                                     new GridFilter("createdDate", " Date", "z")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "S.N.", "", "T"),
                                      new GridColumn("ip", "IP Address", "", "T"),
                                      new GridColumn("fieldValue", "Platform", "", "T"),
                                      new GridColumn("createdDate", "Date", "", "D"),                                     
                                  };
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.InputPerRow = 2;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "id";
            grid.LoadGridOnFilterOnly = true;
            var sql = "EXEC proc_IpAccessLogs @flag = 's'";
            grid.SetComma();
            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }
     }
}