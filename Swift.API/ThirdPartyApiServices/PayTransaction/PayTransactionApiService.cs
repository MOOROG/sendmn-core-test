using Newtonsoft.Json;
using Swift.API.Common;
using Swift.API.Common.PayTransaction;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;

namespace Swift.API.ThirdPartyApiServices.PayTransaction
{
    public class PayTransactionApiService : IPayTransactionApiService
    {
        public JsonResponse PaySearch(PayTxnCheck model)
        {
            //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
            using (var client = RestApiClient.CallThirdParty())
            {
                JsonResponse jsonResponse = new JsonResponse();
                var obj = JsonConvert.SerializeObject(model);
                var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
                try
                {
                    var URL = "api/v1/TP/payTxnCheck";

                    HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
                    string resultData = resp.Content.ReadAsStringAsync().Result;
                    if (resp.IsSuccessStatusCode)
                    {
                        jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
                        // var a = (jsonResponse.Data != null ?
                        // JsonConvert.DeserializeObject<ExRateResponse>(jsonResponse.Data.ToString())
                        // : null); jsonResponse.Data = a;

                        return jsonResponse;
                    }
                    else
                    {
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
                }
                catch (Exception ex)
                {
                    return new JsonResponse()
                    {
                        ResponseCode = "1",
                        Msg = (ex.InnerException == null ? ex.Message : ex.InnerException.Message)
                    };
                }
            }
        }

        public JsonResponse PayConfirm(PayTxnConfirm model)
        {
            //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
            using (var client = RestApiClient.CallThirdParty())
            {
                JsonResponse jsonResponse = new JsonResponse();
                var obj = JsonConvert.SerializeObject(model);
                var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
                try
                {
                    var URL = "api/v1/TP/payTxnConfirm";

                    HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
                    string resultData = resp.Content.ReadAsStringAsync().Result;
                    if (resp.IsSuccessStatusCode)
                    {
                        jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
                        return jsonResponse;
                    }
                    else
                    {
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
                }
                catch (Exception ex)
                {
                    return new JsonResponse()
                    {
                        ResponseCode = "1",
                        Msg = (ex.InnerException == null ? ex.Message : ex.InnerException.Message)
                    };
                }
            }
        }

        public JsonResponse DownloadRiaTxn(RiaTxnDownload model)
        {
            //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
            using (var client = RestApiClient.CallThirdParty())
            {
                JsonResponse jsonResponse = new JsonResponse();
                var obj = JsonConvert.SerializeObject(model);
                var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
                try
                {
                    var URL = "api/v1/TP/DownloadTransaction";

                    HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
                    string resultData = resp.Content.ReadAsStringAsync().Result;
                    if (resp.IsSuccessStatusCode)
                    {
                        jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
                        return jsonResponse;
                    }
                    else
                    {
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
                }
                catch (Exception ex)
                {
                    return new JsonResponse()
                    {
                        ResponseCode = "1",
                        Msg = (ex.InnerException == null ? ex.Message : ex.InnerException.Message)
                    };
                }
            }
        }

        public JsonResponse GetTxnStatus(dynamic model)
        {
            //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
            using (var client = RestApiClient.CallThirdParty())
            {
                JsonResponse jsonResponse = new JsonResponse();
                var obj = JsonConvert.SerializeObject(model);
                var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
                try
                {
                    HttpResponseMessage resp = client.PostAsync("api/v1/TP/PaidSyncToPartner", jbdContent).Result;
                    string resultData = resp.Content.ReadAsStringAsync().Result;
                    if (resp.IsSuccessStatusCode)
                    {
                        jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
                        return jsonResponse;
                    }
                    else
                    {
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
                }
                catch (Exception ex)
                {
                    return new JsonResponse()
                    {
                        ResponseCode = "1",
                        Msg = (ex.InnerException == null ? ex.Message : ex.InnerException.Message)
                    };
                }
            }
        }
    }
}