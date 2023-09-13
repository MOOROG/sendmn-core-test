using System;
using System.Collections.Generic;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.UserLockDetail
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "grid_userLock";
        private const string ViewFunctionId = "10101100";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

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
                                      new GridColumn("userName", "User Name", "", "T"),
                                      new GridColumn("agentName", "Agent Name", "", "T"),
                                      new GridColumn("startDate", "From Date", "", "D"),
                                      new GridColumn("endDate", "To Date", "", "D"),
                                      new GridColumn("lockDesc", "Remarks", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate", "Created Date", "", "D")
                                  };

            bool allowAddEdit = true;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New Record";
            grid.RowIdField = "userLockId";
            grid.AllowEdit = allowAddEdit;
            grid.AllowDelete = true;
            grid.AddPage = "Manage.aspx?userId=" + GetUserId() + "&userName=" + GetUserName() + "&agentId=" + GetAgentId() + "&mode=" + GetMode();

            string sql = "EXEC proc_userLockDetail @flag = 's', @userId = " + GetUserId();
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            //string id = grid.GetCurrentRowId(GridName);
            //if (string.IsNullOrEmpty(id))
            //    return;
            //DbResult dbResult = obj.DeleteLock(GetStatic.GetUser(), id);
            //ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }
    }
}