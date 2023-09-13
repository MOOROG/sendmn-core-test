using Swift.DAL.GeneralDataSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.GeneralSetting.GeneralData
{
    public partial class SubList : System.Web.UI.Page
    {
        private const string DeleteFunctionId = "10111720";
        private const string ViewFunctionId = "10111700";
        private const string AddEditFunctionId = "10111710";
        protected const string GridName = "subList";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private readonly GeneralSettingsSubGridDao _Dao = new GeneralSettingsSubGridDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            DeleteRow();
            LoadGrid();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected string GetID()
        {
            return GetStatic.ReadQueryString("id", "");
        }

        protected string GetTitle()
        {
            return GetStatic.ReadQueryString("title", "");
        }

        private void LoadGrid()
        {
            Title.Text = GetTitle();
            _grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("TYPE_TITLE", "Code", "LT"),
                                       new GridFilter("TYPE_DESC", "Description", "LT"),
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("ref_code", "Code", "", "T"),
                                       new GridColumn("ref_desc", "Description", "", "T"),
                                       new GridColumn("CREATED_BY", "Created By", "", "T"),
                                       new GridColumn("CREATED_DATE", "Created Date", "", "T"),
                                       new GridColumn("MODIFIED_BY", "Modified By", "", "T"),
                                       new GridColumn("MODIFIED_DATE", "Modified Date", "", "T"),
                                   };
            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);

            _grid.MultiSelect = false;
            _grid.GridType = 1;
            _grid.InputPerRow = 2;
            _grid.AllowDelete = _sl.HasRight(DeleteFunctionId);
            _grid.GridName = GridName;
            _grid.ShowFilterForm = true;
            _grid.EnableFilterCookie = false;
            _grid.ShowPagingBar = true;
            _grid.ShowAddButton = allowAddEdit;
            _grid.RowIdField = "refid";
            _grid.AlwaysShowFilterForm = true;
            _grid.AllowEdit = allowAddEdit;
            _grid.ThisPage = "SubList.aspx";
            _grid.AddPage = "Manage.aspx?id=" + GetID() + "&title=" + GetTitle();
            _grid.SetComma();
            _grid.InputLabelOnLeftSide = true;

            string sql = "exec [Proc_GeneralDataSetting] @flag = 'a'";
            sql += ",@ref_rec_type =" + GetID();

            subgds_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string id = _grid.GetCurrentRowId(GridName);

            if (id == "")
                return;

            DbResult dbResult = _Dao.Delete(id, GetStatic.GetUser());
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        protected void delete_Click(object sender, EventArgs e)
        {
            DeleteRow();
        }
    }
}