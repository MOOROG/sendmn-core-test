using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;

namespace Swift.API.MapAPIData
{
    public class DownloadAPIData
    {
        public ResponseModel ThirdPartyApiGetDataOnly<RequestModel, ResponseModel>(RequestModel model, string api_url, string objectName = "Data", string MethodType = "post")
        {
            ResponseModel _responseModel = default(ResponseModel);
            using (HttpClient httpClient = new HttpClient())
            {
                try
                {
                    httpClient.BaseAddress = new Uri(Utility.ReadWebConfig("baseURL", ""));
                    httpClient.DefaultRequestHeaders.Add("apiAccessKey", Utility.ReadWebConfig("apiAccessKey", ""));
                    httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                    httpClient.Timeout = new TimeSpan(0, 0, Convert.ToInt16(Utility.ReadWebConfig("timeOut", "")));
                    HttpResponseMessage resp = new HttpResponseMessage();
                    if (MethodType.ToLower().Equals("get"))
                        resp = httpClient.GetAsync(api_url).Result;
                    if (MethodType.ToLower().Equals("put"))
                    {
                        StringContent jbdContent = new StringContent(JsonConvert.SerializeObject(model).ToString(), Encoding.UTF8, "application/json");
                        resp = httpClient.PutAsync(api_url, jbdContent).Result;
                    }
                    if (MethodType.ToLower().Equals("post"))
                    {
                        var jsonData = JsonConvert.SerializeObject(model).ToString();
                        StringContent jbdContent = new StringContent(jsonData, Encoding.UTF8, "application/json");
                        resp = httpClient.PostAsync(api_url, jbdContent).Result;
                    }

                    if (resp.IsSuccessStatusCode)
                    {
                        var result = resp.Content.ReadAsStringAsync().Result;
                        JObject a = JObject.Parse(result);
                        //var aaaa = a["Data"].Value<JArray>();
                        _responseModel = a.ToObject<ResponseModel>();
                    }
                }
                catch (Exception)
                {
                    _responseModel = default(ResponseModel);
                }
            };
            return _responseModel;
        }
    }
}
