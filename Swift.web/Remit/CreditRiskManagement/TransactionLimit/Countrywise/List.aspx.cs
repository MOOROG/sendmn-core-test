using System;
using System.Collections.Generic;
using System.Web.UI;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.CreditRiskManagement.TransactionLimit.Countrywise
{
    public partial class List : Page
    {
        private const string GridName = "g_c_w";
        private const string ViewFunctionId = "30011400";
        private const string AddEditFunctionId = "30011400";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //Authenticate();
            }
            LoadGrid();
        }

        #region method

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("countryCode", "Country Code", "T"),
                                      new GridFilter("countryName", "Country Name", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("countryCode", "Country Code", "", "T"),
                                      new GridColumn("countryName", "Country", "", "T"),
                                      new GridColumn("link", "", "", "nosort")
                                  };

            //bool allowAddEdit = sl.HasRight(AddEditFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.InputPerRow = 2;
            grid.RowIdField = "countryName";
            grid.AddPage = "manage.aspx";
            grid.AllowCustomLink = false;
            grid.CustomLinkText =
                "<a href = \"SendingLimit/List.aspx?countryId=@countryName\">Collection Limit</a>&nbsp;|&nbsp;<a href = \"ReceivingLimit/List.aspx?countryId=@countryName\">Payment Limit</a>";
           
            grid.CustomLinkVariables = "countryName";

            string sql = "[proc_countryMaster] @flag = 's2'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        #endregion
    }
}