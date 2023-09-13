using Newtonsoft.Json;
using Swift.API.Common;
using Swift.DAL.ExchangeSystem;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.Administration.CurrencyExchange {
  public partial class CashTopUp : System.Web.UI.Page {
    private const string GridName = "grid_listCash";
    private const string ViewFunctionId = "20230101";
    private readonly StaticDataDdl _sl = new StaticDataDdl();
    private readonly SwiftGrid _grid = new SwiftGrid();
    private ExchangeDao rm = new ExchangeDao();
    protected void Page_Load(object sender, EventArgs e) {
      if(!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
        string reqMethod = Request.Form["MethodName"];
        switch(reqMethod) {
          case "Save":
            Save();
            break;
        }
        LoadGrid();
      }
    }

    private void Authenticate() {
      _sl.CheckAuthentication(ViewFunctionId);
    }
    protected string GetParam() {
      return GetStatic.ReadQueryString("account", "");
    }

    private void LoadGrid() {
      accVal.Text = GetParam();
      var ds = rm.RateListLoadGrid("accDetail",GetStatic.GetUser(),accVal.Text, "1", "10", "currency", "Desc");
      var dtPaging = ds.Tables[0];
      var dt = ds.Tables[1];
      var html = new StringBuilder();
      html.Append("<table>");
      html.Append("<thead><tr><th rowspan=\"2\">Currency</th><th rowspan=\"2\">Note</th>" +
        "<th style=\"background-color: #c3d5ea\" colspan=\"2\">Opening Balance</th>" +
        "<th style=\"background-color: #adcc9a\" rowspan=\"2\">Income Number</th>" +
        "<th style=\"background-color: #f3b6b5\" rowspan=\"2\">Expense Number</th>" +
        "<th style=\"background-color: #adcc9a\" rowspan=\"2\">Cash Top-Up</th>" +
        "<th style=\"background-color: #f3b6b5\" rowspan=\"2\">Deduction</th>" +
        "<th style=\"background-color: #e2efda\" colspan=\"2\">Current Balance</th>" +
        "<th style=\"background-color: #e2efda\" colspan=\"2\">Closing Balance</th>" +
        "<th style=\"background-color: #f9cbac\" colspan=\"2\">Difference</th></tr><tr>");
      html.Append("<th style=\"background-color: #c3d5ea\">Number</th>");
      html.Append("<th style=\"background-color: #c3d5ea\">Amount</th>");
      html.Append("<th style=\"background-color: #e2efda\">Number</th>");
      html.Append("<th style=\"background-color: #e2efda\">Amount</th>");
      html.Append("<th style=\"background-color: #e2efda\">Number</th>");
      html.Append("<th style=\"background-color: #e2efda\">Amount</th>");
      html.Append("<th style=\"background-color: #f9cbac\">Number</th>");
      html.Append("<th style=\"background-color: #f9cbac\">Amount</th>");
      html.Append("</tr></thead><tbody class=\"updateBody\">");
      var i = 0;
      int cnt = 0;
      html.Append("<td rowspan=\"" + dt.Rows.Count + 1 + "\" class=\"curId\"></td>");
      foreach(DataRow dr in dt.Rows) {
        cnt = cnt + 1;
        var id = Convert.ToInt32(dr["account"]);
        html.Append(++i % 2 == 1 ? "<tr id=\"row_" + cnt + "\">" : "<tr id=\"row_" + cnt + "\">");
        curVal.Text = dr["currency"].ToString();
        html.Append("<td class=\"hidden account" + cnt + "\">" + id + "/></td>");
        html.Append("<td class=\"note" + cnt + "\">" + dr["moneyNote"] + "</td>");
        html.Append("<td style=\"background-color: #c3d5ea\" class=\"oBalance" + cnt + "\">" + dr["openBalance"] + "</td>");
        html.Append("<td style=\"background-color: #c3d5ea\" class=\"oAmount" + cnt + "\">" + dr["openAmount"] + "</td>");
        html.Append("<td style=\"background-color: #adcc9a\" class=\"income" + cnt + "\">" + dr["income"] + "</td>");
        html.Append("<td style=\"background-color: #f3b6b5\" class=\"expense" + cnt + "\">" + dr["expense"] + "</td>");
        html.Append("<td style=\"background-color: #adcc9a\"><input class=\"topUpAmount topUp" + cnt + "\" " +
          "style=\"background-color: #adcc9a;border: 1px solid #adcc9a;\" " +
          "type=\"number\" min=\"0\" value\"\"></td>");
        html.Append("<td style=\"background-color: #f3b6b5\"><input class=\"removeAmount remove" + cnt + "\" " +
          "style=\"background-color: #f3b6b5;border: 1px solid #f3b6b5;\" " +
          "type=\"number\" value\"\"></td>");
        html.Append("<td style=\"background-color: #e2efda\" class=\"curBalance" + cnt + "\">" + dr["currentBalance"] + "</td>");
        html.Append("<td style=\"background-color: #e2efda\" class=\"curBalanceAmt" + cnt + "\">" + dr["cBalanceAmount"] + "</td>");
        html.Append("<td style=\"background-color: #e2efda\"><input class=\"closeAmount closeBalance" + cnt + "\" " +
          "style=\"background-color: #e2efda;border: 1px solid #e2efda;\" type=\"number\" min=\"0\" value\"\"></td>");
        html.Append("<td style=\"background-color: #e2efda\" class=\"closeBalanceAmt" + cnt + "\">" + dr["closeBalanceAmt"] + "</td>");
        html.Append("<td style=\"background-color: #f9cbac\" class=\"diff" + cnt + "\">" + dr["difference"] + "</td>");
        html.Append("<td style=\"background-color: #f9cbac\" class=\"diffAmount" + cnt + "\">" + dr["differenceAmount"] + "</td>");
        html.Append("</tr>");
      }
      html.Append("</tbody></table>");
      function_grid.InnerHtml = html.ToString();
    }
    private void Save() {
      string data = Request.Form["data"];
      ReplenishmentModel mod = JsonConvert.DeserializeObject<ReplenishmentModel>(data);
      DbResult _dbRes = new DbResult();
      mod.user = GetStatic.GetUser();
      mod.flag = "replenishment";
      _dbRes = rm.NubiaReplenishment(mod);
      GetStatic.JsonResponse(_dbRes, Page);
    }

  }
}