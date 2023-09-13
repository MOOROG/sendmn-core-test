using System;
using System.Collections.Generic;
using System.Text;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationUserSetup
{
    public partial class DeactivatedUserList : System.Web.UI.Page
    {
        private const string GridName = "grdDelUsr";
        private const string ViewFunctionId = "10101300";

        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly ApplicationUserDao _obj = new ApplicationUserDao();
        private readonly SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.AlertMessage(Page);
                
                hdnUserType.Value = "";
            }
            LoadGrid();
        }

        protected string GetAgent()
        {
            return GetStatic.ReadQueryString("agentId", "");
        }

        protected long GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode");
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                   {
                                       
                                        //new GridFilter("branchName", "Branch Name", "a"),
                                       new GridFilter("userName", "User Name", "a"),
                                       new GridFilter("firstName", "First Name", "LT")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       //new GridColumn("branchName", "Branch Name","", "T"),
                                       new GridColumn("userName", "User Name","", "a"),
                                       new GridColumn("agentCode", "Agent Code", "", "T"),
                                       new GridColumn("name", "Name", "", "LT"),
                                       new GridColumn("address", "Address", "", "LT"),
                                       new GridColumn("lastLoginTs", "Last Login", "", "T"),
                                       new GridColumn("lastPwdChangedOn", "Password Change", "", "T"),
                                       new GridColumn("lockStatus", "Lock Status", "", "T")
                                   };

            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.ShowAddButton = false;
            _grid.ShowFilterForm = true;
            _grid.GridName = GridName;
            _grid.AlwaysShowFilterForm = true;

            _grid.ShowPagingBar = true;
            _grid.RowIdField = "userId";

            _grid.AllowCustomLink = true;

            var customLinkText = new StringBuilder();
            if (_sl.HasRight(ViewFunctionId))
                customLinkText.Append(
                    "<a href=\"#\" onclick=\"RestoreUser(@userId);\"><img src=\"" + GetStatic.GetUrlRoot() + "/images/refresh.png\" border=0 title=\"Restore user\" alt=\"Restore user\" /></a>");
            _grid.CustomLinkText = customLinkText.ToString();

            _grid.CustomLinkVariables = "userId";
            _grid.InputPerRow = 3;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            _grid.GridMinWidth = 800;

            var sql = "EXEC [proc_applicationUsers] @flag = 's', @isDeleted = 'Y'";

            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (GetMode() == 1)
                GetStatic.AlertMessage(Page);
            else
                GetStatic.PrintMessage(Page);
        }

        protected void btnRestoreUser_Click(object sender, EventArgs e)
        {
            if (!isRefresh)
            {
                var dbResult = _obj.RestoreDeletedUser(GetStatic.GetUser(), hddUserId.Value);
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