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
    public partial class ListMessage2 : Page
    {
        private const string GridName = "grd_msg2";
        private const string ViewFunctionId = "10111100";
        private const string AddEditFunctionId = "10111110";
        private const string DeleteFunctionId = "10111120";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly MessageSettingDao _obj = new MessageSettingDao();
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
                                       new GridFilter("CountryName", "Sending Country", "LT"),
                                       new GridFilter("AgentName", "Sending AgentName", "LT"),
                                       new GridFilter("rCountry", "Receiving Country", "LT"),
                                       new GridFilter("rAgent", "Receiving AgentName", "LT"),
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("CountryName", "Sending Country", "", "T"),
                                       new GridColumn("AgentName", "Sending Agent", "", "T"),
                                       new GridColumn("rCountry", "Receiving Country", "", "T"),
                                       new GridColumn("rAgent", "Receiving Agent", "", "T"),

                                       new GridColumn("msgType", "Message Type", "", "T"),
                                       new GridColumn("isActive", "Is Active", "", "T")
                                   };

            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.InputPerRow = 4;
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

            _grid.AddPage = "ManageMessage2.aspx";

            string sql = "[proc_message] @flag = 's2'";

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
            DbResult dbResult = _obj.DeleteMsgBlock2(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }
    }
}