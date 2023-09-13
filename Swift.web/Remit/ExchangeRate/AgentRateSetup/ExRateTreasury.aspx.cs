using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.web.Remit.ExchangeRate.AgentRateSetup
{
    public partial class ExRateTreasury : System.Web.UI.Page
    {
        private ExRateTreasuryDao obj = new ExRateTreasuryDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftTab _tab = new SwiftTab();
        private const string GridName = "grd_ert";
        private const string ViewFunctionId = "30012400";
        private const string AddEditFunctionId = "30012410";
        private const string ApproveFunctionId = "30012430";

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
            if (!IsPostBack)
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

        private string GetRateType()
        {
            return GetStatic.ReadQueryString("rateType", "");
        }

        protected string GetIsFw()
        {
            return GetStatic.ReadQueryString("isFw", "");
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void LoadGrid()
        {
            var cRateId = "";
            var pRateId = "";
            var defExRateId = GetDefExRateId();
            countryOrderBy.Text = "receivingCountry";

            if (!string.IsNullOrEmpty(GetDefExRateId()))
            {
                switch (GetRateType().ToLower())
                {
                    case "c":
                        countryOrderBy.Text = "receivingCountry";
                        cRateId = GetDefExRateId();
                        defExRateId = "";
                        break;

                    case "p":
                        countryOrderBy.Text = "sendingCountry";
                        pRateId = GetDefExRateId();
                        defExRateId = "";
                        break;
                }
            }

            var isActive = "";
            isActive = "Y";
            btnMarkActive.Visible = false;
            btnMarkInactive.Visible = true;

            var ds = obj.LoadGridAfterCostChange(GetStatic.GetUser(), "1", "1000", countryOrderBy.Text, "", defExRateId, cRateId, pRateId, "", "", isActive);

            var dt = ds.Tables[1];
            var html = new StringBuilder();
            html.Append("<table id=\"rateTable\" class=\"table table-responsive table-bordered table-striped\">");
            html.Append("<tr class=\"hdtitle\">");
            html.Append("<th rowspan=\"3\" class=\"headingTH\" align=\"center\"><a href=\"javascript:void(0);\" onClick=\"CheckAll(this)\">√</a></th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\"><center>Send Country</center></th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\"><center>Send Agent<div class=\"headingAgent\"></div></center></th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\"><center>Receive Country</center></th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\"><center>Receive Agent<div class=\"headingAgent\"></div></center></th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\">Service Type</th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\">Send<br/>Curr.</th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\">Receive<br/>Curr.</th>");
            html.Append("<th colspan=\"8\" class=\"headingTH\"><center>Head Office<span id=\"agentfxs\" onclick=\"ShowAgentFxCol();\" title=\"Show Agent Fx\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
            html.Append("<th rowspan=\"2\" colspan=\"2\" class=\"headingTH\" ondblclick=\"HideAgentFxCol();\" style=\"cursor: pointer;\"><center><span id=\"agentfxh\" onclick=\"HideAgentFxCol();\" title=\"Hide Agent Fx\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Agent FX<span id=\"tolerances\" onclick=\"ShowToleranceCol();\" title=\"Show Tolerance\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
            html.Append("<th colspan=\"3\" class=\"headingTH\" ondblclick=\"HideToleranceCol();\" style=\"cursor: pointer;\"><center><span id=\"toleranceh\" onclick=\"HideToleranceCol();\" title=\"Hide Tolerance\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Tolerance<span id=\"sendingagents\" onclick=\"ShowSendingAgentCol();\" title=\"Show Sending Agent\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
            html.Append("<th colspan=\"6\" class=\"headingTH\" ondblclick=\"HideSendingAgentCol();\" style=\"cursor: pointer;\"><center><span id=\"sendingagenth\" onclick=\"HideSendingAgentCol();\" title=\"Hide Sending Agent\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Sending Agent<span id=\"customertols\" onclick=\"ShowCustomerTolCol();\" title=\"Show Customer Tol.\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
            html.Append("<th colspan=\"2\" rowspan=\"2\" class=\"headingTH\" ondblclick=\"HideCustomerTolCol();\" style=\"cursor: pointer;\"><center><span id=\"customertolh\" onclick=\"HideCustomerTolCol();\" title=\"Hide Customer Tol.\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Cust. Tol.</center></th>");
            html.Append("<th colspan=\"4\" class=\"headingTH\"><center>Cross Rate</center></th>");

            html.Append("<th rowspan=\"3\" class=\"headingTH\">Status</th>");
            //html.Append("<th rowspan=\"2\" class=\"headingTH\" align=\"center\"><a href=\"javascript:void(0);\" onClick=\"CheckAll(this)\">√|×</a></th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\">Last Updated</th>");

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
            //html.Append("<th class=\"headingTH\">Country</th>");
            //html.Append("<th class=\"headingTH\" style=\"min-width: 100px !important;\">Agent</th>");
            //html.Append("<th class=\"headingTH\">Country</th>");
            //html.Append("<th class=\"headingTH\" style=\"min-width: 100px !important;\">Agent</th>");

            //Head Office
            html.Append("<th class=\"thhorate\">Rate</th>");
            html.Append("<th class=\"thhorate\">Margin(I)</th>");
            html.Append("<th id=\"cHoMargin\" nowrap=\"nowrap\" class=\"thhorate showHand\" onclick=\"ShowHideCopyFunction(this,'cHoMargin');\">Margin<img src=\"../../../images/sortdn.gif\" border=\"0\" height=\"8\" width=\"8\"/></th>");
            html.Append("<th class=\"thhorate\">Offer</th>");
            html.Append("<th class=\"thhorate\">Rate</th>");
            html.Append("<th class=\"thhorate\">Margin(I)</th>");
            html.Append("<th id=\"pHoMargin\" nowrap=\"nowrap\" class=\"thhorate showHand\" onclick=\"ShowHideCopyFunction(this,'pHoMargin');\">Margin<img src=\"../../../images/sortdn.gif\" border=\"0\" height=\"8\" width=\"8\"/></th>");
            html.Append("<th class=\"thhorate\">Offer</th>");

            //Agent FX
            html.Append("<th class=\"thagentFx\">Value</th>");
            html.Append("<th class=\"agentFx\">Type</th>");

            //Tolerance
            html.Append("<th class=\"headingTH\">Min</th>");
            html.Append("<th class=\"headingTH\">Max</th>");

            //Sending Agent
            html.Append("<th class=\"thsendagentrate\">Rate</th>");
            html.Append("<th id=\"cAgentMargin\" nowrap=\"nowrap\" class=\"thsendagentrate showHand\" onclick=\"ShowHideCopyFunction(this,'cAgentMargin');\">Margin<img src=\"../../../images/sortdn.gif\" border=\"0\" height=\"8\" width=\"8\"/></th>");
            html.Append("<th class=\"thsendagentrate\">Offer</th>");
            html.Append("<th class=\"thsendagentrate\">Rate</th>");
            html.Append("<th id=\"pAgentMargin\" nowrap=\"nowrap\" class=\"thsendagentrate showHand\" onclick=\"ShowHideCopyFunction(this,'pAgentMargin');\">Margin<img src=\"../../../images/sortdn.gif\" border=\"0\" height=\"8\" width=\"8\"/></th>");
            html.Append("<th class=\"thsendagentrate\">Offer</th>");

            //Cust. Tol.
            html.Append("<th class=\"thcustomertol\">Min</th>");
            html.Append("<th class=\"thcustomertol\">Max</th>");

            //Customer
            html.Append("<th class=\"thcustomerrate\">Max Rate</th>");
            html.Append("<th class=\"thcustomerrate\">Agent Rate</th>");
            html.Append("<th class=\"thcustomerrate\">Cross Margin</th>");
            html.Append("<th class=\"thcustomerrate\">Customer Rate</th>");

            //html.Append("<th class=\"headingTH\" align=\"center\"><input type=\"button\" onClick=\"UpdateCheckedRecords();\" value=\"Update\" /></th>");
            html.Append("</tr>");

            var i = 0;
            var countryName = "";
            foreach (DataRow dr in dt.Rows)
            {
                var id = dr["exRateTreasuryId"].ToString();
                if (countryOrderBy.Text == "receivingCountry")
                {
                    if (countryName != dr["pCountryName"].ToString())
                    {
                        html.Append(
                            "<tr class=\"trcountry\"><td colspan=\"37\" class=\"tdcountry\" style=\"cursor: pointer\" onclick=\"CheckGroup(this,'" + dr["pCountryCode"] + "');\"><b>Receiving Country : " + GetStatic.GetCountryFlag(dr["pCountryCode"].ToString()) +
                            dr["pCountryName"] + "</b></td></tr>");
                        countryName = dr["pCountryName"].ToString();
                    }
                }
                else
                {
                    if (countryName != dr["cCountryName"].ToString())
                    {
                        html.Append(
                            "<tr class=\"trcountry\"><td colspan=\"37\" class=\"tdcountry\" style=\"cursor: pointer\" onclick=\"CheckGroup(this,'" + dr["cCountryCode"] + "');\"><b>Sending Country : " + GetStatic.GetCountryFlag(dr["cCountryCode"].ToString()) +
                            dr["cCountryName"] + "</b></td></tr>");
                        countryName = dr["cCountryName"].ToString();
                    }
                }

                if (dr["isUpdated"].ToString() == "Y")
                {
                    html.Append("<tr id=\"row_" + id + "\"" + AppendRowSelectionProperty("selectedbg", "rowhighlight", "GridOddRowOver") + ">");
                    if (dr["modType"].ToString() == "I")
                    {
                        var countryCode = countryOrderBy.Text == "sendingCountry" ? dr["cCountryCode"].ToString() : dr["pCountryCode"].ToString();
                        html.Append("<td align=\"center\">");
                        html.Append("<input type=\"checkbox\" id = \"" + countryCode + "_" + id + "\" name = \"chkId\" value=\"" + id + "\" onclick=\"KeepRowSelection(" + i + "," + id + ",'" + countryCode + "');\" />");
                        html.Append("<input type=\"hidden\" id=\"" + id + "\" name=\"" + id + "\" value=\"" + i + "\"/>");
                        html.Append("<input type=\"hidden\" id=\"cRateMaskBd_" + id + "\" name=\"cRateMaskBd_" + id + "\" value=\"" + dr["cRateMaskMulBd"] + "\"/>");
                        html.Append("<input type=\"hidden\" id=\"cRateMaskAd_" + id + "\" name=\"cRateMaskAd_" + id + "\" value=\"" + dr["cRateMaskMulAd"] + "\"/>");
                        html.Append("<input type=\"hidden\" id=\"pRateMaskAd_" + id + "\" name=\"pRateMaskAd_" + id + "\" value=\"" + dr["pRateMaskMulAd"] + "\"/>");
                        html.Append("<input type=\"hidden\" id=\"pRateMaskAd_" + id + "\" name=\"pRateMaskAd_" + id + "\" value=\"" + dr["pRateMaskMulAd"] + "\"/>");
                        html.Append("<input type=\"hidden\" id=\"crossRateMaskAd_" + id + "\" name=\"crossRateMaskAd_" + id + "\" value=\"" + dr["crossRateMaskAd"] + "\"/>");
                        html.Append("</td>");
                        html.Append("<td nowrap=\"nowrap\">" + GetStatic.GetCountryFlag(dr["cCountryCode"].ToString()) + dr["cCountryName"] + "</td>");
                        html.Append("<td>" + dr["cAgentName"] + "</td>");
                        html.Append("<td nowrap=\"nowrap\">" + GetStatic.GetCountryFlag(dr["pCountryCode"].ToString()) + dr["pCountryName"] + "</td>");
                        html.Append("<td>" + dr["pAgentName"] + "</td>");
                        html.Append("<td>" + dr["tranType"] + "</td>");
                        html.Append("<td>" + dr["cCurrency"] + "</td>");
                        html.Append("<td>" + dr["pCurrency"] + "</td>");

                        //Head Office Cost, Margin, Offer to agent
                        html.Append("<td class=\"tdhorate\">" + dr["cRate"] + "</td>");
                        html.Append("<td class=\"tdhorate\">" + dr["cMargin"] + "</td>");
                        html.Append(ComposeTextBox(dr, id, "cHoMargin", true, "tdhorate", false));
                        html.Append("<td class=\"tdhorate\" id=\"cOffer_" + id + "\">" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"])) + "</td>");
                        html.Append("<td class=\"tdhorate\">" + dr["pRate"] + "</td>");
                        html.Append("<td class=\"tdhorate\">" + dr["pMargin"] + "</td>");
                        html.Append(ComposeTextBox(dr, id, "pHoMargin", true, "tdhorate", false));
                        html.Append("<td class=\"tdhorate\" id=\"pOffer_" + id + "\">" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"])) + "</td>");

                        //Agent Fx
                        html.Append(ComposeTextBox(dr, id, "sharingValue", true, "tdagentfx", false));
                        html.Append("<td class=\"tdagentfx\"><select id=\"sharingType_" + id + "\" name=\"sharingType_" + id + "\">");
                        var sharingTypeList = "";
                        sharingTypeList = dr["sharingType"].ToString().ToUpper() == "P"
                                              ? "<option value=\"P\" selected=\"selected\">%</option><option value=\"F\">F</option>"
                                              : "<option value=\"P\">%</option><option value=\"F\" selected=\"selected\">F</option>";
                        html.Append(sharingTypeList);
                        html.Append("</select></td>");

                        //Tolerance
                        html.Append("<td><select id=\"toleranceOn_" + id + "\" name=\"toleranceOn_" + id + "\">");
                        var tolOnList = "";
                        var crossMarginTb = "";
                        if (dr["toleranceOn"].ToString().ToUpper() == "S")
                        {
                            tolOnList =
                                "<option value=\"S\" selected=\"selected\">SR</option><option value=\"P\">PR</option><option value=\"C\">CR</option>";
                            crossMarginTb = ComposeTextBox(dr, id, "agentCrossRateMargin", false, "tdCustomerRate", false);
                        }
                        else if (dr["toleranceOn"].ToString().ToUpper() == "P")
                        {
                            tolOnList =
                                "<option value=\"S\">SR</option><option value=\"P\" selected=\"selected\">PR</option><option value=\"C\">CR</option>";
                            crossMarginTb = ComposeTextBox(dr, id, "agentCrossRateMargin", false, "tdCustomerRate", false);
                        }
                        else if (dr["toleranceOn"].ToString().ToUpper() == "C")
                        {
                            tolOnList =
                                "<option value=\"S\">SR</option><option value=\"P\">PR</option><option value=\"C\" selected=\"selected\">CR</option>";
                            crossMarginTb = ComposeTextBox(dr, id, "agentCrossRateMargin", true, "tdCustomerRate", false);
                        }
                        html.Append(tolOnList);
                        html.Append("</select></td>");
                        html.Append(ComposeTextBox(dr, id, "agentTolMin", true, "tdagenttol", false));
                        html.Append(ComposeTextBox(dr, id, "agentTolMax", true, "tdagenttol", false));

                        //Agent Cost, Margin, Offer to customer
                        html.Append("<td class=\"tdsendagentrate\" id=\"cAgentOffer_" + id + "\">" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"])) + "</td>");
                        html.Append(ComposeTextBox(dr, id, "cAgentMargin", true, "tdsendagentrate", false));
                        html.Append("<td class=\"tdsendagentrate\" id=\"cCustomerOffer_" + id + "\">" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"]) + Convert.ToDecimal(dr["cAgentMargin"])) + "</td>");
                        html.Append("<td class=\"tdsendagentrate\" id=\"pAgentOffer_" + id + "\">" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"])) + "</td>");
                        html.Append(ComposeTextBox(dr, id, "pAgentMargin", true, "tdsendagentrate", false));
                        html.Append("<td class=\"tdsendagentrate\" id=\"pCustomerOffer_" + id + "\">" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"]) - Convert.ToDecimal(dr["pAgentMargin"])) + "</td>");

                        //Customer Tol
                        html.Append(ComposeTextBox(dr, id, "customerTolMin", true, "tdcustomertol", false));
                        html.Append(ComposeTextBox(dr, id, "customerTolMax", true, "tdcustomertol", false));

                        //Customer
                        html.Append(ComposeTextBox(dr, id, "maxCrossRate", false, "tdcustomerrate", false));
                        html.Append(ComposeTextBox(dr, id, "crossRate", false, "tdcustomerrate", false));
                        html.Append(crossMarginTb);
                        html.Append(ComposeTextBox(dr, id, "customerRate", false, "tdcustomerrate", false));

                        html.Append("<td>" + dr["status"] + "</td>");
                        //html.Append("<td align=\"center\"><input type=\"checkbox\" id = \"chk_" +
                        //           id + "\" name = \"chkId\" value=\"" + id +
                        //           "\" /></td>");
                        html.Append("<td nowrap='nowrap'>");
                        html.Append("<input type=\"hidden\" id=\"cRate_" + id + "\" name=\"cRate_" + id + "\" value=\"" + dr["cRate"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"pRate_" + id + "\" name=\"pRate_" + id + "\" value=\"" + dr["pRate"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"cMin_" + id + "\" name=\"cMin_" + id + "\" value=\"" + dr["cMin"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"cMax_" + id + "\" name=\"cMax_" + id + "\" value=\"" + dr["cMax"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"pMin_" + id + "\" name=\"pMin_" + id + "\" value=\"" + dr["pMin"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"pMax_" + id + "\" name=\"pMax_" + id + "\" value=\"" + dr["pMax"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"isUpdated_" + id + "\" name=\"isUpdated_" + id + "\" value=\"Y\" />");
                        html.Append("<div id=\"divUpdate_" + id + "\" style=\"position:absolute;margin-top: 17px; margin-left: 0px; display: none; border: none;\">");
                        html.Append("<input id=\"btnUpdate_" + id + "\" type=\"button\" class=\"btn btn-primary\" onclick=\"UpdateRate(" + id + ",'Y')\" value=\"Update\"/>");
                        html.Append("<img src=\"../../../Images/close-icon.png\" border=\"0\" class=\"showHand\" onclick=\"RemoveDivUpdate(" + id + ");\" title=\"Close\"/>");
                        html.Append("</div>");
                        html.Append(dr["lastModifiedDate"] + "<br/>" + dr["lastModifiedBy"]);
                        html.Append("</td></tr>");
                    }
                    else //Load Old and New value for cost rate modified record
                    {
                        var countryCode = countryOrderBy.Text == "sendingCountry" ? dr["cCountryCode"].ToString() : dr["pCountryCode"].ToString();
                        html.Append("<td rowspan=\"2\" align=\"center\">");
                        html.Append("<input type=\"checkbox\" id = \"" + countryCode + "_" + id + "\" name = \"chkId\" value=\"" + id + "\" onclick=\"KeepRowSelection(" + i + "," + id + ",'" + countryCode + "');\" />");
                        html.Append("<input type=\"hidden\" id=\"" + id + "\" name=\"" + id + "\" value=\"" + i + "\"/>");
                        html.Append("<input type=\"hidden\" id=\"cRateMaskBd_" + id + "\" name=\"cRateMaskBd_" + id + "\" value=\"" + dr["cRateMaskMulBd"] + "\"/>");
                        html.Append("<input type=\"hidden\" id=\"cRateMaskAd_" + id + "\" name=\"cRateMaskAd_" + id + "\" value=\"" + dr["cRateMaskMulAd"] + "\"/>");
                        html.Append("<input type=\"hidden\" id=\"pRateMaskAd_" + id + "\" name=\"pRateMaskAd_" + id + "\" value=\"" + dr["pRateMaskMulAd"] + "\"/>");
                        html.Append("<input type=\"hidden\" id=\"pRateMaskAd_" + id + "\" name=\"pRateMaskAd_" + id + "\" value=\"" + dr["pRateMaskMulAd"] + "\"/>");
                        html.Append("<input type=\"hidden\" id=\"crossRateMaskAd_" + id + "\" name=\"crossRateMaskAd_" + id + "\" value=\"" + dr["crossRateMaskAd"] + "\"/>");
                        html.Append("</td>");
                        html.Append("<td nowrap=\"nowrap\" rowspan=\"2\">" + GetStatic.GetCountryFlag(dr["cCountryCode"].ToString()) + dr["cCountryName"] + "</td>");
                        html.Append("<td rowspan=\"2\">" + dr["cAgentName"] + "</td>");
                        html.Append("<td nowrap=\"nowrap\" rowspan=\"2\">" + GetStatic.GetCountryFlag(dr["pCountryCode"].ToString()) + dr["pCountryName"] + "</td>");
                        html.Append("<td rowspan=\"2\">" + dr["pAgentName"] + "</td>");
                        html.Append("<td rowspan=\"2\">" + dr["tranType"] + "</td>");
                        html.Append("<td rowspan=\"2\">" + dr["cCurrency"] + "</td>");
                        html.Append("<td rowspan=\"2\">" + dr["pCurrency"] + "</td>");

                        //Current Value-------------------------------------------------------------------------------------------------------------

                        //Head Office Cost, Margin, Offer to agent
                        html.Append("<td class=\"tdhorate\">" + dr["cRate"] + "</td>");
                        html.Append("<td class=\"tdhorate\">" + dr["cMargin"] + "</td>");
                        html.Append("<td class=\"tdhorate\">" + dr["cHoMargin"] + "</td>");
                        html.Append("<td class=\"tdhorate\">" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"])) + "</td>");
                        html.Append("<td class=\"tdhorate\">" + dr["pRate"] + "</td>");
                        html.Append("<td class=\"tdhorate\">" + dr["pMargin"] + "</td>");
                        html.Append("<td class=\"tdhorate\">" + dr["pHoMargin"] + "</td>");
                        html.Append("<td class=\"tdhorate\">" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"])) + "</td>");

                        //Agent Fx
                        html.Append("<td class=\"tdagentfx\">" + dr["sharingValue"] + "</td>");
                        html.Append(ComposeLabel(dr, "sharingType", "tdagentfx", false));

                        //Tolerance
                        html.Append(ComposeLabel(dr, "toleranceOn", "tdagenttol", false));
                        html.Append("<td>" + dr["agentTolMin"] + "</td>");
                        html.Append("<td>" + dr["agentTolMax"] + "</td>");

                        //Agent Cost, Margin, Offer to customer
                        html.Append("<td class=\"tdsendagentrate\">" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"])) + "</td>");
                        html.Append("<td class=\"tdsendagentrate\">" + dr["cAgentMargin"] + "</td>");
                        html.Append("<td class=\"tdsendagentrate\">" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"]) + Convert.ToDecimal(dr["cAgentMargin"])) + "</td>");
                        html.Append("<td class=\"tdsendagentrate\">" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"])) + "</td>");
                        html.Append("<td class=\"tdsendagentrate\">" + dr["pAgentMargin"] + "</td>");
                        html.Append("<td class=\"tdsendagentrate\">" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"]) - Convert.ToDecimal(dr["pAgentMargin"])) + "</td>");

                        //Customer Tol
                        html.Append(ComposeLabel(dr, "customerTolMin", "tdcustomertol", false));
                        html.Append(ComposeLabel(dr, "customerTolMax", "tdcustomertol", false));

                        //Customer
                        html.Append(ComposeLabel(dr, "maxCrossRate", "tdcustomerrate", false));
                        html.Append(ComposeLabel(dr, "crossRate", "tdcustomerrate", false));
                        html.Append(ComposeLabel(dr, "agentCrossRateMargin", "tdcustomerrate", false));
                        html.Append(ComposeLabel(dr, "customerRate", "tdcustomerrate", false));

                        html.Append("<td>" + dr["status"] + "</td>");
                        //html.Append("<td rowspan=\"2\" align=\"center\"><input type=\"checkbox\" id = \"chk_" +
                        //            id + "\" name = \"chkId\" value=\"" + id +
                        //            "\" /></td>");
                        html.Append("<td rowspan=\"2\" nowrap='nowrap'>");
                        html.Append("<input type=\"hidden\" id=\"cRate_" + id + "\" name=\"cRate_" + id + "\" value=\"" + dr["cRateNew"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"pRate_" + id + "\" name=\"pRate_" + id + "\" value=\"" + dr["pRateNew"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"cMin_" + id + "\" name=\"cMin_" + id + "\" value=\"" + dr["cMin"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"cMax_" + id + "\" name=\"cMax_" + id + "\" value=\"" + dr["cMax"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"pMin_" + id + "\" name=\"pMin_" + id + "\" value=\"" + dr["pMin"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"pMax_" + id + "\" name=\"pMax_" + id + "\" value=\"" + dr["pMax"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"isUpdated_" + id + "\" name=\"isUpdated_" + id + "\" value=\"Y\" />");
                        html.Append("<div id=\"divUpdate_" + id + "\" style=\"position:absolute;margin-top: 17px; margin-left: 0px; display: none; border: none;\">");
                        html.Append("<input id=\"btnUpdate_" + id + "\" type=\"button\" class=\"btn btn-primary\" onclick=\"UpdateRate(" + id + ",'Y')\" value=\"Update\"/>");
                        html.Append("<img src=\"../../../Images/close-icon.png\" border=\"0\" class=\"showHand\" onclick=\"RemoveDivUpdate(" + id + ");\" title=\"Close\"/>");
                        html.Append("</div>");
                        html.Append(dr["lastModifiedDate"] + "<br/>" + dr["lastModifiedBy"]);
                        html.Append("</td></tr>");
                        html.Append("<tr class=\"rowhighlight\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='rowhighlight'\">");

                        //New Value----------------------------------------------------------------------------------------------------------------------------------

                        //Head Office Cost, Margin, Offer to agent
                        html.Append("<td class=\"rowNew\" id=\"cRateLbl_" + id + "\">" + dr["cRateNew"] + "</td>");
                        html.Append("<td class=\"rowNew\" id=\"cMargin_" + id + "\">" + dr["cMarginNew"] + "</td>");
                        html.Append(ComposeTextBoxWithValue(dr, id, "cHoMargin", true, "tdhorate", "onblur", "CalcCOffers(this," + id + "," + dr["cRateMaskMulBd"] + "," + dr["cRateMaskMulAd"] + "," + dr["crossRateMaskAd"] + ");", false, dr["cHoMarginNew"].ToString()));
                        html.Append("<td class=\"rowNew\" id=\"cOffer_" + id + "\">" + (Convert.ToDecimal(dr["cRateNew"]) + Convert.ToDecimal(dr["cMarginNew"]) + Convert.ToDecimal(dr["cHoMarginNew"])) + "</td>");
                        html.Append("<td class=\"rowNew\" id=\"pRateLbl_" + id + "\">" + dr["pRateNew"] + "</td>");
                        html.Append("<td class=\"rowNew\" id=\"pMargin_" + id + "\">" + dr["pMarginNew"] + "</td>");
                        html.Append(ComposeTextBoxWithValue(dr, id, "pHoMargin", true, "tdhorate", "onblur", "CalcPOffers(this," + id + "," + dr["cRateMaskMulBd"] + "," + dr["cRateMaskMulAd"] + "," + dr["pRateMaskMulBd"] + "," + dr["pRateMaskMulAd"] + "," + dr["crossRateMaskAd"] + ");", false, dr["pHoMarginNew"].ToString()));
                        html.Append("<td class=\"rowNew\" id=\"pOffer_" + id + "\">" + (Convert.ToDecimal(dr["pRateNew"]) - Convert.ToDecimal(dr["pMarginNew"]) - Convert.ToDecimal(dr["pHoMarginNew"])) + "</td>");

                        //Agent Fx
                        html.Append(ComposeTextBoxWithValue(dr, id, "sharingValue", true, "rowNew", false, dr["sharingValueNew"].ToString()));
                        html.Append("<td class=\"rowNew\"><select id=\"sharingType_" + id + "\" name=\"sharingType_" + id + "\">");
                        var sharingTypeList = "";
                        sharingTypeList = dr["sharingTypeNew"].ToString().ToUpper() == "P"
                                              ? "<option value=\"P\" selected=\"selected\">%</option><option value=\"F\">F</option>"
                                              : "<option value=\"P\">%</option><option value=\"F\" selected=\"selected\">F</option>";
                        html.Append(sharingTypeList);
                        html.Append("</select></td>");

                        //Tolerance
                        html.Append("<td><select id=\"toleranceOn_" + id + "\" name=\"toleranceOn_" + id + "\">");
                        var tolOnList = "";
                        var crossMarginTb = "";
                        if (dr["toleranceOnNew"].ToString().ToUpper() == "S")
                        {
                            tolOnList =
                                "<option value=\"S\" selected=\"selected\">SR</option><option value=\"P\">PR</option><option value=\"C\">CR</option>";
                            crossMarginTb = ComposeTextBoxWithValue(dr, id, "agentCrossRateMargin", false, "rowNew", false, dr["agentCrossRateMarginNew"].ToString());
                        }
                        else if (dr["toleranceOnNew"].ToString().ToUpper() == "P")
                        {
                            tolOnList =
                                "<option value=\"S\">SR</option><option value=\"P\" selected=\"selected\">PR</option><option value=\"C\">CR</option>";
                            crossMarginTb = ComposeTextBoxWithValue(dr, id, "agentCrossRateMargin", false, "rowNew", false, dr["agentCrossRateMarginNew"].ToString());
                        }
                        else if (dr["toleranceOnNew"].ToString().ToUpper() == "C")
                        {
                            tolOnList =
                                "<option value=\"S\">SR</option><option value=\"P\">PR</option><option value=\"C\" selected=\"selected\">CR</option>";
                            crossMarginTb = ComposeTextBoxWithValue(dr, id, "agentCrossRateMargin", true, "rowNew", "onblur", "OnBlurCrossMargin(this, " + id + ")", false, dr["agentCrossRateMarginNew"].ToString());
                        }
                        else
                        {
                            tolOnList =
                                "<option value=\"S\">SR</option><option value=\"P\">PR</option><option value=\"C\">CR</option>";
                            crossMarginTb = ComposeTextBoxWithValue(dr, id, "agentCrossRateMargin", false, "rowNew", false, dr["agentCrossRateMarginNew"].ToString());
                        }
                        html.Append(tolOnList);
                        html.Append("</select></td>");
                        html.Append(ComposeTextBoxWithValue(dr, id, "agentTolMin", true, "rowNew", false, dr["agentTolMinNew"].ToString()));
                        html.Append(ComposeTextBoxWithValue(dr, id, "agentTolMax", true, "rowNew", false, dr["agentTolMaxNew"].ToString()));

                        //Agent Cost, Margin, Offer to customer
                        html.Append("<td class=\"rowNew\" id=\"cAgentOffer_" + id + "\">" + (Convert.ToDecimal(dr["cRateNew"]) + Convert.ToDecimal(dr["cMarginNew"]) + Convert.ToDecimal(dr["cHoMarginNew"])) + "</td>");
                        html.Append(ComposeTextBoxWithValue(dr, id, "cAgentMargin", true, "rowNew", "onblur", "CalcCOffers(this," + id + "," + dr["cRateMaskMulBd"] + "," + dr["cRateMaskMulAd"] + "," + dr["crossRateMaskAd"] + ");", false, dr["cAgentMarginNew"].ToString()));
                        html.Append("<td class=\"rowNew\" id=\"cCustomerOffer_" + id + "\">" + (Convert.ToDecimal(dr["cRateNew"]) + Convert.ToDecimal(dr["cMarginNew"]) + Convert.ToDecimal(dr["cHoMarginNew"]) + Convert.ToDecimal(dr["cAgentMarginNew"])) + "</td>");
                        html.Append("<td class=\"rowNew\" id=\"pAgentOffer_" + id + "\">" + (Convert.ToDecimal(dr["pRateNew"]) - Convert.ToDecimal(dr["pMarginNew"]) - Convert.ToDecimal(dr["pHoMarginNew"])) + "</td>");
                        html.Append(ComposeTextBoxWithValue(dr, id, "pAgentMargin", true, "rowNew", "onblur", "CalcPOffers(this," + id + "," + dr["cRateMaskMulBd"] + "," + dr["cRateMaskMulAd"] + "," + dr["pRateMaskMulBd"] + "," + dr["pRateMaskMulAd"] + "," + dr["crossRateMaskAd"] + ");", false, dr["pAgentMarginNew"].ToString()));
                        html.Append("<td class=\"rowNew\" id=\"pCustomerOffer_" + id + "\">" + (Convert.ToDecimal(dr["pRateNew"]) - Convert.ToDecimal(dr["pMarginNew"]) - Convert.ToDecimal(dr["pHoMarginNew"]) - Convert.ToDecimal(dr["pAgentMarginNew"])) + "</td>");

                        //Customer Tol
                        html.Append(ComposeTextBoxWithValue(dr, id, "customerTolMin", true, "rowNew", false, dr["customerTolMinNew"].ToString()));
                        html.Append(ComposeTextBoxWithValue(dr, id, "customerTolMax", true, "rowNew", false, dr["customerTolMaxNew"].ToString()));

                        //Customer
                        html.Append(ComposeTextBoxWithValue(dr, id, "maxCrossRate", false, "rowNew", false, dr["maxCrossRateNew"].ToString()));
                        html.Append(ComposeTextBoxWithValue(dr, id, "crossRate", false, "rowNew", false, dr["crossRateNew"].ToString()));
                        html.Append(crossMarginTb);
                        html.Append(ComposeTextBoxWithValue(dr, id, "customerRate", false, "rowNew", false, dr["customerRateNew"].ToString()));

                        html.Append("<td>" + dr["statusNew"] + "</td>");
                        html.Append("</tr>");
                    }
                }
                else
                {
                    if ((dr["modType"].ToString() == "U") && dr["modifiedBy"].ToString() == GetStatic.GetUser())  //Load Data for modifying user
                    {
                        var countryCode = countryOrderBy.Text == "sendingCountry" ? dr["cCountryCode"].ToString() : dr["pCountryCode"].ToString();
                        html.Append(++i % 2 == 1 ? "<tr id=\"row_" + id + "\"" + AppendRowSelectionProperty("selectedbg", "oddbg", "GridOddRowOver") + ">" : "<tr id=\"row_" + id + "\"" + AppendRowSelectionProperty("selectedbg", "evenbg", "GridEvenRowOver") + ">");
                        html.Append("<td align=\"center\">");
                        html.Append("<input type=\"checkbox\" id = \"" + countryCode + "_" + id + "\" name = \"chkId\" value=\"" + id + "\" onclick=\"KeepRowSelection(" + i + "," + id + ",'" + countryCode + "');\" />");
                        html.Append("<input type=\"hidden\" id=\"" + id + "\" name=\"" + id + "\" value=\"" + i + "\"/>");
                        html.Append("<input type=\"hidden\" id=\"cRateMaskBd_" + id + "\" name=\"cRateMaskBd_" + id + "\" value=\"" + dr["cRateMaskMulBd"] + "\"/>");
                        html.Append("<input type=\"hidden\" id=\"cRateMaskAd_" + id + "\" name=\"cRateMaskAd_" + id + "\" value=\"" + dr["cRateMaskMulAd"] + "\"/>");
                        html.Append("<input type=\"hidden\" id=\"pRateMaskAd_" + id + "\" name=\"pRateMaskAd_" + id + "\" value=\"" + dr["pRateMaskMulAd"] + "\"/>");
                        html.Append("<input type=\"hidden\" id=\"pRateMaskAd_" + id + "\" name=\"pRateMaskAd_" + id + "\" value=\"" + dr["pRateMaskMulAd"] + "\"/>");
                        html.Append("<input type=\"hidden\" id=\"crossRateMaskAd_" + id + "\" name=\"crossRateMaskAd_" + id + "\" value=\"" + dr["crossRateMaskAd"] + "\"/>");
                        html.Append("</td>");
                        html.Append("<td nowrap=\"nowrap\">" + GetStatic.GetCountryFlag(dr["cCountryCode"].ToString()) + dr["cCountryName"] + "</td>");
                        html.Append("<td>" + dr["cAgentName"] + "</td>");
                        html.Append("<td nowrap=\"nowrap\">" + GetStatic.GetCountryFlag(dr["pCountryCode"].ToString()) + dr["pCountryName"] + "</td>");
                        html.Append("<td>" + dr["pAgentName"] + "</td>");
                        html.Append("<td>" + dr["tranType"] + "</td>");
                        html.Append("<td>" + dr["cCurrency"] + "</td>");
                        html.Append("<td>" + dr["pCurrency"] + "</td>");

                        //Head Office Rate, Margin, Offer to Agent
                        html.Append("<td class=\"tdhorate\" id=\"cRateLbl_" + id + "\">" + dr["cRateNew"] + "</td>");
                        html.Append("<td class=\"tdhorate\" id=\"cMargin_" + id + "\">" + dr["cMarginNew"] + "</td>");
                        html.Append(ComposeTextBoxWithValue(dr, id, "cHoMargin", true, "tdhorate", "onblur", "CalcCOffers(this," + id + "," + dr["cRateMaskMulBd"] + "," + dr["cRateMaskMulAd"] + "," + dr["crossRateMaskAd"] + ");", false, dr["cHoMarginNew"].ToString()));
                        html.Append("<td class=\"tdhorate\" id=\"cOffer_" + id + "\">" + (Convert.ToDecimal(dr["cRateNew"]) + Convert.ToDecimal(dr["cMarginNew"]) + Convert.ToDecimal(dr["cHoMarginNew"])) + "</td>");
                        html.Append("<td class=\"tdhorate\" id=\"pRateLbl_" + id + "\">" + dr["pRateNew"] + "</td>");
                        html.Append("<td class=\"tdhorate\" id=\"pMargin_" + id + "\">" + dr["pMarginNew"] + "</td>");
                        html.Append(ComposeTextBoxWithValue(dr, id, "pHoMargin", true, "tdhorate", "onblur", "CalcPOffers(this," + id + "," + dr["cRateMaskMulBd"] + "," + dr["cRateMaskMulAd"] + "," + dr["pRateMaskMulBd"] + "," + dr["pRateMaskMulAd"] + "," + dr["crossRateMaskAd"] + ");", false, dr["pHoMarginNew"].ToString()));
                        html.Append("<td class=\"tdhorate\" id=\"pOffer_" + id + "\">" + (Convert.ToDecimal(dr["pRateNew"]) - Convert.ToDecimal(dr["pMarginNew"]) - Convert.ToDecimal(dr["pHoMarginNew"])) + "</td>");

                        //Agent Fx
                        html.Append(ComposeTextBoxWithValue(dr, id, "sharingValue", true, "tdagentfx", false, dr["sharingValueNew"].ToString()));
                        html.Append("<td class=\"tdagentfx\"><select id=\"sharingType_" + id + "\" name=\"sharingType_" + id + "\">");
                        var sharingTypeList = "";
                        sharingTypeList = dr["sharingTypeNew"].ToString().ToUpper() == "P"
                                                    ? "<option value=\"P\" selected=\"selected\">%</option><option value=\"F\">F</option>"
                                                    : "<option value=\"P\">%</option><option value=\"F\" selected=\"selected\">F</option>";
                        html.Append(sharingTypeList);
                        html.Append("</select></td>");

                        //Tolerance
                        html.Append("<td><select id=\"toleranceOn_" + id + "\" name=\"toleranceOn_" + id + "\">");
                        var tolOnList = "";
                        var crossMarginTb = "";
                        if (dr["toleranceOnNew"].ToString().ToUpper() == "S")
                        {
                            tolOnList =
                                "<option value=\"S\" selected=\"selected\">SR</option><option value=\"P\">PR</option><option value=\"C\">CR</option>";
                            crossMarginTb = ComposeTextBoxWithValue(dr, id, "agentCrossRateMargin", false, "tdcustomerrate", false, dr["agentCrossRateMarginNew"].ToString());
                        }
                        else if (dr["toleranceOnNew"].ToString().ToUpper() == "P")
                        {
                            tolOnList =
                                "<option value=\"S\">SR</option><option value=\"P\" selected=\"selected\">PR</option><option value=\"C\">CR</option>";
                            crossMarginTb = ComposeTextBoxWithValue(dr, id, "agentCrossRateMargin", false, "tdcustomerrate", false, dr["agentCrossRateMarginNew"].ToString());
                        }
                        else if (dr["toleranceOnNew"].ToString().ToUpper() == "C")
                        {
                            tolOnList =
                                "<option value=\"S\">SR</option><option value=\"P\">PR</option><option value=\"C\" selected=\"selected\">CR</option>";
                            crossMarginTb = ComposeTextBoxWithValue(dr, id, "agentCrossRateMargin", true, "tdcustomerrate", "onblur", "OnBlurCrossMargin(this, " + id + ");", false, dr["agentCrossRateMarginNew"].ToString());
                        }
                        else
                        {
                            tolOnList =
                                "<option value=\"S\">SR</option><option value=\"P\">PR</option><option value=\"C\">CR</option>";
                            crossMarginTb = ComposeTextBoxWithValue(dr, id, "agentCrossRateMargin", false, "tdcustomerrate", false, dr["agentCrossRateMarginNew"].ToString());
                        }
                        html.Append(tolOnList);
                        html.Append("</select></td>");
                        html.Append(ComposeTextBoxWithValue(dr, id, "agentTolMin", true, "tdagenttol", false, dr["agentTolMinNew"].ToString()));
                        html.Append(ComposeTextBoxWithValue(dr, id, "agentTolMax", true, "tdagenttol", false, dr["agentTolMaxNew"].ToString()));

                        //Sending Agent Rate, Margin, Offer to Customer
                        html.Append("<td class=\"tdsendagentrate\" id=\"cAgentOffer_" + id + "\">" + (Convert.ToDecimal(dr["cRateNew"]) + Convert.ToDecimal(dr["cMarginNew"]) + Convert.ToDecimal(dr["cHoMarginNew"])) + "</td>");
                        html.Append(ComposeTextBoxWithValue(dr, id, "cAgentMargin", true, "tdsendagentrate", "onblur", "CalcCOffers(this," + id + "," + dr["cRateMaskMulBd"] + "," + dr["cRateMaskMulAd"] + "," + dr["crossRateMaskAd"] + ");", false, dr["cAgentMarginNew"].ToString()));
                        html.Append("<td class=\"tdsendagentrate\" id=\"cCustomerOffer_" + id + "\">" + (Convert.ToDecimal(dr["cRateNew"]) + Convert.ToDecimal(dr["cMarginNew"]) + Convert.ToDecimal(dr["cHoMarginNew"]) + Convert.ToDecimal(dr["cAgentMarginNew"])) + "</td>");
                        html.Append("<td class=\"tdsendagentrate\" id=\"pAgentOffer_" + id + "\">" + (Convert.ToDecimal(dr["pRateNew"]) - Convert.ToDecimal(dr["pMarginNew"]) - Convert.ToDecimal(dr["pHoMarginNew"])) + "</td>");
                        html.Append(ComposeTextBoxWithValue(dr, id, "pAgentMargin", true, "tdsendagentrate", "onblur", "CalcPOffers(this," + id + "," + dr["cRateMaskMulBd"] + "," + dr["cRateMaskMulAd"] + "," + dr["pRateMaskMulBd"] + "," + dr["pRateMaskMulAd"] + "," + dr["crossRateMaskAd"] + ");", false, dr["pAgentMarginNew"].ToString()));
                        html.Append("<td class=\"tdsendagentrate\" id=\"pCustomerOffer_" + id + "\">" + (Convert.ToDecimal(dr["pRateNew"]) - Convert.ToDecimal(dr["pMarginNew"]) - Convert.ToDecimal(dr["pHoMarginNew"]) - Convert.ToDecimal(dr["pAgentMarginNew"])) + "</td>");

                        //Customer Tol
                        html.Append(ComposeTextBoxWithValue(dr, id, "customerTolMin", true, "tdcustomertol", false, dr["customerTolMinNew"].ToString()));
                        html.Append(ComposeTextBoxWithValue(dr, id, "customerTolMax", true, "tdcustomertol", false, dr["customerTolMaxNew"].ToString()));

                        //Customer
                        html.Append(ComposeTextBoxWithValue(dr, id, "maxCrossRate", false, "tdcustomerrate", false, dr["maxCrossRateNew"].ToString()));
                        html.Append(ComposeTextBoxWithValue(dr, id, "crossRate", false, "tdcustomerrate", false, dr["crossRateNew"].ToString()));
                        html.Append(crossMarginTb);
                        html.Append(ComposeTextBoxWithValue(dr, id, "customerRate", false, "tdcustomerrate", false, dr["customerRateNew"].ToString()));

                        html.Append("<td>" + dr["status"] + "</td>");

                        html.Append("<td nowrap='nowrap'>");
                        html.Append("<input type=\"hidden\" id=\"cRate_" + id + "\" name=\"cRate_" + id + "\" value=\"" + dr["cRateNew"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"pRate_" + id + "\" name=\"pRate_" + id + "\" value=\"" + dr["pRateNew"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"cMin_" + id + "\" name=\"cMin_" + id + "\" value=\"" + dr["cMin"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"cMax_" + id + "\" name=\"cMax_" + id + "\" value=\"" + dr["cMax"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"pMin_" + id + "\" name=\"pMin_" + id + "\" value=\"" + dr["pMin"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"pMax_" + id + "\" name=\"pMax_" + id + "\" value=\"" + dr["pMax"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"isUpdated_" + id + "\" name=\"isUpdated_" + id + "\" value=\"N\" />");
                        html.Append("<div id=\"divUpdate_" + id + "\" style=\"position:absolute;margin-top: 17px; margin-left: 0px; display: none; border: none;\">");
                        html.Append("<input id=\"btnUpdate_" + id + "\" type=\"button\" class=\"btn btn-primary\" onclick=\"UpdateRate(" + id + ",'N')\" value=\"Update\"/>");
                        html.Append("<img src=\"../../../Images/close-icon.png\" border=\"0\" class=\"showHand\" onclick=\"RemoveDivUpdate(" + id + ");\" title=\"Close\"/>");
                        html.Append("</div>");
                        html.Append(dr["lastModifiedDate"] + "<br/>" + dr["lastModifiedBy"]);
                        if (dr["haschanged"].ToString().ToUpper().Equals("Y"))
                        {
                            if (dr["modifiedby"].ToString() == GetStatic.GetUser())
                            {
                                html.Append("&nbsp;<a title = \"View Changes\" href=\"javascript:void(0)\"\"><img alt = \"Waiting for Approval\" border = \"0\" title = \"Waiting for Approval\" src=\"" + GetStatic.GetUrlRoot() + "/images/wait-icon.png\" /></a></td></tr>");
                            }
                            else
                            {
                                html.Append("&nbsp;<a title = \"View Changes\" href=\"javascript:void(0)\"\">" + ApproveText + "</a>");
                            }
                        }
                        html.Append("</td></tr>");
                    }
                    else //Load Data for normal user
                    {
                        var countryCode = countryOrderBy.Text == "sendingCountry" ? dr["cCountryCode"].ToString() : dr["pCountryCode"].ToString();
                        html.Append(++i % 2 == 1 ? "<tr id=\"row_" + id + "\"" + AppendRowSelectionProperty("selectedbg", "oddbg", "GridOddRowOver") + ">" : "<tr id=\"row_" + id + "\"" + AppendRowSelectionProperty("selectedbg", "evenbg", "GridEvenRowOver") + ">");
                        html.Append("<td align=\"center\">");
                        if ((dr["modType"].ToString() == "U" || dr["modType"].ToString() == "I") && dr["modifiedBy"].ToString() != GetStatic.GetUser())
                        {
                        }
                        else
                        {
                            html.Append("<input type=\"checkbox\" id = \"" + countryCode + "_" + id + "\" name = \"chkId\" value=\"" + id + "\" onclick=\"KeepRowSelection(" + i + "," + id + ",'" + countryCode + "');\" />");
                            html.Append("<input type=\"hidden\" id=\"" + id + "\" name=\"" + id + "\" value=\"" + i + "\"/>");
                            html.Append("<input type=\"hidden\" id=\"cRateMaskBd_" + id + "\" name=\"cRateMaskBd_" + id + "\" value=\"" + dr["cRateMaskMulBd"] + "\"/>");
                            html.Append("<input type=\"hidden\" id=\"cRateMaskAd_" + id + "\" name=\"cRateMaskAd_" + id + "\" value=\"" + dr["cRateMaskMulAd"] + "\"/>");
                            html.Append("<input type=\"hidden\" id=\"pRateMaskAd_" + id + "\" name=\"pRateMaskAd_" + id + "\" value=\"" + dr["pRateMaskMulAd"] + "\"/>");
                            html.Append("<input type=\"hidden\" id=\"pRateMaskAd_" + id + "\" name=\"pRateMaskAd_" + id + "\" value=\"" + dr["pRateMaskMulAd"] + "\"/>");
                            html.Append("<input type=\"hidden\" id=\"crossRateMaskAd_" + id + "\" name=\"crossRateMaskAd_" + id + "\" value=\"" + dr["crossRateMaskAd"] + "\"/>");
                        }
                        html.Append("</td>");
                        html.Append("<td nowrap=\"nowrap\">" + GetStatic.GetCountryFlag(dr["cCountryCode"].ToString()) + dr["cCountryName"] + "</td>");
                        html.Append("<td>" + dr["cAgentName"] + "</td>");
                        html.Append("<td nowrap=\"nowrap\">" + GetStatic.GetCountryFlag(dr["pCountryCode"].ToString()) + dr["pCountryName"] + "</td>");
                        html.Append("<td>" + dr["pAgentName"] + "</td>");
                        html.Append("<td>" + dr["tranType"] + "</td>");
                        html.Append("<td>" + dr["cCurrency"] + "</td>");
                        html.Append("<td>" + dr["pCurrency"] + "</td>");

                        //Head Office Rate, Margin, Offer to Agent
                        html.Append("<td class=\"tdhorate\" id=\"cRateLbl_" + id + "\">" + dr["cRate"] + "</td>");
                        html.Append("<td class=\"tdhorate\" id=\"cMargin_" + id + "\">" + dr["cMargin"] + "</td>");
                        html.Append("<input type=\"hidden\" id=\"cHoMargin_" + id + "_current\" value=\"" + dr["cHoMargin"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"pHoMargin_" + id + "_current\" value=\"" + dr["pHoMargin"] + "\" />");
                        html.Append(ComposeTextBox(dr, id, "cHoMargin", true, "tdhorate", "onblur", "CalcCOffers(this," + id + "," + dr["cRateMaskMulBd"] + "," + dr["cRateMaskMulAd"] + "," + dr["crossRateMaskAd"] + ");", false));
                        html.Append("<td class=\"tdhorate\" id=\"cOffer_" + id + "\">" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"])) + "</td>");
                        html.Append("<td class=\"tdhorate\" id=\"pRateLbl_" + id + "\">" + dr["pRate"] + "</td>");
                        html.Append("<td class=\"tdhorate\" id=\"pMargin_" + id + "\">" + dr["pMargin"] + "</td>");
                        html.Append(ComposeTextBox(dr, id, "pHoMargin", true, "tdhorate", "onblur", "CalcPOffers(this," + id + "," + dr["cRateMaskMulBd"] + "," + dr["cRateMaskMulAd"] + "," + dr["pRateMaskMulBd"] + "," + dr["pRateMaskMulAd"] + "," + dr["crossRateMaskAd"] + ");", false));
                        html.Append("<td class=\"tdhorate\" id=\"pOffer_" + id + "\">" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"])) + "</td>");

                        //Agent Fx
                        html.Append(ComposeTextBox(dr, id, "sharingValue", true, "tdagentfx", false));
                        html.Append("<td class=\"tdagentfx\"><select id=\"sharingType_" + id + "\" name=\"sharingType_" + id + "\">");
                        var sharingTypeList = "";
                        sharingTypeList = dr["sharingType"].ToString().ToUpper() == "P"
                                                  ? "<option value=\"P\" selected=\"selected\">%</option><option value=\"F\">F</option>"
                                                  : "<option value=\"P\">%</option><option value=\"F\" selected=\"selected\">F</option>";
                        html.Append(sharingTypeList);
                        html.Append("</select></td>");

                        //Tolerance
                        html.Append("<td><select id=\"toleranceOn_" + id + "\" name=\"toleranceOn_" + id + "\">");
                        var tolOnList = "";
                        var crossRateTb = "";
                        if (dr["toleranceOn"].ToString().ToUpper() == "S")
                        {
                            tolOnList =
                                "<option value=\"S\" selected=\"selected\">SR</option><option value=\"P\">PR</option><option value=\"C\">CR</option>";
                            crossRateTb = ComposeTextBox(dr, id, "agentCrossRateMargin", false, "tdcustomerrate", false);
                        }
                        else if (dr["toleranceOn"].ToString().ToUpper() == "P")
                        {
                            tolOnList =
                                "<option value=\"S\">SR</option><option value=\"P\" selected=\"selected\">PR</option><option value=\"C\">CR</option>";
                            crossRateTb = ComposeTextBox(dr, id, "agentCrossRateMargin", false, "tdcustomerrate", false);
                        }
                        else if (dr["toleranceOn"].ToString().ToUpper() == "C")
                        {
                            tolOnList =
                                "<option value=\"S\">SR</option><option value=\"P\">PR</option><option value=\"C\" selected=\"selected\">CR</option>";
                            crossRateTb = ComposeTextBox(dr, id, "agentCrossRateMargin", true, "tdcustomerrate", "onblur", "OnBlurCrossMargin(this, " + id + ");", false);
                        }
                        else
                        {
                            tolOnList =
                                "<option value=\"S\">SR</option><option value=\"P\">PR</option><option value=\"C\">CR</option>";
                            crossRateTb = ComposeTextBox(dr, id, "agentCrossRateMargin", false, "tdcustomerrate", false);
                        }
                        html.Append(tolOnList);
                        html.Append("</select></td>");
                        html.Append(ComposeTextBox(dr, id, "agentTolMin", true, "tdagenttol", false));
                        html.Append(ComposeTextBox(dr, id, "agentTolMax", true, "tdagenttol", false));

                        //Sending Agent Rate, Margin, Offer to Customer
                        html.Append("<td class=\"tdsendagentrate\" id=\"cAgentOffer_" + id + "\">" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"])) + "</td>");
                        html.Append(ComposeTextBox(dr, id, "cAgentMargin", true, "tdsendagentrate", "onblur", "CalcCOffers(this," + id + "," + dr["cRateMaskMulBd"] + "," + dr["cRateMaskMulAd"] + "," + dr["crossRateMaskAd"] + ");", false));
                        html.Append("<td class=\"tdsendagentrate\" id=\"cCustomerOffer_" + id + "\">" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"]) + Convert.ToDecimal(dr["cAgentMargin"])) + "</td>");
                        html.Append("<td class=\"tdsendagentrate\" id=\"pAgentOffer_" + id + "\">" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"])) + "</td>");
                        html.Append(ComposeTextBox(dr, id, "pAgentMargin", true, "tdsendagentrate", "onblur", "CalcPOffers(this," + id + "," + dr["cRateMaskMulBd"] + "," + dr["cRateMaskMulAd"] + "," + dr["pRateMaskMulBd"] + "," + dr["pRateMaskMulAd"] + "," + dr["crossRateMaskAd"] + ");", false));
                        html.Append("<td class=\"tdsendagentrate\" id=\"pCustomerOffer_" + id + "\">" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"]) - Convert.ToDecimal(dr["pAgentMargin"])) + "</td>");

                        //Customer Tol
                        html.Append(ComposeTextBox(dr, id, "customerTolMin", true, "tdcustomertol", false));
                        html.Append(ComposeTextBox(dr, id, "customerTolMax", true, "tdcustomertol", false));

                        //Customer
                        html.Append(ComposeTextBox(dr, id, "maxCrossRate", false, "tdcustomerrate", false));
                        html.Append(ComposeTextBox(dr, id, "crossRate", false, "tdcustomerrate", false));
                        html.Append(crossRateTb);
                        html.Append(ComposeTextBox(dr, id, "customerRate", false, "tdcustomerrate", false));

                        html.Append("<td>" + dr["status"] + "</td>");

                        html.Append("<td nowrap='nowrap'>");
                        html.Append("<input type=\"hidden\" id=\"cRate_" + id + "\" name=\"cRate_" + id + "\" value=\"" + dr["cRate"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"pRate_" + id + "\" name=\"pRate_" + id + "\" value=\"" + dr["pRate"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"cMin_" + id + "\" name=\"cMin_" + id + "\" value=\"" + dr["cMin"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"cMax_" + id + "\" name=\"cMax_" + id + "\" value=\"" + dr["cMax"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"pMin_" + id + "\" name=\"pMin_" + id + "\" value=\"" + dr["pMin"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"pMax_" + id + "\" name=\"pMax_" + id + "\" value=\"" + dr["pMax"] + "\" />");
                        html.Append("<input type=\"hidden\" id=\"isUpdated_" + id + "\" name=\"isUpdated_" + id + "\" value=\"N\" />");
                        html.Append("<div id=\"divUpdate_" + id + "\" style=\"position:absolute;margin-top: 17px; margin-left: 0px; display: none; border: none;\">");
                        html.Append("<input id=\"btnUpdate_" + id + "\" type=\"button\" class=\"button\" onclick=\"UpdateRate(" + id + ",'N')\" value=\"Update\"/>");
                        html.Append("<img src=\"../../../Images/close-icon.png\" border=\"0\" class=\"showHand\" onclick=\"RemoveDivUpdate(" + id + ");\" title=\"Close\"/>");
                        html.Append("</div>");
                        html.Append(dr["lastModifiedDate"] + "<br/>" + dr["lastModifiedBy"]);
                        if (dr["haschanged"].ToString().ToUpper().Equals("Y"))
                        {
                            if (dr["modifiedby"].ToString() == GetStatic.GetUser())
                            {
                                html.Append("&nbsp;<a title = \"View Changes\" href=\"javascript:void(0)\"\"><img alt = \"Waiting for Approval\" border = \"0\" title = \"Waiting for Approval\" src=\"" + GetStatic.GetUrlRoot() + "/images/wait-icon.png\" /></a></td></tr>");
                            }
                            else
                            {
                                html.Append("&nbsp;<a title = \"View Changes\" href=\"javascript:void(0)\"\">" + ApproveText + "</a>");
                            }
                        }
                        html.Append("</td></tr>");
                    }
                }
            }
            html.Append("</table>");
            rpt_grid.InnerHtml = html.ToString();
            GetStatic.CallBackJs1(Page, "Show Hide", "ShowHideDetail();");
            if (dt.Rows.Count > 0)
            {
                btnUpdateChanges.Visible = true;
                btnMarkActive.Visible = false;
                btnMarkInactive.Visible = true;
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
            if (!enable)
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
            //if (showDistinctMinusValue)
            //{
            //    styleAttr = Convert.ToDouble(dr[valueField]) < 0 ? " style=\"color:red ! important;\" " : " style=\"color:green !important;\"";
            //}
            html.Append("<input class=\"" + textBoxCss + "\"" + disabled + "id=\"" + valueField + "_" + id + "\" name=\"" + valueField + "_" + id + "\" onfocus=\"ShowHideUpdateFunction(this," + id + ");\" type=\"text\" value=\"" + dr[valueField] + "\"" + evtAttr + styleAttr + "/>");
            html.Append(hiddenHtmlControls);
            html.Append("</td>");
            return html.ToString();
        }

        private string ComposeTextBoxWithValue(DataRow dr, string id, string valueField, bool enable, string cssClass, bool showDistinctMinusValue, string value)
        {
            return ComposeTextBoxWithValue(dr, id, valueField, enable, cssClass, "", "", showDistinctMinusValue, value);
        }

        private string ComposeTextBoxWithValue(DataRow dr, string id, string valueField, bool enable, string cssClass, string evt, string evtFunction, bool showDistinctMinusValue, string value)
        {
            var disabled = "";
            var hiddenHtmlControls = "";
            var textBoxCss = "inputBox";
            if (!enable)
            {
                disabled = " readonly=\"readonly\" ";
                textBoxCss += " disabled";
            }
            {
                hiddenHtmlControls = "<input type=\"hidden\" id=\"" + valueField + "_" + id + "_current\" value=\"" +
                                     value + "\" />";
            }
            var evtAttr = !string.IsNullOrEmpty(evt) ? " " + evt + "=\"" + evtFunction + "\"" : "";
            var styleAttr = "";
            var html = new StringBuilder("<td class=\"" + cssClass + "\">");
            //if (showDistinctMinusValue)
            //{
            //    styleAttr = Convert.ToDouble(value) < 0 ? " style=\"color:red ! important;\" " : " style=\"color:green !important;\"";
            //}
            html.Append("<input class=\"" + textBoxCss + "\"" + disabled + "id=\"" + valueField + "_" + id + "\" name=\"" + valueField + "_" + id + "\" onfocus=\"ShowHideUpdateFunction(this," + id + ");\" type=\"text\" value=\"" + value + "\"" + evtAttr + styleAttr + "/>");
            html.Append(hiddenHtmlControls);
            html.Append("</td>");
            return html.ToString();
        }

        private string ComposeLabel(DataRow dr, string valueField, string cssClass, bool showDistinctMinusValue)
        {
            var html = new StringBuilder();
            var styleAttr = "";
            //if (showDistinctMinusValue)
            //{
            //    styleAttr = Convert.ToDouble(dr[valueField]) < 0
            //                    ? " style=\"color: red !important;\" "
            //                    : " style=\"color: green !important;\" ";
            //}
            html.Append("<td class=\"" + cssClass + "\" " + styleAttr + ">" + dr[valueField] + "</td>");
            return html.ToString();
        }

        private void Update()
        {
            var dbResult = obj.Update(GetStatic.GetUser(), exRateTreasuryId.Value, tolerance.Value
                            , hddCHoMargin.Value, hddCAgentMargin.Value, hddPHoMargin.Value, hddPAgentMargin.Value
                            , sharingType.Value, sharingValue.Value, toleranceOn.Value, agentTolMin.Value, agentTolMax.Value, customerTolMin.Value, customerTolMax.Value
                            , crossRate.Value, agentCrossRateMargin.Value, customerRate.Value, isUpdated.Value);

            if (dbResult.ErrorCode != "0")
            {
                GetStatic.AlertMessage(Page, dbResult.Msg);
                return;
            }
            GetStatic.WriteSession("exRateTreasuryIds", exRateTreasuryId.Value);
            Response.Redirect("../ExRateTreasury/ModifySummary.aspx");
            //ManageMessage(dbResult);
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (!isRefresh)
            {
                Update();
            }
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                if (!string.IsNullOrEmpty(hdnIsFw.Value))
                    Response.Redirect("List.aspx?isFw=" + hdnIsFw.Value);
                else
                {
                    Response.Redirect("List.aspx");
                }
            }
            GetStatic.AlertMessage(Page);
        }

        protected void btnHidden_Click(object sender, EventArgs e)
        {
            //SaveAsCookie();
            LoadGrid();
        }

        private void UpdateChangesInBulk()
        {
            /*
            var dbResult = obj.UpdateRateFromMaster(GetStatic.GetUser(), chkList);
            ManageMessage(dbResult);
             * */

            var exRateTreasuryIds = GetStatic.ReadFormData("chkId", "");
            if (string.IsNullOrEmpty(exRateTreasuryIds))
            {
                GetStatic.AlertMessage(Page, "Please select record to update");
                return;
            }
            var exRateTreasuryList = exRateTreasuryIds.Split(',');
            var xml = new StringBuilder();
            xml.Append("<root>");
            foreach (var id in exRateTreasuryList)
            {
                xml.Append("<row");
                xml.Append(" exRateTreasuryId=\"" + id + "\"");
                xml.Append(" tolerance=\"0\"");
                xml.Append(" cHoMargin=\"" + GetStatic.ReadFormData("cHoMargin_" + id, "") + "\"");
                xml.Append(" cAgentMargin=\"" + GetStatic.ReadFormData("cAgentMargin_" + id, "") + "\"");
                xml.Append(" pHoMargin=\"" + GetStatic.ReadFormData("pHoMargin_" + id, "") + "\"");
                xml.Append(" pAgentMargin=\"" + GetStatic.ReadFormData("pAgentMargin_" + id, "") + "\"");
                xml.Append(" sharingType=\"" + GetStatic.ReadFormData("sharingType_" + id, "") + "\"");
                xml.Append(" sharingValue=\"" + GetStatic.ReadFormData("sharingValue_" + id, "") + "\"");
                xml.Append(" toleranceOn=\"" + GetStatic.ReadFormData("toleranceOn_" + id, "") + "\"");
                xml.Append(" agentTolMin=\"" + GetStatic.ReadFormData("agentTolMin_" + id, "") + "\"");
                xml.Append(" agentTolMax=\"" + GetStatic.ReadFormData("agentTolMax_" + id, "") + "\"");
                xml.Append(" customerTolMin=\"" + GetStatic.ReadFormData("customerTolMin_" + id, "") + "\"");
                xml.Append(" customerTolMax=\"" + GetStatic.ReadFormData("customerTolMax_" + id, "") + "\"");
                xml.Append(" crossRate=\"" + GetStatic.ReadFormData("crossRate_" + id, "") + "\"");
                xml.Append(" agentCrossRateMargin=\"" + GetStatic.ReadFormData("agentCrossRateMargin_" + id, "") + "\"");
                xml.Append(" customerRate=\"" + GetStatic.ReadFormData("customerRate_" + id, "") + "\"");
                xml.Append(" isUpdated=\"" + GetStatic.ReadFormData("isUpdated_" + id, "") + "\"");
                xml.Append(" />");
            }
            xml.Append("</root>");
            exRateTreasuryIds = obj.UpdateXml(GetStatic.GetUser(), xml.ToString());
            GetStatic.WriteSession("exRateTreasuryIds", exRateTreasuryIds);
            Response.Redirect("../ExRateTreasury/ModifySummary.aspx");
        }

        private void UpdateChanges()
        {
            /*
            var dbResult = obj.UpdateRateFromMaster(GetStatic.GetUser(), chkList);
            ManageMessage(dbResult);
             * */

            var exRateTreasuryIds = GetStatic.ReadFormData("chkId", "");
            if (string.IsNullOrEmpty(exRateTreasuryIds))
            {
                GetStatic.AlertMessage(Page, "Please select record to update");
                return;
            }
            var exRateTreasuryList = exRateTreasuryIds.Split(',');
            foreach (var id in exRateTreasuryList)
            {
                exRateTreasuryId.Value = id;
                tolerance.Value = "0";
                hddCHoMargin.Value = GetStatic.ReadFormData("cHoMargin_" + id, "");
                hddCAgentMargin.Value = GetStatic.ReadFormData("cAgentMargin_" + id, "");
                hddPHoMargin.Value = GetStatic.ReadFormData("pHoMargin_" + id, "");
                hddPAgentMargin.Value = GetStatic.ReadFormData("pAgentMargin_" + id, "");
                sharingType.Value = GetStatic.ReadFormData("sharingType_" + id, "");
                sharingValue.Value = GetStatic.ReadFormData("sharingValue_" + id, "");
                toleranceOn.Value = GetStatic.ReadFormData("toleranceOn_" + id, "");
                agentTolMin.Value = GetStatic.ReadFormData("agentTolMin_" + id, "");
                agentTolMax.Value = GetStatic.ReadFormData("agentTolMax_" + id, "");
                customerTolMin.Value = GetStatic.ReadFormData("customerTolMin_" + id, "");
                customerTolMax.Value = GetStatic.ReadFormData("customerTolMax_" + id, "");
                crossRate.Value = GetStatic.ReadFormData("crossRate_" + id, "");
                agentCrossRateMargin.Value = GetStatic.ReadFormData("agentCrossRateMargin_" + id, "");
                customerRate.Value = GetStatic.ReadFormData("customerRate_" + id, "");
                isUpdated.Value = GetStatic.ReadFormData("isUpdated_" + id, "");
                var dbResult = obj.Update(GetStatic.GetUser(), exRateTreasuryId.Value, tolerance.Value
                            , hddCHoMargin.Value, hddCAgentMargin.Value, hddPHoMargin.Value, hddPAgentMargin.Value
                            , sharingType.Value, sharingValue.Value, toleranceOn.Value, agentTolMin.Value, agentTolMax.Value, customerTolMin.Value, customerTolMax.Value
                            , crossRate.Value, "", customerRate.Value, isUpdated.Value);
                if (dbResult.ErrorCode != "0")
                    exRateTreasuryList = exRateTreasuryList.Where(val => val != id).ToArray();
            }
            exRateTreasuryIds = string.Join(",", exRateTreasuryList);
            GetStatic.WriteSession("exRateTreasuryIds", exRateTreasuryIds);
            Response.Redirect("../ExRateTreasury/ModifySummary.aspx");
        }

        protected void btnUpdateChanges_Click(object sender, EventArgs e)
        {
            if (!isRefresh)
            {
                //UpdateChanges();
                UpdateChangesInBulk();
            }
        }

        protected void countryOrderBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadGrid();
        }

        protected void btnMarkInactive_Click(object sender, EventArgs e)
        {
            var chkGroupList = GetStatic.ReadFormData("chkId", "");
            if (string.IsNullOrEmpty(chkGroupList))
            {
                GetStatic.AlertMessage(Page, "Please select record to update");
                return;
            }
            var dbResult = obj.MarkAsActiveInactive(GetStatic.GetUser(), chkGroupList, "N");
            ManageMessage(dbResult);
        }

        protected void btnMarkActive_Click(object sender, EventArgs e)
        {
            var chkGroupList = GetStatic.ReadFormData("chkId", "");
            if (string.IsNullOrEmpty(chkGroupList))
            {
                GetStatic.AlertMessage(Page, "Please select record to update");
                return;
            }
            var dbResult = obj.MarkAsActiveInactive(GetStatic.GetUser(), chkGroupList, "Y");
            ManageMessage(dbResult);
        }

        #region Browser Refresh

        private bool refreshState;
        private bool isRefresh;

        protected override void LoadViewState(object savedState)
        {
            object[] AllStates = (object[])savedState;
            base.LoadViewState(AllStates[0]);
            refreshState = bool.Parse(AllStates[1].ToString());
            if (Session["ISREFRESH"] != null && Session["ISREFRESH"] != "")
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