using System;
using System.Collections.Generic;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;


namespace Swift.web.SwiftSystem.Notification.LoginLogs
{
    public partial class List : System.Web.UI.Page
    {
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary _swiftLibrary = new RemittanceLibrary();
        private const string ViewFunctionId = "10121200";
        private const string GridName = "grdLoginLog";
        private readonly ApplicationUserDao _obj = new ApplicationUserDao();
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
            grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("logType", "Log Type",
                                                     "1:EXEC proc_LoginViewLogs @flag = 'type'"),
                                       new GridFilter("agent", "Branch Code", "LT"),
                                       new GridFilter("Reason", "Remarks", "T"),
                                       new GridFilter("createdBy", "Login ID", "T"),
                                       new GridFilter("createdDate", "Access Date", "z"),
                                       new GridFilter("isLocked", "Lock Status", "2")
                                   };

            grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("lockStatus", "Lock Status", "", "T"),
                                       new GridColumn("createdDate", "Access Date", "", "DT"),
                                       //new GridColumn("agentCode", "Branch Code", "", "T"),
                                       //new GridColumn("employeeId", "Emp ID", "", "T"),
                                       new GridColumn("createdBy", "Login ID", "", "T"),
                                       new GridColumn("IP", "IP Address", "", "T"),
                                       new GridColumn("LOGIN_COUNTRY", "Login Country", "", "T"),
                                       new GridColumn("ADDRESS", "Full Address", "", "T"),
                                       new GridColumn("OTP_ATTEMPT", "OTP Attempt", "", "T"),
                                       new GridColumn("Reason", "Remarks", "", "T"),
                                       new GridColumn("logType", "Log Type", "", "T"),
                                       new GridColumn("userData", "Data Input", "", "T"),
                                       new GridColumn("Edit", " ", "", "nosort")
                                   };
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.InputLabelOnLeftSide = true;
            grid.InputPerRow = 3;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.GridMinWidth = 800;
            grid.IsGridWidthInPercent = true;
            grid.GridWidth = 100;
            grid.RowIdField = "rowid";
            grid.ThisPage = "List.aspx";
            grid.AlwaysShowFilterForm = true;
            grid.LoadGridOnFilterOnly = true;

            grid.AllowEdit = false;

            var sql = "exec [proc_LoginViewLogs] @flag = 's'";
            grid.SetComma();
            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        protected void btnLockUnlockUser_Click(object sender, EventArgs e)
        {
            if (!isRefresh)
            {
                var dbResult = _obj.LockUnlockUser(GetStatic.GetUser(), hddUserId.Value);
                ManageMessage(dbResult);
                LoadGrid();
            }
        }

        #region Browser Refresh
        private bool refreshState;
        private bool isRefresh;

        protected override void LoadViewState(object savedState)
        {
            object[] AllStates = (object[])savedState;
            base.LoadViewState(AllStates[0]);
            refreshState = bool.Parse(AllStates[1].ToString());
            if (Session["ISREFRESH"] != null && Session["ISREFRESH"] != "")
                isRefresh = (refreshState == (bool)Session["ISREFRESH"]);
        }

        protected override object SaveViewState()
        {
            Session["ISREFRESH"] = refreshState;
            object[] AllStates = new object[3];
            AllStates[0] = base.SaveViewState();
            AllStates[1] = !(refreshState);
            return AllStates;
        }

        #endregion
    }
}