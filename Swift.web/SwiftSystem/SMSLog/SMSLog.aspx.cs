using Swift.API.Common;
using Swift.API.Common.SMS;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.AgentPanel.Send;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace Swift.web.SwiftSystem.SMSLog
{
    public partial class SMSLog : System.Web.UI.Page
    {
        private readonly ReceiptDao obj = new ReceiptDao();
        private readonly SwiftLibrary sl = new SwiftLibrary();
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private SendTranIRHDao st = new SendTranIRHDao();
        private const string GridName = "SMSLogGridAdm";
        private const string ViewFunctionId = "20319000";
        private const string ReSendFunctionId = "20319010";
        private const string SyncFunctionId = "20319020";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            var methodName = Request.Form["MethodName"];
            if (methodName == "SyncStatus")
                SyncStatus();
            if (methodName == "SendSMS")
                SendSMS();
            if (!IsPostBack)
            {

            }
            LoadGrid();
        }

        private void SendSMS()
        {
            string ProcessId = Guid.NewGuid().ToString().Replace("-", "") + ":resendSms";
            SendSMSApiService _sendAPI = new SendSMSApiService();
            DataRow dr = obj.GetTxnDataForSMS(GetStatic.GetUser(), Request.Form["controlno"]);
            string msgBody = GetStatic.GetSMSTextForTxn(dr);

            SMSRequestModel _req = new SMSRequestModel
            {
                ProviderId = "onewaysms",
                MobileNumber = Request.Form["mobileNumber"].Trim().Replace("+", ""),
                SMSBody = msgBody,
                ProcessId = ProcessId.Substring(ProcessId.Length - 40, 40),
                RequestedBy = GetStatic.GetUser(),
                UserName = GetStatic.GetUser(),
                method = "send"
            };

            JsonResponse _resp = _sendAPI.SMSTPApi(_req);

            string isSuccess = (_resp.ResponseCode == "0") ? "1" : "0";

            obj.LogSMS(Request.Form["controlno"], GetStatic.GetUser(), msgBody, Request.Form["mobileNumber"].Trim().Replace("+", ""),
                            ProcessId, _resp.Extra, isSuccess);

            GetStatic.JsonResponse(_resp, this);
        }

        private void SyncStatus()
        {
            string ProcessId = Guid.NewGuid().ToString().Replace("-", "") + ":syncStatusSms";
            SendSMSApiService _sendAPI = new SendSMSApiService();
            //GetSMSTextForTxn
            SMSRequestModel _req = new SMSRequestModel
            {
                ProviderId = "onewaysms",
                ProcessId = Request.Form["processId"],
                RequestedBy = GetStatic.GetUser(),
                UserName = GetStatic.GetUser(),
                method = "status",
                MTID = Request.Form["mtId"]
            };

            JsonResponse _resp = _sendAPI.SMSTPApi(_req);

            string status = (_resp.ResponseCode == "0" || _resp.ResponseCode == "100") ? "Success" : "Fail";

            obj.LogSMSSyncStatus(GetStatic.GetUser(), Request.Form["rowId"], status, _resp.Msg);

            GetStatic.JsonResponse(_resp, this);
        }

        private void LoadGrid()
        {
            //var tranNo = GetStatic.ReadWebConfig("tranNoName", "");
            _grid.FilterList = new List<GridFilter>
            {
                new GridFilter("CONTROL_NO", "Control No", "T"),
                new GridFilter("MOBILE_NUMBER", "Mobile No", "T"),
                new GridFilter("CREATED_BY", "Sent By", "T")
            };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("CONTROL_NO", "Control No", "", "T"),
                                      new GridColumn("MOBILE_NUMBER", "Mobile No", "", "T"),
                                      new GridColumn("PROCESS_ID", "Process ID", "", "T"),
                                      new GridColumn("IS_SEND_SUCCESS", "Is Send Success", "", "T"),
                                      new GridColumn("MSG_BODY", "Message", "", "T"),
                                      new GridColumn("CREATED_BY", "Sent By", "", "T"),
                                      new GridColumn("CREATED_DATE", "Sent Date", "", "D"),
                                      new GridColumn("STATUS", "Status", "", "T"),
                                      new GridColumn("STATUS_DETAIL", "Status Detail", "", "T")
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.LoadGridOnFilterOnly = false;
            _grid.ShowPagingBar = true;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.AllowDelete = false;
            _grid.RowIdField = "ROW_ID";
            _grid.ThisPage = "SMSLog.aspx"; ;
            _grid.InputPerRow = 4;
            _grid.EnablePdfDownload = true;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.ShowCheckBox = false;
            _grid.IsGridWidthInPercent = true;
            _grid.AllowCustomLink = true;
            _grid.CustomLinkVariables = "ROW_ID,MT_ID,PROCESS_ID,MOBILE_NUMBER,CONTROL_NO";
            var customLinkText = new StringBuilder();

            if (_sdd.CheckAuthentication(SyncFunctionId))
                customLinkText.Append("<a href=\"javascript:void(0);\" onclick=\"SynccStatus('@ROW_ID','@MT_ID','@PROCESS_ID')\" title='Sync Status'><span class=\"action-icon btn btn-xs btn-primary\"><i class=\"fa fa-recycle\"></i><span></a>");

            if (_sdd.CheckAuthentication(ReSendFunctionId))
                customLinkText.Append("&nbsp;&nbsp;<a href=\"javascript:void(0);\" onclick=\"ResendSMS('@ROW_ID', '@MOBILE_NUMBER', '@CONTROL_NO')\" title='Re-Send SMS'><span class=\"action-icon btn btn-xs btn-primary\"><i class=\"fa fa-send\"></i><span></a>");

            _grid.CustomLinkText = customLinkText.ToString();

            string sql = "[PROC_SMS_LOG] @flag='s'";
            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        public void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }
    }
}