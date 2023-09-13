using System;
using System.Collections.Generic;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;


namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting.SystemEmailSetup
{
    public partial class List : Page
    {
        private const string GridName = "grid_SystemEmailSetup";
        private const string ViewFunctionId = "10111600";
        private const string AddEditFunctionId = "10111610";

        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly SystemEmailSetupDao obj = new SystemEmailSetupDao();
        private readonly SwiftLibrary swiftLibrary = new SwiftLibrary();

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

        #region method

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("name", "Name", "LT"),
                                      new GridFilter("email", "Email", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                        new GridColumn("country", "Country", "", "T"),
                                        new GridColumn("name", "Name", "", "T"),
                                        new GridColumn("email", "Email", "", "T"),
                                        new GridColumn("mobile", "Mobile", "", "T"),
                                        new GridColumn("agent", "Agent", "", "T"),
                                        new GridColumn("isCancel", "Cancel", "", "T"),
                                        new GridColumn("isTrouble", "Trouble", "", "T"),
                                        new GridColumn("isAccount", "Account", "", "T"),
                                        new GridColumn("isXRate", "XRate", "", "T"),
                                        new GridColumn("isSummary", "Summary", "", "T"),
                                        new GridColumn("isbankGuaranteeExpiry", "Bank Gurantee Expiry", "", "T")
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowAddButton = true;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.InputPerRow = 4;
            grid.RowIdField = "id";
            grid.GridWidth = 800;
            grid.MultiSelect = false;
            grid.AllowEdit = swiftLibrary.HasRight(AddEditFunctionId);
            grid.AllowDelete = true;
            grid.AllowApprove = false;

            grid.AddPage = "Manage.aspx";
            grid.AllowCustomLink = false;


            string sql = "[proc_systemEmailSetup] @flag = 's'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string id = grid.GetCurrentRowId(GridName);
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

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        #endregion
    }
}