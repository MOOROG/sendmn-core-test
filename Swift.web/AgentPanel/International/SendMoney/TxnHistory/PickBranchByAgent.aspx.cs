using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.AgentPanel.International.SendMoney.TxnHistory
{
    public partial class PickBranchByAgent : System.Web.UI.Page
    {
        private const string GridName = "gridPickBranchByAgent";
        private const string ViewFunctionId = "10122600";
        private const string AddEditFunctionId = "10122610";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadGrid();
                return;
            }
            LoadGrid();
        }

        public string GetAgentId()
        {
            return GetStatic.ReadQueryString("pAgent", "");
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                   {
                                      new GridFilter("branchName", "Branch Name", "LT"),
                                      new GridFilter("agentAddress", "Branch Address", "LT")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("branchName", "Branch Name", "", "T"),
                                       new GridColumn("agentCountry", "Branch Country Name", "", "T"),
                                       new GridColumn("agentAddress", "Branch Address", "", "T"),
                                       new GridColumn("agentPhone1", "Branch Phone Number", "", "T"),
                                   };

            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.ShowCheckBox = true;
            _grid.GridType = 1;
            _grid.InputPerRow = 4;
            _grid.GridName = GridName;
            _grid.ShowFilterForm = true;
            _grid.EnableFilterCookie = false;
            _grid.ShowPagingBar = true;
            _grid.RowIdField = "agentId";
            _grid.AlwaysShowFilterForm = true;
            _grid.ThisPage = "PickBranchByAgent.aspx";
            _grid.SetComma();
            _grid.InputLabelOnLeftSide = true;

            string sql = "exec [Proc_AgentBankMapping] @flag = 'pickBranchById',@agentId=" + GetAgentId();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
    }
}