using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.web.Component.Grid;
using Swift.web.Library;
using Swift.web.Component.Grid.gridHelper;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting
{
    public partial class DynamicPopupList : System.Web.UI.Page
    {
        private const string GridName = "grid_dpMessage";
        private const string ViewFunctionId = "10111100";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string AddEditFunctionId = "10111110";


        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                GetStatic.SetActiveMenu(ViewFunctionId);
            }
            LoadGrid();
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("scope", "File For", "LT"),
                                        new GridFilter("isEnable", "Is Active", "2")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("rowId", "S.No", "", "T"),
                                       new GridColumn("scope", "File For", "", "T"),
                                       new GridColumn("fileDescription", "Description", "", "T"),
                                       new GridColumn("isEnable", "Is Enable", "", "T")
                                   };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowAddButton = true;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.RowIdField = "rowId";
            _grid.MultiSelect = true;
            _grid.AddPage = "DynamicPopupManage.aspx";
            _grid.AllowEdit = true;
            _grid.AllowDelete = false;
            _grid.ThisPage = "DynamicPopupList.aspx";
            _grid.AddButtonTitleText = "Add New Popup message";
            // _grid.EditText = "Edit";
            const string sql = "exec [proc_dynamicPopupMessage] @flag = 's'";
            _grid.InputPerRow = 3;
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

    }
}