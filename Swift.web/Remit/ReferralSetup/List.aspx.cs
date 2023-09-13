using Swift.DAL.Remittance.APIPartner;
using Swift.DAL.Remittance.ReferralSetup;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.ReferralSetup
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "referralGrid_list";
        private string ViewFunctionId = "20201700";
        private string AddEditFunctionId = "20201710";
        private string DeleteFunctionId = "20201720";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly ReferralSetupDao _refDao = new ReferralSetupDao();

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

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {

            _grid.FilterList = new List<GridFilter>
                                  {
                                     new GridFilter("branchId", "Branch", "1: EXEC PROC_REFERALSETUP @flag = 'branchNameForFilter'"),
                                     new GridFilter("referralTypeCode", "Referral Type", "1: EXEC PROC_REFERALSETUP @flag = 'referalType'"),
                                     new GridFilter("referralName", "Referral Name", "T"),
                                     new GridFilter("referralCode", "Referral code", "T")
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("REFERRAL_CODE", "Referral Code", "", "T"),
                                      new GridColumn("REFERRAL_NAME", "Referral Name", "100", "T"),
                                      new GridColumn("BranchName", "Branch Name", "100", "T"),
                                      new GridColumn("REFERRAL_MOBILE", "Mobile No.", "100", "T"),
                                      new GridColumn("REFERRAL_ADDRESS", "Address ", "100", "T"),
                                      new GridColumn("RULE_TYPE", "Rule Type", "", "T"),
                                      new GridColumn("REFERRAL_LIMIT", "Cash Hold Limit", "", "T"),
                                      new GridColumn("IS_ACTIVE", "Is Active", "", "T"),
                                  };

            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.ShowAddButton = true;
            _grid.AllowEdit = _sl.HasRight(AddEditFunctionId);
            _grid.AllowDelete = false;
            _grid.AddPage = "Manage.aspx";
            _grid.AllowDelete = _sl.HasRight(DeleteFunctionId);
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.AllowCustomLink = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "row_id";
            _grid.ThisPage = "List.aspx";
            var link = "&nbsp;<a title=\"View Commission Rule\" onclick=\"CommissionRuleSetup('@REFERRAL_CODE')\" class=\"btn btn-xs btn-primary\"><i class=\"fa fa-align-justify\"></i></a>";

            _grid.CustomLinkVariables = "REFERRAL_CODE";
            _grid.CustomLinkText = link;
            _grid.InputPerRow = 5;

            string sql = "EXEC [PROC_REFERALSETUP] @flag = 'S'";

            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string rowId = _grid.GetCurrentRowId(GridName);
            if (rowId == "")
                return;
            var user = GetStatic.GetUser();

            DbResult dbResult = _refDao.Delete(GetStatic.GetUser(), rowId);
            GetStatic.SetMessage(dbResult);
            Response.Redirect("List.aspx");
        }
    }
}