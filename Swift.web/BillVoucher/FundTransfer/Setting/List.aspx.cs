using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.BillVoucher.FundTransfer.Setting
{
    public partial class List : System.Web.UI.Page
    {
        private readonly RemittanceLibrary remLibrary = new RemittanceLibrary();
        private readonly SwiftGrid grid = new SwiftGrid();
        private const string ViewFuntionId = "20153000";

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
                                      new GridColumn("transferType", "Transfer Type", "", "T"),
                                      new GridColumn("nameOfPartner", "Name Of Partner", "", "T"),
                                      new GridColumn("receiveUSDNostro", "Nostro Account", "", "T"),
                                      new GridColumn("receiveUSDCorrespondent", "Correspondent Account", "", "T"),
                                      new GridColumn("CreatedBy", "Created By", "", "T"),
                                      new GridColumn("CreatedDate", "Creaed Date", "", "D"),
                                  };

            var allowAddEdit = true;
            grid.GridDataSource = SwiftGrid.GridDS.AccountDB;
            grid.GridName = "Add";
            grid.GridType = 1;

            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New ";
            grid.RowIdField = "rowId";
            grid.AddPage = "Manage.aspx";
            grid.InputPerRow = 4;
            grid.InputLabelOnLeftSide = true;
            grid.AlwaysShowFilterForm = true;
            grid.AllowEdit = allowAddEdit;
            grid.DisableSorting = true;

            string sql = "proc_PayoutAgentAccount @Flag = 's'";
            grid.SetComma();

            rptGrid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            remLibrary.CheckAuthentication(ViewFuntionId);
        }
    }
}