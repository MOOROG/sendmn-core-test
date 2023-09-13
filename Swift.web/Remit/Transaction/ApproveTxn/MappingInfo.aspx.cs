using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Transaction.ApproveTxn
{
    public partial class MappingInfo : System.Web.UI.Page
    {
        private const string GridName = "grid_Beneficiarylist";

        private ApproveTransactionDao at = new ApproveTransactionDao();
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadGrid();
            GetAvailableBalance();
        }

        private void GetAvailableBalance()
        {
            string amount = at.GetAvailableBalance(GetStatic.GetUser(), getTranId());

            lblAvailableBalance.InnerText = "Available Balance: " + GetStatic.ShowDecimal(amount);
        }

        private void LoadGrid()
        {
            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),
                                      new GridColumn("fullName", "Customer Name", "", "T"),
                                      new GridColumn("particulars", "particulars", "", "T"),
                                      new GridColumn("depositAmount", "depositAmount", "", "M"),
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = false;
            _grid.AllowEdit = false;
            _grid.AlwaysShowFilterForm = false;
            _grid.ShowFilterForm = false;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "customerId";
            _grid.ThisPage = "MappingInfo.aspx";
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            _grid.AllowCustomLink = true;
            var approveLink = "&nbsp;<input type = 'button' class='btn btn-primary m-t-25' onclick = \"Approve(@customerId,@tranId,'"+ getTranId()+ "');\" value = 'Approve' />";
            approveLink += "&nbsp;<input type = 'button' class='btn btn-primary m-t-25' onclick = \"Reject(@customerId,@tranId);\" value = 'Reject' />";

            //var editLink = swiftLibrary.HasRight(EditFunctionId) ? "<span class=\"action-icon\"> <btn type=\"button\" class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Edit\"> <a href =\"Manage.aspx?receiverId=@receiverId&customerId=@customerId&hideSearchDiv=" + hideSearchDiv.Value + "\"><i class=\"fa fa-edit\" ></i></a></btn></span>" : "";
            //var printLink = "<span class=\"action-icon\"> <btn type=\"button\" class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Print Details\"> <a href =\"ReceiverDetails.aspx?receiverId=@receiverId\"><i class=\"fa fa-print\" ></i></a></btn></span>";

            _grid.CustomLinkText = approveLink;
            _grid.CustomLinkVariables = "tranId,customerId";
            string sql = "EXEC [PROC_CUSTOMER_DEPOSITS] @flag = 'getMappedDeposits',@tranId=" + getTranId() + " ";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private string getTranId()
        {
            var tranId = GetStatic.ReadQueryString("id", "");
            return tranId;
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            string tranId = hddTranId.Value;
            string customerId = hddCustomerId.Value;
            string remittrantempId = hddremitTranTempId.Value;
            DbResult _dbRes = new DbResult();
            if (!string.IsNullOrEmpty(tranId))
            {
                _dbRes = at.ApproveMappingData(GetStatic.GetUser(), tranId, customerId, "deposit-approve", remittrantempId);
                //GetStatic.AlertMessage(this, _dbRes.Msg);
                if (_dbRes.ErrorCode == "0")
                {
                    GetStatic.AlertMessage(this, "Mapping Data approved successfully!!");
                    LoadGrid();
                }
                else
                {
                    GetStatic.AlertMessage(this, _dbRes.Msg);
                }
            }
            else
            {
                GetStatic.AlertMessage(this, "No transaction to approve!!");
            }
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            string tranId = hddTranId.Value;
            string customerId = hddCustomerId.Value;
            DbResult _dbRes = new DbResult();
            if (!string.IsNullOrEmpty(tranId))
            {
                _dbRes = at.ApproveMappingData(GetStatic.GetUser(), tranId, customerId, "reject","");
                //GetStatic.AlertMessage(this, _dbRes.Msg);
                GetStatic.AlertMessage(this, _dbRes.Msg);
                if (_dbRes.ErrorCode == "0")
                {
                    LoadGrid();
                }
            }
            else
            {
                GetStatic.AlertMessage(this, "No transaction to unmap!!");
            }
        }
    }
}