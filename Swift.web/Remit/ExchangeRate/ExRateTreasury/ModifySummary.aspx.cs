using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.ExchangeRate.ExRateTreasury
{
    public partial class ModifySummary : System.Web.UI.Page
    {
        private ExRateReportDao obj = new ExRateReportDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftTab _tab = new SwiftTab();
        private const string GridName = "grd_erms";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
            LoadGrid();
        }

        private void Authenticate()
        {
            _sdd.CheckSession();
        }

        private string GetIsFw()
        {
            return GetStatic.ReadQueryString("isFw", "");
        }

        private string GetExRateTreasuryIds()
        {
            return GetStatic.ReadSession("exRateTreasuryIds", "");
        }

        private void LoadGrid()
        {
            var dt = obj.GetModifySummary(GetStatic.GetUser(), GetExRateTreasuryIds());
            var html = new StringBuilder();
            html.Append("<table id=\"rateTable\" class=\"exTable\" width=\"100%\" cellspacing=\"0\" cellpadding=\"2\" border=\"0\">");
            html.Append("<tr class=\"hdtitle\">");
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
            html.Append("<th class=\"agentFx\">Type</th>");

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
            html.Append("<th class=\"thcustomerrate\">Cross Margin</th>");
            html.Append("<th class=\"thcustomerrate\">Customer Rate</th>");

            html.Append("</tr>");

            foreach (DataRow dr in dt.Rows)
            {
                var id = Convert.ToInt32(dr["exRateTreasuryId"]);
                html.Append("<tr class=\"evenbg\">");
                html.Append("<td rowspan=\"2\" nowrap=\"nowrap\">" + GetStatic.GetCountryFlag(dr["cCountryCode"].ToString()) + dr["cCountryName"] + "</td>");
                html.Append("<td rowspan=\"2\">" + dr["cAgentName"] + "</td>");
                html.Append("<td rowspan=\"2\" nowrap=\"nowrap\">" + GetStatic.GetCountryFlag(dr["pCountryCode"].ToString()) + dr["pCountryName"] + "</td>");
                html.Append("<td rowspan=\"2\">" + dr["pAgentName"] + "</td>");
                html.Append("<td rowspan=\"2\">" + dr["tranType"] + "</td>");
                html.Append("<td rowspan=\"2\">" + dr["cCurrency"] + "</td>");
                html.Append("<td rowspan=\"2\">" + dr["pCurrency"] + "</td>");
                html.Append("<td rowspan=\"2\">" + dr["modType"] + "</td>");

                if (dr["modType"].ToString().ToLower() == "insert")
                {
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
                }
                else if (dr["modType"].ToString().ToLower() == "update")
                {
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
            rpt_grid.InnerHtml = html.ToString();
            GetStatic.CallBackJs1(Page, "Show Hide", "ShowHideDetail();");
        }

        private string AppendRowSelectionProperty(string rowSelectedClass, string defaultClass, string onhoverclass)
        {
            return " class=\"" + defaultClass + "\" ondblclick=\"if(this.className=='" + rowSelectedClass + "'){this.className='" + defaultClass + "';}else{this.className='" + rowSelectedClass + "';}\" onMouseOver=\"if(this.className=='" + defaultClass + "'){this.className='" + onhoverclass + "';}\" onMouseOut=\"if(this.className=='" + rowSelectedClass + "'){}else{this.className='" + defaultClass + "';}\" ";
        }

        private string ComposeLabel(DataRow dr, string valueField, string cssClass, bool showDistinctMinusValue)
        {
            var html = new StringBuilder();
            var styleAttr = "";
            if (showDistinctMinusValue)
            {
                styleAttr = Convert.ToDouble(dr[valueField]) < 0
                                ? " style=\"color: red !important;\" "
                                : " style=\"color: green !important;\" ";
            }
            html.Append("<td class=\"" + cssClass + "\" " + styleAttr + ">" + dr[valueField] + "</td>");
            return html.ToString();
        }

        private string ComposeLabelWithValue(string value, string cssClass, bool showDistinctMinusValue)
        {
            var html = new StringBuilder();
            var styleAttr = "";
            if (showDistinctMinusValue)
            {
                styleAttr = Convert.ToDouble(value) < 0
                                ? " style=\"color: red !important;\" "
                                : " style=\"color: green !important;\" ";
            }
            html.Append("<td class=\"" + cssClass + "\" " + styleAttr + ">" + value + "</td>");
            return html.ToString();
        }

        protected void btnHidden_Click(object sender, EventArgs e)
        {
            LoadGrid();
        }

        protected void countryOrderBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadGrid();
        }
    }
}