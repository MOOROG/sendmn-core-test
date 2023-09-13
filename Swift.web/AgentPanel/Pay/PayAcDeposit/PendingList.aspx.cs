using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.AgentPanel.Pay.PayAcDeposit
{
    public partial class PendingList : System.Web.UI.Page
    {
        public const string GridName = "grdPendingIntl";
        private const string ViewFunctionId = "40131500";
        private const string AddEditFunctionId = "40131510";
        private const string ViewBulkPay = "40131510";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private readonly PayAcDepositDao _obj = new PayAcDepositDao();
        private bool isRefresh;
        private string _tranNosIntl = "";
        private bool hasViewBulkPay = false;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //Authenticate();
                GetStatic.PrintMessage(Page);
            }

            //hasViewBulkPay = _sl.HasRight(ViewBulkPay);
            hasViewBulkPay = true;
            GetStatic.ResizeFrame(Page);
            _tranNosIntl = (Request.Form["hddRowIds"] ?? "").ToString();
            LoadGrid(hasViewBulkPay);
            GetStatic.Process(ref btnPayIntlTxn);
        }

        #region method

        private void LoadGrid(bool viewBulkPay)
        {
            _grid.FilterList = new List<GridFilter>
            {
                new GridFilter("approvedDate", "From Date", "d"),
                new GridFilter("approvedDateTo", "To Date", "d"),
                new GridFilter("controlNo", "Control No", "T")
            };

            _grid.ColumnList = new List<GridColumn>
            {
                new GridColumn("controlNo", "Control No", "", "T"),
                new GridColumn("id", "Tran No", "", "T"),
                new GridColumn("sCountry", "Sending Country", "", "T"),
                new GridColumn("sAgentName", "Sending Agent", "", "T"),
                new GridColumn("pBankName", "Bank Name", "", "T"),
                new GridColumn("pBankBranchName", "Branch Name", "", "T"),
                new GridColumn("ReceiverName", "Receiver Name", "", "T"),
                new GridColumn("accountNo", "Bank A/C No", "", "T"),
                new GridColumn("approvedDate", "DOT", "", "D"),
                new GridColumn("pAmt", "pAmt", "Total Amount", "M"),
                new GridColumn("unpaidDays", "Unpaid Days", "", "T")
            };
            bool allowAddEdit = true;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            //bool allowAddEdit = _sl.HasRight(AddEditFunctionId);
            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.ShowFilterForm = true;
            _grid.AlwaysShowFilterForm = true;
            _grid.EnableFilterCookie = false;
            _grid.ShowPagingBar = true;
            _grid.SortOrder = "desc";
            _grid.RowIdField = "id";
            _grid.InputPerRow = 3;
            _grid.AllowEdit = false;
            _grid.ShowAddButton = false;
            _grid.ShowCheckBox = true;
            if (viewBulkPay)
            {
                _grid.MultiSelect = true;
            }

            _grid.CallBackFunction = "GridManager();";
            string sql = "exec [proc_PayAcDepositAgentV2] @flag = 'pendingList-int', @pAgent = '" + GetStatic.GetAgent() + "'";

            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
            if (_sl.HasRight(ViewBulkPay))
            {
                btnPayIntlTxn.Visible = true;
            }
            else
            {
                btnPayIntlTxn.Visible = true;
            }
        }

        #endregion method

        protected void btnPayIntlTxn_Click(object sender, EventArgs e)
        {
            if (!isRefresh)
            {
                PayAcDepositIntl();
            }
        }

        private void PayAcDepositIntl()
        {
            if (string.IsNullOrEmpty(_tranNosIntl))
            {
                GetStatic.AlertMessage(Page, "Please select international txn to post");
                return;
            }
            var dbResult = _obj.PayAcDepositIntlAgent(GetStatic.GetUser(), _tranNosIntl, GetStatic.GetAgent());
            if (dbResult.ErrorCode == "0")
                GetStatic.AlertMessage(Page, dbResult.Msg);
            LoadGrid(hasViewBulkPay);

            return;
        }

        #region Browser Refresh

        private bool refreshState;

        protected override void LoadViewState(object savedState)
        {
            object[] AllStates = (object[])savedState;
            base.LoadViewState(AllStates[0]);
            refreshState = bool.Parse(AllStates[1].ToString());
            if (Session["ISREFRESH"] != null && Session["ISREFRESH"] != "")
                isRefresh = (refreshState == (bool)Session["ISREFRESH"]);
        }

        protected override object SaveViewState()
        {
            Session["ISREFRESH"] = refreshState;
            object[] AllStates = new object[3];
            AllStates[0] = base.SaveViewState();
            AllStates[1] = !(refreshState);
            return AllStates;
        }

        #endregion Browser Refresh
    }
}