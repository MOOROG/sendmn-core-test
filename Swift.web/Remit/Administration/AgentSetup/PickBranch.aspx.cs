using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Administration.AgentSetup
{
    public partial class PickBranch : System.Web.UI.Page
    {
        private const string GridName = "grid_branchPick";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

        public string GetGridName()
        {
            return GridName;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                swiftLibrary.CheckSession();
            }
            LoadGrid();
        }

        #region method

        private void LoadGrid()
        {
            string ddlSql2 = "EXEC [proc_staticDataValue] @flag = 'l', @typeId = 4300";
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("agentCountry", "Country", "LT"),
                                      new GridFilter("agentGroup", "Agent Group", "1:" + ddlSql2),
                                      new GridFilter("agentLocation", "Location", "1:EXEC proc_apiLocation @flag = 'fl'"),
                                      new GridFilter("parentName", "Agent", "LT"),
                                      new GridFilter("agentName", "Branch", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("parentName", "Agent", "", "T"),
                                      new GridColumn("agentName", "Branch", "", "T"),
                                      new GridColumn("agentType1", "Type", "", "T"),
                                      new GridColumn("countryName", "Country", "", "T"),
                                      new GridColumn("agentGroup", "Agent Group", "", "T")
                                  };

            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "agentId";
            grid.ThisPage = "PickAgent.aspx";
            grid.MultiSelect = false;
            grid.ShowCheckBox = true;

            grid.InputPerRow = 3;

            grid.AddPage = "Manage.aspx";
            grid.GridWidth = 800;

            string sql = "[proc_agentPicker] @flag = 's', @populateBranch = 'Y'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
        }

        private void ManageMessage(string res)
        {
            GetStatic.CallBackJs1(Page, "Call Back", "CallBack('" + res + "');");
        }

        #endregion method

        protected void btnPick_Click(object sender, EventArgs e)
        {
            var obj = new AgentDao();
            string agentId = grid.GetRowId(GridName);
            var res = obj.SelectAgent(agentId);
            ManageMessage(res);
        }
    }
}