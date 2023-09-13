using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.CreditRiskManagement.CreditSecurity
{
    public partial class ListAgent : Page
    {
        private const string GridName = "grdCrSecurity";
        private const string ViewFunctionId = "20181400";
        private const string AddEditFunctionId = "20181410";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        public string GetGridName()
        {
            return GridName;
        }

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
                                      new GridFilter("agentName", "Agent Name", "a"),
                                      new GridFilter("agentState", "Zone",
                                                     "1:EXEC proc_zoneDistrictMap @flag = 'zl_g',@countryId = '151'"),
                                      new GridFilter("agentDistrict", "District",
                                                     "1:EXEC proc_zoneDistrictMap @flag = 'dl'"),
                                      new GridFilter("agentLocation", "Location",
                                                     "1:EXEC proc_zoneDistrictMap @flag = 'll_g'")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("agentName", "Name", "", "T"),
                                      new GridColumn("agentState", "Zone", "", "T"),
                                      new GridColumn("agentDistrict", "District", "", "T"),
                                      new GridColumn("agentLocation", "agentLocation", "", "T")
                                  };

            bool allowAddEdit = sl.HasRight(AddEditFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "agentId";
            grid.ThisPage = "ListAgent.aspx";

            grid.InputPerRow = 4;

            grid.AllowCustomLink = allowAddEdit;
            grid.CustomLinkText =
                "<a href=\"BankGuarantee/List.aspx?agentId=@agentId\">Bank Guarantee</a> | <a href=\"Mortgage/List.aspx?agentId=@agentId\">Mortgage</a> | <a href=\"CashSecurity/List.aspx?agentId=@agentId\">Cash Security</a> | <a href=\"FixedDeposit/List.aspx?agentId=@agentId\">Fixed Deposit</a>&nbsp;";
            grid.CustomLinkVariables = "agentId";
            grid.GridWidth = 800;

            string sql = "[proc_agentCreditSecurity] @flag = 's'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        #endregion method
    }
}