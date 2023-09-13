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
    public partial class SubLocationList : System.Web.UI.Page
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
                                     new GridFilter("location", "Location", "T"),
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),                                      
                                      new GridColumn("location", "Location", "", "T"),
                                      new GridColumn("subLocation", "Sub Location", "", "T"),
                                      new GridColumn("partnerSubLocationId", "Sub Location Id", "", "T"),                             
                                      new GridColumn("partnerLocationId", "Location Id", "", "T")                              
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.AllowEdit = swiftLibrary.HasRight(AddEditFunctionId);
            _grid.AllowDelete = true;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "rowId";
            _grid.ThisPage = "List.aspx";
            _grid.ShowAddButton = swiftLibrary.HasRight(AddEditFunctionId);
            _grid.AddPage = "ManageSubLocation.aspx?locId=" + GetId() + "&locName=" + GetLocation();
            _grid.InputPerRow = 4;
            _grid.AllowCustomLink = true;
            //_grid.LoadGridOnFilterOnly = true;

            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;

            _grid.CustomLinkVariables = "rowId";

            string sql = "EXEC [proc_tpLocationSetup] @flag = 'sub-list', @locationId=" + GetId();
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        public string GetLocation()
        {
            return GetStatic.ReadQueryString("locName", "");
        }

        public string GetId()
        {
            return GetStatic.ReadQueryString("locId", "");
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