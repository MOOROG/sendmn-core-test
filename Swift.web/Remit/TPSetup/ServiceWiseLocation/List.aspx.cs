using Swift.DAL.Remittance.TPSetup;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.TPSetup.ServiceWiseLocation
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "grid_list";
        private const string ViewFunctionId = "20174000";
        private const string AddEditFunctionId = "20174010";
        private const string LockUnlock = "20174020";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private readonly TPSetupDao _partnerDao = new TPSetupDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
            }
            LoadGrid();
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }


        private void LoadGrid()
        {

            _grid.FilterList = new List<GridFilter>
                                  {
                                     new GridFilter("countryName", "Country Name", "T"),
                                     new GridFilter("location", "Location", "T"),
                                     new GridFilter("partnerLocationId", "Location Code", "T"),
                                     new GridFilter("typeTitle", "Service Type", "T"),
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),                                      
                                      new GridColumn("countryName", "Country Name", "", "T"),
                                      new GridColumn("location", "Location", "", "T"),
                                      new GridColumn("partnerLocationId", "Partner Location Id", "", "T"),
                                      new GridColumn("typeTitle", "Service Type", "", "T"),                             
                                      new GridColumn("isActive", "Is Active", "", "T")                              
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.AllowEdit = swiftLibrary.HasRight(AddEditFunctionId);
            _grid.AllowDelete = false;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "rowId";
            _grid.ThisPage = "List.aspx";
            _grid.ShowAddButton = swiftLibrary.HasRight(AddEditFunctionId);
            _grid.AddPage = "ManageLocation.aspx";
            _grid.InputPerRow = 4;
            _grid.AllowCustomLink = true;
            //_grid.LoadGridOnFilterOnly = true;

            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;

            _grid.CustomLinkVariables = "rowId,location";

            var link = "&nbsp;<a class=\"btn btn-xs btn-success\" title=\"View Sub Location\" href=\"SubLocationList.aspx?locId=@rowId&locName=@location\"><i class=\"fa fa-eye\"></i></a>";
            if (swiftLibrary.HasRight(LockUnlock))
            {
                link += "&nbsp;<a class=\"btn btn-xs btn-success\" title=\"Block/Unblock\" href=\"javascript:void(0);\" onclick=\"LockUnlock(@rowId)\"><i class=\"fa fa-check\"></i></a>";
            }
            _grid.CustomLinkText = link;

            string sql = "EXEC [proc_tpLocationSetup] @flag = 'list' ";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.AlertMessage(Page);
        }

        protected void btBlockUnblock_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(hddPartnerId.Value))
            {
                DbResult dbResult = _partnerDao.EnableDisable(GetStatic.GetUser(), hddPartnerId.Value);
                ManageMessage(dbResult);
                LoadGrid();
            }
        }
    }
}