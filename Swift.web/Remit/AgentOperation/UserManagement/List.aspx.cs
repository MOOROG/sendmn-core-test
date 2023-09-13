using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using Swift.web.SwiftSystem.UserManagement.ApplicationUserPool;
using System;
using System.Collections.Generic;
using System.Text;

namespace Swift.web.Remit.AgentOperation.UserManagement
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "grd_branchUsr";
        private const string ViewFunctionId = "40112500";
        private const string ResetPassword = "40112520";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly ApplicationUserDao _obj = new ApplicationUserDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        internal UserPool userPool = UserPool.GetInstance();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        private void LoadGrid()
        {
            string user = GetStatic.GetUser();
            string isActAsBranch = GetStatic.GetIsActAsBranch();
            string agentType = GetStatic.GetAgentType();
            string agentId = GetStatic.GetBranch();
            string parentId = GetStatic.GetAgent();

            _grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("userName", "User Name", "LT"),
                                       new GridFilter("agentName", "Branch Name", "LT")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("agentCode", "Agent ID", "", "T"),
                                       new GridColumn("employeeId", "Employee ID", "", "T"),
                                       new GridColumn("userName", "User Name", "", "LT"),
                                       new GridColumn("userFullName", "User Full Name", "", "LT"),
                                       new GridColumn("agentName", "Branch", "", "T"),
                                       new GridColumn("address", "Address", "", "T"),
                                       new GridColumn("lockStatus", "Lock Status", "", "T")
                                   };

            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.InputPerRow = 2;
            _grid.ShowAddButton = false;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.RowIdField = "userId";
            _grid.AlwaysShowFilterForm = true;
            _grid.IsGridWidthInPercent = true;
            _grid.GridWidth = 100;
            _grid.GridMinWidth = 700;
            _grid.AllowEdit = false;
            _grid.AllowCustomLink = true;
            var customLinkText = new StringBuilder();
            if (_sl.HasRight(ResetPassword))
                customLinkText.Append(
                    "<a href = \"ResetPassword.aspx?userName=@userName&agentId=@agentId" +
                    "\">Reset Password</a>&nbsp;&nbsp;");
            _grid.CustomLinkText = customLinkText.ToString();

            _grid.CustomLinkVariables = "userName,userId,agentId";

            string sql = "exec [proc_branchUserList] @flag='su'";
            sql = sql + ", @agentId=" + _grid.FilterString(agentId);
            sql = sql + ", @isActAsBranch=" + _grid.FilterString(isActAsBranch);
            sql = sql + ", @agentType=" + _grid.FilterString(agentType);
            sql = sql + ", @parentId = " + _grid.FilterString(parentId);

            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            if (GetStatic.GetIsActAsBranch() == "Y")
            {
                _sl.CheckAuthentication(ViewFunctionId + "," + GetStatic.GetIsActAsBranch());
            }
            else
            {
                Response.Redirect(GetStatic.GetAuthenticationPage());
            }
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        protected void btnLockUnlockUser_Click(object sender, EventArgs e)
        {
            var dbResult = _obj.LockUnlockUser(GetStatic.GetUser(), hddUserId.Value);
            ManageMessage(dbResult);
            LoadGrid();
        }
    }
}