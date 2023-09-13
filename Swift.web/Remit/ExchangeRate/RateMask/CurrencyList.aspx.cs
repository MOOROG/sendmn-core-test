using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.ExchangeRate.RateMask
{
    public partial class CurrencyList : System.Web.UI.Page
    {
        private const string GridName = "gCl";
        private const string ViewFunctionId = "30012000";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        #region method

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("currencyCode", "Currency Code", "T"),
                                      new GridFilter("isoNumeric", "ISO Numeric", "T"),
                                      new GridFilter("currencyName", "Currency Name", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("currencyCode", "Currency Code", "", "T"),
                                      new GridColumn("isoNumeric", "ISO Numeric", "", "T"),
                                      new GridColumn("currencyName", "Currency Name", "", "T")
                                  };
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "currencyId";
            grid.MultiSelect = true;
            grid.AllowDelete = false;
            grid.InputPerRow = 3;
            grid.AllowCustomLink = true;
            grid.CustomLinkVariables = "currencyCode,currencyId";
            grid.CustomLinkText = "<a href = '#' onclick=\"OpenInNewWindow('" + GetStatic.GetUrlRoot() +
                                   "/Remit/ExchangeRate/RateMask/RoundingSetup.aspx?currencyId=@currencyId&currencyCode=@currencyCode')\"><img src=\"" +
                                   GetStatic.GetUrlRoot() +
                                   "/Images/view-detail-icon.png\" border=0 title = \"View Rounding Setup\" /></a>";
            string sql = "[proc_currencyMaster] @flag = 's'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        #endregion method
    }
}