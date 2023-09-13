using System;
using System.Collections.Generic;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Cancel
{
    public partial class ApproveReqUnapprovedTxn : System.Web.UI.Page
    {
        protected const string GridName = "grid_canceltrnunapp";
        private const string ViewFunctionId = "20122100";
        private const string ApproveFunctionId = "20122110";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly CancelTransactionDao obj = new CancelTransactionDao();
        private StaticDataDdl _sdd = new StaticDataDdl();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
            LoadGrid("");
            GetStatic.ResizeFrame(Page);
            GetStatic.Process(ref btnApprove);
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + ApproveFunctionId);
            btnApprove.Visible = _sdd.HasRight(ApproveFunctionId);
        }

        private void LoadGrid(string cNo)
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("controlNo", "Control No.", "LT"),
                                      new GridFilter("id", "Tran Id", "LT"),
                                      new GridFilter("createdBy", "Req. User", "LT"),
                                      new GridFilter("Branch", "Branch", "LT")
                                  };
            //grid.FilterList = new List<GridFilter>
            //                      {
            //                          new GridFilter("controlNo", "Control No.", "LT"),
            //                          new GridFilter("senderName", "Sender Name", "LT"),
            //                          new GridFilter("sStateName", "Sender State", "LT")                                     
            //                      };
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("id", "Tran Id", "", "T"),
                                      new GridColumn("controlNo", "Control No.", "", "T"),
                                      new GridColumn("pCountry", "Country", "", "T"),
                                      new GridColumn("Branch", "Branch", "", "T"),
                                      new GridColumn("createdBy", "Req. User", "", "T"),
                                      new GridColumn("requestedDate", "Requested Date & Time", "100", "T"),
                                      new GridColumn("senderName", "Sender Name", "", "T"),
                                      new GridColumn("receiverName", "Receiver Name", "", "T"),
                                      new GridColumn("cAmt", "Coll. Amt", "", "M"),
                                      new GridColumn("trnStatusBeforeCnlReq", "Tran Status", "", "T")
                                  };
            //grid.ColumnList = new List<GridColumn>
            //                      {
            //                          new GridColumn("id", "Tran Id", "", "T"),
            //                          new GridColumn("controlNo", "Control No.", "", "T"),
            //                          new GridColumn("sCustomerId", "Customer Id", "", "T"),
            //                          new GridColumn("senderName", "Sender Name", "", "T"),
            //                          new GridColumn("sCountryName", "Country", "", "T"),
            //                          new GridColumn("sStateName", "Sender State", "", "T"),
            //                          new GridColumn("sCity", "Sender City", "", "T"),
            //                          new GridColumn("sAddress", "Sender Address", "", "T")                                      
            //                      };
            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = true;
            grid.InputPerRow = 4;
            grid.ShowPagingBar = true;
            grid.RowIdField = "controlNo";
            grid.EnableFilterCookie = true;
            grid.ShowCheckBox = true;
            grid.CallBackFunction = "GridCallBack()";
            grid.SetComma();
            grid.GridWidth = 100;
            grid.GridMinWidth = 700;
            grid.IsGridWidthInPercent = true;
            grid.EnableCookie = true;
            grid.SelectionCheckBoxList = cNo;
            grid.AlwaysShowFilterForm = true;
            string sql = @"EXEC proc_cancelTranInt @flag = 's1',@userType=" + _sl.FilterString(GetStatic.GetUserType()) + "";
            //string sql = @"EXEC proc_cancelTran @flag = 's'" + "";

            grd_tran.InnerHtml = grid.CreateGrid(sql);
            divTranDetails.Visible = false;
        }

        private void LoadByControlNo(string cNo)
        {
            btnTranSelect.Visible = false;
            ucTran.SearchData("", cNo, "", "Y", "CANCEL", "ADM: CANCEL TXN");

            switch (ucTran.TranStatus)
            {
                case "":
                    divTranDetails.Visible = false;
                    PrintMessage("Transaction not found");
                    return;

                case "Cancel":
                    divTranDetails.Visible = false;
                    PrintMessage("Transaction has already been cancelled");
                    return;
                case "Block":
                    divTranDetails.Visible = false;
                    PrintMessage("Transaction is blocked");
                    return;
                case "Compliance":
                    divTranDetails.Visible = false;
                    PrintMessage("Transaction under compliance");
                    return;
                case "Lock":
                    divTranDetails.Visible = false;
                    PrintMessage("Transaction is locked. Please contact HO");
                    return;
            }
            //switch (ucTran.PayStatus)
            //{
            //    case "Post":
            //        divTranDetails.Visible = false;
            //        PrintMessage("Transaction is Post. Please contact Head Office.");
            //        return;
            //}
            divTranDetails.Visible = ucTran.TranFound;
            hddTran.Value = ucTran.TranNo;
            trnStatusBeforeCnlReq.Text = ucTran.trnStatusBeforeCnlReq;
            gridDisplay.Visible = false;
        }

        private void PrintMessage(string msg)
        {
            GetStatic.CallBackJs1(Page, "Result", "alert('" + msg + "')");
        }

        private void ManageApproveMessage(DbResult dbResult)
        {
            if(dbResult.ErrorCode!="0")
            {
                GetStatic.CallBackJs1(Page, "Result", "alert('" + dbResult.Msg + "')");
                return;
            }
                
            string trnId = "";
            string url = "CancelReceiptInt.aspx?controlNo=" + ucTran.CtrlNo;
            string mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");

            string scriptName = "CallBack";
            string functionName = "CallBack('" + mes + "','" + url + "')";
            GetStatic.CallBackJs1(Page, scriptName, functionName);
        }

        private void ManageRejectMessage(DbResult dbResult)
        {
            var url = "ApproveReqUnapprovedTxn.aspx";
            string mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");

            string scriptName = "CallBack";
            string functionName = "CallBack('" + mes + "','" + url + "');";
            GetStatic.CallBackJs1(Page, scriptName, functionName);
        }

        private void ApproveCancelRequest()
        {
            string agentCancel = _sl.GetAgentCancelTypeAdmin(ucTran.CtrlNo);
            DbResult dbResult = obj.ApproveCancelRequest(GetStatic.GetUser(), ucTran.CtrlNo, approveRemarks.Text, "Y", agentCancel);
            ManageApproveMessage(dbResult);
        }
        
        protected void btnTranSelect_Click(object sender, EventArgs e)
        {
            string id = grid.GetRowId(GridName);
            LoadGrid(id);
            if (!string.IsNullOrWhiteSpace(id))
                LoadByControlNo(id);
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            ApproveCancelRequest();
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            RejectCancelRequest();
        }

        private void RejectCancelRequest()
        {
            string agentCancel = _sl.GetAgentCancelTypeAdmin(ucTran.CtrlNo);
            DbResult dbResult = obj.RejectCancelRequestInt(GetStatic.GetUser(), ucTran.CtrlNo, approveRemarks.Text, "Y",agentCancel);
            ManageRejectMessage(dbResult);
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("ApproveReqUnapprovedTxn.aspx");
        }
    }
}