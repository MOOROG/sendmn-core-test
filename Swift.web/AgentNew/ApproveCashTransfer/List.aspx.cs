using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.AgentNew.ApproveCashTransfer
{
    public partial class List : System.Web.UI.Page
    {
        protected const string GridName = "ApproveVaultTransfer";
        private string ViewFunctionId = "20220000";
        private const string ApproveFunctionId = "20220010";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly SwiftGrid _grid = new SwiftGrid();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                //Authenticate();
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
            _grid.AllowApprove = _sl.HasRight(ApproveFunctionId);
            _grid.ApproveFunctionId = ApproveFunctionId;
            _grid.AlwaysShowFilterForm = false;
            _grid.ShowFilterForm = false;
            _grid.RowIdField = "rowId";
            _grid.ThisPage = "ApproveTransferToVaultList.aspx";
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;

            string sql = "EXEC PROC_VAULTTRANSFER @flag = 's-from-vault', @branchId=" + _sl.FilterString(GetStatic.GetBranch());
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        protected string GetUserId()
        {
            return GetStatic.ReadQueryString("userId", "");
        }
    }
}