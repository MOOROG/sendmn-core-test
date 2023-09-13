using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.ApplicationLog
{
    public partial class UserLog : System.Web.UI.Page
    {
        private const string ViewFunctionId = "10121300";
        protected const string GridName = "grdUseLog";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("createdBy", "User", "LT"),
                                       new GridFilter("logType", "Log Type","1:exec proc_dropDownList @FLAG='logtype'" ),
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("logType", "Log Type", "", "T"),
                                       new GridColumn("IP", "IP", "", "T"),
                                       new GridColumn("Reason", "Reason", "", "T"),
                                       new GridColumn("createdBy", "User", "", "T"),
                                       new GridColumn("createdDate", "Log Date", "", "T"),
                                   };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.InputPerRow = 2;
            _grid.GridName = GridName;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.RowIdField = "rowId";
            _grid.AlwaysShowFilterForm = true;
            _grid.AllowCustomLink = true;

            _grid.AddButtonTitleText = "Add New Data";
            _grid.AllowCustomLink = true;

            _grid.CustomLinkVariables = "rowId";
            _grid.CustomLinkText = "<a href='#' onClick=\"PopUpWindow('ViewDetail.aspx?id=@rowId','dialogHeight:350px;dialogWidth:600px;dialogLeft:300;dialogTop:200;center:yes') \"><img src=\"../../Images/but_view.gif\" alt='User Log' border='0' /></a>";
            //_grid.CustomLinkText = "<a href=\"SubList.aspx?id=@rowId\" ><img src=\"../../Images/but_view.gif\" ></a>";
            //_grid.AddPage = "ViewDetail.aspx";
            _grid.ThisPage = "UserLog.aspx";
            _grid.SetComma();
            _grid.InputLabelOnLeftSide = true;

            const string sql = "exec [Proc_UserLogs] @flag = 's'";

            guserLog_grid.InnerHtml = _grid.CreateGrid(sql);
        }
    }
}