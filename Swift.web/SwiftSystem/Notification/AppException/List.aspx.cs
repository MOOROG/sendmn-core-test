using System;
using System.Collections.Generic;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.Notification.AppException
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "10121800";
        private const string ViewDetailFunctionId = "10121800";
        private const string GridName = "grdAppEx";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftGrid grid = new SwiftGrid();
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
            _sdd.CheckAuthentication(ViewFunctionId + "," + ViewDetailFunctionId);

        }

        private void LoadGrid()
        {

            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("id", "Error Log ID", "N"),
                                      new GridFilter("createdBy", "User Name", "T"),
                                      new GridFilter("createdDate", "Date", "z")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("id", "Log ID", "", "T"),
                                      new GridColumn("errorPage", "Page", "", "T"),
                                      new GridColumn("errorMsg", "Message", "300", "T"),
                                      new GridColumn("createdBy", "User", "", "T"),
                                      new GridColumn("createdDate", "Date", "", "DT")
                                     
                                  };
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.GridType = 1;
            grid.ShowFilterForm = true;
            grid.AlwaysShowFilterForm = true;
            grid.InputPerRow = 3;
            grid.LoadGridOnFilterOnly = true;
            grid.GridMinWidth = 700;
            grid.IsGridWidthInPercent = true;
            grid.GridWidth = 100;
            grid.ShowPagingBar = true;
            grid.RowIdField = "id";

            grid.EncodeJSInData = true;

            if (_sdd.HasRight(ViewDetailFunctionId))
            {
                grid.AllowCustomLink = true;
                grid.CustomLinkText = "<a href = \"#\" onclick=\"OpenInNewWindow('Manage.aspx?id=@id')\" title=\"View Error Detail\">View</a>";
                grid.CustomLinkVariables = "id";
            }
            grid.SetComma();
            var sql = @"EXEC proc_errorLogs @flag = 's'";
            rpt_grid.InnerHtml = grid.CreateGrid(sql);

        }
    }
}