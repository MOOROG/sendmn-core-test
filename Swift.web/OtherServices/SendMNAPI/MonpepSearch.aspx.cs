using Newtonsoft.Json;
using Swift.API.Common;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using static Swift.DAL.Model.Monpep;

namespace Swift.web.OtherServices.SendMNAPI {
  public partial class MonpepSearch : System.Web.UI.Page {
    private const string GridName = "grid_list";
    private const string ViewFunctionId = "20111300, 20192002";
    private const string AddFunctionId = "20111310";
    private const string ViewFunctionIdAgent = "40120000";
    private const string AddFunctionIdAgent = "40120010";

    private readonly SwiftGrid _grid = new SwiftGrid();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private RemittanceDao swift = new RemittanceDao();
    public string docPath;
    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
      }
      if (Request.Form[hdnCurrentTab.UniqueID] != null) {
        hdnCurrentTab.Value = Request.Form[hdnCurrentTab.UniqueID];
      } else {
        hdnCurrentTab.Value = "menu";
      }
      
    }

    private void Authenticate() {
      swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
    }
    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }

    public void LoadData() {
      string ns = nameSearch.Value;
      using (var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var jbdContent = new StringContent("{\"q\": \"" + ns + "\"}", Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/monPep";

          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if (resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            SearchEntityResponse ser = JsonConvert.DeserializeObject<SearchEntityResponse>(jsonResponse.Data.ToString());
            if (ser.results.Count > 0) {
              var aa = ser.results;
              List<SingleProperties> lProList = new List<SingleProperties>();
              foreach (Result dts in aa) {
                SingleProperties lPro = new SingleProperties();
                if (dts.properties.sourceUrl != null)
                  lPro.sourceUrl = dts.properties.sourceUrl[0].ToString();
                if (dts.properties.birthPlace != null)
                  lPro.birthPlace = dts.properties.birthPlace[0].ToString();
                if (dts.properties.gender != null)
                  lPro.gender = dts.properties.gender[0].ToString();
                if (dts.properties.name != null)
                  lPro.name = dts.properties.name[0].ToString();
                if (dts.properties.birthDate != null)
                  lPro.birthDate = dts.properties.birthDate[0].ToString();
                if (dts.properties.position != null)
                  lPro.position = dts.properties.position[0].ToString();
                lProList.Add(lPro);
              }
              monpepGrid.DataSource = lProList;
              monpepGrid.DataBind();
            }
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

    protected void searchBtn_Click(object sender, EventArgs e) {
      if (Request.Form[hdnCurrentTab.UniqueID].Equals("menu")) {
        monpepGrid.DataSource = null;
        monpepGrid.DataBind();
        LoadData();
      } else {
        mandakhGrid.DataSource = null;
        mandakhGrid.DataBind();
        List<Apeplist> pepList = new List<Apeplist>();
        var sql = "select name,nameorg,title,designation,dob,pob,gquality,lquality,nationality,passportNo,nationalId,address,listedOn,others from ApepList where (name like '%" + nameSearch.Value + "%' or nameorg like '%" + nameSearch.Value + "%')";
        var dt = swift.ExecuteDataset(sql).Tables[0];
        foreach (DataRow dr in dt.Rows) {
          Apeplist pepSingle = new Apeplist();
          pepSingle.name = dr["name"].ToString();
          pepSingle.nameorg = dr["nameorg"].ToString();
          pepSingle.title = dr["title"].ToString();
          pepSingle.designation = dr["designation"].ToString();
          pepSingle.dob = dr["dob"].ToString();
          pepSingle.pob = dr["pob"].ToString();
          pepSingle.gquality = dr["gquality"].ToString();
          pepSingle.lquality = dr["lquality"].ToString();
          pepSingle.nationality = dr["nationality"].ToString();
          pepSingle.passportNo = dr["passportNo"].ToString();
          pepSingle.nationalId = dr["nationalId"].ToString();
          pepSingle.address = dr["address"].ToString();
          pepSingle.listedOn = dr["listedOn"].ToString();
          pepSingle.others = dr["others"].ToString();
          pepList.Add(pepSingle);
        }
        mandakhGrid.DataSource = pepList;
        mandakhGrid.DataBind();
      }
    }
  }
}