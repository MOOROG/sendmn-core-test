using System;
using System.Collections.Generic;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Component.Grid;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.web.Library;
using Swift.DAL.SwiftDAL;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting
{
    public partial class ListMessageBroadCast : System.Web.UI.Page
    {
        private const string GridName = "grdMsgBroadCast";
        private const string ViewFunctionId = "10111100";
        private const string AddEditFunctionId = "10111110";
        private const string DeleteFunctionId = "10111120";
        private readonly SwiftGrid _grid = new SwiftGrid();
        readonly MessageBroadCastDao mbcd = new MessageBroadCastDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
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

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("countryName", "Country", "T"),
                                       new GridFilter("agentName", "Agent", "T"),
                                       new GridFilter("branchName", "Branch", "T")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("countryName", "Country", "", "T"),
                                       new GridColumn("agentName", "Agent", "", "T"),
                                       new GridColumn("branchName", "Branch", "", "T"),
                                       new GridColumn("msgTitle", "Message Title", "", "T"),
                                       new GridColumn("msgDetail", "Message Detail", "", "T"),
                                       new GridColumn("userType", "User Type", "", "T"),
                                       new GridColumn("isActive", "Is Active", "", "T"),
                                       new GridColumn("createdBy", "Created By", "", "T"),
                                       new GridColumn("createdDate", "Created Date", "", "T")
                                   };

            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.InputPerRow = 3;
            _grid.GridName = GridName;
            _grid.ShowAddButton = allowAddEdit;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.AddButtonTitleText = "Add New Message";
            _grid.RowIdField = "msgBroadCastId";
            _grid.AllowEdit = allowAddEdit;
            _grid.AllowDelete = _sl.HasRight(DeleteFunctionId);
            _grid.AddPage = "ManageMessageBroadCast.aspx";
            string sql = " EXEC proc_msgBroadCast @flag = 's'";
            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void DeleteRow()
        {
            string id = _grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = mbcd.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }
    }
}