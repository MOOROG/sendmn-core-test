using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.ExchangeRate.ExRateTreasury
{
    public partial class CopyAgentWiseRate : System.Web.UI.Page
    {
        private ExRateReportDao obj = new ExRateReportDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftTab _tab = new SwiftTab();
        private const string GridName = "grd_copyrate";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                LoadTab();
                PopulateDdl();
            }
        }

        private string autoSelect(string str1, string str2)
        {
            if (str1 == str2)
                return "selected=\"selected\"";
            else
                return "";
        }

        private void Authenticate()
        {
            _sdd.CheckSession();
        }

        private string GetIsFw()
        {
            return GetStatic.ReadQueryString("isFw", "");
        }

        private void LoadTab()
        {
            var isFw = GetIsFw();

            var queryStrings = "?isFw=" + isFw;
            _tab.NoOfTabPerRow = 8;
            _tab.TabList = new List<TabField>
                               {
                                   new TabField("Treasury Rate", "List.aspx" + queryStrings),
                                   new TabField("Add New", "Manage.aspx" + queryStrings),
                                   new TabField("Approve", "ApproveList.aspx" + queryStrings),
                                   new TabField("Reject", "RejectList.aspx" + queryStrings),
                                   new TabField("My changes", "MyChangeList.aspx" + queryStrings),
                                   new TabField("Copy Rate", "", true),
                               };

            divTab.InnerHtml = _tab.CreateTab();
        }

        private void PopulateDdl()
        {
            LoadSendingCountry(ref cCountry);
            LoadReceivingCountry(ref pCountry);
        }

        private void LoadGrid(string applyFor)
        {
            var applyAgent = applyFor.ToLower() == "c" ? applyToSendAgent.Text : applyToReceiveAgent.Text;
            var dt = obj.LoadGridForCopy(GetStatic.GetUser(), cCountry.Text, cAgent.Text, pCountry.Text, pAgent.Text, applyFor, applyAgent);
            var html = new StringBuilder();
            html.Append("<div class=\"responsive-table\">");
            html.Append("<table id=\"rateTable\" class=\"table table-responsive table-striped table-bordered \">");
            html.Append("<tr class=\"hdtitle\">");
            html.Append("<th rowspan=\"3\" class=\"headingTH\" align=\"center\"><a href=\"javascript:void(0);\" onClick=\"CheckAll(this)\">√</a></th>");
            html.Append("<th colspan=\"2\" rowspan=\"2\" class=\"headingTH\"><center>Send</center></th>");
            html.Append("<th colspan=\"2\" rowspan=\"2\" class=\"headingTH\"><center>Receive</center></th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\">Service Type</th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\">Send<br/>Curr.</th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\">Receive<br/>Curr.</th>");
            html.Append("<th colspan=\"8\" class=\"headingTH\"><center>Head Office<span id=\"agentfxs\" onclick=\"ShowAgentFxCol();\" title=\"Show Agent Fx\"><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></center></th>");
            html.Append("<th rowspan=\"2\" colspan=\"2\" class=\"headingTH\" ondblclick=\"HideAgentFxCol();\" style=\"cursor: pointer;\"><center><span id=\"agentfxh\" onclick=\"HideAgentFxCol();\" title=\"Hide Agent Fx\"><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span>Agent FX<span id=\"tolerances\" onclick=\"ShowToleranceCol();\" title=\"Show Tolerance\"><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></center></th>");
            html.Append("<th colspan=\"3\" class=\"headingTH\" ondblclick=\"HideToleranceCol();\" style=\"cursor: pointer;\"><center><span id=\"toleranceh\" onclick=\"HideToleranceCol();\" title=\"Hide Tolerance\"><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span>Tolerance<span id=\"sendingagents\" onclick=\"ShowSendingAgentCol();\" title=\"Show Sending Agent\"><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></center></th>");
            html.Append("<th colspan=\"6\" class=\"headingTH\" ondblclick=\"HideSendingAgentCol();\" style=\"cursor: pointer;\"><center><span id=\"sendingagenth\" onclick=\"HideSendingAgentCol();\" title=\"Hide Sending Agent\"><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span>Sending Agent<span id=\"customertols\" onclick=\"ShowCustomerTolCol();\" title=\"Show Customer Tol.\"><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></center></th>");
            html.Append("<th colspan=\"2\" rowspan=\"2\" class=\"headingTH\" ondblclick=\"HideCustomerTolCol();\" style=\"cursor: pointer;\"><center><span id=\"customertolh\" onclick=\"HideCustomerTolCol();\" title=\"Hide Customer Tol.\"><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span>Cust. Tol.</center></th>");
            html.Append("<th colspan=\"3\" class=\"headingTH\"><center>Cross Rate</center></th>");

            html.Append("<th rowspan=\"3\" class=\"headingTH\">Last Update/Approve</th>");

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
            html.Append("<th colspan=\"3\" class=\"headingTH\"><center>Send Curr. vs Receive Curr.</center></th>");

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
            html.Append("<th class=\"thcustomerrate\">Customer Rate</th>");

            html.Append("</tr>");

            var i = 0;
            var countryName = "";
            foreach (DataRow dr in dt.Rows)
            {
                var id = dr["exRateTreasuryId"].ToString();
                var countryCode = applyFor.ToLower() == "c" ? dr["pCountryCode"].ToString() : dr["cCountryCode"].ToString();
                if (applyFor.ToLower() == "c")
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
                html.Append(++i % 2 == 1 ? "<tr id=\"row_" + id + "\"" + AppendRowSelectionProperty("selectedbg", "oddbg", "GridOddRowOver") + ">" : "<tr id=\"row_" + id + "\"" + AppendRowSelectionProperty("selectedbg", "evenbg", "GridEvenRowOver") + ">");
                html.Append("<td align=\"center\">");
                html.Append("<input type=\"checkbox\" id = \"" + countryCode + "_" + id + "\" name = \"chkId\" value=\"" + id + "\" onclick=\"KeepRowSelection(" + i + "," + id + ",'" + countryCode + "');\" />");
                html.Append("<input type=\"hidden\" id=\"" + id + "\" name=\"" + id + "\" value=\"" + i + "\"/>");
                html.Append("</td>");
                html.Append("<td nowrap=\"nowrap\">" + GetStatic.GetCountryFlag(dr["cCountryCode"].ToString()) + dr["cCountryName"] + "</td>");
                html.Append("<td>" + dr["cAgentName"] + "</td>");
                html.Append("<td nowrap=\"nowrap\">" + GetStatic.GetCountryFlag(dr["pCountryCode"].ToString()) + dr["pCountryName"] + "</td>");
                html.Append("<td>" + dr["pAgentName"] + "</td>");
                html.Append("<td>" + dr["tranType"] + "</td>");
                html.Append("<td>" + dr["cCurrency"] + "</td>");
                html.Append("<td>" + dr["pCurrency"] + "</td>");

                //Head Office Rate, Margin, Offer to Agent
                html.Append("<td class=\"tdhorate\">" + dr["cRate"] + "</td>");
                html.Append(ComposeLabel(dr, "cMargin", "tdhorate", true));
                html.Append(ComposeLabel(dr, "cHoMargin", "tdhorate", true));
                html.Append("<td class=\"tdhorate\">" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"])) + "</td>");
                html.Append("<td class=\"tdhorate\">" + dr["pRate"] + "</td>");
                html.Append(ComposeLabel(dr, "pMargin", "tdhorate", true));
                html.Append(ComposeLabel(dr, "pHoMargin", "tdhorate", true));
                html.Append("<td class=\"tdhorate\">" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"])) + "</td>");

                //Agent Fx
                html.Append("<td class=\"tdagentfx\">" + dr["sharingValue"] + "</td>");
                html.Append("<td class=\"tdagentfx\">" + dr["sharingType"] + "</td>");

                //Tolerance
                html.Append("<td class=\"tdagenttol\">" + dr["toleranceOn"] + "</td>");
                html.Append("<td class=\"tdagenttol\">" + dr["agentTolMin"] + "</td>");
                html.Append("<td class=\"tdagenttol\">" + dr["agentTolMax"] + "</td>");

                //Sending Agent Rate, Margin, Offer to Customer
                html.Append("<td class=\"tdsendagentrate\">" + (Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"])) + "</td>");
                html.Append(ComposeLabel(dr, "cAgentMargin", "tdsendagentrate", true));
                html.Append(ComposeLabelWithValue((Convert.ToDecimal(dr["cRate"]) + Convert.ToDecimal(dr["cMargin"]) + Convert.ToDecimal(dr["cHoMargin"]) + Convert.ToDecimal(dr["cAgentMargin"])).ToString(), "tdsendagentrate", true));
                html.Append("<td class=\"tdsendagentrate\">" + (Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"])) + "</td>");
                html.Append(ComposeLabel(dr, "pAgentMargin", "tdsendagentrate", true));
                html.Append(ComposeLabelWithValue((Convert.ToDecimal(dr["pRate"]) - Convert.ToDecimal(dr["pMargin"]) - Convert.ToDecimal(dr["pHoMargin"]) - Convert.ToDecimal(dr["pAgentMargin"])).ToString(), "tdsendagentrate", true));

                //Customer Tol
                html.Append("<td class=\"tdcustomertol\">" + dr["customerTolMin"] + "</td>");
                html.Append("<td class=\"tdcustomertol\">" + dr["customerTolMax"] + "</td>");

                //Customer
                html.Append("<td class=\"tdcustomerrate\">" + dr["maxCrossRate"] + "</td>");
                html.Append("<td class=\"tdcustomerrate\">" + dr["crossRate"] + "</td>");
                html.Append("<td class=\"tdcustomerrate\">" + dr["customerRate"] + "</td>");

                html.Append("<td nowrap='nowrap'><b>" + dr["modifiedDate"] + " " + dr["modifiedBy"] + "<br/>" + dr["approvedDate"] + " " + dr["approvedBy"] + "</b></td>");
                html.Append("</tr>");
            }
            html.Append("</table>");
            html.Append("</div>");

            rpt_grid.InnerHtml = html.ToString();
            GetStatic.CallBackJs1(Page, "Show Hide", "ShowHideDetail();");
            if (i > 0)
            {
                btnCopy.Visible = true;
            }
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

        private void LoadSendingCountry(ref DropDownList ddl)
        {
            var sql = "EXEC proc_countryMaster @flag = 'scl'";
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", "", "All");
        }

        private void LoadReceivingCountry(ref DropDownList ddl)
        {
            var sql = "EXEC proc_countryMaster @flag = 'rcl'";
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", "", "All");
        }

        private void LoadAgent(ref DropDownList ddl, string countryId)
        {
            var sql = "EXEC proc_agentMaster @flag = 'alc', @agentCountryId = " + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", "", "All");
        }

        protected void cCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref cAgent, cCountry.Text);
            LoadAgent(ref applyToSendAgent, cCountry.Text);
            cCountry.Focus();
        }

        protected void pCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref pAgent, pCountry.Text);
            LoadAgent(ref applyToReceiveAgent, pCountry.Text);
            pCountry.Focus();
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(applyToSendAgent.Text) && !string.IsNullOrEmpty(applyToReceiveAgent.Text))
            {
                GetStatic.AlertMessage(Page, "Please choose either only to apply to sending agent or to receiving agent");
                return;
            }
            var applyFor = "";
            if (!string.IsNullOrEmpty(applyToSendAgent.Text))
                applyFor = "c";
            else if (!string.IsNullOrEmpty(applyToReceiveAgent.Text))
                applyFor = "p";
            else
            {
                GetStatic.AlertMessage(Page, "Please choose agent to apply the setup");
                return;
            }
            LoadGrid(applyFor);
        }

        private void Copy()
        {
            if (!string.IsNullOrEmpty(applyToSendAgent.Text) && !string.IsNullOrEmpty(applyToReceiveAgent.Text))
            {
                GetStatic.AlertMessage(Page, "Please choose either only to apply to sending agent or to receiving agent");
                return;
            }
            var applyFor = "";
            var applyAgentName = "";
            var applyAgentId = "";
            if (!string.IsNullOrEmpty(applyToSendAgent.Text))
            {
                applyFor = "c";
                applyAgentName = applyToSendAgent.SelectedItem.Text;
                applyAgentId = applyToSendAgent.Text;
            }
            else if (!string.IsNullOrEmpty(applyToReceiveAgent.Text))
            {
                applyFor = "p";
                applyAgentName = applyToReceiveAgent.SelectedItem.Text;
                applyAgentId = applyToReceiveAgent.Text;
            }
            else
            {
                GetStatic.AlertMessage(Page, "Please choose agent to apply the setup");
                return;
            }
            var exRateTreasuryIds = GetStatic.ReadFormData("chkId", "");
            if (string.IsNullOrEmpty(exRateTreasuryIds))
            {
                GetStatic.AlertMessage(Page, "Please select record(s) to apply the setting");
                return;
            }
            var confirmText = "Are you sure to apply the selected setting(s) to " + applyAgentName + "?";
            GetStatic.AttachConfirmMsg(ref btnCopy, confirmText);
            var dbResult = obj.Copy(GetStatic.GetUser(), exRateTreasuryIds, applyAgentId, applyFor);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.AlertMessage(Page, dbResult.Msg);
                return;
            }
            GetStatic.WriteSession("exRateTreasuryIds", exRateTreasuryIds);
            Response.Redirect("CopySummary.aspx?applyAgent=" + applyAgentId + "&applyFor=" + applyFor);
        }

        protected void btnCopy_Click(object sender, EventArgs e)
        {
            Copy();
        }
    }
}