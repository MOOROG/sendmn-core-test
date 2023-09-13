using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.AgentOperation.UserManagement
{
    public partial class ListAgent : System.Web.UI.Page
    {
        private string _gridName;
        private const string ViewFunctionId = "40112500";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
            LoadTab();
            DeleteRow();
            LoadGrid();
        }

        #region QueryString

        protected string GetAgentId()
        {
            return GetStatic.ReadQueryString("agentId", GetStatic.GetAgent());
        }

        protected string GetParentId()
        {
            return GetStatic.ReadQueryString("parentId", GetStatic.GetAgent());
        }

        protected string GetActAsBranchFlag()
        {
            return GetStatic.ReadQueryString("actAsBranch", GetStatic.GetIsActAsBranch());
        }

        protected string GetAgentType()
        {
            return GetStatic.ReadQueryString("agentType", GetStatic.GetAgentType());
        }

        #endregion QueryString

        #region method

        private void LoadTab()
        {
            spnName.InnerHtml = sl.GetAgentBreadCrumb(GetAgentId());
        }

        private void LoadGrid()
        {
            //string ddlSql2 = "EXEC [proc_staticDataValue] @flag = 'l', @typeId = 4300";
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("haschanged", "Change Status", "1:EXEC [proc_agentMaster] @flag = 'hc'"),
                                      new GridFilter("agentCountry", "Country", "LT"),
                                      new GridFilter("agentName", "Name", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("AgentCode", "Code", "", "T"),
                                      new GridColumn("agentName", "Name", "", "T"),
                                      new GridColumn("agentType1", "Type", "", "T"),
                                      new GridColumn("countryName", "Country", "", "T")
                                  };

            grid.GridType = 1;
            grid.GridName = _gridName;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.SortBy = "countryName";
            grid.SortOrder = "ASC";
            grid.DisableSorting = false;
            grid.AddButtonTitleText = "Add New Record";
            grid.RowIdField = "agentId";
            grid.ThisPage = "List.aspx";

            grid.InputPerRow = 2;
            grid.AllowCustomLink = true;
            grid.CustomLinkText =
                "<a href=\"List.aspx?agentId=@agentId\"><img src = \"" + GetStatic.GetUrlRoot() + "/images/user_icon.gif\" border=0 alt = \"Users\" title=\"Users\" /></a>";
            grid.CustomLinkVariables = "agentId,agentType,parentId,agentName";
            grid.GridWidth = 800;

            string sql = "[proc_branchUserSetup] @flag = 'sa'" +
                         ", @parentId = " + grid.FilterString(GetAgentId()) +
                         ", @agentType = " + grid.FilterString(GetAgentType());
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        private void DeleteRow()
        {
            var abf = new AgentDao();
            string id = grid.GetCurrentRowId(_gridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = abf.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        #endregion method

        protected void btnLoadGrid_Click(object sender, EventArgs e)
        {
            LoadGrid();
        }
    }
}