using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace Swift.web.Remit.ExchangeRate.AgentRateSetup {
  public partial class List : System.Web.UI.Page {
    private DefExRateDao obj = new DefExRateDao();
    private readonly StaticDataDdl _sdd = new StaticDataDdl();
    private readonly SwiftTab _tab = new SwiftTab();
    private const string GridName = "grd_ars";
    private const string ViewFunctionId = "30012400";
    private const string AddEditFunctionId = "30012410";

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
        Authenticate();
        GetStatic.AlertMessage(Page);
        LoadTab();
        LoadGrid();
      }
    }

    private string autoSelect(string str1, string str2) {
      if(str1 == str2)
        return "selected=\"selected\"";
      else
        return "";
    }

    private void Authenticate() {
      _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
    }

    private string GetPagingBlock(int _total_record, int _page, int _page_size) {
      var str = new StringBuilder("<input type = \"hidden\" name=\"hdd_curr_page\" id = \"hdd_curr_page\" value=\"" + _page.ToString() + "\">");
      str.Append("<tr><td colspan='12'><table class='table table-bordered table-striped table-responsive'>");
      str.Append("<td class=\"GridTextNormal\" nowrap='nowrap'>Result :&nbsp;<b>" + _total_record.ToString() + "</b>&nbsp;records&nbsp;");
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
      str.Append("</td>");
      str.AppendLine("<td align='right'>");

      if(_page > 1)
        str.AppendLine("<img style = \"cursor:pointer\" onclick =\"Nav(" + (_page - 1) + ", '" + GridName + "');\" title='Go to Previous page(Page : " + (_page - 1) + ")' src='" + GetStatic.GetUrlRoot() + "/images/prev.gif' border='0'>&nbsp;&nbsp;&nbsp;");
      else
        str.AppendLine("<img src='" + GetStatic.GetUrlRoot() + "/images/disprev.gif' border='0'>&nbsp;&nbsp;&nbsp;");

      if(_page * _page_size < _total_record)
        str.AppendLine("<img style = \"cursor:pointer\" onclick =\"Nav(" + (_page + 1) + ", '" + GridName + "');\" title='Go to Next page(Page : " + (_page + 1) + ")' src='" + GetStatic.GetUrlRoot() + "/images/next.gif' border='0'>&nbsp;&nbsp;&nbsp;");
      else
        str.AppendLine("<img src='" + GetStatic.GetUrlRoot() + "/images/disnext.gif' border='0'>&nbsp;&nbsp;&nbsp;");

      str.AppendLine("<a href=\"Manage.aspx\" title=\"Add New Record\"><img src='" +
                              GetStatic.GetUrlRoot() + "/images/add.gif' style=\"cursor: pointer;\" border='0'></a>");

      // str.AppendLine("&nbsp; <img title = 'Export to Excel' style = 'cursor:pointer' onclick
      // = \"DownloadGrid('" + GetStatic.GetUrlRoot() + "');\" src='" + GetStatic.GetUrlRoot()
      // + "/images/excel.gif' border='0'>");

      str.AppendLine("</td>");
      str.AppendLine("</tr></table></td></tr>");

      return str.ToString();
    }

    private string loadPagingBlock(DataTable dtPaging) {
      string pagingTable = "";
      foreach(DataRow row in dtPaging.Rows) {
        pagingTable = GetPagingBlock(int.Parse(row["totalRow"].ToString()), int.Parse(row["pageNumber"].ToString()), int.Parse(row["pageSize"].ToString()));
      }
      return pagingTable;
    }

    private void LoadTab() {
      _tab.NoOfTabPerRow = 2;
      _tab.TabList = new List<TabField>
                         {
                                   new TabField("Agent Rate", "", true)
                               };
      var allowAddEdit = _sdd.HasRight(ViewFunctionId);
      if(allowAddEdit)
        _tab.TabList.Add(new TabField("Add New", "Manage.aspx"));

      divTab.InnerHtml = _tab.CreateTab();
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

      int page_size = Convert.ToUInt16(_page_size);

      var ds = obj.LoadGrid(GetStatic.GetUser(), "AG", _page.ToString(), page_size.ToString(), "defExRateId", sortd, currency.Text, country.Text, agent.Text);
      var dtPaging = ds.Tables[0];

      var dt = ds.Tables[1];
      var html = new StringBuilder();
      html.Append("<div class=\"responsive-table\">");
      html.Append("<table class=\"table table-responsive table-striped table-bordered\">");
      html.Append(loadPagingBlock(dtPaging));
      html.Append("<tr class=\"hdtitle\">");
      html.Append("<th rowspan=\"2\" class=\"headingTH\">Agent</th>");
      html.Append("<th rowspan=\"2\" class=\"headingTH\">Base Currency</th>");
      html.Append("<th rowspan=\"2\" class=\"headingTH\">Quote Currency</th>");
      html.Append("<th rowspan=\"2\" class=\"headingTH\">Factor</th>");
      html.Append("<th colspan=\"3\" class=\"headingTH\"><center>Send</center></th>");
      html.Append("<th colspan=\"3\" class=\"headingTH\"><center>Receive</center></th>");
      html.Append("<th rowspan=\"2\" class=\"headingTH\"></th>");
      html.Append("<th rowspan=\"2\" class=\"headingTH\">Last Updated</th>");
      html.Append("</tr><tr class=\"hdtitle\">");
      html.Append("<th class=\"thcoll\">Rate</th>");
      html.Append("<th class=\"thcoll\">Margin</th>");
      html.Append("<th class=\"thcoll\">Offer</th>");
      html.Append("<th class=\"thpay\">Rate</th>");
      html.Append("<th class=\"thpay\">Margin</th>");
      html.Append("<th class=\"thpay\">Offer</th>");
      html.Append("</tr>");
      var i = 0;
      var countryName = "";

      var allowAddEdit = _sdd.HasRight(AddEditFunctionId);
      foreach(DataRow dr in dt.Rows) {
        var id = Convert.ToInt32(dr["defExRateId"]);
        if(countryName != dr["countryName"].ToString()) {
          html.Append(
              "<tr class=\"trcountry\"><td colspan=\"37\" class=\"tdcountry\" style=\"cursor: pointer;\" onclick=\"CheckGroup(this,'" + dr["countryCode"] + "');\"><b>" + GetStatic.GetCountryFlag(dr["countryCode"].ToString()) +
              dr["countryName"] + "</b></td></th>");
          countryName = dr["countryName"].ToString();
        }
        html.Append(++i % 2 == 1 ? "<tr id=\"row_" + id + "\" onclick=\"KeepRowSelection(" + i + "," + id + ",'" + dr["countryCode"] + "');\" class=\"oddbg\" onmouseover=\"if(this.className=='oddbg'){this.className='GridOddRowOver'}\" onmouseout=\"if(this.className=='selectedbg'){} else{this.className='oddbg'}\">" : "<tr id=\"row_" + id + "\" onclick=\"KeepRowSelection(" + i + "," + id + ",'" + dr["countryCode"] + "');\" class=\"evenbg\" onmouseover=\"if(this.className=='evenbg'){this.className='GridEvenRowOver'}\" onmouseout=\"if(this.className=='selectedbg'){}else{this.className='evenbg'}\">");
        html.Append("<td>" + dr["agentName"] + "</td>");
        html.Append("<td>" + dr["baseCurrency"] + "</td>");
        html.Append("<td>" + dr["currency"] + "(" + dr["currencyName"] + ")" + "</td>");
        html.Append(dr["factor"].ToString() == "M"
                        ? "<td nowrap=\"nowrap\"><input id=\"mul_" + id + "\" disabled=\"disabled\" type=\"radio\" name=\"factor_" + id + "\" value=\"M\" checked=\"checked\">MUL</input><input id=\"div_" + id + "\" disabled=\"disabled\" type=\"radio\" name=\"factor_" + id + "\" value=\"D\">DIV</input></td>"
                        : "<td nowrap=\"nowrap\"><input id=\"mul_" + id + "\" disabled=\"disabled\" type=\"radio\" name=\"factor_" + id + "\" value=\"M\">MUL</input><input id=\"div_" + id + "\" disabled=\"disabled\" type=\"radio\" name=\"factor_" + id + "\" value=\"D\" checked=\"checked\">DIV</input></td>");
        switch(dr["cOperationType"].ToString()) {
          case "B":
            html.Append("<td class='tdColl'><input class='inputBox' id=\"cRate_" + id + "\" onblur=\"CalcCollectionOffer(" + id + ",this," + dr["maskMulBD"] + "," + dr["maskMulAD"] + "," + dr["maskDivBD"] + "," + dr["maskDivAD"] + ");\" type=\"text\" value=\"" + dr["cRate"] + "\"/>" + "</td>");
            html.Append("<td class='tdColl'><input class='inputBox' id=\"cMargin_" + id + "\" onblur=\"CalcCollectionOffer(" + id + ",this," + dr["maskMulBD"] + "," + dr["maskMulAD"] + "," + dr["maskDivBD"] + "," + dr["maskDivAD"] + ");\" type=\"text\" value=\"" + dr["cMargin"] + "\"/>" + "</td>");
            html.Append("<td class='tdColl' nowrap=\"nowrap\">");
            html.Append("<input class='inputBox' style=\"background: #EFEFEF !important; color: #666666 !important;\" id=\"cOffer_" + id + "\" readonly=\"readonly\" type=\"text\" value=\"" + dr["cOffer"] + "\"/>");
            html.Append("<img src=\"../../../images/rule.gif\" style=\"cursor: pointer;\" onclick=\"ShowTreasuryRate(" + id + ",'c');\" border=\"0\" title=\"Show Treasury Rate\"/>");
            html.Append("<input type=\"hidden\" id=\"cRate_" + id + "_Cv\" value=\"" + dr["cRate"] + "\" />");
            html.Append("<input type=\"hidden\" id=\"cMargin_" + id + "_Cv\" value=\"" + dr["cMargin"] + "\" />");
            html.Append("</td>");

            html.Append("<td class='tdPay'><input class='inputBox' id=\"pRate_" + id + "\" onblur=\"CalcPaymentOffer(" + id + ",this," + dr["maskMulBD"] + "," + dr["maskMulAD"] + "," + dr["maskDivBD"] + "," + dr["maskDivAD"] + ");\" type=\"text\" value=\"" + dr["pRate"] + "\"/>" + "</td>");
            html.Append("<td class='tdPay'><input class='inputBox' id=\"pMargin_" + id + "\" onblur=\"CalcPaymentOffer(" + id + ",this," + dr["maskMulBD"] + "," + dr["maskMulAD"] + "," + dr["maskDivBD"] + "," + dr["maskDivAD"] + ");\" type=\"text\" value=\"" + dr["pMargin"] + "\"/>" + "</td>");
            html.Append("<td class='tdPay' nowrap=\"nowrap\">");
            html.Append("<input class='inputBox' style=\"background: #EFEFEF !important; color: #666666 !important;\" readonly=\"readonly\" id=\"pOffer_" + id + "\" type=\"text\" value=\"" + dr["pOffer"] + "\"/>");
            html.Append("<img src=\"../../../images/rule.gif\" style=\"cursor: pointer;\" onclick=\"ShowTreasuryRate(" + id + ",'p');\" border=\"0\" title=\"Show Treasury Rate\"/>");
            html.Append("<input type=\"hidden\" id=\"pRate_" + id + "_Cv\" value=\"" + dr["pRate"] + "\" />");
            html.Append("<input type=\"hidden\" id=\"pMargin_" + id + "_Cv\" value=\"" + dr["pMargin"] + "\" />");
            html.Append("</td>");
            break;

          case "S":
            html.Append("<td class='tdColl'><input class='inputBox' id=\"cRate_" + id + "\" onblur=\"CalcCollectionOffer(" + id + ",this," + dr["maskMulBD"] + "," + dr["maskMulAD"] + "," + dr["maskDivBD"] + "," + dr["maskDivAD"] + ");\" type=\"text\" value=\"" + dr["cRate"] + "\"/>" + "</td>");
            html.Append("<td class='tdColl'><input class='inputBox' id=\"cMargin_" + id + "\" onblur=\"CalcCollectionOffer(" + id + ",this," + dr["maskMulBD"] + "," + dr["maskMulAD"] + "," + dr["maskDivBD"] + "," + dr["maskDivAD"] + ");\" type=\"text\" value=\"" + dr["cMargin"] + "\"/>" + "</td>");
            html.Append("<td class='tdColl' nowrap=\"nowrap\">");
            html.Append("<input class='inputBox' style=\"background: #EFEFEF !important; color: #666666 !important;\" id=\"cOffer_" + id + "\" readonly=\"readonly\" type=\"text\" value=\"" + dr["cOffer"] + "\"/>");
            html.Append("<img src=\"../../../images/rule.gif\" style=\"cursor: pointer;\" onclick=\"ShowTreasuryRate(" + id + ",'c');\" border=\"0\" title=\"Show Treasury Rate\"/>");
            html.Append("<input type=\"hidden\" id=\"cRate_" + id + "_Cv\" value=\"" + dr["cRate"] + "\" />");
            html.Append("<input type=\"hidden\" id=\"cMargin_" + id + "_Cv\" value=\"" + dr["cMargin"] + "\" />");
            html.Append("</td>");

            html.Append("<td class='tdPay'></td>");
            html.Append("<td class='tdPay'></td>");
            html.Append("<td class='tdPay'></td>");
            break;

          case "R":
            html.Append("<td class='tdColl'></td>");
            html.Append("<td class='tdColl'></td>");
            html.Append("<td class='tdColl'></td>");

            html.Append("<td class='tdPay'><input class='inputBox' id=\"pRate_" + id + "\" onblur=\"CalcPaymentOffer(" + id + ",this," + dr["maskMulBD"] + "," + dr["maskMulAD"] + "," + dr["maskDivBD"] + "," + dr["maskDivAD"] + ");\" type=\"text\" value=\"" + dr["pRate"] + "\"/>" + "</td>");
            html.Append("<td class='tdPay'><input class='inputBox' id=\"pMargin_" + id + "\" onblur=\"CalcPaymentOffer(" + id + ",this," + dr["maskMulBD"] + "," + dr["maskMulAD"] + "," + dr["maskDivBD"] + "," + dr["maskDivAD"] + ");\" type=\"text\" value=\"" + dr["pMargin"] + "\"/>" + "</td>");
            html.Append("<td class='tdPay' nowrap=\"nowrap\">");
            html.Append("<input class='inputBox' style=\"background: #EFEFEF !important; color: #666666 !important;\" readonly=\"readonly\" id=\"pOffer_" + id + "\" type=\"text\" value=\"" + dr["pOffer"] + "\"/>");
            html.Append("<img src=\"../../../images/rule.gif\" style=\"cursor: pointer;\" onclick=\"ShowTreasuryRate(" + id + ",'p');\" border=\"0\" title=\"Show Treasury Rate\"/>");
            html.Append("<input type=\"hidden\" id=\"pRate_" + id + "_Cv\" value=\"" + dr["pRate"] + "\" />");
            html.Append("<input type=\"hidden\" id=\"pMargin_" + id + "_Cv\" value=\"" + dr["pMargin"] + "\" />");
            html.Append("</td>");
            break;

          default:
            html.Append("<td class='tdColl'></td>");
            html.Append("<td class='tdColl'></td>");
            html.Append("<td class='tdColl'></td>");
            html.Append("<td class='tdPay'></td>");
            html.Append("<td class='tdPay'></td>");
            html.Append("<td class='tdPay'></td>");
            break;
        }
        html.Append("<td nowrap='nowrap' width='75px'>");
        html.Append("<input type=\"hidden\" id=\"cMin_" + id + "\" value=\"" + dr["cMin"] + "\" />");
        html.Append("<input type=\"hidden\" id=\"cMax_" + id + "\" value=\"" + dr["cMax"] + "\" />");
        html.Append("<input type=\"hidden\" id=\"pMin_" + id + "\" value=\"" + dr["pMin"] + "\" />");
        html.Append("<input type=\"hidden\" id=\"pMax_" + id + "\" value=\"" + dr["pMax"] + "\" />");
        html.Append("<input type=\"hidden\" id=\"operationType_" + id + "\" value=\"" + dr["cOperationType"] + "\"/>");
        if(allowAddEdit)
          html.Append("<input id=\"btnUpdate_" + id + "\" type=\"button\" class='btn btn-primary m-t-25' disabled=\"disabled\" class=\"buttonDisabled\" onclick=\"UpdateRate(" + id + ")\" value=\"Update\" title = \"Confirm Update\"/>");
        html.Append("<span id=\"status_" + id + "\"></span>");
        html.Append("</td>");
        html.Append("<td nowrap=\"nowrap\">" + dr["lastModifiedDate"] + "<br/>" + dr["lastModifiedBy"] + "</td>");
        html.Append("</tr>");
      }
      html.Append("</table>");
      html.Append("</div>");
      rpt_grid.InnerHtml = html.ToString();
    }

    private string AppendRowSelectionProperty(string rowSelectedClass, string defaultClass, string onhoverclass) {
      return " class=\"" + defaultClass + "\" ondblclick=\"if(this.className=='" + rowSelectedClass + "'){this.className='" + defaultClass + "';}else{this.className='" + rowSelectedClass + "';}\" onMouseOver=\"if(this.className=='" + defaultClass + "'){this.className='" + onhoverclass + "';}\" onMouseOut=\"if(this.className=='" + rowSelectedClass + "'){}else{this.className='" + defaultClass + "';}\" ";
    }

    protected void btnUpdate_Click(object sender, EventArgs e) {
      var dbResult = obj.Update(GetStatic.GetUser(), defExRateId.Value, "AG", "", "", "", "", factor.Value, cRate.Value,
                       cMargin.Value, cMax.Value, cMin.Value, pRate.Value, pMargin.Value, pMax.Value, pMin.Value, "Y");
      ManageMessage(dbResult);
    }

    private void ManageMessage(DbResult dbResult) {
      GetStatic.SetMessage(dbResult);
      if(dbResult.ErrorCode == "0") {
        Response.Redirect("~/Remit/ExchangeRate/ExRateTreasury/ApproveList.aspx");
      }
      GetStatic.AlertMessage(Page);
    }

    protected void btnHidden_Click(object sender, EventArgs e) {
      LoadGrid();
    }

    private void MarkActiveInactive(string isActive) {
      var defExRateIds = GetStatic.ReadFormData("chkId", "");
      if(string.IsNullOrEmpty(defExRateIds)) {
        GetStatic.AlertMessage(Page, "Please select record(s) to update");
        return;
      }
      var dbResult = obj.MarkAsActiveInactive(GetStatic.GetUser(), defExRateIds, isActive);
      ManageMessage(dbResult);
    }

    protected void btnMarkInactive_Click(object sender, EventArgs e) {
      MarkActiveInactive("N");
    }
  }
}