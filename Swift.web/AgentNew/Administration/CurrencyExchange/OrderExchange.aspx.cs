
using Swift.DAL.BL.LoadMoneyWalletDao;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Web.UI.WebControls;
using static Swift.web.Autocomplete;
using Swift.API.Common;
using Swift.API.Common.ExRate;
using System.Collections.Generic;
using System.Data;
using Newtonsoft.Json;
using System.Web.Services;
using static iText.StyledXmlParser.Jsoup.Select.Evaluator;
using System.Text;
using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.DAL.ExchangeSystem;
using Microsoft.Extensions.Primitives;
using iText.StyledXmlParser.Jsoup.Helper;

namespace Swift.web.AgentNew.Administration.CurrencyExchange {
  public partial class OrderExchange : System.Web.UI.Page {

    private const string ViewFunctionId = "20230101";
    private const string ViewFunctionIdAgent = "40120000";

    private ExchangeDao ex = new ExchangeDao();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    protected long GetId() {
      return GetStatic.ReadNumericDataFromQueryString("orderId");
    }
    protected void Page_Load(object sender, EventArgs e) {
      swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
      if(GetId() > 0)
        PopulateDataById();
      string reqMethod = Request.Form["MethodName"];
      switch(reqMethod) {
        case "mntTCA":
          LoadGrid(reqMethod);
          break;
        case "other":
          LoadGrid(reqMethod);
          break;
        case "add_Click":
          add_Click();
          break;
      }
    }

    private void add_Click() {
      ExrateCurrency mod = new ExrateCurrency(){
        orderId = Request.Form["orderId"].ToString(),
        type = Request.Form["type"].ToString(),
        paymentMode = Request.Form["paymentMode"].ToString(),
        firstName = Request.Form["firstName"].ToString(),
        middleName = Request.Form["middleName"].ToString(),
        lastName = Request.Form["lastName"].ToString(),
        regNumber = Request.Form["rd"].ToString(),
        mobile = Request.Form["mobile"].ToString(),
        accountNumber = Request.Form["accountNumber"].ToString(),
        cRate = Request.Form["cRate"].ToString(),
        pRate = Request.Form["pRate"].ToString(),
        cCur = Request.Form["cCur"].ToString(),
        pCur = Request.Form["pCur"].ToString(),
        cashAmount1 = Request.Form["cashAmount1"].ToString(),
        cashAmount2 = Request.Form["cashAmount2"].ToString(),
        accAmount = Request.Form["accAmount"].ToString(),
        customerRate = Request.Form["customerRate"].ToString(),
        mntVal = Request.Form["mntVal"].ToString(),
        curVal = Request.Form["curVal"].ToString(),
        user = GetStatic.GetUser(),
        agentId = GetStatic.GetAgentId(),
      };
      DbResult _dbRes = ex.UploadCurrencyExchange(mod);
      GetStatic.JsonResponse(_dbRes, Page);
    }

    private void LoadGrid(string curId) {
      var ds = ex.mntTbaListLoadGrid(curId,Request.Form["curr"],GetStatic.GetUser(), "1", "10", "id", "ASC");
      var dt = ds.Tables[1];
      string htmlData = "";
      htmlData = htmlData + "<table><tr style=\"background: #fdd537;\"><th colspan=\"3\">" + Request.Form["curr"] + "</th></tr><tr><th>Notes</th><th>Numbers</th>";
      htmlData = htmlData + "<th>Amounts</th></tr>";
      var i = 0;
      int cnt = 0;
      int sum = 0;
      foreach(DataRow dr in dt.Rows) {
        cnt = cnt + 1;
        var id = Convert.ToInt32(dr["id"]);
        if(Convert.ToInt32(dr["moneyNote"]) > 0) {
          htmlData = htmlData + "<tr id=\"row_" + id + "\">";
          htmlData = htmlData + "<td>" + String.Format("{0:N0}", dr["moneyNote"]) + "</td>";
          htmlData = htmlData + "<td class=\"" + Request.Form["curr"] + dr["moneyNote"] + "Stock\">" + dr["currentBalance"] + "</td>";
          htmlData = htmlData + "<td>" + String.Format("{0:N0}", dr["sum"]) + "</td>";
          htmlData = htmlData + "</tr>";
          sum = sum + Convert.ToInt32(dr["sum"]);
        } else {
          htmlData = htmlData + "<tr style=\"background: #fdd537;\"><th>Stock /Cash/</th><th colspan=\"2\" class=\"cash" + Request.Form["curr"] + "Stock\">" + String.Format("{0:N0}", sum) + "</th></tr>";
          if(Request.Form["curr"] == "MNT")
            htmlData = htmlData + "<tr style=\"background: #fdd537;\"><th>Stock /Acc/</th><th colspan=\"2\" class=\"accMNTStock\">" + String.Format("{0:N0}", dr["sum"]) + "</th></tr>";
        }
      }
      htmlData = htmlData + "</table>";
      GetStatic.JsonResponse(htmlData, Page);
    }

    private void PopulateDataById() {
      string order = ex.FilterString(GetId().ToString());
      string sql = "EXEC [proc_currencyExchange] @flag = 'orderExchange', @id = " +order;
      DataRow dr = ex.ExecuteDataRow(sql);
      if(dr != null) {
        firstname.Text = dr["firstName"].ToString();
        middleName.Text = dr["middleName"].ToString();
        lastname.Text = dr["lastName1"].ToString();
        rd.Text = dr["idNumber"].ToString();
        mobileNum.Text = dr["mobile"].ToString();
        accountNumber.Text = dr["bankAccountNo"].ToString();
        rateView.Text = dr["rate"].ToString().Trim();
        cAmountHide.Text = dr["fromCurrency"].ToString().Trim();
        pAmountHide.Text = dr["toCurrency"].ToString().Trim();
        pCurrencyHide.Text = dr["toCurrencyCode"].ToString().Trim();
        orderId.Text = order;
      }
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }
  }
}