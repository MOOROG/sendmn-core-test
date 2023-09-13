using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;


namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting
{
    public partial class CategoryList : Page
    {
        private const string ViewFunctionId = "10111500";
        private const string AddEditFunctionId = "10111510";
        private const string DeleteFunctionId = "10111520";
        protected const string GridName = "grd_ContactCategory";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly ContactCategory obj = new ContactCategory();
        private readonly SwiftLibrary swiftLibrary = new SwiftLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
         
            }
            DeleteRow();
            LoadGrid();

        }
        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }
        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), hdnId.Value);
            if (dr == null)
                return;

            categoryName.Text = dr["categoryName"].ToString();
            categoryDesc.Text = dr["categoryDesc"].ToString();
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser(),hdnId.Value, categoryName.Text, categoryDesc.Text);

            ManageMessage(dbResult);
            LoadGrid();
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.AlertMessage(Page);
        }

        private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("categoryName", "Category Name", "", "T"),
                                      new GridColumn("categoryDesc", "Category Desc", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate", "Created Date", "", "D")
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = false;
            grid.GridWidth = 800;
            grid.RowIdField = "id";
            grid.CallBackFunction = "GridCallBack()";
            grid.DisableSorting = false;
            grid.ThisPage = "CategoryList.aspx";
            grid.MultiSelect = false;
            grid.ShowCheckBox = true;
            grid.SelectionCheckBoxList = grid.GetRowId();
            grid.AllowEdit = false;
            grid.AllowDelete = swiftLibrary.HasRight(DeleteFunctionId);

            string sql = "EXEC proc_categoryContact @flag = 's'";
            grid.AllowCustomLink = allowAddEdit;
            grid.CustomLinkText = "<a href = \"CustomerList.aspx?id=@id&categoryName=@categoryName\">Add Customer Contact</a>";
            grid.CustomLinkVariables = "id,categoryName";

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
            LoadGrid();
        }

        private void Edit()
        {
            string id = grid.GetRowId();
            hdnId.Value = id;
            PopulateDataById();
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Edit();
        }

        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            Update();
        }

    }
}