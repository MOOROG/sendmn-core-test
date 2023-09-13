using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Data;
using System.Linq;
using System.Text;
using static iText.StyledXmlParser.Jsoup.Select.Evaluator;

namespace Swift.web.Remit.ExchangeRate.TPRate
{
  public partial class RiaRate : System.Web.UI.Page
  {
    private ExRateTreasuryDao obj = new ExRateTreasuryDao();
    private readonly StaticDataDdl _sdd = new StaticDataDdl();
    private readonly SwiftTab _tab = new SwiftTab();
    private const string ViewFunctionId = "30012600";
    private const string AddEditFunctionId = "30012600";

    private string _popUpParam = "dialogHeight:400px;dialogWidth:500px;dialogLeft:300;dialogTop:100;center:yes";

    public string PopUpParam
    {
      set { _popUpParam = value; }
      get { return _popUpParam; }
    }

    private string _approveText = "<img alt = \"View Changes\" border = \"0\" title = \"View Changes\" src=\"" + GetStatic.GetUrlRoot() + "/images/view-changes.jpg\" /> ";

    public string ApproveText
    {
      set { _approveText = value; }
      get { return _approveText; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
      Authenticate();
      if(!IsPostBack)
      {
        GetStatic.AlertMessage(Page);
        LoadGrid();
        hdnIsFw.Value = GetStatic.ReadQueryString("isFw", "");
      }
    }

    private string GetDefExRateId()
    {
      return GetStatic.ReadQueryString("defExRateId", "");
    }

    private void Authenticate()
    {
      _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
    }

    private void LoadGrid()
    {
      var defExRateId = GetDefExRateId();
      defExRateId = "";
      var ds = obj.LoadGridAfterCostChange(GetStatic.GetUser(), "1", "1000", "receivingCountry", "", defExRateId, "17", "", "", "", "Y");

      var dt = ds.Tables[1];
      var html = new StringBuilder();
      #region
      html.Append("<table id=\"rateTable\" class=\"table table-responsive table-bordered table-striped\">");
      html.Append("<tr class=\"hdtitle\">");

      html.Append("<th colspan=\"6\" class=\"headingTH\"><center>Head Office</center></th>");
      html.Append("<th colspan=\"2\" class=\"headingTH\"><center>Cross Rate</center></th>");

      html.Append("<th rowspan=\"3\" class=\"headingTH\">Status</th>");
      html.Append("<th rowspan=\"3\" class=\"headingTH\">Last Updated</th>");

      html.Append("</tr><tr class=\"hdtitle\">");
      //Head Office
      html.Append("<th colspan=\"3\" class=\"headingTH\"><center>USD vs Send Curr.</center></th>");
      html.Append("<th colspan=\"3\" class=\"headingTH\"><center>USD vs Receive Curr.</center></th>");

      //Customer
      html.Append("<th colspan=\"2\" class=\"headingTH\"><center>Send Curr. vs Receive Curr.</center></th>");

      html.Append("</tr>");

      html.Append("</tr><tr class=\"hdtitle\">");

      //Head Office
      html.Append("<th class=\"thhorate\">Rate</th>");
      html.Append("<th class=\"thhorate\">Margin(I)</th>");
      html.Append("<th class=\"thhorate\">Offer</th>");
      html.Append("<th class=\"thhorate\">Rate</th>");
      html.Append("<th class=\"thhorate\">Margin(I)</th>");
      html.Append("<th class=\"thhorate\">Offer</th>");

      //Customer
      html.Append("<th class=\"thcustomerrate\">Max Rate</th>");
      html.Append("<th class=\"thcustomerrate\">Customer Rate</th>");

      html.Append("</tr>");
      #endregion
      var i = 0;
      var countryName = "";
      try
      {
        foreach(DataRow dr in dt.Rows)
        {
          var id = dr["exRateTreasuryId"].ToString();
          if(countryName != dr["pCountryName"].ToString())
          {
            html.Append(
                "<tr class=\"trcountry\"><td colspan=\"12\" class=\"tdcountry\" style=\"cursor: pointer\" onclick=\"CheckGroup(this,'" + dr["pCountryCode"] + "');\"><b>Receiving Country : " + GetStatic.GetCountryFlag(dr["pCountryCode"].ToString()) +
                dr["pCountryName"] + "</b></td></tr>");
            countryName = dr["pCountryName"].ToString();
          }
          var countryCode = dr["pCountryCode"].ToString();
          html.Append(++i % 2 == 1 ? "<tr id=\"row_" + id + "\"" + AppendRowSelectionProperty("selectedbg", "oddbg", "GridOddRowOver") + ">" : "<tr id=\"row_" + id + "\"" + AppendRowSelectionProperty("selectedbg", "evenbg", "GridEvenRowOver") + ">");

          html.Append("<input type=\"hidden\" id=\"" + id + "\" name=\"selectId\" value=\"" + id + "\"/>");
          html.Append("<input type=\"hidden\" id=\"cMin_" + id + "\" name=\"cMin_" + id + "\" value=\"" + dr["cMin"] + "\" />");
          html.Append("<input type=\"hidden\" id=\"cMax_" + id + "\" name=\"cMax_" + id + "\" value=\"" + dr["cMax"] + "\" />");
          //Head Office Rate, Margin, Offer to Agent
          html.Append(ComposeTextBox(dr, id, "cRate", true, "tdcRate", "onblur", "CalcCOffers(this," + id + "," + dr["cRateMaskMulAd"] + "," + dr["crossRateMaskAd"] + ");", true));
          html.Append(ComposeTextBox(dr, id, "cMargin", true, "tdcMargin", "onblur", "CalcCOffers(this," + id + "," + dr["cRateMaskMulAd"] + "," + dr["crossRateMaskAd"] + ");", true));
          html.Append("<td class=\"tdhorate\" id=\"cOffer_" + id + "\">" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"])) + "</td>");
          html.Append("<td class=\"tdhorate\" id=\"pRateLbl_" + id + "\">" + dr["pRate"] + "</td>");
          html.Append("<td class=\"tdhorate\" id=\"pMargin_" + id + "\">" + dr["pMargin"] + "</td>");
          html.Append("<td class=\"tdhorate\" id=\"pOffer_" + id + "\">" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"])) + "</td>");


          //Customer
          html.Append(ComposeTextBox(dr, id, "maxCrossRate", false, "tdcustomerrate", false));
          //html.Append(ComposeTextBox(dr, id, "customerRate", false, "tdcustomerrate", false));
          html.Append(ComposeTextBox(dr, id, "customerRate", true, "tdcustomerRate", "onblur", "CalcCusRate(this," + id + "," + dr["cRateMaskMulAd"] + ");", true));

          html.Append("<td>" + dr["status"] + "</td>");

          html.Append("<td nowrap='nowrap'>" + dr["lastModifiedDate"] + "<br/>" + dr["lastModifiedBy"] + "</td></tr>");
        }
      }
      catch(Exception ex)
      {
        string x = ex.ToString();
      }
      html.Append("</table>");
      rpt_grid.InnerHtml = html.ToString();
      if(dt.Rows.Count > 0)
      {
        btnUpdateChanges.Visible = true;
      }
    }

    private string AppendRowSelectionProperty(string rowSelectedClass, string defaultClass, string onhoverclass)
    {
      return " class=\"" + defaultClass + "\" ondblclick=\"if(this.className=='" + rowSelectedClass + "'){this.className='" + defaultClass + "';}else{this.className='" + rowSelectedClass + "';}\" onMouseOver=\"if(this.className=='" + defaultClass + "'){this.className='" + onhoverclass + "';}\" onMouseOut=\"if(this.className=='" + rowSelectedClass + "'){}else{this.className='" + defaultClass + "';}\" ";
    }

    private string ComposeTextBox(DataRow dr, string id, string valueField, bool enable, string cssClass, bool showDistinctMinusValue)
    {
      return ComposeTextBox(dr, id, valueField, enable, cssClass, "", "", showDistinctMinusValue);
    }

    private string ComposeTextBox(DataRow dr, string id, string valueField, bool enable, string cssClass, string evt, string evtFunction, bool showDistinctMinusValue)
    {
      var disabled = "";
      var hiddenHtmlControls = "";
      var textBoxCss = "inputBox";
      if(!enable)
      {
        disabled = " readonly=\"readonly\" ";
        textBoxCss += " disabled";
      }
      else
      {
        hiddenHtmlControls = "<input type=\"hidden\" id=\"" + valueField + "_" + id + "_current\" value=\"" +
                             dr[valueField] + "\" />";
      }
      var evtAttr = !string.IsNullOrEmpty(evt) ? " " + evt + "=\"" + evtFunction + "\"" : "";
      var styleAttr = "";
      var html = new StringBuilder("<td class=\"" + cssClass + "\">");
      html.Append("<input class=\"" + textBoxCss + "\"" + disabled + "id=\"" + valueField + "_" + id + "\" name=\"" + valueField + "_" + id + "\" type=\"text\" value=\"" + dr[valueField] + "\"" + evtAttr + styleAttr + "/>");
      html.Append(hiddenHtmlControls);
      html.Append("</td>");
      return html.ToString();
    }


    private void UpdateChangesInBulk()
    {
      var exRateTreasuryIds = GetStatic.ReadFormData("selectId", "");
      if(string.IsNullOrEmpty(exRateTreasuryIds))
      {
        GetStatic.AlertMessage(Page, "Please select record to update");
        return;
      }
      var exRateTreasuryList = exRateTreasuryIds.Split(',');
      var xml = new StringBuilder();
      xml.Append("<root>");
      foreach(var id in exRateTreasuryList)
      {
        xml.Append("<row");
        xml.Append(" exRateTreasuryId=\"" + id + "\"");
        xml.Append(" cRate=\"" + GetStatic.ReadFormData("cRate_" + id, "") + "\"");
        xml.Append(" cMargin1=\"" + GetStatic.ReadFormData("cMargin_" + id, "") + "\"");
        xml.Append(" maxRate=\"" + GetStatic.ReadFormData("maxCrossRate_" + id, "") + "\"");
        xml.Append(" customerRate=\"" + GetStatic.ReadFormData("customerRate_" + id, "") + "\"");
        xml.Append(" />");
      }
      xml.Append("</root>");
      exRateTreasuryIds = obj.UpdateXmlRia(GetStatic.GetUser(), xml.ToString());
      GetStatic.WriteSession("exRateTreasuryIds", exRateTreasuryIds);
      Response.Redirect("../TPRate/RiaRate.aspx");
    }

    protected void btnUpdateChanges_Click(object sender, EventArgs e)
    {
      if(!isRefresh)
      {
        UpdateChangesInBulk();
      }
    }

    #region Browser Refresh

    private bool refreshState;
    private bool isRefresh;

    protected override void LoadViewState(object savedState)
    {
      object[] AllStates = (object[])savedState;
      base.LoadViewState(AllStates[0]);
      refreshState = bool.Parse(AllStates[1].ToString());
      if(Session["ISREFRESH"] != null && Session["ISREFRESH"] != "")
        isRefresh = (refreshState == (bool)Session["ISREFRESH"]);
    }

    protected override object SaveViewState()
    {
      Session["ISREFRESH"] = refreshState;
      object[] AllStates = new object[3];
      AllStates[0] = base.SaveViewState();
      AllStates[1] = !(refreshState);
      return AllStates;
    }

    #endregion Browser Refresh
  }
}