using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.Administration.CurrencySetup
{
    public partial class List : Page
    {
        private const string GridName = "gridCurrency";
        private const string ViewFunctionId = "10111500";
        private const string AddEditFunctionId = "10111510";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            DeleteRow();
            LoadGrid();
        }

        #region method

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("currencyCode", "Currency Code:", "T"),
                                      new GridFilter("isoNumeric", "ISO Numeric:", "T"),
                                      new GridFilter("currencyName", "Currency Name:", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("currencyCode", "Currency Code", "", "T"),
                                      new GridColumn("isoNumeric", "ISO Numeric", "", "T"),
                                      new GridColumn("currencyName", "Currency Name", "", "T")
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.ShowAddButton = true;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;

            grid.RowIdField = "currencyId";

            grid.MultiSelect = true;
            grid.AllowEdit = allowAddEdit;
            grid.AllowDelete = false;

            grid.AddPage = "Manage.aspx?currencyCode=@currencyCode";
            grid.CustomLinkVariables = "currencyCode";
            string sql = "[proc_currencyMaster] @flag = 's'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            var obj = new CurrencyDao();
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        #endregion method
    }
}