using Swift.DAL.Remittance.APIPartner;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.APIPartners
{
    public partial class RouteApiPartners : System.Web.UI.Page
    {
        protected const string GridName = "gridAgentRating";
        private string ViewFunctionId = "20177300";
        private string AddEditFunctionId = "20191210";
        private string ApproveFunctionId = "20177300";

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
            string ddlSql = "EXEC [PROC_API_ROUTE_PARTNERS] @flag = 'agent-list'";
            string ddlSql1 = "EXEC [PROC_API_ROUTE_PARTNERS] @flag = 'payout-list'";
            string ddlSql2 = "EXEC [PROC_API_ROUTE_PARTNERS] @flag = 'country-list'";

            _grid.FilterList = new List<GridFilter>
                                  {
                                     new GridFilter("agentId", "Partner", "1:"+ddlSql, "0"),
                                     new GridFilter("PaymentMethod", "Payment Method", "1:"+ddlSql1, "0"),
                                     new GridFilter("CountryId","Country","1:" + ddlSql2, "0")
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("agentName", "Partner", "", "T"),
                                      new GridColumn("countryName", "Country", "100", "T"),
                                      new GridColumn("PAYOUT_METHOD", "Payout Method", "100", "T"),
                                      new GridColumn("IS_ACTIVE", "Is Active", "", "T"),
                                      new GridColumn("isRealTime", "Is RealTime", "", "T"),

                                         new GridColumn("minTxnLimit", "minTxnLimit", "100", "M"),
                                      new GridColumn("maxTxnLimit", "maxTxnLimit", "100", "M"),
                                      new GridColumn("LimitCurrency", "LimitCurrency", "", "T"),
                                      new GridColumn("exRateCalByPartner", "exRateCalByPartner", "", "T"),
                                      new GridColumn("isACValidateSupport", "isACValidateSupport", "", "T")
                                  };

            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.ShowAddButton = true;
            _grid.AllowEdit = true;
            _grid.AllowDelete = false;
            _grid.AddPage = "AddApiPartner.aspx";
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.AllowCustomLink = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "id";
            _grid.ThisPage = "RouteApiPartners.aspx";
            _grid.AllowApprove = true;
            _grid.ApproveFunctionId = ApproveFunctionId;

            var link = "&nbsp;<a href=\"javascript:void(0);\" onclick=\"EnableDisable('@id','@agentName','@countryName','@IS_ACTIVE');\" class=\"btn btn-xs btn-primary\">Enable/Disable</a>";

            _grid.CustomLinkVariables = "id,agentName,countryName,IS_ACTIVE";
            _grid.CustomLinkText = link;
            _grid.InputPerRow = 5;

            string sql = "EXEC [PROC_API_ROUTE_PARTNERS] @flag = 'S'";

            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            APIPartnerDao _dao = new APIPartnerDao();
            if (!string.IsNullOrEmpty(isActive.Value))
            {
                var dbResult = _dao.EnableDisable(rowId.Value, GetStatic.GetUser(), isActive.Value);
                GetStatic.SetMessage(dbResult);
                Response.Redirect("RouteApiPartners.aspx");
            }
        }
    }
}