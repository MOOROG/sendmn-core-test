using Swift.DAL.BL.SwiftSystem;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.SwiftSystem.UserManagement.AdminUserSetup
{
    public partial class UserAgentMapping : System.Web.UI.Page
    {
        private const string GridName = "grd_user_agent";
        private const string ViewFunctionId = "10101300";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly UserGroupMappingDao _obj = new UserGroupMappingDao();
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
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("id");
        }
        protected long GetUserId()
        {
            return GetStatic.ReadNumericDataFromQueryString("userId");
        }
        protected string GetUserName()
        {
            return GetStatic.ReadQueryString("userName", "");
        }
        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
                Response.Redirect("UserAgentMapping.aspx?userId=" + GetUserId() + "&userName=" + GetUserName());
            else
                GetStatic.AlertMessage(Page);
        }
        private void Update()
        {
            DbResult dbResult = _obj.UpdateUserAgent(GetStatic.GetUser(), GetId().ToString(), sendAgent.Value, GetUserName());
            ManageMessage(dbResult);
        }
        private void DeleteRow()
        {
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = _obj.DeleteUserAgent(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }
        private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("userFullName", "User Full Name", "", "T"),
                                      new GridColumn("userName", "UserName", "", "T"),
                                      new GridColumn("agentName", "Agent Name", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate", "Created Date", "", "T")
                                  };

            grid.GridName = GridName;
            grid.GridType = 1;
            grid.DisableJsFilter = true;
            grid.DisableSorting = true;
            grid.ShowAddButton = true;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New";
            grid.RowIdField = "id";
            grid.AddPage = "UserAgentMapping.aspx?userId=" + GetUserId() + "&userName=" + GetUserName();
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.AllowEdit = false;
            grid.AllowDelete = true;
            grid.GridWidth = 1020;
            string sql = "EXEC proc_userAgentMapping @flag = 's', @userName = " + GetUserName();
            grid.SetComma();
            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }
        protected void bntSubmit_Click(object sender, EventArgs e)
        {
            Update();
        }
    }
}