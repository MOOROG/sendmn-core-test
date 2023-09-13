using log4net;
using Newtonsoft.Json;
using Swift.API.Common;
using Swift.API.Common.ExRate;
using Swift.API.Common.SendTxn;
using Swift.API.Common.SyncModel.Bank;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net.Http;
using System.Text;

namespace Swift.API.ThirdPartyApiServices {
  public class ExchangeRateAPIService {
    private readonly ILog _log = LogManager.GetLogger(typeof(ExchangeRateAPIService));
    public JsonResponse GetExchangeRate(ExRateRequest model) {
      //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var obj = JsonConvert.SerializeObject(model);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/ExRate";

          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<ExRateResponse>(jsonResponse.Data.ToString()) : null);
            jsonResponse.Data = a;

            return jsonResponse;
          } else {
            var errorJson = JsonConvert.DeserializeObject<ErrorJosn>(resultData);
            var jsonResponseData = JsonConvert.DeserializeObject<JsonResponse>(errorJson.Message);
            var data = JsonConvert.DeserializeObject<List<Data>>(jsonResponseData.Data.ToString());
            _log.Error("Error occured Core Exrate. Error " + jsonResponseData.Msg);
            jsonResponse.Id = jsonResponseData.Id;
            jsonResponse.ResponseCode = jsonResponseData.ResponseCode;
            jsonResponse.Msg = jsonResponseData.Msg;
            jsonResponse.Data = data;
            jsonResponse.Extra = jsonResponseData.Extra;
            jsonResponse.Extra1 = jsonResponseData.Extra1;
            return jsonResponse;
          }
        } catch (Exception ex) {
          _log.Error("Error occured Core Exrate. Error " + ex);
          return new JsonResponse() {
            ResponseCode = "1",
            Msg = (ex.InnerException == null ? ex.Message : ex.InnerException.Message)
          };
        }
      }
    }
    public JsonResponse GetTPExrate(ExRateCalculateRequest m) {
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();

        ExRateCalculate model = new ExRateCalculate() {
          SBranch = Convert.ToInt32("394442"),
          SSuperAgent = Convert.ToInt32("394436"),
          AgentRefId = "",
          CalcBy = m.calcBy,
          CAmount = Convert.ToDecimal(m.cAmount == "" ? "0" : m.cAmount),
          CardOnline = "",
          CollCurrency = m.sCurrency,
          CouponCode = "",
          CustomerId = 0,
          IsManualSc = false,
          IsOnline = false,
          ManualSc = 0,
          PAgentId = Convert.ToInt32(m.pAgent == "" ? "0" : m.pAgent),
          PAgentName = "",
          PAmount = Convert.ToDecimal(m.pAmount == "" ? "0" : m.pAmount),
          PaymentType = m.paymentType,
          PayoutPartner = Convert.ToInt32(m.payoutPartner == "" ? "0" : m.payoutPartner),
          PCountry = Convert.ToInt32(m.pCountry == "" ? "0" : m.pCountry),
          pCountryCode = m.pCountryName,
          PCountryName = m.pCountryName,
          PCurrency = m.pCurrency,
          ProcessFor = "send",
          ProcessId = m.processId == "" ? Guid.NewGuid().ToString() : m.processId,
          ProviderId = "",
          RequestedBy = "mobile",
          SAgent = 0,
          SCountry = Convert.ToInt32(m.sCountry == "" ? "0" : m.sCountry),
          SCurrency = m.sCurrency,
          ServiceType = m.serviceType,
          SessionId = Guid.NewGuid().ToString(),
          tPExRate = m.tpExRate,
          UserName = m.userId
          , receiverIsOrg = m.receiverIsOrg
        };

        var obj = JsonConvert.SerializeObject(model);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/ExRate";
          _log.Debug("Core ExRate : " + obj);
          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<ExRateResponse>(jsonResponse.Data.ToString()) : null);
            jsonResponse.Data = a;

            return jsonResponse;
          } else {
            var errorJson = JsonConvert.DeserializeObject<ErrorJosn>(resultData);
            var jsonResponseData = JsonConvert.DeserializeObject<JsonResponse>(errorJson.Message);
            _log.Error("Error occured Core Exrate. Error " + jsonResponseData.Msg);
            var data = JsonConvert.DeserializeObject<List<Data>>(jsonResponseData.Data.ToString());
            jsonResponse.Id = jsonResponseData.Id;
            jsonResponse.ResponseCode = jsonResponseData.ResponseCode;
            jsonResponse.Msg = jsonResponseData.Msg;
            jsonResponse.Data = data;
            jsonResponse.Extra = jsonResponseData.Extra;
            jsonResponse.Extra1 = jsonResponseData.Extra1;
            return jsonResponse;
          }
        } catch (Exception ex) {
          _log.Error("Error occured Core Exrate. Error " + ex);
          return new JsonResponse() {
            ResponseCode = "1",
            Msg = (ex.InnerException == null ? ex.Message : ex.InnerException.Message)
          };
        }
      }
    }
    public JsonResponse GetTxnStatus(dynamic model) {
      //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var obj = JsonConvert.SerializeObject(model);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/GetStatus";

          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            if (jsonResponse.ResponseCode.Equals("104")) {
              var datas = JsonConvert.DeserializeObject<List<Data>>(jsonResponse.Data.ToString());
              string msg = "";
              foreach (var item in datas) {
                msg += "  " + item.Message;
              }
              jsonResponse.Msg += msg;
            }
            return jsonResponse;
          } else {
            var errorJson = JsonConvert.DeserializeObject<ErrorJosn>(resultData);
            var jsonResponseData = JsonConvert.DeserializeObject<JsonResponse>(errorJson.Message);
            var data = JsonConvert.DeserializeObject<List<Data>>(jsonResponseData.Data.ToString());
            jsonResponse.Id = jsonResponseData.Id;
            jsonResponse.ResponseCode = jsonResponseData.ResponseCode;
            jsonResponse.Msg = jsonResponseData.Msg;
            //jsonResponse.Data = data;
            jsonResponse.Extra = jsonResponseData.Extra;
            return jsonResponse;
          }
        } catch (Exception ex) {
          return new JsonResponse() {
            ResponseCode = "1",
            Msg = (ex.InnerException == null ? ex.Message : ex.InnerException.Message)
          };
        }
      }
    }

    public List<TransactionResponse> DownloadInficareTransaction(string url) {
      //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
      using (var client = RestApiClient.CallThirdParty()) {
        List<TransactionResponse> jsonResponse = new List<TransactionResponse>();
        try {
          HttpResponseMessage resp = client.GetAsync(url).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            //jsonResponse = JsonConvert.DeserializeObject<List<RetrieveMultipleResponse>>(resultData);
            jsonResponse = JsonConvert.DeserializeObject<List<TransactionResponse>>(resultData);
            jsonResponse[0].errorCode = "0";
            jsonResponse[0].errorMsg = "Success";
            return jsonResponse;
          } else {
            jsonResponse[0].errorCode = "1";
            jsonResponse[0].errorMsg = "Success";
            return jsonResponse;
          }
        } catch (Exception ex) {
          jsonResponse[0].errorCode = "1";
          jsonResponse[0].errorMsg = (ex.InnerException == null ? ex.Message : ex.InnerException.Message);
          return jsonResponse;
        }
      }
    }

    public List<CustomerData> DownloadInficareCustomer(string url) {
      //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
      using (var client = RestApiClient.CallThirdParty()) {
        List<CustomerData> jsonResponse = new List<CustomerData>();
        try {
          HttpResponseMessage resp = client.GetAsync(url).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            //jsonResponse = JsonConvert.DeserializeObject<List<RetrieveMultipleResponse>>(resultData);
            jsonResponse = JsonConvert.DeserializeObject<List<CustomerData>>(resultData);
            jsonResponse[0].errorCode = "0";
            jsonResponse[0].errorMsg = "Success";
            return jsonResponse;
          } else {
            jsonResponse[0].errorCode = "1";
            jsonResponse[0].errorMsg = "Success";
            return jsonResponse;
          }
        } catch (Exception ex) {
          jsonResponse[0].errorCode = "1";
          jsonResponse[0].errorMsg = (ex.InnerException == null ? ex.Message : ex.InnerException.Message);
          return jsonResponse;
        }
      }
    }

    public List<ReceiverData> DownloadInficareReceiver(string url) {
      //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
      using (var client = RestApiClient.CallThirdParty()) {
        List<ReceiverData> jsonResponse = new List<ReceiverData>();
        try {
          HttpResponseMessage resp = client.GetAsync(url).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            //jsonResponse = JsonConvert.DeserializeObject<List<RetrieveMultipleResponse>>(resultData);
            jsonResponse = JsonConvert.DeserializeObject<List<ReceiverData>>(resultData);
            jsonResponse[0].errorCode = "0";
            jsonResponse[0].errorMsg = "Success";
            return jsonResponse;
          } else {
            jsonResponse[0].errorCode = "1";
            jsonResponse[0].errorMsg = "Success";
            return jsonResponse;
          }
        } catch (Exception ex) {
          jsonResponse[0].errorCode = "1";
          jsonResponse[0].errorMsg = (ex.InnerException == null ? ex.Message : ex.InnerException.Message);
          return jsonResponse;
        }
      }
    }

    public List<TransactionSync> DownloadInficareTransactionForSync(string url) {
      //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
      using (var client = RestApiClient.CallThirdParty()) {
        List<TransactionSync> jsonResponse = new List<TransactionSync>();
        try {
          HttpResponseMessage resp = client.GetAsync(url).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            //jsonResponse = JsonConvert.DeserializeObject<List<RetrieveMultipleResponse>>(resultData);
            jsonResponse = JsonConvert.DeserializeObject<List<TransactionSync>>(resultData);
            jsonResponse[0].errorCode = "0";
            jsonResponse[0].errorMsg = "Success";
            return jsonResponse;
          } else {
            jsonResponse[0].errorCode = "1";
            jsonResponse[0].errorMsg = "Success";
            return jsonResponse;
          }
        } catch (Exception ex) {
          jsonResponse[0].errorCode = "1";
          jsonResponse[0].errorMsg = (ex.InnerException == null ? ex.Message : ex.InnerException.Message);
          return jsonResponse;
        }
      }
    }

    public class TransactionSync {
      public string errorCode { get; set; }
      public string errorMsg { get; set; }
      public string transtatus { get; set; }
      public string status { get; set; }
      public string paiddate { get; set; }
      public string cancel_date { get; set; }
      public string tranno { get; set; }
    }

    public class ReceiverData {
      public string errorCode { get; set; }
      public string errorMsg { get; set; }
      public string Col1 { get; set; }
      public string Sender_SNo { get; set; }
      public string ReceiverName { get; set; }
      public string ReceiverMiddleName { get; set; }
      public string ReceiverLastName { get; set; }
      public string ReceiverCountry { get; set; }
      public string ReceiverAddress { get; set; }
      public string Col2 { get; set; }
      public string Col3 { get; set; }
      public string ReceiverCity { get; set; }
      public string ReceiverEmail { get; set; }
      public string Col4 { get; set; }
      public string ReceiverFax { get; set; }
      public string ReceiverMobile { get; set; }
      public string Relation { get; set; }
      public string CustomerbenificiarType { get; set; }
      public string ReceiverIdDescription { get; set; }
      public string ReceiverId { get; set; }
      public string PaymentType { get; set; }
      public string Commercial_bank_Id { get; set; }
      public string PayOutPartner { get; set; }
      public string Api_partnet_bank_name { get; set; }
      public string AccountNo { get; set; }
      public string CustomerRemarks { get; set; }
      public string Reason_for_remittance { get; set; }
      public string CreateBy { get; set; }
      public string Create_TS { get; set; }
      public string Col5 { get; set; }
      public string Col6 { get; set; }
      public string Col7 { get; set; }
      public string SNo { get; set; }
    }

    public class CustomerData {
      public string errorCode { get; set; }
      public string errorMsg { get; set; }
      public string SenderName { get; set; }
      public string SenderMiddleName { get; set; }
      public string SenderLastName { get; set; }
      public string Country { get; set; }
      public string SenderZipCode { get; set; }
      public string SenderCity { get; set; }
      public string SenderState { get; set; }
      public string SenderEmail { get; set; }
      public string SenderMobile2 { get; set; }
      public string SenderMobile { get; set; }
      public string SenderNativeCountry { get; set; }
      public string Date_of_birth { get; set; }
      public string Sender_Occupation { get; set; }
      public string Gender { get; set; }
      public string FullName { get; set; }
      public string Create_by { get; set; }
      public string create_ts { get; set; }
      public string id_issue_DATE { get; set; }
      public string SENDERVISA { get; set; }
      public string SenderFax { get; set; }
      public string SenderPassport { get; set; }
      public string Is_ACT { get; set; }
      public string approve_by { get; set; }
      public string approve_ts { get; set; }
      public string cust_type { get; set; }
      public string is_enable { get; set; }
      public string Force_Change_Pwd { get; set; }
      public string Source_Of_income { get; set; }
      public string SenderAddress { get; set; }
      public string CustomerType { get; set; }
      public string EmploymentType { get; set; }
      public string NameOfEmp { get; set; }
      public string SSN_cardId { get; set; }
      public string Is_Active { get; set; }
      public string Customer_remarks { get; set; }
      public string sendercompany { get; set; }
      public string RegdNo { get; set; }
      public string Org_Type { get; set; }
      public string Date_OfInc { get; set; }
      public string Nature_OD_Company { get; set; }
      public string Position { get; set; }
      public string NameOfAuthorizedPerson { get; set; }
      public string Income { get; set; }
      public string SNo { get; set; }
      public string CustomerId { get; set; }
    }

    public class TransactionResponse {
      public string errorCode { get; set; }
      public string errorMsg { get; set; }
      public string RefNo { get; set; }
      public string pCurrCostRate { get; set; }
      public string PCurrMargin { get; set; }
      public string custRate { get; set; }
      public string SCharge { get; set; }
      public string senderCommission { get; set; }
      public string pAgentComm { get; set; }
      public string pAgentCommCurr { get; set; }
      public string AgentCode { get; set; }
      public string Branch1 { get; set; }
      public string Branch_Code { get; set; }
      public string Branch { get; set; }
      public string ReceiverCountry { get; set; }
      public string paymentType { get; set; }
      public string ben_bank_id_BANK { get; set; }
      public string ben_bank_name_BANK { get; set; }
      public string ben_bank_id { get; set; }
      public string ben_bank_name { get; set; }
      public string rBankAcNo { get; set; }
      public string collMode { get; set; }
      public string paidAmt { get; set; }
      public string receiveAmt { get; set; }
      public string TotalRountAmt { get; set; }
      public string receiveCType { get; set; }
      public string ReceiverRelation { get; set; }
      public string reason_for_remittance { get; set; }
      public string source_of_income { get; set; }
      public string TranStatus { get; set; }
      public string PayStatus { get; set; }
      public string sTime { get; set; }
      public string sempid { get; set; }
      public string confirmdate { get; set; }
      public string sendername { get; set; }
      public string receivername { get; set; }
      public string TranNo { get; set; }
      public string firstName { get; set; }
      public string fullName { get; set; }
      public string senderstate { get; set; }
      public string sendercity { get; set; }
      public string senderAddress { get; set; }
      public string senderemail { get; set; }
      public string sender_mobile { get; set; }
      public string senderPhoneNo { get; set; }
      public string senderNativeCountry { get; set; }
      public string senderFax { get; set; }
      public string senderPassport { get; set; }
      public string ID_issue_Date { get; set; }
      public string senderVisa { get; set; }
      public string ip_address { get; set; }
      public string dateofbirth { get; set; }
      public string senderzipcode { get; set; }
      public string customer_sno { get; set; }
      public string rfirstName { get; set; }
      public string rFullName { get; set; }
      public string rCountry { get; set; }
      public string receiverAddress { get; set; }
      public string receiver_mobile { get; set; }
      public string ReceiverIdDescription { get; set; }
      public string ReceiverId { get; set; }
      public string rRel { get; set; }
      public string receiver_sno { get; set; }
      public string paidBy { get; set; }
      public string paidDate { get; set; }
      public string cancel_date { get; set; }
    }

    public JsonResponse CalculateExRate(string user, string sCountryId, string sSuperAgent, string sAgent, string sBranch, string collCurr,
                                        string pCountryId, string pAgent, string pCurr, string deliveryMethod, string cAmt, string pAmt,
                                        string schemeCode, string senderId, string sessionId, string couponId, string processId, string isManualSc = "", string sc = "") {
      ThirdPartyAPI _tpApi = new ThirdPartyAPI();
      JsonResponse response = new JsonResponse();
      APIJsonResponse jsonResponse = new APIJsonResponse();
      try {
        ExRateCalculate exRequest = new ExRateCalculate() {
          AgentRefId = "",
          CalcBy = "",
          CAmount = Convert.ToDecimal(cAmt == "" ? "0" : cAmt),
          CardOnline = "",
          CollCurrency = collCurr,
          CouponCode = "",
          CustomerId = 0,
          IsExRateCalcByPartner = false,
          IsManualSc = false,
          IsOnline = false,
          ManualSc = 0,
          PAgentName = "",
          PAmount = Convert.ToDecimal(pAmt == "" || pAmt == null ? "0" : pAmt),
          PaymentType = "",
          PayoutPartner = 0,
          PCountry = Convert.ToInt32(pCountryId == "" || pCountryId == null ? "0" : pCountryId),
          pCountryCode = "",
          PCountryName = "",
          PCurrency = pCurr,
          ProcessId = processId,
          ProviderId = "",
          RequestedBy = "mobile",
          SAgent = Convert.ToInt32(sAgent == "" || sAgent == null ? "0" : sAgent),
          SBranch = 0,
          SCountry = Convert.ToInt32(sCountryId == "" || sCountryId == null ? "0" : sCountryId),
          SCurrency = Utility.ReadWebConfig("minusTwoHundred", ""),
          ServiceType = deliveryMethod,
          SessionId = "",
          SSuperAgent = Convert.ToInt32(sSuperAgent == "" || sSuperAgent == null ? "0" : sSuperAgent),
          tPExRate = "",
          UserName = "TEST",
          ProcessFor = "dashboard",
        };

        var result = _tpApi.ThirdPartyApiGetDataOnly<ExRateCalculate, APIJsonResponse>(exRequest, "api/v1/TP/ExRate", out jsonResponse);
        response = new JsonResponse() {
          ErrorCode = result.ResponseCode,
          Id = result.Id,
          Msg = result.Msg,
          Data = result.Data,
          Extra = result.Extra,
          Extra2 = result.Extra1
        };

        if (response.ErrorCode == "0") {
          return response;
        } else {
          return response;
        }
      } catch (Exception ex) {
        response.SetResponse("1", "Error occured while  calculating ex-rate");
        return response;
      }
    }

    public JsonResponse SendTransactionContact(MobileRemitRequest model, string bankName) {
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        string bicNo = bankName;
        TpSendMoney tp = new TpSendMoney() {
          CalBy = model.CalBy,
          CDD = new CustomerDueDiligence() { PurposeOfRemittance = model.PurposeOfRemittance, RelWithSender = model.RelWithSender, SourceOfFund = model.SourceOfFund },
          CollAmt = model.CollAmt,
          CollCurr = model.CollCurr,
          DeliveryMethodId = Convert.ToInt32(model.DeliveryMethodId == "" || model.DeliveryMethodId == null ? "0" : model.DeliveryMethodId),
          ExRate = model.ExRate,
          ForexSessionId = model.FOREX_SESSION_ID,
          IsRealtime = false,
          PaymentType = model.PaymentType,
          PayoutAmt = model.PayoutAmt == "" ? "0" : model.PayoutAmt,
          PayoutCurr = model.PCurr,
          PayOutPartnerId = Convert.ToInt32(model.PayOutPartner == "" || model.PayOutPartner == null ? "0" : model.PayOutPartner),
          PBankId = Convert.ToInt32(bicNo),
          PBranchId = Convert.ToInt32(model.PBranch == "" || model.PBranch == null ? "0" : model.PBranch),
          PCountryId = 0,
          ProcessId = model.ProcessId,
          ProviderId = "",
          Receiver = new ReceiverInfo() { ReceiverId = model.ReceiverId, AccountNo = model.ReceiverAccountNo },
          RequestedBy = "mobile",
          ScDiscount = model.Discount,
          SCountryId = 0,
          SenderId = model.SenderId,
          ServiceCharge = model.ServiceCharge,
          SessionId = "",
          SIpAddress = model.IpAddress,
          SourceType = "",
          TpExRate = model.TpExRate,
          TpPCurr = model.TpPCurr,
          TransferAmt = model.TransferAmt,
          UserName = model.User,
          txnCompliance = model.txnCompliance,
          senderIsOrg = model.senderIsOrg,
          receiverIsOrg = model.receiverIsOrg,
          receiverBinn = model.receiverBinn,
          receiverBikk = model.receiverBikk,
          transactionDesc = model.transactionDesc,
          whichCur = model.whichCur
        };
        var obj = JsonConvert.SerializeObject(tp);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/mobileSendTxn";

          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<ExRateResponse>(jsonResponse.Data.ToString()) : null);
            jsonResponse.Data = a;

            return jsonResponse;
          } else {
            var errorJson = JsonConvert.DeserializeObject<ErrorJosn>(resultData);
            var jsonResponseData = JsonConvert.DeserializeObject<JsonResponse>(errorJson.Message);
            var data = JsonConvert.DeserializeObject<List<Data>>(jsonResponseData.Data.ToString());
            jsonResponse.Id = jsonResponseData.Id;
            jsonResponse.ResponseCode = jsonResponseData.ResponseCode;
            jsonResponse.Msg = jsonResponseData.Msg;
            jsonResponse.Data = data;
            jsonResponse.Extra = jsonResponseData.Extra;
            jsonResponse.Extra1 = jsonResponseData.Extra1;
            return jsonResponse;
          }
        } catch (Exception ex) {
          return new JsonResponse() {
            ResponseCode = "1",
            Msg = (ex.InnerException == null ? ex.Message : ex.InnerException.Message)
          };
        }
      }
    }

  }
}