using System;
using System.Collections.Generic;
using System.Web.UI;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.StaticData
{
    public partial class List : Page
    {
        private const string GridName = "grid_sdtTyp";
        private const string ViewFunctionId = "10111000";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        //private const string AddEditFunctionId = "10111010";


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
                                       new GridFilter("TypeTitle", "Type Name", "LT")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("typeId", "ID", "", "T"),
                                       new GridColumn("TypeTitle", "Type Title", "", "T"),
                                       new GridColumn("TypeDesc", "Type Description", "", "T")
                                   };
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 2;
            _grid.GridName = GridName;
            _grid.ShowAddButton = false;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.RowIdField = "typeId";
            _grid.MultiSelect = true;
            _grid.AllowEdit = true;
            _grid.AllowDelete = false;
            _grid.AddPage = "StaticValueList.aspx";
            _grid.EditText = "View";
            const string sql = "select * from staticDataType WHERE isInternal = 0";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

    }
}