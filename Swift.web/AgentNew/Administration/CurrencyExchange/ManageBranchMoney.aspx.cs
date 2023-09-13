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
  public partial class ManageBranchMoney : System.Web.UI.Page {
    private readonly ILog _log = LogManager.GetLogger(typeof(ExchangeRateAPIService));
    protected const string GridName = "grid_ManageBranchMoney";
    private const string ViewFunctionId = "20232001";
    private const string ViewFunctionIdAgent = "40120000";

    private ExchangeDao rm = new ExchangeDao();
    private readonly RemittanceDao obj = new RemittanceDao();
    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

    private string _popUpParam = "dialogHeight:400px;dialogWidth:500px;dialogLeft:300;dialogTop:100;center:yes";
    public string PopUpParam {
      set { _popUpParam = value; }
      get { return _popUpParam; }
    }

    private string _approveText = "<img alt = \"View Changes\" border = \"0\" title = \"View Changes\" src=\"" + GetStatic.GetUrlRoot() + "/images/view-changes.jpg\" /> ";
    public string ApproveText {
      set { _approveText = value; }
      get { return _approveText; }
    }

    protected void Page_Load(object sender, EventArgs e) {
      if(!IsPostBack) {
        swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
        GetStatic.PrintMessage(Page);
        string sql = "select available_amt from [SendMnPro_Account].[dbo].ac_master where acct_num = '7000011'";
        DataSet ds = obj.ExecuteDataset(sql);
        if(ds != null && ds.Tables[0] != null)
          amount.Text = ds.Tables[0].Rows[0][0].ToString();
        else
          amount.Text = "0";
        swiftLibrary.SetDDL(ref reciever, "proc_dropDownLists @flag = 'adminUser', @user='" + GetStatic.GetUser() + "'", "VALUE", "TEXT", "", "");
        string reqMethod = Request.Form["MethodName"];
        switch(reqMethod) {
          case "Save":
            Save();
            break;
        }
      }
      LoadGrid();
    }

    private string autoSelect(string str1, string str2) {
      if(str1 == str2)
        return "selected=\"selected\"";
      else
        return "";
    }

    private string LoadPagingBlock(DataTable dtPaging) {
      string pagingTable = "";
      foreach(DataRow row in dtPaging.Rows) {
        pagingTable = GetPagingBlock(int.Parse(row["totalRow"].ToString()), int.Parse(row["pageNumber"].ToString()), int.Parse(row["pageSize"].ToString()));
      }
      return pagingTable;
    }

    private string GetPagingBlock(int _total_record, int _page, int _page_size) {
      var str = new StringBuilder("<input type = \"hidden\" name=\"money_page\" id = \"money_page\" value=\"" + _page.ToString() + "\">");
      str.Append("<tr><td colspan='20'><table class='table table-responsive table-bordered table-striped'>");
      str.Append("<tr>");
      str.Append("<td nowrap='nowrap'>Result :&nbsp;<b>" + _total_record.ToString() + "</b>&nbsp;records&nbsp;");
      str.Append("<select name=\"ddl_per_page\" onChange=\"submit_form();\">");
      str.Append("<option value=\"10\"" + autoSelect("10", _page_size.ToString()) + ">10</option>");
      str.Append("<option value=\"20\"" + autoSelect("20", _page_size.ToString()) + ">20</option>");
      str.Append("<option value=\"30\"" + autoSelect("30", _page_size.ToString()) + ">30</option>");
      str.Append("<option value=\"40\"" + autoSelect("40", _page_size.ToString()) + ">40</option>");
      str.Append("<option value=\"50\"" + autoSelect("50", _page_size.ToString()) + ">50</option>");
      str.Append("<option value=\"100\"" + autoSelect("100", _page_size.ToString()) + ">100</option>");
      str.Append("</select>&nbsp;&nbsp;per page&nbsp;&nbsp;");
      str.AppendLine("<select name=\"" + GridName + "_ddl_pageNumber\"  onChange=\"nav(this.value);\">");
      int remainder = _total_record % _page_size;
      int total_page = (_total_record - remainder) / _page_size;
      if(remainder > 0)
        total_page++;

      for(var i = 1; i <= total_page; i++) {
        str.AppendLine("<option value=\"" + i + "\"" + autoSelect(i.ToString(), _page.ToString()) + ">" + i + "</option>");
      }
      str.AppendLine("</tr></table></td></tr>");
      return str.ToString();
    }

    private void LoadGrid() {
      string _page_size = "10";
      string sortd = "DESC";
      int _page = 1;

      if(Request.Form["money_page"] != null)
        _page = Convert.ToInt32(Request.Form["money_page"].ToString());

      if(Request.Cookies["page_size"] != null)
        _page_size = Request.Cookies["page_size"].Value.ToString();

      if(Request.Form["ddl_per_page"] != null)
        _page_size = Request.Form["ddl_per_page"].ToString();

      Response.Cookies["page_size"].Value = _page_size;

      int page_size = Convert.ToUInt16(_page_size);
      var ds = rm.RateListLoadGrid("money",reciever.SelectedValue, _page.ToString(),"", page_size.ToString(), "acct_num", sortd);
      var dtPaging = ds.Tables[0];
      var dt = ds.Tables[1];
      var html = new StringBuilder();
      html.Append("<div class=\"table table-responsive\">");
      html.Append("<table class=\"table table-responsive table-bordered table-striped replenishment\">");
      html.Append(LoadPagingBlock(dtPaging));
      html.Append("<thead><tr class=\"hdtitle\">");
      html.Append("<th class=\"headingTH\" nowrap=\"nowrap\"><center>S.N</center></th>");
      html.Append("<th class=\"headingTH\" nowrap=\"nowrap\"><center>Account Number</center></th>");
      html.Append("<th class=\"headingTH\" nowrap=\"nowrap\"><center>Account Type</center></th>");
      html.Append("<th class=\"headingTH\" nowrap=\"nowrap\"><center>Currency</center></th>");
      html.Append("<th class=\"headingTH\" nowrap=\"nowrap\"><center>Amount</center></th>");
      html.Append("<th class=\"headingTH\" nowrap=\"nowrap\"><center>Add</center></th>");
      html.Append("<th class=\"headingTH\" nowrap=\"nowrap\"><center>Minus</center></th>");
      html.Append("</tr></thead> <tbody id=\"repBody\">");

      var i = 0;
      int cnt = 0;
      foreach(DataRow dr in dt.Rows) {
        cnt = cnt + 1;
        var id = Convert.ToInt32(dr["acct_id"]);
        html.Append(++i % 2 == 1 ? "<tr id=\"row_" + cnt + "\">" : "<tr id=\"row_" + cnt + "\">");
        html.Append("<td class='hidden'><input type=\"text\" id = \"trId" + cnt + "\" value=\"" + id + "\"/></td>");
        html.Append("<td class='hidden'><input type=\"text\" id = \"trAmountId" + cnt + "\" value=''/></td>");
        html.Append("<td class='hidden'><input type=\"text\" id = \"traccReportId" + cnt + "\" value=\"" + dr["acct_rpt_code"] + "\"/></td>");
        html.Append("<td class='hidden'><input type=\"text\" id = \"trcurId" + cnt + "\" value=\"" + dr["ac_currency"] + "\"/></td>");
        html.Append("<td class='hidden'><input type=\"text\" id = \"tramtId" + cnt + "\" value=\"" + GetStatic.ParseDouble(dr["amt"].ToString()) + "\"/></td>");
        html.Append("<td><center id='value" + cnt + "' class='value'>" + cnt + "</center></td>");
        html.Append("<td><center id='value" + cnt + "' class='value'>" + dr["acct_num"] + "</center></td>");
        html.Append("<td><center id='value" + cnt + "' class='value'>" + dr["acct_rpt_name"] + "</center></td>");
        html.Append("<td><center id='value" + cnt + "' class='value'>" + dr["ac_currency"] + "</center></td>");
        html.Append("<td><center id='value" + cnt + "' class='value'>" + GetStatic.ParseDouble(dr["amt"].ToString()) + "</center></td>");
        html.Append("<td class=\"tdPay\"><center id='value" + cnt + "' class='value'><input class='form-control' onkeyup=\"amountKeyup(event,'minusAmount'," + cnt + ");\" type=\"text\" id = \"addAmount" + cnt + "\" value=\"\"/>" + "</center></td>");
        html.Append("<td class=\"tdPay\"><center id='value" + cnt + "' class='value'><input class='form-control' onkeyup=\"amountKeyup(event,'addAmount'," + cnt + ");\" type=\"text\" id = \"minusAmount" + cnt + "\" value=\"\"/>" + "</center></td>");
        html.Append("</tr>");
      }

      html.Append("</tbody></table>");
      html.Append("</div>");
      rpt_replenishment.InnerHtml = html.ToString();
    }

    private void Save() {
      string data = Request.Form["data"];
      var myArray = JsonConvert.DeserializeObject<ReplenishmentModel[]>(data);
      DbResult _dbRes = new DbResult();
      foreach(ReplenishmentModel mod in myArray) {
        mod.flag = "money";
        mod.user = GetStatic.GetUser();
        _dbRes = rm.NubiaReplenishment(mod);
      }
      GetStatic.JsonResponse(_dbRes, Page);
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }
    protected void btnHidden_Click(object sender, EventArgs e) {
      LoadGrid();
    }
  }
}