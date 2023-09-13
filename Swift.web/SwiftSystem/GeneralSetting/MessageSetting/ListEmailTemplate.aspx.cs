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
    public partial class ListEmailTemplate : Page
    {
        private const string GridName = "grd_emailTemplate";
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
                                        new GridFilter("templateName", "Template Name", "T"),
                                        new GridFilter("emailSubject", "Email Subject", "T")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("templateName", "Template Name", "", "T"),
                                       new GridColumn("emailSubject", "Email Subject", "", "T"),
                                       new GridColumn("templateFor", "Template For", "", "T"),
                                       new GridColumn("replyTo", "Reply To", "", "T"),
                                       new GridColumn("isEnabled", "Enabled", "", "T"),
                                       new GridColumn("isResponseToAgent", "Response To Agent", "", "T"),
                                       new GridColumn("createdBy", "Created By", "", "T"),
                                       new GridColumn("createdDate", "Created Date", "", "D")
                                   };

            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.ShowAddButton = allowAddEdit;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.AddButtonTitleText = "Add New Template";
            _grid.RowIdField = "id";
            _grid.GridWidth = 800;
            _grid.InputPerRow = 3;
            _grid.AllowEdit = allowAddEdit;

            _grid.AddPage = "ManageEmailTemplate.aspx";

            string sql = "[proc_emailTemplate] @flag = 's'";

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