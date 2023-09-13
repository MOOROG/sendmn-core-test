using System;
using System.Collections.Generic;
using System.Web.UI;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationRoleSetup
{
    public partial class List : Page
    {
        protected const string GridName = "grdRole";
        private const string ViewFunctionId = "10101000";
        private const string AddEditFunctionId = "10101010";
        private const string DeleteFunctionId = "10101020";
        private const string AssignFunctionId = "10101040";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly ApplicationRoleDao _roleDao = new ApplicationRoleDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
           
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
            }
             DeleteRow();
            LoadGrid();
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                   {
                                      new GridFilter("roleName", "Name", "LT"),
                                       new GridFilter("isActive", "Is Active", "1:EXEC Proc_dropdown_remit @flag = 'isActive'")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("roleName", "Role Name", "", "T"),
                                       new GridColumn("roleType", "Role Description", "", "T"),
                                       new GridColumn("isActive", "Is Active", "", "T"),
                                       new GridColumn("createdBy", "Created By", "", "T"),
                                       new GridColumn("createdDate", "Created Date", "", "DT"),
                                       new GridColumn("modifiedBy", "Modified By", "", "T"),
                                       new GridColumn("modifiedDate", "Modified Date", "", "DT")
                                   };

            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);

            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.InputPerRow = 4;
            _grid.GridName = GridName;
            _grid.ShowAddButton = allowAddEdit;
            _grid.ShowFilterForm = true;
            _grid.EnableFilterCookie = false;
            _grid.ShowPagingBar = true;
            _grid.AddButtonTitleText = "Add New Role";
            _grid.RowIdField = "roleId";
            _grid.AlwaysShowFilterForm = true;

            _grid.AllowEdit = allowAddEdit;
            _grid.AllowCustomLink = _sl.HasRight(AssignFunctionId);
             
            _grid.CustomLinkText =
                "<span class=\"action-icon\"> <btn class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Assign Function\"> <a href =\"rolefunction.aspx?roleId=@roleId&roleName=@roleName\"><i class=\"fa fa-cogs\" ></i></a></btn></span>";
            _grid.CustomLinkVariables = "roleId,roleName";
            _grid.AddPage = "Manage.aspx";
            _grid.ThisPage = "List.aspx";
            _grid.SetComma();
            _grid.InputLabelOnLeftSide = true;
            _grid.SortOrder = "DESC";
            const string sql = "exec [proc_applicationRoles] @flag = 's'";

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void DeleteRow()
        {
            string id = _grid.GetCurrentRowId(GridName);

            if (id == "")
                return;

            DbResult dbResult = _roleDao.Delete(id, GetStatic.GetUser());
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }
    }
}