using System;
using System.Collections.Generic;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.Commission.AgentCommissionRule
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "grdAcr";
        private const string ViewFunctionId = "20131500";
        private const string AddEditFunctionId = "20131510";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
            LoadGrid();
        }

        #region method

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("agentName", "Agent Name", "a"),
                                      new GridFilter("agentCountry", "Country","LT"),
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("agentName", "Agent Name", "", "T"),
                                      new GridColumn("agentCountry", "Country", "", "T")
                                  };

            bool allowAddEdit = sl.HasRight(AddEditFunctionId);
            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AlwaysShowFilterForm = true;
            grid.RowIdField = "agentId";
            grid.AddPage = "Manage.aspx";
            grid.InputPerRow = 3;
            grid.AllowCustomLink = allowAddEdit;
            grid.CustomLinkText =
                "<a href = \"AgentCommission.aspx?agentId=@agentId\">Agent Commission</a>";
            grid.CustomLinkVariables = "agentId";

            string sql = "[proc_agentCommissionRule] @flag = 's', @isSettlingAgent = 'Y',@agentId="+sl.FilterString(GetStatic.ReadWebConfig("IntlSuperAgentId",""));
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        #endregion
    }
}