using Swift.DAL.Remittance.APIPartner;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Transaction.PromotionalCampaign
{
    public partial class List : System.Web.UI.Page
    {
        protected const string GridName = "gridAgentRating";
        private string ViewFunctionId = "20320000";
        private string AddEditFunctionId = "20320010";
        private string ApproveFunctionId = "20320020";

        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            string ddlSql1 = "EXEC [PROC_API_ROUTE_PARTNERS] @flag = 'payout-list'";
            string ddlSql2 = "EXEC [PROC_API_ROUTE_PARTNERS] @flag = 'country-list'";

            _grid.FilterList = new List<GridFilter>
                                  {
                                     new GridFilter("COUNTRY_ID","Country","1:" + ddlSql2, "0"),
                                     new GridFilter("PAYMENT_METHOD", "Payment Method", "1:"+ddlSql1, "0")
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("COUNTRYNAME", "COUNTRY", "", "T"),
                                      new GridColumn("PAYOUT_METHOD", "Payout Method", "", "T"),
                                      new GridColumn("PROMOTION_TYPE", "PROMOTION TYPE", "", "T"),
                                      new GridColumn("PROMOTIONAL_CODE", "PROMOTIONAL CODE", "", "T"),
                                      new GridColumn("PROMOTIONAL_MSG", "PROMOTIONAL MSG", "", "T"),
                                      new GridColumn("PROMOTION_VALUE", "PROMOTION VALUE", "", "M"),
                                      new GridColumn("START_DT", "START DATE", "", "D"),
                                      new GridColumn("END_DT", "END DATE", "", "D"),
                                      new GridColumn("IS_ACTIVE", "Is Active", "", "T"),
                                  };

            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.ShowAddButton = true;
            _grid.AllowEdit = true;
            _grid.AllowDelete = false;
            _grid.AddPage = "Manage.aspx";
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.AllowCustomLink = false;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "ROW_ID";
            _grid.ThisPage = "List.aspx";
            _grid.AllowApprove = true;
            _grid.ApproveFunctionId = ApproveFunctionId;

            //var link = "&nbsp;<a href=\"javascript:void(0);\" onclick=\"EnableDisable('@id','@agentName','@countryName','@IS_ACTIVE');\" class=\"btn btn-xs btn-primary\">Enable/Disable</a>";

            //_grid.CustomLinkVariables = "id,agentName,countryName,IS_ACTIVE";
            //_grid.CustomLinkText = link;
            _grid.InputPerRow = 5;

            string sql = "EXEC [PROC_PROMOTIONAL_CAMPAIGN] @flag = 'S'";

            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            APIPartnerDao _dao = new APIPartnerDao();
            if (!string.IsNullOrEmpty(isActive.Value))
            {
                var dbResult = _dao.EnableDisablePromotion(rowId.Value, GetStatic.GetUser(), isActive.Value);
                GetStatic.SetMessage(dbResult);
                Response.Redirect("List.aspx");
            }
        }
    }
}