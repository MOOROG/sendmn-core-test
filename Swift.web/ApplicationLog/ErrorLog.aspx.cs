using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.ApplicationLog
{
    public partial class ErrorLog : System.Web.UI.Page
    {
        private SwiftLibrary _sl = new SwiftLibrary();
        private const string ViewFunctionId = "10112000";
        private readonly SwiftGrid _grid = new SwiftGrid();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
            }
            LoadGrid();
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("id", "Log ID", "T"),
                                       new GridFilter("createdDate", "Date", "Z")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("id", "Log ID", "", "T"),
                                       new GridColumn("errorPage", "Error Page", "", "T"),
                                       new GridColumn("errorMsg", "Error Message", "", "T"),
                                      new GridColumn("createdBy", "User", "", "T"),
                                       new GridColumn("createdDate", "Log Date", "", "D")
                                   };

            _grid.GridType = 1;
            _grid.InputPerRow = 2;
            _grid.GridName = "ErrorLog";
            _grid.EnableFilterCookie = false;
            _grid.ShowPagingBar = true;
            _grid.RowIdField = "id";
            _grid.ShowFilterForm = true;

            _grid.AllowCustomLink = true;
            _grid.CustomLinkText = "<a href='#' title='View Error Details' onClick=\"PopUpWindow('ErrorDetail.aspx?id=@id','dialogHeight:470px;dialogWidth:750px;dialogLeft:200;dialogTop:100;center:yes')\"><img src='../Images/but_view.gif\' alt='View Error Details' class='showHand' border='0' ></a>";
            _grid.CustomLinkVariables = "id";

            _grid.InputLabelOnLeftSide = true;

            const string sql = "EXEC proc_errorLogs @flag = 's'";
            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}