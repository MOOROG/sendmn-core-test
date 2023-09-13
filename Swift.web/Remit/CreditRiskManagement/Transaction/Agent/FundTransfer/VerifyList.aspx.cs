using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Transaction.Agent.FundTransfer
{
    public partial class VerifyList : System.Web.UI.Page
    {
        private const string GridName = "grdfundtransferadmin";
        private const string ViewFunctionId = "20181900";
        private const string ApproveFunctionId = "20181910";
        private const string VerifyFunctionId = "20181920";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly AgentFundDepositDao _obj = new AgentFundDepositDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        private void LoadGrid()
        {
            var ddlSql = "EXEC proc_fundDeposit @flag='ddlStatus'";
            _grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("agentId", "Agent Name", "T"),
                                      new GridFilter("fromDate", "From Date","D"),
                                      new GridFilter("toDate", "To Date","D"),
                                      new GridFilter("amount", "Amount","T"),
                                      new GridFilter("status", "Status", "1:" + ddlSql)
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("Agent", "Agent", "", "T"),
                                      new GridColumn("Date", "Date", "", "T"),
                                      new GridColumn("Bank", "Bank", "", "T"),
                                      new GridColumn("Amount", "Amount", "", "T"),
                                      new GridColumn("Status", "Status", "", "T"),
                                      new GridColumn("Remarks", "Remarks", "", "T"),
                                  };
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.GridWidth = 800;
            _grid.ShowFilterForm = true;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.RowIdField = "rowId";
            _grid.InputPerRow = 4;
            _grid.AllowCustomLink = true;
            _grid.CustomLinkVariables = "rowId,Status";
            _grid.CustomLinkText = "<input type='button' onclick=\"Open('view.aspx?id=@rowId&st=@Status');\" value='View'/>";
            string sql = "EXEC proc_fundDeposit @flag='vl'";
            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}