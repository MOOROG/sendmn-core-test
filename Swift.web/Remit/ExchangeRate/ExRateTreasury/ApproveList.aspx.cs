using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.ExchangeRate.ExRateTreasury {
  public partial class ApproveList : System.Web.UI.Page {
    private ExRateTreasuryDao obj = new ExRateTreasuryDao();
    private readonly StaticDataDdl _sdd = new StaticDataDdl();
    private readonly SwiftTab _tab = new SwiftTab();
    private const string GridName = "grd_erta";
    private const string ViewFunctionId = "30012300";
    private const string ApproveFunctionId = "30012330";

    private string chkList = "";

    protected void Page_Load(object sender, EventArgs e) {
      Authenticate();
      chkList = Request.Form["chkId"];
      if(!IsPostBack) {
        GetStatic.AlertMessage(Page);
        PopulateDdl();
        LoadTab();
      }
      LoadGrid();
    }

    protected string GetIsFw() {
      return GetStatic.ReadQueryString("isFw", "");
    }

    private void LoadTab() {
      var isFw = GetIsFw();

      var queryStrings = "?isFw=" + isFw;
      _tab.NoOfTabPerRow = 8;
      _tab.TabList = new List<TabField>
                         {
                                   new TabField("Treasury Rate", "List.aspx" + queryStrings),
                                   new TabField("Add New", "Manage.aspx" + queryStrings),
                                   new TabField("Approve", "", true),
                                   new TabField("Reject", "RejectList.aspx" + queryStrings),
                                   new TabField("My changes", "MyChangeList.aspx" + queryStrings),
                                   new TabField("Copy Rate", "CopyAgentWiseRate.aspx" + queryStrings),
                               };

      divTab.InnerHtml = _tab.CreateTab();
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
      var str = new StringBuilder("<input type = \"hidden\" name=\"hdd_curr_page\" id = \"hdd_curr_page\" value=\"" + _page.ToString() + "\">");
      str.Append("<tr><td colspan='40'><table class='table table-responsive table-striped table-bordered'>");
      str.Append("<td  class=\"GridTextNormal\" nowrap='nowrap'>Result :&nbsp;<b>" + _total_record.ToString() + "</b>&nbsp;records&nbsp;");
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
      for(var i = 1; i <= total_page; i++) {
        str.AppendLine("<option value=\"" + i + "\"" + autoSelect(i.ToString(), _page.ToString()) + ">" + i + "</option>");
      }
      str.Append("</td>");
      str.AppendLine("<td width=\"100%\" align='right'>");

      if(_page > 1)
        str.AppendLine("<img style = \"cursor:pointer\" onclick =\"Nav(" + (_page - 1) + ", '" + GridName + "');\" title='Go to Previous page(Page : " + (_page - 1) + ")' src='" + GetStatic.GetUrlRoot() + "/images/prev.gif' border='0'>&nbsp;&nbsp;&nbsp;");
      else
        str.AppendLine("<img src='" + GetStatic.GetUrlRoot() + "/images/disprev.gif' border='0'>&nbsp;&nbsp;&nbsp;");

      if(_page * _page_size < _total_record)
        str.AppendLine("<img style = \"cursor:pointer\" onclick =\"Nav(" + (_page + 1) + ", '" + GridName + "');\" title='Go to Next page(Page : " + (_page + 1) + ")' src='" + GetStatic.GetUrlRoot() + "/images/next.gif' border='0'>&nbsp;&nbsp;&nbsp;");
      else
        str.AppendLine("<img src='" + GetStatic.GetUrlRoot() + "/images/disnext.gif' border='0'>&nbsp;&nbsp;&nbsp;");

      //str.AppendLine("<a href=\"Manage.aspx\" title=\"Add New Record\"><img src='" +
      //                        GetStatic.GetUrlRoot() + "/images/add.gif' border='0'></a>");

      // str.AppendLine("&nbsp; <img title = 'Export to Excel' style = 'cursor:pointer' onclick
      // = \"DownloadGrid('" + GetStatic.GetUrlRoot() + "');\" src='" + GetStatic.GetUrlRoot()
      // + "/images/excel.gif' border='0'>");

      str.AppendLine("</td>");
      str.AppendLine("</tr></table></td></tr>");

      return str.ToString();
    }

    private void Authenticate() {
      _sdd.CheckAuthentication(ViewFunctionId + "," + ApproveFunctionId);
      btnApprove.Visible = _sdd.HasRight(ApproveFunctionId);
    }

    private void LoadGrid() {
      string _page_size = "10";
      string sortd = "ASC";
      int _page = 1;

      if(Request.Form["hdd_curr_page"] != null)
        _page = Convert.ToInt32(Request.Form["hdd_curr_page"].ToString());

      if(Request.Cookies["page_size"] != null)
        _page_size = Request.Cookies["page_size"].Value.ToString();

      if(Request.Form["ddl_per_page"] != null)
        _page_size = Request.Form["ddl_per_page"].ToString();

      Response.Cookies["page_size"].Value = _page_size;

      var ds = obj.LoadGridApprove(GetStatic.GetUser(), _page.ToString(), _page_size, "exRateTreasuryId", sortd, "Y", cCountry.Text, cAgent.Text, cCurrency.Text, pCountry.Text, pAgent.Text, pCurrency.Text, tranType.Text);
      var dtPaging = ds.Tables[0];
      var dt = ds.Tables[1];
      var html = new StringBuilder();
      html.Append("<div class=\"responsive-table\">");
      html.Append("<table class='table table-responsive table-striped table-bordered'>");
      html.Append(LoadPagingBlock(dtPaging));
      html.Append("<tr class=\"hdtitle\">");
      html.Append("<th rowspan=\"3\" Class=\"headingTH\" nowrap = \"nowrap\"><a href=\"javascript:void(0);\" onClick=\"CheckAll(this)\">√</a></th>");
      html.Append("<th colspan=\"2\" rowspan=\"2\" class=\"headingTH\"><center>Send</center></th>");
      html.Append("<th colspan=\"2\" rowspan=\"2\" class=\"headingTH\"><center>Receive</center></th>");
      html.Append("<th rowspan=\"3\" class=\"headingTH\">Service Type</th>");
      html.Append("<th rowspan=\"3\" class=\"headingTH\">Send<br/>Curr.</th>");
      html.Append("<th rowspan=\"3\" class=\"headingTH\">Receive<br/>Curr.</th>");
      html.Append("<th rowspan=\"3\" class=\"headingTH\">Mode</th>");
      html.Append("<th rowspan=\"3\" class=\"headingTH\">Value</th>");
      html.Append("<th colspan=\"8\" class=\"headingTH\"><center>Head Office<span id=\"agentfxs\" onclick=\"ShowAgentFxCol();\" title=\"Show Agent Fx\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
      html.Append("<th rowspan=\"2\" colspan=\"2\" class=\"headingTH\" ondblclick=\"HideAgentFxCol();\" style=\"cursor: pointer;\"><center><span id=\"agentfxh\" onclick=\"HideAgentFxCol();\" title=\"Hide Agent Fx\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Agent FX<span id=\"tolerances\" onclick=\"ShowToleranceCol();\" title=\"Show Tolerance\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
      html.Append("<th colspan=\"3\" class=\"headingTH\" ondblclick=\"HideToleranceCol();\" style=\"cursor: pointer;\"><center><span id=\"toleranceh\" onclick=\"HideToleranceCol();\" title=\"Hide Tolerance\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Tolerance<span id=\"sendingagents\" onclick=\"ShowSendingAgentCol();\" title=\"Show Sending Agent\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
      html.Append("<th colspan=\"6\" class=\"headingTH\" ondblclick=\"HideSendingAgentCol();\" style=\"cursor: pointer;\"><center><span id=\"sendingagenth\" onclick=\"HideSendingAgentCol();\" title=\"Hide Sending Agent\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Sending Agent<span id=\"customertols\" onclick=\"ShowCustomerTolCol();\" title=\"Show Customer Tol.\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
      html.Append("<th colspan=\"2\" rowspan=\"2\" class=\"headingTH\" ondblclick=\"HideCustomerTolCol();\" style=\"cursor: pointer;\"><center><span id=\"customertolh\" onclick=\"HideCustomerTolCol();\" title=\"Hide Customer Tol.\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Cust. Tol.</center></th>");
      html.Append("<th colspan=\"4\" class=\"headingTH\"><center>Cross Rate</center></th>");
      html.Append("<th rowspan=\"3\" class=\"headingTH\"><center>Status</center></th>");
      html.Append("<th rowspan=\"3\" class=\"headingTH\">Updated By/On</th>");

      html.Append("</tr><tr class=\"hdtitle\">");
      //Head Office
      html.Append("<th colspan=\"4\" class=\"headingTH\"><center>USD vs Send Curr.</center></th>");
      html.Append("<th colspan=\"4\" class=\"headingTH\"><center>USD vs Receive Curr.</center></th>");

      //Tolerance
      html.Append("<th rowspan=\"2\" class=\"headingTH\"><center>On</center></th>");
      html.Append("<th colspan=\"2\" class=\"headingTH\"><center>Agent</center></th>");

      //Sending Agent
      html.Append("<th colspan=\"3\" class=\"headingTH\"><center>USD vs Send Curr.</center></th>");
      html.Append("<th colspan=\"3\" class=\"headingTH\"><center>USD vs Receive Curr.</center></th>");

      //Customer
      html.Append("<th colspan=\"4\" class=\"headingTH\"><center>Send Curr. vs Receive Curr.</center></th>");

      html.Append("</tr>");

      html.Append("</tr><tr class=\"hdtitle\">");
      html.Append("<th class=\"headingTH\">Country</th>");
      html.Append("<th class=\"headingTH\">Agent<div class=\"headingAgent\"></div></th>");
      html.Append("<th class=\"headingTH\">Country</th>");
      html.Append("<th class=\"headingTH\">Agent<div class=\"headingAgent\"></div></th>");

      //Head Office
      html.Append("<th class=\"thhorate\">Rate</th>");
      html.Append("<th class=\"thhorate\">Margin(I)</th>");
      html.Append("<th class=\"thhorate\">Margin</th>");
      html.Append("<th class=\"thhorate\">Offer</th>");
      html.Append("<th class=\"thhorate\">Rate</th>");
      html.Append("<th class=\"thhorate\">Margin(I)</th>");
      html.Append("<th class=\"thhorate\">Margin</th>");
      html.Append("<th class=\"thhorate\">Offer</th>");

      //Agent FX
      html.Append("<th class=\"thagentFx\">Value</th>");
      html.Append("<th class=\"thagentFx\">Type</th>");

      //Tolerance
      html.Append("<th class=\"headingTH\">Min</th>");
      html.Append("<th class=\"headingTH\">Max</th>");

      //Sending Agent
      html.Append("<th class=\"thsendagentrate\">Rate</th>");
      html.Append("<th class=\"thsendagentrate\">Margin</th>");
      html.Append("<th class=\"thsendagentrate\">Offer</th>");
      html.Append("<th class=\"thsendagentrate\">Rate</th>");
      html.Append("<th class=\"thsendagentrate\">Margin</th>");
      html.Append("<th class=\"thsendagentrate\">Offer</th>");

      //Cust. Tol.
      html.Append("<th class=\"thcustomertol\">Min</th>");
      html.Append("<th class=\"thcustomertol\">Max</th>");

      //Customer
      html.Append("<th class=\"thcustomerrate\">Max Rate</th>");
      html.Append("<th class=\"thcustomerrate\">Agent Rate</th>");
      html.Append("<th class=\"thcustomerrate\">Agent Margin</th>");
      html.Append("<th class=\"thcustomerrate\">Customer Rate</th>");

      html.Append("</tr>");

      foreach(DataRow dr in dt.Rows) {
        var id = Convert.ToInt32(dr["exRateTreasuryId"]);
        html.Append("<tr class=\"evenbg\">");

        //if (dr["modifiedby"].ToString() != GetStatic.GetUser())
        //{
        //    html.Append("<td align=\"center\" rowspan=\"2\"><input type='checkbox' id = \"chk_" + id + "\" name ='chkId' onclick=\"EnableDisableButton();\" value='" + id + "' " + (id.ToString() != "" ? "checked='checked'" : "") + " /></td>");
        //}
        //else
        //{
        //    html.Append("<td align=\"center\" rowspan=\"2\">&nbsp;</td>");
        //}
        html.Append("<td align=\"center\" rowspan=\"2\"><input type='checkbox' id = \"chk_" + id + "\" name ='chkId' onclick=\"EnableDisableButton();\" value='" + id + "' " + (id.ToString() != "" ? "checked='checked'" : "") + " /></td>");
        html.Append("<td rowspan=\"2\" nowrap=\"nowrap\">" + GetStatic.GetCountryFlag(dr["cCountryCode"].ToString()) + dr["cCountryName"] + "</td>");
        html.Append("<td rowspan=\"2\">" + dr["cAgentName"] + "</td>");
        html.Append("<td rowspan=\"2\" nowrap=\"nowrap\">" + GetStatic.GetCountryFlag(dr["pCountryCode"].ToString()) + dr["pCountryName"] + "</td>");
        html.Append("<td rowspan=\"2\">" + dr["pAgentName"] + "</td>");
        html.Append("<td rowspan=\"2\">" + dr["tranType"] + "</td>");
        html.Append("<td rowspan=\"2\">" + dr["cCurrency"] + "</td>");
        html.Append("<td rowspan=\"2\">" + dr["pCurrency"] + "</td>");
        html.Append("<td rowspan=\"2\">" + dr["modType"] + "</td>");

        if(dr["modType"].ToString().ToLower() == "insert") {
          html.Append("<td align=\"center\"><b>Current</b></td>");

          //Head Office
          html.Append("<td class='tdhorate'></td>");
          html.Append("<td class='tdhorate'></td>");
          html.Append("<td class='tdhorate'></td>");
          html.Append("<td class='tdhorate'></td>");
          html.Append("<td class='tdhorate'></td>");
          html.Append("<td class='tdhorate'></td>");
          html.Append("<td class='tdhorate'></td>");
          html.Append("<td class='tdhorate'></td>");

          //Agent Fx
          html.Append("<td class='rowCurrent'></td>");
          html.Append("<td class='rowCurrent'></td>");

          //Tolerance On
          html.Append("<td class='rowCurrent'></td>");
          html.Append("<td class='rowCurrent'></td>");
          html.Append("<td class='rowCurrent'></td>");

          //Sending Agent
          html.Append("<td class='tdsendagentrate'></td>");
          html.Append("<td class='tdsendagentrate'></td>");
          html.Append("<td class='tdsendagentrate'></td>");
          html.Append("<td class='tdsendagentrate'></td>");
          html.Append("<td class='tdsendagentrate'></td>");
          html.Append("<td class='tdsendagentrate'></td>");

          //Cust. Tol.
          html.Append("<td class='rowCurrent'></td>");
          html.Append("<td class='rowCurrent'></td>");

          //Customer
          html.Append("<td class='tdcustomerrate'></td>");
          html.Append("<td class='tdcustomerrate'></td>");
          html.Append("<td class='tdcustomerrate'></td>");
          html.Append("<td class='tdcustomerrate'></td>");

          html.Append("<td class='rowCurrent'></td>");
          html.Append("<td rowspan = \"2\">" + dr["modifiedBy"] + "<br/>" + dr["modifiedDate"] + "</td>");

          html.Append("<tr class=\"oddbg\">");
          html.Append("<td align=\"center\"><b>New</b></td>");

          //Head Office
          html.Append("<td class='rowNew'>" + dr["cRate"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["cMargin"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["cHoMargin"] + "</td>");
          html.Append("<td class='rowNew'>" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"])) + "</td>");
          html.Append("<td class='rowNew'>" + dr["pRate"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["pMargin"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["pHoMargin"] + "</td>");
          html.Append("<td class='rowNew'>" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"])) + "</td>");

          //Agent Fx
          html.Append("<td class='rowNew'>" + dr["sharingType"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["sharingValue"] + "</td>");

          //Tolerance On
          html.Append("<td class='rowNew'>" + dr["toleranceOn"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["agentTolMin"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["agentTolMax"] + "</td>");

          //Sending Agent
          html.Append("<td class='rowNew'>" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"])) + "</td>");
          html.Append("<td class='rowNew'>" + dr["cAgentMargin"] + "</td>");
          html.Append("<td class='rowNew'>" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"]) + Convert.ToDecimal(dr["cAgentMargin"])) + "</td>");
          html.Append("<td class='rowNew'>" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"])) + "</td>");
          html.Append("<td class='rowNew'>" + dr["pAgentMargin"] + "</td>");
          html.Append("<td class='rowNew'>" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"]) - Convert.ToDecimal(dr["pAgentMargin"])) + "</td>");

          //Cust. Tol.
          html.Append("<td class='rowNew'>" + dr["customerTolMin"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["customerTolMax"] + "</td>");

          //Customer
          html.Append("<td class='rowNew'>" + dr["maxCrossRate"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["crossRate"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["agentCrossRateMargin"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["customerRate"] + "</td>");

          html.Append("<td class='rowNew'>" + dr["status"] + "</td>");
        } else if(dr["modType"].ToString().ToLower() == "update") {
          html.Append("<td align=\"center\"><b>Current</b></td>");

          //Head Office
          html.Append("<td class='tdhorate'>" + dr["cRate"] + "</td>");
          html.Append("<td class='tdhorate'>" + dr["cMargin"] + "</td>");
          html.Append("<td class='tdhorate'>" + dr["cHoMargin"] + "</td>");
          html.Append("<td class='tdhorate'>" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"])) + "</td>");
          html.Append("<td class='tdhorate'>" + dr["pRate"] + "</td>");
          html.Append("<td class='tdhorate'>" + dr["pMargin"] + "</td>");
          html.Append("<td class='tdhorate'>" + dr["pHoMargin"] + "</td>");
          html.Append("<td class='tdhorate'>" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"])) + "</td>");

          //Agent Fx
          html.Append("<td class='rowCurrent'>" + dr["sharingType"] + "</td>");
          html.Append("<td class='rowCurrent'>" + dr["sharingValue"] + "</td>");

          //Tolerance On
          html.Append("<td class='rowCurrent'>" + dr["toleranceOn"] + "</td>");
          html.Append("<td class='rowCurrent'>" + dr["agentTolMin"] + "</td>");
          html.Append("<td class='rowCurrent'>" + dr["agentTolMax"] + "</td>");

          //Sending Agent
          html.Append("<td class='tdsendagentrate'>" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"])) + "</td>");
          html.Append("<td class='tdsendagentrate'>" + dr["cAgentMargin"] + "</td>");
          html.Append("<td class='tdsendagentrate'>" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"]) + Convert.ToDecimal(dr["cAgentMargin"])) + "</td>");
          html.Append("<td class='tdsendagentrate'>" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"])) + "</td>");
          html.Append("<td class='tdsendagentrate'>" + dr["pAgentMargin"] + "</td>");
          html.Append("<td class='tdsendagentrate'>" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"]) - Convert.ToDecimal(dr["pAgentMargin"])) + "</td>");

          //Cust. Tol.
          html.Append("<td class='rowCurrent'>" + dr["customerTolMin"] + "</td>");
          html.Append("<td class='rowCurrent'>" + dr["customerTolMax"] + "</td>");

          //Customer
          html.Append("<td class='tdcustomerrate'>" + dr["maxCrossRate"] + "</td>");
          html.Append("<td class='tdcustomerrate'>" + dr["crossRate"] + "</td>");
          html.Append("<td class='tdcustomerrate'>" + dr["agentCrossRateMargin"] + "</td>");
          html.Append("<td class='tdcustomerrate'>" + dr["customerRate"] + "</td>");

          html.Append("<td class='rowCurrent'>" + dr["status"] + "</td>");
          html.Append("<td rowspan = \"2\">" + dr["modifiedBy"] + "<br/>" + dr["modifiedDate"] + "</td>");

          html.Append("<tr class=\"oddbg\">");
          html.Append("<td align=\"center\"><b>New</b></td>");

          //Head Office
          html.Append("<td class='rowNew'>" + dr["cRateNew"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["cMarginNew"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["cHoMarginNew"] + "</td>");
          html.Append("<td class='rowNew'>" + (Convert.ToDecimal(dr["cRateNew"]) + Convert.ToDecimal(dr["cMarginNew"]) + Convert.ToDecimal(dr["cHoMarginNew"])) + "</td>");
          html.Append("<td class='rowNew'>" + dr["pRateNew"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["pMarginNew"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["pHoMarginNew"] + "</td>");
          html.Append("<td class='rowNew'>" + (Convert.ToDecimal(dr["pRateNew"]) - Convert.ToDecimal(dr["pMarginNew"]) - Convert.ToDecimal(dr["pHoMarginNew"])) + "</td>");

          //Agent Fx
          html.Append("<td class='rowNew'>" + dr["sharingTypeNew"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["sharingValueNew"] + "</td>");

          //Tolerance On
          html.Append("<td class='rowNew'>" + dr["toleranceOnNew"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["agentTolMinNew"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["agentTolMaxNew"] + "</td>");

          //Sending Agent
          html.Append("<td class='rowNew'>" + (Convert.ToDecimal(dr["cRateNew"]) + Convert.ToDecimal(dr["cMarginNew"]) + Convert.ToDecimal(dr["cHoMarginNew"])) + "</td>");
          html.Append("<td class='rowNew'>" + dr["cAgentMarginNew"] + "</td>");
          html.Append("<td class='rowNew'>" + (Convert.ToDecimal(dr["cRateNew"]) + Convert.ToDecimal(dr["cMarginNew"]) + Convert.ToDecimal(dr["cHoMarginNew"]) + Convert.ToDecimal(dr["cAgentMarginNew"])) + "</td>");
          html.Append("<td class='rowNew'>" + (Convert.ToDecimal(dr["pRateNew"]) - Convert.ToDecimal(dr["pMarginNew"]) - Convert.ToDecimal(dr["pHoMarginNew"])) + "</td>");
          html.Append("<td class='rowNew'>" + dr["pAgentMarginNew"] + "</td>");
          html.Append("<td class='rowNew'>" + (Convert.ToDecimal(dr["pRateNew"]) - Convert.ToDecimal(dr["pMarginNew"]) - Convert.ToDecimal(dr["pHoMarginNew"]) - Convert.ToDecimal(dr["pAgentMarginNew"])) + "</td>");

          //Cust. Tol.
          html.Append("<td class='rowNew'>" + dr["customerTolMinNew"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["customerTolMaxNew"] + "</td>");

          //Customer
          html.Append("<td class='rowNew'>" + dr["maxCrossRateNew"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["crossRateNew"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["agentCrossRateMarginNew"] + "</td>");
          html.Append("<td class='rowNew'>" + dr["customerRateNew"] + "</td>");

          html.Append("<td class='rowNew'>" + dr["statusNew"] + "</td>");
        }
      }

      html.Append("</table>");
      html.Append("</div>");
      rpt_grid.InnerHtml = html.ToString();
      GetStatic.CallBackJs1(Page, "Show Hide", "ShowHideDetail();");
    }

    private void ManageMessage(DbResult dbResult) {
      GetStatic.SetMessage(dbResult);
      if(dbResult.ErrorCode == "0") {
        Response.Redirect("ApproveList.aspx");
      }
      GetStatic.AlertMessage(Page);
    }

    private void Approve() {
      var exRateTreasuryIds = chkList;
      if(string.IsNullOrEmpty(exRateTreasuryIds)) {
        GetStatic.AlertMessage(Page, "Please select the record(s) to approve");
        return;
      }
      var dbResult = obj.Approve(GetStatic.GetUser(), exRateTreasuryIds);
      GetStatic.WriteSession("exRateTreasuryIds", exRateTreasuryIds);
      Response.Redirect("ApproveSummary.aspx");
    }

    protected void btnApprove_Click(object sender, EventArgs e) {
      Approve();
    }

    protected void btnReject_Click(object sender, EventArgs e) {
      var dbResult = obj.Reject(GetStatic.GetUser(), chkList);
      ManageMessage(dbResult);
    }

    protected void countryOrderBy_SelectedIndexChanged(object sender, EventArgs e) {
      LoadGrid();
    }

    private void PopulateDdl() {
      LoadSendingCountry(ref cCountry, "");
      LoadReceivingCountry(ref pCountry, "");
      //LoadAgent(ref cAgent, cCountry.Text, "");
      //LoadAgent(ref pAgent, pCountry.Text, "");
      //LoadCurrency(ref cCurrency, cCountry.Text, "");
      //LoadCurrency(ref pCurrency, pCountry.Text, "");
    }

    private void LoadSendingCountry(ref DropDownList ddl, string defaultValue) {
      var sql = "EXEC proc_countryMaster @flag = 'scl'";
      _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, "All");
    }

    private void LoadReceivingCountry(ref DropDownList ddl, string defaultValue) {
      var sql = "EXEC proc_countryMaster @flag = 'rcl'";
      _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, "All");
    }

    private void LoadCurrency(ref DropDownList ddl, string countryId, string defaultValue) {
      var sql = "EXEC proc_countryCurrency @flag='cl', @countryId=" + _sdd.FilterString(countryId);
      _sdd.SetDDL(ref ddl, sql, "currencyId", "currencyCode", defaultValue, "All");
    }

    private void LoadAgent(ref DropDownList ddl, string countryId, string defaultValue) {
      var sql = "EXEC proc_agentMaster @flag = 'alc', @agentCountryId = " + _sdd.FilterString(countryId);
      _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", defaultValue, "All");
    }

    private void LoadTranType(ref DropDownList ddl, string countryId, string defaultValue) {
      var sql = "EXEC proc_dropDownLists @flag = 'recModeByCountry', @param = " + _sdd.FilterString(countryId);
      _sdd.SetDDL(ref ddl, sql, "serviceTypeId", "typeTitle", defaultValue, "Any");
    }

    protected void cCountry_SelectedIndexChanged(object sender, EventArgs e) {
      LoadAgent(ref cAgent, cCountry.Text, "");
      LoadCurrency(ref cCurrency, cCountry.Text, "");
      cCountry.Focus();
    }

    protected void pCountry_SelectedIndexChanged(object sender, EventArgs e) {
      LoadTranType(ref tranType, pCountry.Text, "");
      LoadAgent(ref pAgent, pCountry.Text, "");
      LoadCurrency(ref pCurrency, pCountry.Text, "");
      pCountry.Focus();
    }

    protected void btnFilterShowHide_Click(object sender, System.Web.UI.ImageClickEventArgs e) {
      if(td_Search.Visible) {
        td_Search.Visible = false;
        btnFilterShowHide.ImageUrl = "../../../images/icon_show.gif";
      } else {
        td_Search.Visible = true;
        btnFilterShowHide.ImageUrl = "../../../images/icon_hide.gif";
      }
    }

    protected void btnHidden_Click(object sender, EventArgs e) {
      LoadGrid();
    }
  }
}