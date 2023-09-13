using System;
using System.Collections.Generic;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting
{
    public partial class ListMessage3 : Page
    {
        private const string GridName = "grd_msg2";
        private const string ViewFunctionId = "10111900";
        private const string AddEditFunctionId = "10111910";
        private const string DeleteFunctionId = "10111920";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly MessageSettingDao _obj = new MessageSettingDao();
        private readonly SwiftLibrary _sl = new SwiftLibrary();

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
                                       new GridFilter("agentName", "Agent", "T")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("agentName", "Agent", "", "T"),
                                        new GridColumn("promotionalMsg", "Message", "", "T"),
                                       new GridColumn("msgType", "Message Type", "", "T"),
                                       new GridColumn("isActive", "Is Active", "", "T"),
                                       new GridColumn("createdBy", "Created By", "", "T"),
                                       new GridColumn("createdDate", "Created Date", "", "T")
                                   };

            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);

            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.ShowAddButton = allowAddEdit;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.AddButtonTitleText = "Add New Message";
            _grid.RowIdField = "msgId";
            _grid.MultiSelect = false;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            _grid.AllowEdit = allowAddEdit;
            _grid.AllowDelete = _sl.HasRight(DeleteFunctionId);

            _grid.AddPage = "ManageMessage3.aspx";

            string sql = "[proc_message] @flag = 's3'";

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
            DbResult dbResult = _obj.DeleteMsgBlock3(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult); 
            GetStatic.PrintMessage(Page);
        }
    }
}