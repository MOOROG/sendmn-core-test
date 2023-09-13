using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.BillVoucher.TreasuryDealBooking.DealingBank
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly RemittanceLibrary remLibrary = new RemittanceLibrary();
        private readonly SwiftGrid grid = new SwiftGrid();
        private const string ViewFunctionId = "20150090";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("BankName", "Bank Name", "T")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                       new GridColumn("rowId",  "Sno.", "", "T"),
                                      new GridColumn("BankName", "Bank Name", "", "T"),
                                      new GridColumn("SellAcNo", "Sell Account Number", "", "T"),
                                      new GridColumn("BuyAcNo", "Buy Account Number", "", "T"),
                                      new GridColumn("CreatedBy", "Created By", "", "T"),
                                      new GridColumn("CreatedDate", "Created Date", "", "D"),
                                  };

            var allowAddEdit = true;
            grid.GridDataSource = SwiftGrid.GridDS.AccountDB;
            grid.GridName = "newBankAdd";
            grid.GridType = 1;

            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New ";
            grid.RowIdField = "rowId";
            grid.AddPage = "Manage.aspx";
            grid.InputPerRow = 4;
            grid.InputLabelOnLeftSide = true;
            //  grid.ApproveFunctionId = true;
            //grid.AllowApprove = true;
            grid.AlwaysShowFilterForm = true;
            grid.AllowEdit = allowAddEdit;
            grid.DisableSorting = true;

            string sql = "proc_DealBankSetting @Flag = 's'";
            grid.SetComma();

            rptGrid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            remLibrary.CheckAuthentication(ViewFunctionId);
        }
    }
}