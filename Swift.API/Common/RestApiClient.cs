using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;

namespace Swift.API.Common {
  public class RestApiClient {
    private static int timeOut = 100;//Convert.ToInt16(ConfigurationManager.AppSettings["ApiTimeOutSeconds"]);
    public static HttpClient CallThirdParty() {
      string thirdPartyUrl = ConfigurationManager.AppSettings["thirdparty_URL"].ToString();
      var httpClient = new HttpClient();
      httpClient.BaseAddress = new Uri(thirdPartyUrl);
      httpClient.DefaultRequestHeaders.Add("apiAccessKey", ConfigurationManager.AppSettings["thirdparty_HeaderToken"].ToString());
      httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
      httpClient.Timeout = new TimeSpan(0, 0, timeOut);
      return httpClient;
    }

    public static HttpClient CallMobileApi() {
      string mbUrl = ConfigurationManager.AppSettings["mobileapi_URL"].ToString();
      var httpClient = new HttpClient();
      httpClient.BaseAddress = new Uri(mbUrl);
      httpClient.DefaultRequestHeaders.TryAddWithoutValidation("SENDMN-TOKEN", "39587YT398@FBQOW8RY3#948R7GB@CNEQW987GF87$TD18$1981..919@@##joghndvberteiru");
      //httpClient.DefaultRequestHeaders.TryAddWithoutValidation("Bearer", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6ImRlbW8iLCJHdWlkIjoiMDBiMWU0M2UtOThlNy00YWRkLTk4MDMtOTI1NDlmMDA2OWYxIiwiQ3VzdG9tZXJObyI6IjIiLCJHbWVLZnRjQ2xpZW50SWQiOiJsN3h4ZmFkOGQyNzQ2ZDgyNGY0Y2JhM2M4NzJiMWFjMTNlZWQiLCJuYmYiOjE2NjA4Nzk2ODYsImV4cCI6MTY2MTQ3OTY4NiwiaWF0IjoxNjYwODc5Njg2LCJpc3MiOiJodHRwczovL21vYmlsZWFwaS5KTUVyZW1pdC5jb206ODAwMiIsImF1ZCI6Imh0dHBzOi8vbW9iaWxlYXBpLkpNRXJlbWl0LmNvbTo4MDAyIn0.QHHw24IJVWZjVbP-j9mbji4aJNGm5pTWq-vUZv0kp7k");
      httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6ImRlbW8iLCJHdWlkIjoiMDBiMWU0M2UtOThlNy00YWRkLTk4MDMtOTI1NDlmMDA2OWYxIiwiQ3VzdG9tZXJObyI6IjIiLCJHbWVLZnRjQ2xpZW50SWQiOiJsN3h4ZmFkOGQyNzQ2ZDgyNGY0Y2JhM2M4NzJiMWFjMTNlZWQiLCJuYmYiOjE2NjA4Nzk2ODYsImV4cCI6MTY2MTQ3OTY4NiwiaWF0IjoxNjYwODc5Njg2LCJpc3MiOiJodHRwczovL21vYmlsZWFwaS5KTUVyZW1pdC5jb206ODAwMiIsImF1ZCI6Imh0dHBzOi8vbW9iaWxlYXBpLkpNRXJlbWl0LmNvbTo4MDAyIn0.QHHw24IJVWZjVbP-j9mbji4aJNGm5pTWq-vUZv0kp7k");
      httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
      httpClient.Timeout = new TimeSpan(0, 0, timeOut);
      return httpClient;
    }
  }
}
