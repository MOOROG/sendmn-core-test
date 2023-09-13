using Swift.DAL.GeneralDataSettings;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.GeneralSetting.GeneralData
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "10111700";

        protected const string GridName = "grdGeneralDataSettings";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private readonly GeneralDataSettingsDao _Dao = new GeneralDataSettingsDao();

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
                                       new GridFilter("TYPE_TITLE", "Title", "LT"),
                                       new GridFilter("TYPE_DESC", "Description", "LT"),
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("TYPE_TITLE", "Title", "", "T"),
                                       new GridColumn("TYPE_DESC", "Description", "", "T"),
                                   };

            _grid.GridType = 1;
            _grid.InputPerRow = 2;
            _grid.GridName = GridName;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.RowIdField = "ROWID";
            _grid.AlwaysShowFilterForm = true;
            _grid.AllowCustomLink = true;

            _grid.AddButtonTitleText = "Add New Data";
            _grid.AllowCustomLink = true;

            _grid.CustomLinkVariables = "ROWID,TYPE_TITLE";

            _grid.CustomLinkText = "<a href=\"SubList.aspx?id=@ROWID&title=@TYPE_TITLE\" ><img src=\"../../Images/but_view.gif\" ></a>";
            _grid.AddPage = "Manage.aspx";
            _grid.ThisPage = "List.aspx";
            _grid.SetComma();
            _grid.InputLabelOnLeftSide = true;

            const string sql = "exec [Proc_GeneralDataSetting] @flag = 's'";

            gds_grid.InnerHtml = _grid.CreateGrid(sql);
        }
    }
}