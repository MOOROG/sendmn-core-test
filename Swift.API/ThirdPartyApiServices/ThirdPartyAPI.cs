using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;

namespace Swift.API.ThirdPartyApiServices {
  public class ThirdPartyAPI {
    private static int timeOut = 100;
    private string tp_base_url = Utility.ReadWebConfig("thirdparty_URL", "");
    private string apiAccessKey = Utility.ReadWebConfig("thirdparty_HeaderToken", "");

    public ResponseModel ThirdPartyApiGetDataOnly<RequestModel, ResponseModel>(RequestModel model, string api_url, out APIJsonResponse jsonResponse, string MethodType = "post") {
      ResponseModel _responseModel = default(ResponseModel);
      using (HttpClient httpClient = new HttpClient()) {
        try {
          httpClient.BaseAddress = new Uri(tp_base_url);
          //httpClient.DefaultRequestHeaders.Add("apiAccessKey", apiAccessKey);
          httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
          httpClient.Timeout = new TimeSpan(0, 0, timeOut);
          HttpResponseMessage resp = new HttpResponseMessage();
          var jsonData = JsonConvert.SerializeObject(model).ToString();
          StringContent jbdContent = new StringContent(jsonData, Encoding.UTF8, "application/json");
          resp = httpClient.PostAsync(api_url, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            var result = resp.Content.ReadAsStringAsync().Result;
            JObject a = JObject.Parse(result);
            _responseModel = a.ToObject<ResponseModel>();
          } else {
            ErrorJosn errorJson = JsonConvert.DeserializeObject<ErrorJosn>(resultData);
            APIJsonResponse jsonResponseData = JsonConvert.DeserializeObject<APIJsonResponse>(errorJson.Message);
            List<Data> data = JsonConvert.DeserializeObject<List<Data>>(jsonResponseData.Data.ToString());
            jsonResponse = new APIJsonResponse() {
              Id = jsonResponseData.Id,
              Msg = jsonResponseData.Msg,
              Data = data,
              Extra = jsonResponseData.Extra,
              Extra1 = jsonResponseData.Extra1
            };
          }
        } catch (HttpRequestException ex) {
          jsonResponse = new APIJsonResponse() {
            ResponseCode = "999",
            Msg = ex.Message,
            Data = ex.Data,
          };
          _responseModel = default(ResponseModel);
        }
      };

      jsonResponse = new APIJsonResponse() {
        ResponseCode = "0",
        Msg = "Api Calling process successfully!"
      };
      return _responseModel;
    }
  }

  public class APIJsonResponse {
    public string ResponseCode { get; set; }
    public string Msg { get; set; }
    public string Id { get; set; }
    public object Data { get; set; }
    public string Extra { get; set; }
    public string Extra1 { get; set; }

    public void SetResponse(string responseCode, string msg, string id = null, string extra = null, string extra1 = null) {
      ResponseCode = responseCode;
      Msg = msg;
      Id = id;
      Extra = extra;
      Extra1 = extra1;
    }
  }

  public class ErrorJosn {
    public string Message { get; set; }
  }

  public class Data {
    public string Name { get; set; }
    public string Message { get; set; }
  }

}
