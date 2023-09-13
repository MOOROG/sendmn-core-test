using Newtonsoft.Json;
using Swift.API.Common;
using Swift.API.Common.SyncModel.Bank;
using Swift.API.Common.SyncModel.Polaris;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;

namespace Swift.API.ThirdPartyApiServices {
  public class SyncBankAndBranchService {
    public JsonResponse GetBankList(BankRequest model) {
      //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var obj = JsonConvert.SerializeObject(model);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/bankList";

          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<List<BankResponse>>(jsonResponse.Data.ToString()) : null);
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

    public JsonResponse GetBankBranchList(BankRequest model) {
      //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var obj = JsonConvert.SerializeObject(model);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/bankBranchList";

          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<List<BankBranchResponse>>(jsonResponse.Data.ToString()) : null);
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
    public JsonResponse GetBankStatement(GetStatus model) {
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var obj = JsonConvert.SerializeObject(model);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/khanbankStatement";

          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<List<Statements>>(jsonResponse.Data.ToString()) : null);
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

    public JsonResponse GetGlmtBankStatement(GetStatus model) {
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var obj = JsonConvert.SerializeObject(model);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/GolomtApi";

          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<List<Ntry>>(jsonResponse.Data.ToString()) : null);
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
    public JsonResponse GetTDBStatement(GetStatus model) {
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var obj = JsonConvert.SerializeObject(model);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/TDBApi";
          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<List<Ntry>>(jsonResponse.Data.ToString()) : null);
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

    public JsonResponse SyncWithPolaris(List<PolarisModels> listPmdls) {
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var obj = JsonConvert.SerializeObject(listPmdls);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/polarisTransaction";

          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<List<Statements>>(jsonResponse.Data.ToString()) : null);
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

    public JsonResponse GetStateBankStatement(string stDate, string toDate) {
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        SbStatementsReq stb = new SbStatementsReq {
          acntNo = null,
          startDate = stDate,
          endDate = toDate,
          tranFlag = "statement"
        };
        var obj = JsonConvert.SerializeObject(stb);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/stateBankTransfer";

          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<List<SbStatementsRes>>(jsonResponse.Data.ToString()) : null);
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

    public JsonResponse GetXacBankStatement(string stDate, string toDate) {
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        XacBankRequest stb = new XacBankRequest {
          startDate = stDate,
          endDate = toDate
        };
        var obj = JsonConvert.SerializeObject(stb);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/XacBankTransfer";

          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<List<XacStatementsResDtl>>(jsonResponse.Data.ToString()) : null);
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

    public class SbStatementsReq {
      public string acntNo { get; set; }
      public string startDate { get; set; }
      public string endDate { get; set; }
      public string tranFlag { get; set; }
    }

    public class SbStatementsRes {
      public string JrNo { get; set; }
      public string JrItemNo { get; set; }
      public string AcntNo { get; set; }
      public string CurCode { get; set; }
      public string TxnType { get; set; }
      public double Amount { get; set; }
      public double Rate { get; set; }
      public double Balance { get; set; }
      public string TxnDate { get; set; }
      public string SysDate { get; set; }
      public string TxnDesc { get; set; }
      public string ContAcntNo { get; set; }
      public string ContAcntName { get; set; }
      public string ContBankCode { get; set; }
      public string Location { get; set; }
      public string BranchNo { get; set; }
      public string Corr { get; set; }
    }

    public class XacBankRequest {
      public string account { get; set; }
      public string startDate { get; set; }
      public string endDate { get; set; }
    }
    public class XacStatementsResDtl {
      //public string PRODUCTNAME { get; set; }
      //public string BRANCHNAME { get; set; }
      public string CREDITAMOUNT { get; set; }
      public string ACCOUNTID { get; set; }
      public string CUSTOMERID { get; set; }
      //public string CUSTOMERNAME { get; set; }
      //public string BRANCHID { get; set; }
      public string CLOSINGBALANCE { get; set; }
      //public string OPENINGBALANCE { get; set; }
      public string OPENDATE { get; set; }
      //public string RATE { get; set; }
      //public string TRXDATE { get; set; }
      //public string DEBITAMOUNT { get; set; }
      //public string EODBALANCE { get; set; }
      public string DESCRIPTION { get; set; }
      //public string CURRENCY { get; set; }
    }
  }
}