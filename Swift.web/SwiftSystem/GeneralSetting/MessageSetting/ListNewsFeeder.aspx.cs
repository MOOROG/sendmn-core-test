using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting
{
    public partial class ListNewsFeeder : Page
    {
        private const string GridName = "grd_newsFeederMsg";
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
                WriteCookie();
            }
            DeleteRow();
            LoadGrid();
        }
        private void WriteCookie()
        {
            string key = GridName + "_isActive" + "_c_" + GetStatic.GetUser();
            string value = "Y";
            var httpCookie = new HttpCookie(key, value);
            httpCookie.Expires = DateTime.Now.AddDays(1);
            HttpContext.Current.Response.Cookies.Add(httpCookie);
        }
        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                   {
                                        new GridFilter("countryName", "Country", "T"),
                                        new GridFilter("agentName", "Agent", "T"),
                                        new GridFilter("branchName", "Branch", "T"),
                                         new GridFilter("userType", "User Type",
                                                     "1:Exec proc_message @flag ='userType'"),
                                        new GridFilter("isActive", "Is Active", "2:")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("countryName", "Country", "", "T"),
                                       new GridColumn("agentName", "Agent", "", "T"),
                                       new GridColumn("branchName", "Branch", "", "T"),
                                       new GridColumn("msgType", "Applies For", "", "T"),
                                       new GridColumn("newsFeederMsg", "Message", "", "T"),
                                       new GridColumn("isActive", "Is Active", "", "T"),
                                       new GridColumn("createdBy", "Created By", "", "T"),
                                       new GridColumn("userType","User Type","","T"),
                                       new GridColumn("createdDate", "Created Date", "", "T")
                                   };

            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.ShowAddButton = allowAddEdit;
            _grid.ShowFilterForm = true;
            _grid.InputPerRow = 6;
            _grid.ShowPagingBar = true;
            _grid.AddButtonTitleText = "Add New Message";
            _grid.RowIdField = "msgId";
            _grid.MultiSelect = false;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            _grid.AllowEdit = allowAddEdit;
            _grid.AllowDelete = _sl.HasRight(DeleteFunctionId);

            _grid.AddPage = "ManageNewsFeeder.aspx";

            string sql = "[proc_message] @flag = 's5'";
            sql += ",@countryId=" + _grid.FilterString(GetStatic.GetCountryId());

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
            DbResult dbResult = _obj.DeleteHeadMsg(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }
    }
}