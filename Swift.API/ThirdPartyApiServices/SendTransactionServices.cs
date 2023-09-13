using Newtonsoft.Json;
using Swift.API.Common;
using Swift.API.Common.CancelTxn;
using Swift.API.Common.SendTxn;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;

namespace Swift.API.ThirdPartyApiServices {
  public class SendTransactionServices {
    public JsonResponse SendTransaction(SendTransactionRequest model) {
      //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var obj = JsonConvert.SerializeObject(model);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/sendTxn";

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

    public JsonResponse ReleaseTransaction(TFReleaseTxnRequest model) {
      //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var obj = JsonConvert.SerializeObject(model);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/releaseTxn";

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

    public JsonResponse GetPayerData(PayerDataRequest model) {
      //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var obj = JsonConvert.SerializeObject(model);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/payer";

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

    public JsonResponse CancelTransaction(CancelTxnRequest model) {
      //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var obj = JsonConvert.SerializeObject(model);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/cancelTxnRequest";

          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            return jsonResponse;
          } else {
            return new JsonResponse() {
              ResponseCode = "1",
              Msg = "Internal server error !"
            };
          }
        } catch (Exception ex) {
          return new JsonResponse() {
            ResponseCode = "1",
            Msg = (ex.InnerException == null ? ex.Message : ex.InnerException.Message)
          };
        }
      }
    }

    public JsonResponse SendHoldlimitTransaction(string user, string tranNo) {
      SendTransactionRequest model = new SendTransactionRequest();
      model.UserName = user;
      model.TranId = Convert.ToInt32(tranNo);
      //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var obj = JsonConvert.SerializeObject(model);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/sendHoldedTxn";

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

    public JsonResponse InterbankTransfer(SendmnTranMdl sndMdl) {
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var obj = JsonConvert.SerializeObject(sndMdl);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/interbankTransferSendmn";

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
  public class SendmnTranMdl {
    public string bankFlag { get; set; }
    public int amount { get; set; }
    public string fromAccount { get; set; }
    public string toAccount { get; set; }
    public string ProcessId { get; set; }
    public string UserName { get; set; }
    public string ProviderId { get; set; }
    public string SessionId { get; set; }
    public string betweenKhan { get; set; }
  }
}