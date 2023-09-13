using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.UserApprovalLimit
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "grid_userLimit";
        private const string ViewFunctionId = "10101160";
        private const string AddEditFunctionId = "10101110";
        private const string DeleteFunctionId = "10101120";
        private const string ApproveFunctionId = "10101130";
        private const string ApproveFunctionId2 = "10101130";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private UserLimitDao obj = new UserLimitDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.SetActiveMenu(ViewFunctionId);
                if(GetMode() == "1")
                    GetStatic.AlertMessage(Page);
                else
                    GetStatic.PrintMessage(Page);
            }
            DeleteRow();
            LoadGrid();
        }

        #region QueryString
        protected string GetUserName()
        {
            return GetStatic.ReadQueryString("userName", "");
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        protected long GetUserId()
        {
            return GetStatic.ReadNumericDataFromQueryString("userId");
        }
        protected string GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode").ToString();
        }
        #endregion

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("currencyCode", "Currency", "", "T"),
                                      new GridColumn("userName", "User Name", "", "T"),
                                      new GridColumn("sendLimit", "Send Limit", "", "M"),
                                      new GridColumn("payLimit", "Pay Limit", "", "M")
                                  };

            bool allowAddEdit = sl.HasRight(AddEditFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New Record";
            grid.RowIdField = "userLimitId";
            grid.AllowEdit = allowAddEdit;
            grid.AllowDelete = sl.HasRight(DeleteFunctionId);
            grid.AllowApprove = sl.HasRight(ApproveFunctionId);
            grid.ApproveFunctionId = ApproveFunctionId;
            grid.ApproveFunctionId2 = ApproveFunctionId2;
            grid.AddPage = "Manage.aspx?userId=" + GetUserId() + "&userName=" + GetUserName() + "&agentId=" + GetAgentId() + "&mode=" + GetMode();

            string sql = "EXEC proc_agentUserLimit @flag = 's', @userId = " + GetUserId();
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
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
           
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }
    }
}