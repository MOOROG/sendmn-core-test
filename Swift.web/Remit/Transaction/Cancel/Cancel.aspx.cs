using Swift.API.Common.CancelTxn;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Library;
using System;
using System.Web.UI;

namespace Swift.web.Remit.Transaction.Cancel {
  public partial class Cancel : Page {
    protected const string GridName = "grid_canceltrn";

    private const string ViewFunctionId = "20121400";
    private const string ProcessFunctionId = "20121410";
    private readonly SwiftGrid grid = new SwiftGrid();
    private readonly CancelTransactionDao obj = new CancelTransactionDao();
    private StaticDataDdl _sdd = new StaticDataDdl();
    private readonly SmtpMailSetting _smtpMailSetting = new SmtpMailSetting();

    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        Authenticate();
        //LoadGrid("");
        GetStatic.PrintMessage(Page);
      }
      GetStatic.ResizeFrame(Page);
    }

    private void Authenticate() {
      _sdd.CheckAuthentication(ViewFunctionId + "," + ProcessFunctionId);
      btnCancel.Visible = _sdd.HasRight(ProcessFunctionId);
    }

    private void LoadByControlNo(string cNo) {
      ucTran.SearchData("", cNo, "", "N", "CANCEL", "ADM: CANCEL TXN");
      switch (ucTran.TranStatus) {
        case "":
          divTranDetails.Visible = false;
          PrintMessage("Transaction not found");
          return;

        case "Paid":
          divTranDetails.Visible = false;
          PrintMessage("Transaction has already been paid");
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
      searchDiv.Visible = !ucTran.TranFound;
      header.Text = "Cancel Transaction";
      hddTran.Value = ucTran.TranNo;
      //SendEmail();
    }

    private void PrintMessage(string msg) {
      GetStatic.CallBackJs1(Page, "Result", "alert('" + msg + "')");
    }

    private void ManageMessage(DbResult dbResult) {
      string url = "CancelReceipt.aspx?tranId=" + ucTran.TranNo;
      string mes = GetStatic.ParseResultJsPrint(dbResult);
      mes = mes.Replace("<center>", "");
      mes = mes.Replace("</center>", "");

      string scriptName = "CallBack";
      string functionName = "CallBack('" + mes + "','" + url + "')";
      GetStatic.CallBackJs1(Page, scriptName, functionName);

      // Page.ClientScript.RegisterStartupScript(this.GetType(), "Done", "<script language =
      // \"javascript\">return CallBack('" + mes + "')</script>");
    }

    private void RejectCancelRequest() {
      var dbResult = obj.RejectCancelRequestV2(GetStatic.GetUser(), ucTran.CtrlNo);
      GetStatic.SetMessage(dbResult);
      Response.Redirect("Cancel.aspx");
    }

    //Local Method
    private void CancelTranLocal() {
      var isRealTime = ucTran.isPartnerRealTime;
      DbResult dbResult = new DbResult();
      if (isRealTime == "1") { // tranglo or GME
        SendTransactionServices _tpSend = new SendTransactionServices();
        CancelTxnRequest cancelTxn = new CancelTxnRequest() {
          CancelReason = cancelReason.Text,
          PartnerPinNo = ucTran.CtrlNo,
          ProviderId = ucTran.partnerId,
          ControlNo = ucTran.CtrlNo,
          TranNo = ucTran.TranNo,
          SessionId = Guid.NewGuid().ToString(),
          UserName = GetStatic.GetUserName(),
          ProcessId = Guid.NewGuid().ToString(),
        };
        var result = _tpSend.CancelTransaction(cancelTxn);
        if (result.ResponseCode == "968" || result.ResponseCode == "IB1066") {
          dbResult = obj.CancelRequestWithRealTime(GetStatic.GetUser(), ucTran.CtrlNo, cancelReason.Text, result.Id);
        } else if (result.ResponseCode == "IB1061" || result.ResponseCode == "0") {
          dbResult = obj.CancelLocal(GetStatic.GetUser(), ucTran.CtrlNo, cancelReason.Text, "N");
        } else {
          dbResult = new DbResult() { ErrorCode = result.ResponseCode, Msg = result.Msg };
        }
      } else {
        dbResult = obj.CancelLocal(GetStatic.GetUser(), ucTran.CtrlNo, cancelReason.Text, "N"); //N means Cancel without charge
        //_smtpMailSetting.ToEmails = "mnsupport@hanpass.com,op@hanpass.com,sooryun@hanpass.com,saraka7@hanpass.com,oyunnomin@hanpass.com";
        //_smtpMailSetting.CcEmails = "khatanbaatar@send.mn,tseesuren@send.mn";
        if (ucTran.SAgentId.Equals("394717")) {
          _smtpMailSetting.ToEmails = "bat-uul@send.mn";
          _smtpMailSetting.MsgSubject = "Cancel confirmation , " + ucTran.CtrlNo + "," + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
          _smtpMailSetting.MsgBody = "<!DOCTYPE html><html><head><style>td, th {border: 1px solid #dddddd;  text-align: left;  padding: 8px;}tr: nth-child(even) {" +
            "background-color: #dddddd;}</style></head><body><table><tr><th>No</th><th>SendMN ControlNo</th><th>Hanpass TxnID</th><th>Status</th><th>Reason</th><th>Date</th></tr>" +
            "<tr><td>1</td><td>" + ucTran.CtrlNo + "</td><td>" + dbResult.Extra + "</td><td>Cancel</td>" +
            "<td>User cancel</td><td>2023-08-30</td></tr></table></body></html>";
          _smtpMailSetting.SendSmtpMailSimple(_smtpMailSetting);
        }
      }

      ManageMessage(dbResult);
    }

    protected void btnSearch_Click(object sender, EventArgs e) {
      LoadByControlNo(controlNo.Text);
    }

    protected void btnTranSelect_Click(object sender, EventArgs e) {
      string id = grid.GetRowId(GridName);
      //LoadGrid(id);
      LoadByControlNo(id);
    }

    protected void btnCancel_Click(object sender, EventArgs e) {
      CancelTranLocal();
    }

    protected void btnReject_Click(object sender, EventArgs e) {
      RejectCancelRequest();
    }
  }
}