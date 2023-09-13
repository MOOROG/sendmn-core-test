using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.Administration.CountrySetup
{
    public partial class List : Page
    {
        private const string GridName = "gridCountryCurrDetails";
        private const string ViewFunctionId = "10111200";
        private const string AddEditFunctionId = "10111210";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly CountryDao obj = new CountryDao();
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
                                      new GridFilter("countryCode", "Country Code:", "T"),
                                      new GridFilter("countryName", "Country Name:", "LT"),
                                      new GridFilter("isoAlpha3", "ISO Alpha3:", "LT"),
                                      new GridFilter("isoNumeric", "ISO Numeric:", "LT"),
                                      new GridFilter("isOperativeCountry", "Is Operative:", "2")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("countryCode", "Country Code", "", "T"),
                                      new GridColumn("countryName", "Country", "", "T"),
                                      new GridColumn("isoAlpha3", "ISO Alpha3", "", "T"),
                                      new GridColumn("isoNumeric", "ISO Numeric", "", "T"),
                                      new GridColumn("isOperativeCountryFlag", "Is Operative Country", "", "T"),
                                      new GridColumn("operationType", "Operation Type", "", "T")
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.ShowAddButton = true;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AlwaysShowFilterForm = true;

            grid.RowIdField = "countryId";

            grid.MultiSelect = true;
            grid.AllowEdit = allowAddEdit;
            grid.AllowDelete = false;
            grid.AllowApprove = false;

            grid.InputPerRow = 3;
            grid.AddPage = "manage.aspx?opType=@opType";
            grid.AllowCustomLink = true;
            //var bankIcon = Misc.GetIcon("ba", "OpenBankList(@countryId,'@opType')");
            //grid.CustomLinkText = bankIcon;
            grid.CustomLinkVariables = "countryName,countryId,opType";

            string sql = "[proc_countryMaster] @flag = 's'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
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