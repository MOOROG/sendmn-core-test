using Newtonsoft.Json;
using Swift.API.Common;
using Swift.API.Common.Cancel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;

namespace Swift.API.ThirdPartyApiServices
{
    public class CancelRequestServices
    {
        public JsonResponse CancelTransaction(CancelTxn model)
        {
            //Log.Debug("Calculate | Calling third party api to fetch the ex-rate details " + JsonConvert.SerializeObject(model));
            using (var client = RestApiClient.CallThirdParty())
            {
                JsonResponse jsonResponse = new JsonResponse();
                var obj = JsonConvert.SerializeObject(model);
                var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
                try
                {
                    var URL = "api/v1/TP/cancelTxn";

                    HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
                    string resultData = resp.Content.ReadAsStringAsync().Result;
                    if (resp.IsSuccessStatusCode)
                    {
                        jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
                        if (jsonResponse.ResponseCode.Equals("104"))
                        {
                            var datas = JsonConvert.DeserializeObject<List<Data>>(jsonResponse.Data.ToString());
                            string msg = "";
                            foreach (var item in datas)
                            {
                                msg += "  " + item.Message;
                            }
                            jsonResponse.Msg += msg;
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
