using System;
using System.Collections.Generic;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.APILocationMapping
{
    public partial class List : Page
    {
        private const string GridName = "grdLocation";
        private const string ViewFunctionId = "10111700";
        private const string AddEditFunctionId = "10111710";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly ApiLocationMapperDao obj = new ApiLocationMapperDao();
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
                                       new GridFilter("districtCode", "Location Code", "LT"),
                                       new GridFilter("districtName", "Location Name", "LT"),
                                       new GridFilter("district", "District Name", "LT"),
                                       new GridFilter("zone", "Zone Name", "LT"),
                                       new GridFilter("region", "Dev. Region", "LT")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("locationCode", "Location Code", "", "T"),
                                       new GridColumn("locationName", "Location Name", "", "T"),
                                       new GridColumn("zoneName", "Zone Name", "", "T"),
                                       new GridColumn("districtName", "District Name", "", "T"),
                                       new GridColumn("regionName", "Dev. Region", "", "T"),
                                       new GridColumn("isActive", "Is Active", "", "T")
                                   };
            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.ShowAddButton = true;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.InputPerRow = 3;
            _grid.RowIdField = "rowId";
            _grid.SortBy = "locationName";
            _grid.SortOrder = "ASC";
            _grid.MultiSelect = false;
            _grid.AllowEdit = _sl.HasRight(AddEditFunctionId);
            _grid.AllowDelete = false;
            _grid.AddPage = "Manage.aspx";
            _grid.AllowCustomLink = true;
            _grid.CustomLinkVariables = "locationCode";
            _grid.CustomLinkText = "<a href=\"LocationDistrictMap.aspx?districtCode=@locationCode\">View</a>";
            string sql = "EXEC proc_apiLocation @flag = 's'";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }


        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void btnImportLoc_Click(object sender, EventArgs e)
        {
            ImportLocation();
        }

        private void ImportLocation()
        {
            var dbResult = new DbResult();
            try
            {
                dbResult = obj.ImportLocation(GetStatic.GetUser());
                ManageMessage(dbResult);
                LoadGrid();
            }
            catch(Exception ex)
            {
                dbResult.SetError("1", "Cannot connect Server", "");
                ManageMessage(dbResult);
            }
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }
    }
}