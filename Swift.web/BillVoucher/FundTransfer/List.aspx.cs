using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Reflection;

namespace Swift.web.Remit.BankFundTreasury
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20153000";
        private readonly SwiftLibrary _sdd = new SwiftLibrary();
        public SwiftGrid grid = new SwiftGrid();
        private string GridName = "FundTransferGrid";

        protected void Page_Load(object sender, EventArgs e)
        {
            _sdd.CheckSession();
            if (!IsPostBack)
            {
                populateDdl();
            }
            populateList();
        }

        protected void search_Click(object sender, EventArgs e)
        {
            populateList("reset");
        }

        private void populateDdl()
        {
            _sdd.SetDDL(ref ddlbankId, "EXEC proc_dropDownList @FLAG='BankList'", "RowId", "BankName", "", "Select Bank");
        }

        private void populateList(string type = "")
        {
            LoadGrid(type);
        }

        private void LoadGrid(string type = "")
        {
            if (type.Equals("reset"))
            {
                //var scriptName = "ResetPageNumber";
                //var functionName = "ResetPageNumber('" + GridName + "');";
                //GetStatic.CallBackJs1(Page, scriptName, functionName);
                Request.Form.GetType().BaseType.BaseType.GetField("_readOnly", BindingFlags.NonPublic | BindingFlags.Instance)
                    .SetValue(Request.Form, false);
                Request.Form[GridName + "_pageNumber"] = "1";
            }
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("RowId", "Row ID", "", "T"),
                                      new GridColumn("BankName", "Bank Name", "", "T"),
                                      new GridColumn("UsdAmt", "USD Amount", "", "M"),
                                      new GridColumn("Rate", "Rate", "", "T"),
                                      new GridColumn("LcyAmt", GetStatic.ReadWebConfig("currencyMN","") +" Amount", "", "M"),
                                      new GridColumn("RemainingAmt", "Remaining USD", "", "M"),
                                      new GridColumn("DealDate",  "Fund Deal Date", "", "D")
                                  };

            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.AccountDB;
            grid.GridType = 1;
            grid.ShowPagingBar = true;
            grid.RowIdField = "RowId";
            string sql = "[proc_DealStockSummary] @Flag='dealSummary',@bankId=" + grid.FilterString(ddlbankId.SelectedValue);
            grid.SetComma();

            rptGrid.InnerHtml = grid.CreateGrid(sql);
        }
    }
}