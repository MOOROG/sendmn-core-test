using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.CreditRiskManagement.TransactionLimit.Agentwise
{
    public partial class List : Page
    {
        private const string GridName = "gridAgentWise";
        private const string ViewFunctionId = "20181100";
        private const string AddEditFunctionId = "20181110";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
            LoadGrid();
        }

        #region method

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("agentName", "Agent Name", "a"),
                                      new GridFilter("agentCountry", "Country",
                                                     "LT"),
                                      //new GridFilter("agentGrp", "Agent Group",
                                      //               "1:EXEC [proc_staticDataValue] @flag = 'l', @typeId = 4300")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("agentName", "Agent Name", "", "T"),
                                      new GridColumn("countryName", "Country", "", "T"),
                                      new GridColumn("link", "", "", "nosort")
                                  };

            bool allowAddEdit = sl.HasRight(AddEditFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AlwaysShowFilterForm = true;
            grid.LoadGridOnFilterOnly = true;

            grid.RowIdField = "agentId";
            grid.AddPage = "Manage.aspx";
            grid.InputPerRow = 3;
            grid.AllowCustomLink = false;
            grid.CustomLinkText =
                "<a href = \"SendingLimit/List.aspx?agentId=@agentId\">Sending Limit</a>&nbsp;|&nbsp;<a href = \"ReceivingLimit/List.aspx?agentId=@agentId\">Payment Limit</a>";
            grid.CustomLinkVariables = "agentId";

            string sql = "[proc_agentMaster] @flag = 's2'"; //[proc_agentMaster] @flag = 's', @isSettlingAgent = 'Y'";
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

        #endregion method
    }
}