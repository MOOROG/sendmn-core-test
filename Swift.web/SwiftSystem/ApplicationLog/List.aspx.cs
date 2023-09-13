using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.SwiftSystem.ApplicationLog
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "appLogList";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                _sl.CheckSession();
                //Authenticate();
                GetStatic.PrintMessage(Page);

            }
            LoadGrid();
        }

        private void Authenticate()
        {
            //_sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("logId", "Log Id:", "LT"),
                                       new GridFilter("createdBy", "User Name:", "LT"),
                                       new GridFilter("createdDate", "Date:", "d"),
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("sn", "Sno.", "", "T"),
                                       new GridColumn("id", "Log Id", "", "T"),
                                       new GridColumn("errorPage", "Error Page","", "a"),
                                       new GridColumn("errorMsg", "Error Msg", "", "T"),
                                       new GridColumn("createdBy", "Created By", "", "LT"),
                                       new GridColumn("createdDate", "Created Date", "", "T"),
                                   };

            _grid.GridType = 1;
            _grid.InputPerRow = 3;
            _grid.GridName = GridName;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.RowIdField = "id";
            _grid.AllowCustomLink = true;
            var customLinkText = new StringBuilder();

            customLinkText.Append("<a href ='#' onclick=\"ManageLogInfo(@id)\" class=\"btn btn-xs btn-primary\" title=\"View Detail\" data-placement=\"top\" data-toggle=\"tooltip\"><i class=\"fa fa-eye\"></i></a>");

            _grid.CustomLinkText = customLinkText.ToString();
            _grid.CustomLinkVariables = "id";

            string sql = " [proc_ApplicationLogsNew] @flag = 's'";

            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
    }
}