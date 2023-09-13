using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Transaction.SuspiciousTxn
{
    public partial class TxnList : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20203300";
        private const string GridName = "grid_suspicious_txn_list";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftGrid grid = new SwiftGrid();
        private ApproveTransactionDao at = new ApproveTransactionDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            GetStatic.PrintMessage(this);
            LoadGrid();
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("CONTROLNO", "JME No.","T"),
                                      new GridFilter("UPLOADLOGID", "Tran ID", "T")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("CONTROLNO", "JME No.", "", "T"),
                                      new GridColumn("UPLOADLOGID", "Tran ID", "", "T"),
                                      new GridColumn("OLD_TRAN_STATUS", "Current Tran Status", "", "T"),
                                      new GridColumn("OLD_PAYSTATUS", "Current Pay Status", "", "T"),
                                      new GridColumn("PAIDDATE", "Paid Date", "", "D"),
                                      new GridColumn("CANCELAPPROVEDDATE", "Cancel Date", "", "D"),
                                      new GridColumn("PAYSTATUS", "New Pay Status", "", "T"),
                                      new GridColumn("TRANSTATUS", "New Tran Status", "", "T")
                                  };

            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.AlwaysShowFilterForm = true;
            grid.EnableFilterCookie = false;
            grid.InputPerRow = 3;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AllowCustomLink = true;
            grid.RowIdField = "CONTROLNO";
            grid.CustomLinkVariables = "CONTROLNO,PAYSTATUS,TRANSTATUS";

            var link = "&nbsp;<a onclick=\"SyncTxn('@CONTROLNO', '@PAYSTATUS', '@TRANSTATUS')\" class=\"btn btn-xs btn-success\" title=\"Sync\" href=\"javascript:voic(0);\"><i class=\"fa fa-refresh\"></i></a>";
            grid.CustomLinkText = link;

            grid.SetComma();

            var sql = @"EXEC PROC_STATUS_CHANGE_AFTER_PAID_OR_CANCEL @flag = 's'";
            rpt_grid.InnerHtml = grid.CreateGrid(sql);

        }

        protected void btnSync_Click(object sender, EventArgs e)
        {
            string controlno = hddControlno.Value;
            DbResult _dbRes = at.SyncTransaction(GetStatic.GetUser(), controlno);
            if (_dbRes.ErrorCode == "0")
            {
                GetStatic.AlertMessage(this, _dbRes.Msg);
                LoadGrid();
            }
            else
            {
                GetStatic.AlertMessage(this, _dbRes.Msg);
            }
        }
    }
}