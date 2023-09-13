using log4net;
using Newtonsoft.Json;
using Swift.API.Common;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.DAL.ExchangeSystem;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services.Description;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.Administration.CurrencyExchange {
  public partial class Replenishment : System.Web.UI.Page {
    private readonly ILog _log = LogManager.GetLogger(typeof(ExchangeRateAPIService));
    protected const string GridName = "grid_replenishment";
    private const string ViewFunctionId = "20230102";
    private const string ViewFunctionIdAgent = "40120000";

    private ExchangeDao rm = new ExchangeDao();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

    protected void Page_Load(object sender, EventArgs e) {
      if(!IsPostBack) {
        swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
        GetStatic.PrintMessage(Page);
        swiftLibrary.SetDDL(ref send, "proc_dropDownLists @flag = 'cUserBranch', @user='" + GetStatic.GetUser() + "'", "userId", "userName", "", "");
        swiftLibrary.SetDDL(ref reciever, "proc_dropDownLists @flag = 'pUserBranch', @user='" + GetStatic.GetUser() + "'", "userId", "userName", " ", " ");
        LoadGrid();
        string reqMethod = Request.Form["MethodName"];
        switch(reqMethod) {
          case "Save":
            Save();
            break;
        }
      }
    }

    private void LoadGrid() {
      var ds = rm.RateListLoadGrid("replenishment",GetStatic.GetUser(),"", "1", "20", "accType", "Desc");
      var dtPaging = ds.Tables[0];
      var dt = ds.Tables[1];
      var html = new StringBuilder();
      html.Append("<table class=\"table table-responsive table-bordered table-striped replenishment\">");
      html.Append("<thead><tr>");
      html.Append("<th>Denoms</th>");
      html.Append("<th>Acct. No.</th>");
      html.Append("<th>Account Type</th>");
      html.Append("<th>Currency</th>");
      html.Append("<th>Opening Balance</th>");
      html.Append("<th>Cash Top-Up</th>");
      html.Append("<th>Deduction</th>");
      html.Append("<th>Current Balance</th>");
      html.Append("<th>Close Balance</th>");
      html.Append("<th>Difference</th>");
      html.Append("</tr></thead><tbody>");
      var i = 0;
      int cnt = 0;
      foreach(DataRow dr in dt.Rows) {
        cnt = cnt + 1;
        var id = Convert.ToInt32(dr["account"]);
        html.Append(++i % 2 == 1 ? "<tr id=\"row_" + cnt + "\">" : "<tr id=\"row_" + cnt + "\">");
        html.Append("<td>" + cnt + "</td>");
        html.Append("<td><a href=\"javascript:void(0);\" onclick=\"ShowOld(" + dr["account"] + ");\">" + dr["account"] + "</a></td>");
        html.Append("<td>" + dr["accType"] + "</td>");
        html.Append("<td>" + dr["currency"] + "</td>");
        html.Append("<td>" + dr["oBalance"] + "</td>");
        html.Append("<td>" + dr["topup"] + "</td>");
        html.Append("<td>" + dr["removed"] + "</td>");
        html.Append("<td>" + dr["currentBalance"] + "</td>");
        html.Append("<td>" + dr["closeBalance"] + "</td>");
        html.Append("<td>" + dr["diff"] + "</td>");
        html.Append("</tr>");
      }
      html.Append("</tbody></table>");
      rpt_replenishment.InnerHtml = html.ToString();
    }

    private void Save() {
      DbResult _dbRes = new DbResult();
      _dbRes = rm.NubiaRateUpdate("close", GetStatic.GetUser(), Request.Form["receiver"], "0","0");
      GetStatic.JsonResponse(_dbRes, Page);
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }
  }
}