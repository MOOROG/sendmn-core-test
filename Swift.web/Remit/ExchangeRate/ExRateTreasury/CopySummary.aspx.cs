using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace Swift.web.Remit.ExchangeRate.ExRateTreasury
{
    public partial class CopySummary : System.Web.UI.Page
    {
        private ExRateReportDao obj = new ExRateReportDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftTab _tab = new SwiftTab();
        private const string GridName = "grd_cs";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                LoadTab();
            }
            LoadGrid();
        }

        private string GetApplyAgent()
        {
            return GetStatic.ReadQueryString("applyAgent", "");
        }

        private string GetApplyFor()
        {
            return GetStatic.ReadQueryString("applyFor", "");
        }

        private string GetExRateTreasuryIds()
        {
            return GetStatic.ReadSession("exRateTreasuryIds", "");
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
                                   new TabField("Copy Rate", "CopyAgentWiseRate.aspx" + queryStrings, true),
                               };

            divTab.InnerHtml = _tab.CreateTab();
        }

        private string GetPagingBlock(int _total_record, int _page, int _page_size)
        {
            var str = new StringBuilder("<input type = \"hidden\" name=\"hdd_curr_page\" id = \"hdd_curr_page\" value=\"" + _page.ToString() + "\">");
            str.Append("<tr><td colspan='37'><table width=\"100%\" cellspacing=\"2\" cellpadding=\"2\" border=\"0\">");
            str.Append("<td width=\"247\" class=\"GridTextNormal\" nowrap='nowrap'>Result :&nbsp;<b>" + _total_record.ToString() + "</b>&nbsp;records&nbsp;");
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
            if (remainder > 0)
                total_page++;
            for (var i = 1; i <= total_page; i++)
            {
                str.AppendLine("<option value=\"" + i + "\"" + autoSelect(i.ToString(), _page.ToString()) + ">" + i + "</option>");
            }
            str.Append("</td>");
            str.AppendLine("<td width=\"100%\" align='right'>");

            if (_page > 1)
                str.AppendLine("<img style = \"cursor:pointer\" onclick =\"Nav(" + (_page - 1) + ", '" + GridName + "');\" title='Go to Previous page(Page : " + (_page - 1) + ")' src='" + GetStatic.GetUrlRoot() + "/images/prev.gif' border='0'>&nbsp;&nbsp;&nbsp;");
            else
                str.AppendLine("<img src='" + GetStatic.GetUrlRoot() + "/images/disprev.gif' border='0'>&nbsp;&nbsp;&nbsp;");

            if (_page * _page_size < _total_record)
                str.AppendLine("<img style = \"cursor:pointer\" onclick =\"Nav(" + (_page + 1) + ", '" + GridName + "');\" title='Go to Next page(Page : " + (_page + 1) + ")' src='" + GetStatic.GetUrlRoot() + "/images/next.gif' border='0'>&nbsp;&nbsp;&nbsp;");
            else
                str.AppendLine("<img src='" + GetStatic.GetUrlRoot() + "/images/disnext.gif' border='0'>&nbsp;&nbsp;&nbsp;");

            //str.AppendLine("&nbsp; <img title = 'Export to Excel' style = 'cursor:pointer' onclick = \"DownloadGrid('" + GetStatic.GetUrlRoot() + "');\"  src='" + GetStatic.GetUrlRoot() + "/images/excel.gif' border='0'>");

            str.AppendLine("</td>");
            str.AppendLine("</tr></table></td></tr>");

            return str.ToString();
        }

        private string loadPagingBlock(DataTable dtPaging)
        {
            string pagingTable = "";
            foreach (DataRow row in dtPaging.Rows)
            {
                pagingTable = GetPagingBlock(int.Parse(row["totalRow"].ToString()), int.Parse(row["pageNumber"].ToString()), int.Parse(row["pageSize"].ToString()));
            }
            return pagingTable;
        }

        private void LoadGrid()
        {
            var dt = obj.GetCopySummary(GetStatic.GetUser(), GetExRateTreasuryIds(), GetApplyAgent(), GetApplyFor());
            var html = new StringBuilder();
            html.Append("<table id=\"rateTable\" class=\"exTable\" width=\"100%\" cellspacing=\"0\" cellpadding=\"2\" border=\"0\">");
            html.Append("<tr class=\"hdtitle\">");
            html.Append("<th colspan=\"2\" rowspan=\"2\" class=\"headingTH\"><center>Send</center></th>");
            html.Append("<th colspan=\"2\" rowspan=\"2\" class=\"headingTH\"><center>Receive</center></th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\">Service Type</th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\">Send<br/>Curr.</th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\">Receive<br/>Curr.</th>");
            html.Append("<th colspan=\"8\" class=\"headingTH\"><center>Head Office<span id=\"agentfxs\" onclick=\"ShowAgentFxCol();\" title=\"Show Agent Fx\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
            html.Append("<th rowspan=\"2\" colspan=\"2\" class=\"headingTH\" ondblclick=\"HideAgentFxCol();\" style=\"cursor: pointer;\"><center><span id=\"agentfxh\" onclick=\"HideAgentFxCol();\" title=\"Hide Agent Fx\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Agent FX<span id=\"tolerances\" onclick=\"ShowToleranceCol();\" title=\"Show Tolerance\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
            html.Append("<th colspan=\"3\" class=\"headingTH\" ondblclick=\"HideToleranceCol();\" style=\"cursor: pointer;\"><center><span id=\"toleranceh\" onclick=\"HideToleranceCol();\" title=\"Hide Tolerance\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Tolerance<span id=\"sendingagents\" onclick=\"ShowSendingAgentCol();\" title=\"Show Sending Agent\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
            html.Append("<th colspan=\"6\" class=\"headingTH\" ondblclick=\"HideSendingAgentCol();\" style=\"cursor: pointer;\"><center><span id=\"sendingagenth\" onclick=\"HideSendingAgentCol();\" title=\"Hide Sending Agent\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Sending Agent<span id=\"customertols\" onclick=\"ShowCustomerTolCol();\" title=\"Show Customer Tol.\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
            html.Append("<th colspan=\"2\" rowspan=\"2\" class=\"headingTH\" ondblclick=\"HideCustomerTolCol();\" style=\"cursor: pointer;\"><center><span id=\"customertolh\" onclick=\"HideCustomerTolCol();\" title=\"Hide Customer Tol.\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Cust. Tol.</center></th>");
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
                if (GetApplyFor().ToLower() == "c")
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

                html.Append("<td nowrap='nowrap'>" + dr["modifiedBy"] + " " + dr["modifiedDate"] + "<br/>" + dr["approvedBy"] + " " + dr["approvedDate"] + "</td>");
                html.Append("</tr>");
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