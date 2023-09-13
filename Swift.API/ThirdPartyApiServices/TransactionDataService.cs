using Newtonsoft.Json;
using Swift.API.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.ModelBinding;

namespace Swift.API.ThirdPartyApiServices
{
    public class TransactionDataService
    {
        public JsonResponse GetTransactionData(TransactionDataRequest model)
        {
            //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
            using (var client = RestApiClient.CallThirdParty())
            {
                JsonResponse jsonResponse = new JsonResponse();
                var obj = JsonConvert.SerializeObject(model);
                var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
                try
                {
                    var URL = "api/v1/TP/getErpTransactionData";

                    HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
                    string resultData = resp.Content.ReadAsStringAsync().Result;
                    if (resp.IsSuccessStatusCode)
                    {
                        jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
                        if (model.flag == "currency")
                        {
                            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<List<TransactionCurrencyDataResponse>>(jsonResponse.Data.ToString()) : null);
                            jsonResponse.Data = a;
                        }
                        else if(model.flag == "days")
                        {
                            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<List<TransactionDaysDataResponse>>(jsonResponse.Data.ToString()) : null);
                            jsonResponse.Data = a;
                        }
                        else if (model.flag == "agentList")
                        {
                            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<List<AgentDataResponse>>(jsonResponse.Data.ToString()) : null);
                            jsonResponse.Data = a;
                        }
                        else if (model.flag == "countryList")
                        {
                            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<List<CountryDataResponse>>(jsonResponse.Data.ToString()) : null);
                            jsonResponse.Data = a;
                        }
                        else if (model.flag == "timeline")
                        {
                            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<List<TimelineDataResponse>>(jsonResponse.Data.ToString()) : null);
                            jsonResponse.Data = a;
                        }
                        else
                        {
                            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<List<TransactionDataResponse>>(jsonResponse.Data.ToString()) : null);
                            jsonResponse.Data = a;
                        }
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
