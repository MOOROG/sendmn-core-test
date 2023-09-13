using System;
using System.Collections.Generic;
using System.Text;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.AdminUserSetup
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "grdAdminUsr";
        private const string ViewFunctionId = "10101300";
        private const string AddEditFunctionId = "10101310";
        private const string DeleteFunctionId = "10101320";
        private const string ApproveFunctionId = "10101330";
        private const string AssignRoleId = "10101350";
        private const string ResetPassword = "10101370";
        private const string LockUser = "10101380";
        private const string UserGroupMapping = "10101310";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly ApplicationUserDao _obj = new ApplicationUserDao();
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
                                       new GridFilter("userName", "User Name", "LT"),
                                       new GridFilter("firstName", "First Name", "LT"),
                                       new GridFilter("isLocked", "Lock Status", "2"),
                                       new GridFilter("haschanged", "Change Status", "2")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("userName", "User Name", "", "LT"),
                                       new GridColumn("userId", "User Code", "", "T"),
                                       new GridColumn("name", "Name", "", "LT"),
                                       new GridColumn("lastLoginTs", "Last Login", "", "T"),
                                       new GridColumn("lastPwdChangedOn", "Password Change", "", "T"),
                                       new GridColumn("lockStatus", "Lock Status", "", "T")
                                   };

            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);

            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.ShowAddButton = allowAddEdit;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.AddButtonTitleText = "Add New User";
            _grid.RowIdField = "userId";
            _grid.MultiSelect = false;

            _grid.AllowEdit = allowAddEdit;
            _grid.AllowDelete = _sl.HasRight(DeleteFunctionId);
            _grid.AllowApprove = false;
            _grid.ApproveFunctionId = ApproveFunctionId;
            _grid.AddPage = "manage.aspx";
            _grid.AllowCustomLink = true;
            var customLinkText = new StringBuilder();
           
            if (_sl.HasRight(AssignRoleId))
                customLinkText.Append(
                    "<a href = \"UserRole.aspx?userName=@userName&userId=@userId" +
                    "\"><img src=\"" + GetStatic.GetUrlRoot() + "/images/role_icon.gif\" border=0 title=\"Assign Role\" alt=\"Assign Role\" /></a>&nbsp;&nbsp;");
           
            if (_sl.HasRight(LockUser))
            customLinkText.Append(
                    "<a href = '#'><img src=\"" + GetStatic.GetUrlRoot() + "/images/unlock.png\" height=\"17\" width=\"16\" border=0 title=\"Lock/Unlock User\" alt=\"Lock/Unlock User\" onclick=\"LockUnlock(@userId,'l');\" /></a>&nbsp;&nbsp;");
            if (_sl.HasRight(ResetPassword))
            customLinkText.Append(
                    "<a href = '#'><img src=\"" + GetStatic.GetUrlRoot() + "/images/change_password.png\" border=0 title=\"Reset Password\" alt=\"Reset Password\" onclick=\"LockUnlock(@userId,'r');\" /></a>&nbsp;&nbsp;");

            if (_sl.HasRight(UserGroupMapping))
                customLinkText.Append(
                    "<a href = \"UserGroupMaping.aspx?userName=@userName&userId=@userId" +
                    "\"><img src=\"" + GetStatic.GetUrlRoot() + "/images/user_icon.gif\" border=0 title=\"User Grouping\" alt=\"Lock User\" /></a>");
        
            _grid.CustomLinkText = customLinkText.ToString();

            _grid.CustomLinkVariables = "userName,userId";
            _grid.InputPerRow = 4;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;

            string sql = "[proc_applicationUsers] @flag = 'hs'";

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
            DbResult dbResult = _obj.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        protected void LockUnlockUser_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(hdnchangeType.Value))
                return;
            DbResult dbResult = null;
            if(hdnchangeType.Value=="l")
                 dbResult = _obj.LockUnlockUser(GetStatic.GetUser(), hddUserId.Value);

            if (hdnchangeType.Value == "r")
                dbResult = _obj.ResetPassword(GetStatic.GetUser(), hddUserId.Value);

            ManageMessage(dbResult);
            LoadGrid();
            hdnchangeType.Value = "";
            hddUserId.Value = "";
        }
    }
}