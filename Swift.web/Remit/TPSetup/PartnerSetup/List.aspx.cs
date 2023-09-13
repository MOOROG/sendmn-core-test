using Swift.DAL.Remittance.Partner;
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

namespace Swift.web.Remit.Administration.PartnerSetup
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "grid_list";
        private const string ViewFunctionId = "20130000";
        private const string AddEditFunctionId = "20130010";
        private const string LockUnlock = "20130010";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private readonly PartnerDao _partnerDao = new PartnerDao();
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
                                     new GridFilter("partnerName", "Partner Name", "T"),
                                     new GridFilter("partnerCountry", "Partner Country", "T"),
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),                                      
                                      new GridColumn("partnerName", "Partner Name", "", "T"),
                                      new GridColumn("partnerCountry", "Partner Country", "", "T"),
                                      new GridColumn("partnerContact", "Partner Contact", "", "T"),
                                      new GridColumn("isActive", "Is Active", "", "T")                              
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.AllowEdit = true;
            _grid.AllowDelete = false;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "rowId";
            _grid.ThisPage = "List.aspx";
            _grid.ShowAddButton = true;
            _grid.AddPage = "Manage.aspx";
            _grid.InputPerRow = 4;
            _grid.AllowCustomLink = true;
            //_grid.LoadGridOnFilterOnly = true;

            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;

            _grid.CustomLinkVariables = "rowId";

            if (swiftLibrary.HasRight(LockUnlock))
            {
                var link = "&nbsp;<a class=\"btn btn-xs btn-success\" title=\"Block/Unblock\" href=\"javascript:void(0);\" onclick=\"LockUnlock(@rowId)\"><i class=\"fa fa-check\"></i></a>";
                _grid.CustomLinkText = link;
            }

            string sql = "EXEC [proc_partner] @flag = 'list' ";
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
                DbResult dbResult = _partnerDao.LockUnlockPartner(GetStatic.GetUser(), hddPartnerId.Value);
                ManageMessage(dbResult);
                LoadGrid();
            }
        }
    }
}