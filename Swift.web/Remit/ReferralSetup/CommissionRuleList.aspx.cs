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
    public partial class CommissionRuleList : System.Web.UI.Page
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
            GetStatic.PrintMessage(this.Page);
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
                                     //new GridFilter("branchId", "Branch", "1: EXEC PROC_REFERALSETUP @flag = 'branchNameForFilter'"),
                                     //new GridFilter("referralTypeCode", "Referral Type", "1: EXEC PROC_REFERALSETUP @flag = 'referalType'"),
                                     //new GridFilter("referralName", "Referral Name", "T"),
                                     //new GridFilter("referralCode", "Referral code", "T")
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("REFERRAL_NAME", "Referral Name", "100", "T"),
                                      new GridColumn("agentName", "Branch Name", "100", "T"),
                                      new GridColumn("COMM_PCNT", "Commission Percent", "100", "M"),
                                      new GridColumn("FX_PCNT", "Forex Income/Loss Percent", "", "M"),
                                      new GridColumn("FLAT_TXN_WISE", "Flat transaction Wise", "", "M"),
                                      new GridColumn("NEW_CUSTOMER", "New Customer", "", "M"),
                                      new GridColumn("DEDUCT_P_COMM_ON_SC", "Deduct PComm On SC", "", "T"),
                                      new GridColumn("DEDUCT_TAX_ON_SC", "Deduct Tax On SC", "", "T"),
                                      new GridColumn("EFFECTIVE_FROM", "Effective From", "", "D"),
                                      new GridColumn("IS_ACTIVE", "Is Active", "", "T"),
                                  };

            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.ShowAddButton = true;
            _grid.AllowEdit = false;
            _grid.AllowDelete = false;
            _grid.AddPage = "CommisionRuleSetup.aspx?referralCode=" + GetReferralCode(); 
            _grid.AllowDelete = false;
            _grid.AlwaysShowFilterForm = false;
            _grid.ShowFilterForm = false;
            _grid.AllowCustomLink = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "referral_id";
            _grid.ThisPage = "CommmissionRuleList.aspx";
            _grid.InputPerRow = 5;
            string sql = "EXEC [PROC_REFERALSETUP] @flag = 'S-commList',@referral_code = "+ GetReferralCode() + "";
            var link = "&nbsp;<a title=\"Edit\" onclick=\"CommissionRuleSetup('@referral_id','@REFERRAL_CODE','@AGENTID', '@ROW_ID')\" class=\"btn btn-xs btn-primary\"><i class=\"fa fa-edit\"></i></a>";
            _grid.CustomLinkText = link;
            _grid.CustomLinkVariables = "referral_id,REFERRAL_CODE,AGENTID,ROW_ID";
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
        private  string GetReferralCode()
        {
            return GetStatic.ReadQueryString("referralCode", "");
        }
    }
}