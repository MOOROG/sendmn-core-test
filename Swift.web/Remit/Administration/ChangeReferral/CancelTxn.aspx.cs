using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Swift.API;
using Swift.API.Common;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.Remittance.APIPartner;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;

namespace Swift.web.Remit.Administration.ChangeReferral
{
    public partial class CancelTxn : System.Web.UI.Page
    {
        private string ViewFunctionId = "20202800";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly APIPartnerDao _dao = new APIPartnerDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.HasRight(ViewFunctionId);
            var MethodName = Request.Form["MethodName"];
            if (MethodName == "SearchTransaction")
                SearchTransactionDetails();

            if (MethodName == "CancelTxn")
                CancelTransaction();

            if (!IsPostBack)
            {
                cancelDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        private void CancelTransaction()
        {
            var controlNo = Request.Form["ControlNo"];
            var cancelDate = Request.Form["CancelDate"];
            var cancelReason = Request.Form["CancelReason"];

            var _dbRes = _dao.CancelTxn(GetStatic.GetUser(), controlNo, cancelDate, cancelReason);

            GetStatic.JsonResponse(_dbRes, this);
        }

        private void SearchTransactionDetails()
        {
            var controlNo = Request.Form["ControlNo"];
            var includePartnerSearch = Request.Form["IncludePartnerSearch"];
            DataRow dr = _dao.GetTransactionDetails(GetStatic.GetUser(), controlNo);

            TxnResponse _resp = new TxnResponse();
            if (dr == null)
            {
                _resp.ErrorCode = "1";
                _resp.Msg = "Internal error occured!";
            }
            else
            {
                _resp.ErrorCode = dr["ErrorCode"].ToString();
                _resp.Msg = dr["Msg"].ToString();
                if (dr["ErrorCode"].ToString().Trim() == "0")
                {
                    _resp.ControlNo = controlNo;
                    _resp.TranId = dr["ID"].ToString();
                    _resp.SenderName = dr["SENDERNAME"].ToString();
                    _resp.ReceiverName = dr["RECEIVERNAME"].ToString();
                    _resp.ReferralName = dr["REFERRAL_NAME"].ToString();
                    _resp.ReferralCode = dr["REFERRAL_CODE"].ToString();
                    _resp.CollectAmount = dr["CAMT"].ToString();
                    _resp.TransferAmount = dr["TAMT"].ToString();
                    _resp.PayoutAmount = dr["PAMT"].ToString();
                    _resp.PayoutCountry = dr["PCOUNTRY"].ToString();
                    _resp.CollMode = dr["COLLMODE"].ToString();
                    _resp.PayoutCurr = dr["PAYOUTCURR"].ToString();
                    _resp.Provider = dr["PSUPERAGENT"].ToString();
                }
            }

            if (includePartnerSearch == "y")
            {

                ExchangeRateAPIService _service = new ExchangeRateAPIService();
                string ProcessId = Guid.NewGuid().ToString().Replace("-", "") + ":" + _resp.Provider + ":cancelStatusCheck";
                var _requestData = new
                {
                    ProcessId = ProcessId.Substring(ProcessId.Length - 40, 40),
                    UserName = GetStatic.GetUser(),
                    ProviderId = _resp.Provider,
                    SessionId = _resp.ControlNo,
                    ControlNo = _resp.ControlNo,
                    PartnerPinNo = _resp.ControlNo
                };

                JsonResponse _syncStatusResponse = _service.GetTxnStatus(_requestData);

                if (_syncStatusResponse.ResponseCode == "0")
                {
                    _resp.ResponseXML = JsonConvert.SerializeObject(_syncStatusResponse);
                    var jsonData = JObject.Parse(_resp.ResponseXML);
                    _resp.StatusName = jsonData["Data"]["StatusName"].ToString();
                    if (_resp.StatusName.ToLower() == "cancel")
                    {
                        _resp.CancelReason = jsonData["Data"]["CancellationReason"].ToString();
                    }
                    
                    _resp.InvoiceTxnStatus = JsonConvert.DeserializeObject<List<TxnStatusChangeList>>(jsonData["Data"]["TransactionInfo"]["InvoiceStatusTimeStamps"].ToString());
                    _resp.LatestStatus = _resp.InvoiceTxnStatus[_resp.InvoiceTxnStatus.Count - 1].FlagName;
                    _resp.LatestDate = GetStatic.ToDate(_resp.InvoiceTxnStatus[_resp.InvoiceTxnStatus.Count - 1].ChangeStatusDate);
                }
                else
                {
                    _resp.ErrorCode = _syncStatusResponse.ResponseCode;
                    _resp.Msg = _syncStatusResponse.Msg;
                }
                
            }

            GetStatic.JsonResponse(_resp, this);
        }

        public class TxnResponse : DbResult
        {
            public string ControlNo { get; set; }
            public string TranId { get; set; }
            public string SenderName { get; set; }
            public string ReceiverName { get; set; }
            public string ReferralName { get; set; }
            public string ReferralCode { get; set; }
            public string CollectAmount { get; set; }
            public string TransferAmount { get; set; }
            public string PayoutAmount { get; set; }
            public string PayoutCountry { get; set; }
            public string CollMode { get; set; }
            public string PayoutCurr { get; set; }
            public string Provider { get; set; }
            public string StatusName { get; set; }
            public string LatestStatus { get; set; }
            public string LatestDate { get; set; }
            public string CancelReason { get; set; }
            public List<TxnStatusChangeList> InvoiceTxnStatus { get; set; }
        }
        
        public class TxnStatusChangeList
        {
            public string FlagId { get; set; }
            public string FlagName { get; set; }
            public string ChangeStatusDate { get; set; }
        }
    }
}