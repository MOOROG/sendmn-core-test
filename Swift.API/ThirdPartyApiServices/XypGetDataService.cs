using Newtonsoft.Json;
using Swift.API.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace Swift.API.ThirdPartyApiServices {
  public class XypGetDataService {
    public JsonResponse GetCizitzenInfo(string regNum, string fingerImgPath) {
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        CitizenIdInfoMdl ciim = new CitizenIdInfoMdl {
          regnumField = regNum,
          fingerImgPath = fingerImgPath
        };
        var obj = JsonConvert.SerializeObject(ciim);
        var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/bankList";

          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            var a = (jsonResponse.Data != null ? JsonConvert.DeserializeObject<List<CitizenIdInfoMdl>>(jsonResponse.Data.ToString()) : null);
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

    public class CitizenIdInfoMdl {
      public string civilIdField { get; set; }
      public string regnumField { get; set; }
      public string fingerImgPath { get; set; }
    }
  }
}
