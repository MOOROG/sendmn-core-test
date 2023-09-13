using Swift.API.Common;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.Compliance.PartnerSyncList
{
    public partial class PartnerSyncList : Page
    {
        private const string GridName = "grid_list";
        private const string ViewFunctionId = "20700000";
        private const string ViewFunctionIdAgent = "20700010";
        private const string SyncFunctionId = "20700000";
        private const string SyncFunctionIdAgent = "20700010";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private ApproveTransactionDao at = new ApproveTransactionDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
            }
            LoadGrid();
            syncBtn.Visible = swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(SyncFunctionIdAgent, SyncFunctionId));
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>()
            {
                new GridFilter("partnerName","Partner Name","T"),
                new GridFilter("controlNo","Control No","T"),
                new GridFilter("date","Date","d"),
                //new GridFilter("sFullName","Sender Name","T"),
                //new GridFilter("rFullName","Receiver Name","T"),
            };
            _grid.ColumnList = new List<GridColumn>
            {
                new GridColumn("partnerName","Partner Name","","T"),
                new GridColumn("controlNo","Control No","","T"),
                new GridColumn("date","Date","","d"),
                new GridColumn("sBranchName","Branch Name","","T"),
                new GridColumn("pAmt","Payout Amount","","T"),
                new GridColumn("sFullName","Sender Name","","T"),
                new GridColumn("rFullName","Receiver Name","","T"),
            };
            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.ShowCheckBox = true;
            _grid.MultiSelect = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "id";
            _grid.ThisPage = "List.aspx";
            _grid.InputPerRow = 3;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            _grid.AllowCustomLink = swiftLibrary.HasRight(GetFunctionIdByUserType(SyncFunctionIdAgent, SyncFunctionId));
            _grid.CustomLinkVariables = "id";
            _grid.CustomLinkText = "<a onclick=\"syncClick('@id')\" class=\"btn btn-xs btn-success\" title=\"Sync\"><i class=\"fa fa-refresh\" aria-hidden=\"true\"></i></a>";
            string sql = "EXEC [proc_GetAllTxnForPartnerSync] @flag = 's' ";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin)
        {
            return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
        }

        protected void syncBtn_Click(object sender, EventArgs e)
        {
            string selectedIds = Request.Form["grid_list_rowId"];
            if (selectedIds == null)
            {
                GetStatic.AlertMessage(this, "Please Choose At Least One Record");
                return;
            }
            int success = 0;
            foreach (var tranId in selectedIds.Split(','))
            {
                var result = syncTxnSingleId(tranId);
                if (result.ResponseCode == "0")
                    success++;
            }
            GetStatic.AlertMessage(this, String.Format("Total {0} Transaction Sync Successfully !", success));
        }

        private JsonResponse syncTxnSingleId(string tranId)
        {
            var result = at.GetHoldedTxnForApprovedByAdmin(GetStatic.GetUser(), tranId, GetStatic.GetSessionId(), "txnHoldRelease");
            return result;
        }

        protected void hdnsyncBtn_Click(object sender, EventArgs e)
        {
            string tranId = hdnTranId.Value;
            var result = syncTxnSingleId(tranId);
            GetStatic.AlertMessage(Page, result.Msg);
        }
    }
}