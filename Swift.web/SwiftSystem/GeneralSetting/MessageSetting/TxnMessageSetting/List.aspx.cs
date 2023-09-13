using System;
using System.Collections.Generic;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting.TxnMessageSetting
{
    public partial class List : Page
    {
        private const string GridName = "grid_txnMessageSetting";
        private const string ViewFunctionId = "10111700";
        private const string AddEditFunctionId = "10111710";
        private const string DeleteFunctionId = "10111720";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private readonly TxnMessageSettingDao obj = new TxnMessageSettingDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            DeleteRow();
            LoadGrid();
        }
        private void DeleteRow()
        {
            string id = _grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }
        #region method

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("country", "Country", "T"),
                                       new GridFilter("service", "Service", "T")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {

                                       new GridColumn("country", "Country", "", "T"),
                                       new GridColumn("service", "Service", "", "T"),
                                       new GridColumn("codeDescription", "Code Description", "", "T"),
                                       new GridColumn("paymentMethodDesc", "Payment Method Desc.", "", "T"),
                                       new GridColumn("flag", "Message Type", "", "T"),
                                       new GridColumn("isActive", "Is Active", "", "T")

                                   };

            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);

            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.ShowAddButton = allowAddEdit;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.AddButtonTitleText = "Add New Message";
            _grid.RowIdField = "id";
            _grid.MultiSelect = false;

            _grid.AllowEdit = allowAddEdit;
            _grid.AllowDelete = _sl.HasRight(DeleteFunctionId);
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;

            _grid.AddPage = "Manage.aspx";

            string sql = "[proc_txnMessageSetup] @flag = 's'";

            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        #endregion
    }
}