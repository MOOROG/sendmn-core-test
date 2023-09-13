using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.Reports.JpDepositList
{
    public partial class List : System.Web.UI.Page
    {
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private const string ViewFunctionIdAgent = "20315000";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            LoadGrid();
        }
        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionIdAgent);
        }
        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
            {
                new GridFilter("particulars", "Particulars", "T"),
                new GridFilter("trandate", "Transaction Date", "D"),
                new GridFilter("depositAmount", "Amount", "T")
            };



            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("tranDate", "Date", "", "D"),
                                      new GridColumn("depositAmount", "Deposit", "", "T"),
                                      new GridColumn("paymentAmount", "Payment", "", "T"),
                                      new GridColumn("particulars", "Particulars", "", "T"),
                                      new GridColumn("closingBalance", "Closing", "", "T"),
                                      new GridColumn("bank", "Bank", "", "T"),
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.ShowPagingBar = true;
            _grid.AllowEdit = false;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "tranid";
            _grid.ThisPage = "List.aspx";
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            _grid.CustomLinkVariables = "tranid";
            string sql = "EXEC [proc_DailyTxnRpt] @flag = 'depositList'";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
    }

}