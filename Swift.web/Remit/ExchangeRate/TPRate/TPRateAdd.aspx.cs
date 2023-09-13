using Newtonsoft.Json;
using Swift.API.Common;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.ExchangeRate.TPRate {
  public partial class TPRateAdd : System.Web.UI.Page {
    private const string ViewFunctionId = "30012500";
    private readonly StaticDataDdl _sdd = new StaticDataDdl();
    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
      }
    }

    private void Authenticate() {
      _sdd.CheckAuthentication(ViewFunctionId);
    }

    protected void btnAdd_Click(object sender, EventArgs e) {
      var req = "{" +
        "\"ProviderId\": \"\"," +
        "\"action\": \"" + actionType.Text + "\"," +
        "\"currFrom\": \"" + fromCurr.Text + "\"," +
        "\"currTo\": \"" + toCurr.Text + "\"," +
        "\"multy\": \"" + multyValue.Text + "\"," +
        "\"div\": \"" + divValue.Text + "\"," +
        "\"rateType\": \"" + rateType.Text + "\"," +
        "\"date\": \"" + rateDate.Text.Replace("-", "") + "\"," +
        "\"ratePoint\": \"" + ratePoint.Text + "\"" +
        "}";
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var jbdContent = new StringContent(req, Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/rateAdd";

          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
          } else {
            jsonResponse.ResponseCode = "999";
            jsonResponse.Msg = "Алдаа! " + resultData;
          }
        } catch (Exception ex) {
          jsonResponse = new JsonResponse() {
            ResponseCode = "1",
            Msg = (ex.InnerException == null ? ex.Message : ex.InnerException.Message)
          };
        }
        GetStatic.AlertMessage(this, jsonResponse.ResponseCode + " : " + jsonResponse.Msg);
      }
    }

    protected void btnBulkAdd_Click(object sender, EventArgs e) {
      string message = "";
      foreach (ListItem ratePointItem in ratePoint.Items) {
        var req = "{" +
          "\"ProviderId\": \"\"," +
          "\"action\": \"" + actionType.Text + "\"," +
          "\"currFrom\": \"" + fromCurr.Text + "\"," +
          "\"currTo\": \"" + toCurr.Text + "\"," +
          "\"multy\": \"" + multyValue.Text + "\"," +
          "\"div\": \"" + divValue.Text + "\"," +
          "\"rateType\": \"" + rateType.Text + "\"," +
          "\"date\": \"" + rateDate.Text.Replace("-", "") + "\"," +
          "\"ratePoint\": \"" + ratePointItem.Value + "\"" +
          "}";
        using (var client = RestApiClient.CallThirdParty()) {
          JsonResponse jsonResponse = new JsonResponse();
          var jbdContent = new StringContent(req, Encoding.UTF8, "application/json");
          try {
            var URL = "api/v1/TP/rateAdd";
            
            HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
            string resultData = resp.Content.ReadAsStringAsync().Result;
            if (resp.IsSuccessStatusCode) {
              jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            } else {
              jsonResponse.ResponseCode = "999";
              jsonResponse.Msg = "Алдаа! " + resultData;
            }
          } catch (Exception ex) {
            jsonResponse = new JsonResponse() {
              ResponseCode = "1",
              Msg = (ex.InnerException == null ? ex.Message : ex.InnerException.Message)
            };
          }
          message += "(" + ratePointItem.Value + " : " + jsonResponse.ResponseCode + " : " + jsonResponse.Msg + ") ";
        }
      }
      GetStatic.AlertMessage(this, message);
    }
  }
}