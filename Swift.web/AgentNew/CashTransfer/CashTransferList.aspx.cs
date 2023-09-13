using Swift.DAL.Remittance.CashAndVault;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.AgentNew.CashTransfer
{
    public partial class CashTransferList : System.Web.UI.Page
    {
        protected const string GridName = "requestCashTransfer";
        private string ViewFunctionId = "20210000";

        //private const string ApproveFunctionId = "20198010";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

        private readonly SwiftGrid _grid = new SwiftGrid();
        private CashAndVaultDao cavDao = new CashAndVaultDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
            }
            LoadGrid();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
            {
            };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),
                                      //new GridColumn("userId", "User Id", "", "T"),
                                      new GridColumn("TransferredAmount", "Transferred Amount", "", "M"),
                                      new GridColumn("fromAcc", "From Account", "", "T"),
                                      new GridColumn("toAcc", "To Account", "", "T"),
                                      new GridColumn("mode", "Transfer Mode", "", "T"),
                                      new GridColumn("TransferredDate", "Transferred Date", "", "D"),
                                      new GridColumn("isApproved", "Approved Status", "", "T"),
                                  };
            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = false;
            //_grid.AllowApprove = _sl.HasRight(ApproveFunctionId);
            //_grid.ApproveFunctionId = ApproveFunctionId;
            _grid.AlwaysShowFilterForm = false;
            _grid.ShowFilterForm = false;
            _grid.RowIdField = "rowId";
            _grid.ThisPage = "CashTransferList.aspx";
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;

            string sql = "EXEC PROC_VAULTTRANSFER @flag = 'sRequestedVaultT', @branchId=" + _sl.FilterString(GetStatic.GetBranch()) + ",@userId=" + _sl.FilterString(GetUserId());
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        protected string GetUserId()
        {
            var userIdAndAgentId = cavDao.GetUserIdAndBranchList(GetStatic.GetUser());
            string a = userIdAndAgentId["userId"].ToString();
            return a;
        }
    }
}