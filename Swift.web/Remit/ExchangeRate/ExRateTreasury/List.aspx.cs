using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.ExchangeRate.ExRateTreasury
{
    public partial class List : System.Web.UI.Page
    {
        private ExRateTreasuryDao obj = new ExRateTreasuryDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftTab _tab = new SwiftTab();
        private const string GridName = "grd_ert";
        private const string ViewFunctionId = "30012300";
        private const string AddEditFunctionId = "30012310";
        private string chkList = "";
        private string chkGroupList = "";

        private const string ApproveFunctionId2 = "";
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
                LoadTab();
                PopulateDdl();
                //LoadGrid();
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

        private string autoSelect(string str1, string str2)
        {
            if (str1 == str2)
                return "selected=\"selected\"";
            else
                return "";
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void LoadTab()
        {
            var isFw = GetIsFw();

            var queryStrings = "?isFw=" + isFw;
            _tab.NoOfTabPerRow = 8;
            _tab.TabList = new List<TabField>
                               {
                                   new TabField("Treasury Rate", "", true),
                                   new TabField("Add New", "Manage.aspx" + queryStrings),
                                   new TabField("Approve", "ApproveList.aspx" + queryStrings),
                                   new TabField("Reject", "RejectList.aspx" + queryStrings),
                                   new TabField("My changes", "MyChangeList.aspx" + queryStrings),
                                   new TabField("Copy Rate", "CopyAgentWiseRate.aspx" + queryStrings),
                               };

            divTab.InnerHtml = _tab.CreateTab();
        }

        private string GetPagingBlock(int _total_record, int _page, int _page_size)
        {
            var str = new StringBuilder("<input type = \"hidden\" name=\"hdd_curr_page\" id = \"hdd_curr_page\" value=\"" + _page.ToString() + "\">");
            str.Append("<tr><td colspan='37'><table width=\"table table-responsive table-striped table-bordered\">");
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

            str.AppendLine("<a href=\"Manage.aspx\" title=\"Add New Record\"><img src='" +
                                    GetStatic.GetUrlRoot() + "/images/add.gif' border='0'></a>");

            // str.AppendLine("&nbsp; <img title = 'Export to Excel' style = 'cursor:pointer' onclick
            // = \"DownloadGrid('" + GetStatic.GetUrlRoot() + "');\" src='" + GetStatic.GetUrlRoot()
            // + "/images/excel.gif' border='0'>");

            str.AppendLine("</td>");
            str.AppendLine("</tr></table></td></tr>");

            return str.ToString();
        }

        private string LoadPagingBlock(DataTable dtPaging)
        {
            string pagingTable = "";
            foreach (DataRow row in dtPaging.Rows)
            {
                pagingTable = GetPagingBlock(int.Parse(row["totalRow"].ToString()), int.Parse(row["pageNumber"].ToString()), int.Parse(row["pageSize"].ToString()));
            }
            return pagingTable;
        }

        protected void SaveAsCookie()
        {
            GetStatic.WriteValue(GridName, ref cCountry, "cCountry");
            GetStatic.WriteValue(GridName, ref cAgent, "cAgent");
            GetStatic.WriteValue(GridName, ref cCurrency, "cCurrency");
            GetStatic.WriteValue(GridName, ref pCountry, "pCountry");
            GetStatic.WriteValue(GridName, ref pAgent, "pAgent");
            GetStatic.WriteValue(GridName, ref pCurrency, "pCurrency");
            GetStatic.WriteValue(GridName, ref tranType, "tranType");
        }

        private void LoadGrid()
        {
            var cCountryId = "";
            var cAgentId = "";
            var cCurrencyId = "";
            var pCountryId = "";
            var pAgentId = "";
            var pCurrencyId = "";
            var tranTypeId = "";

            var cRateId = "";
            var pRateId = "";

            if (!string.IsNullOrEmpty(GetDefExRateId()))
            {
                switch (GetRateType().ToLower())
                {
                    case "c":
                        countryOrderBy.Text = "receivingCountry";
                        cRateId = GetDefExRateId();
                        break;

                    case "p":
                        countryOrderBy.Text = "sendingCountry";
                        pRateId = GetDefExRateId();
                        break;
                }
            }

            string _page_size = "10";
            string sortd = "ASC";
            int _page = 1;

            if (Request.Form["hdd_curr_page"] != null)
                _page = Convert.ToInt32(Request.Form["hdd_curr_page"].ToString());

            if (Request.Cookies["page_size"] != null)
                _page_size = Request.Cookies["page_size"].Value.ToString();

            if (Request.Form["ddl_per_page"] != null)
                _page_size = Request.Form["ddl_per_page"].ToString();

            Response.Cookies["page_size"].Value = _page_size;

            int page_size = Convert.ToUInt16(_page_size);
            var isActive = "";
            if (showInactive.Checked)
            {
                isActive = "N";
                btnMarkActive.Visible = true;
                btnMarkInactive.Visible = false;
            }
            else
            {
                isActive = "Y";
                btnMarkActive.Visible = false;
                btnMarkInactive.Visible = true;
            }

            var ds = obj.LoadGrid(GetStatic.GetUser(), _page.ToString(), page_size.ToString(), countryOrderBy.Text, sortd, cCountry.Text, cAgent.Text, cCurrency.Text, pCountry.Text, pAgent.Text, pCurrency.Text, tranType.Text, ddlIsUpdated.Text, haschanged.Text, isActive, cRateId, pRateId, GetStatic.GetBoolToChar(filterbyPCountryOnly.Checked));
            var dtPaging = ds.Tables[0];

            var dt = ds.Tables[1];
            var html = new StringBuilder();
            html.Append("<div class=\"responsive-table\">");
            html.Append("<table id=\"rateTable\" class=\"table table-responsive table-striped table-bordered\">");
            html.Append(LoadPagingBlock(dtPaging));
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
            //html.Append("<th colspan=\"3\" class=\"headingTH\"><center>Cross Rate</center></th>");
            //html.Append("<th colspan=\"4\" rowspan=\"2\" class=\"headingTH\"><center>For RSP</center></th>");
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
            html.Append("<th class=\"thcustomerrate\">Margin</th>");
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

                //Check for any cost rate updates
                if (dr["isUpdated"].ToString() == "Y")
                {
                    html.Append("<tr id=\"row_" + id + "\"" + AppendRowSelectionProperty("selectedbg", "rowhighlight", "GridOddRowOver") + ">");
                    //Check for mod type insert
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
                        html.Append(ComposeCustomerRateTextBox(dr, id, "customerRate", false, "tdcustomerrate", "", ""));
                        //html.Append(ComposeTextBox(dr, id, "customerRate", false, "tdcustomerrate", false));

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
                        html.Append("<input id=\"btnUpdate_" + id + "\" type=\"button\" class=\"button\" onclick=\"UpdateRate(" + id + ",'Y')\" value=\"Update\"/>");
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
                        html.Append("<input id=\"btnUpdate_" + id + "\" type=\"button\" class=\"btn btn-primary m-t-25\" onclick=\"UpdateRate(" + id + ",'Y')\" value=\"Update\"/>");
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
                        html.Append(ComposeCustomerRateTextBoxWithValue(dr, id, "customerRate", false, "rowNew", "", "", dr["customerRateNew"].ToString()));
                        //html.Append(ComposeTextBoxWithValue(dr, id, "customerRate", false, "rowNew", false, dr["customerRateNew"].ToString()));

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
                        html.Append(ComposeCustomerRateTextBoxWithValue(dr, id, "customerRate", false, "tdcustomerrate",
                                                                        "", "", dr["customerRateNew"].ToString()));
                        //html.Append(ComposeTextBoxWithValue(dr, id, "customerRate", false, "tdcustomerrate", false, dr["customerRateNew"].ToString()));

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
                        html.Append("<input id=\"btnUpdate_" + id + "\" type=\"button\" class=\"btn btn-primary m-t-25\" onclick=\"UpdateRate(" + id + ",'N')\" value=\"Update\"/>");
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
                        //html.Append(ComposeTextBox(dr, id, "customerRate", false, "tdcustomerrate", false));
                        html.Append(ComposeCustomerRateTextBox(dr, id, "customerRate", false, "tdcustomerrate", "", ""));

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
                        html.Append("<input id=\"btnUpdate_" + id + "\" type=\"button\" class=\"btn btn-primary m-t-25\" onclick=\"UpdateRate(" + id + ",'N')\" value=\"Update\"/>");
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
            html.Append("</div>");
            rpt_grid.InnerHtml = html.ToString();
            GetStatic.CallBackJs1(Page, "Show Hide", "ShowHideDetail();");
            if (dt.Rows.Count > 0)
            {
                btnUpdateChanges.Visible = true;
                if (showInactive.Checked)
                {
                    btnMarkActive.Visible = true;
                    btnMarkInactive.Visible = false;
                }
                else
                {
                    btnMarkActive.Visible = false;
                    btnMarkInactive.Visible = true;
                }
            }
        }

        private string AppendRowSelectionProperty(string rowSelectedClass, string defaultClass, string onhoverclass)
        {
            return " class=\"" + defaultClass + "\" ondblclick=\"if(this.className=='" + rowSelectedClass + "'){this.className='" + defaultClass + "';}else{this.className='" + rowSelectedClass + "';}\" onMouseOver=\"if(this.className=='" + defaultClass + "'){this.className='" + onhoverclass + "';}\" onMouseOut=\"if(this.className=='" + rowSelectedClass + "'){}else{this.className='" + defaultClass + "';}\" ";
        }

        private string ComposeCustomerRateTextBox(DataRow dr, string id, string valueField, bool enable, string cssClass, string evt, string evtFunction)
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
            var html = new StringBuilder("<td nowrap=\"nowrap\" class=\"" + cssClass + "\">");
            html.Append("<input class=\"" + textBoxCss + "\"" + disabled + "id=\"" + valueField + "_" + id + "\" name=\"" + valueField + "_" + id + "\" onfocus=\"ShowHideUpdateFunction(this," + id + ");\" type=\"text\" value=\"" + dr[valueField] + "\"" + evtAttr + styleAttr + "/>");
            html.Append(hiddenHtmlControls);
            html.Append(
                "<img src=\"../../../images/rule.gif\" border=\"0\" style=\"cursor: pointer;\" onclick=\"MarginCalculator(" +
                id + ");\"/>");
            html.Append("</td>");
            return html.ToString();
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
            html.Append("<input class=\"" + textBoxCss + "\"" + disabled + "id=\"" + valueField + "_" + id + "\" name=\"" + valueField + "_" + id + "\" type=\"text\" onfocus=\"ShowHideUpdateFunction(this," + id + ");\" value=\"" + value + "\"" + evtAttr + styleAttr + "/>");
            html.Append(hiddenHtmlControls);
            html.Append("</td>");
            return html.ToString();
        }

        private string ComposeCustomerRateTextBoxWithValue(DataRow dr, string id, string valueField, bool enable, string cssClass, string evt, string evtFunction, string value)
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
                                     value + "\" />";
            }
            var evtAttr = !string.IsNullOrEmpty(evt) ? " " + evt + "=\"" + evtFunction + "\"" : "";
            var styleAttr = "";
            var html = new StringBuilder("<td nowrap=\"nowrap\" class=\"" + cssClass + "\">");
            html.Append("<input class=\"" + textBoxCss + "\"" + disabled + "id=\"" + valueField + "_" + id + "\" name=\"" + valueField + "_" + id + "\" onfocus=\"ShowHideUpdateFunction(this," + id + ");\" type=\"text\" value=\"" + dr[valueField] + "\"" + evtAttr + styleAttr + "/>");
            html.Append(hiddenHtmlControls);
            html.Append(
                "<img src=\"../../../images/rule.gif\" border=\"0\" style=\"cursor: pointer;\" onclick=\"MarginCalculator(" +
                id + ");\"/>");
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
            Response.Redirect("ModifySummary.aspx");
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
            if (showInactive.Checked == false && string.IsNullOrEmpty(ddlIsUpdated.Text))
            {
                if (string.IsNullOrEmpty(cCountry.Text) && string.IsNullOrEmpty(pCountry.Text))
                {
                    GetStatic.AlertMessage(Page,
                                            "Please select at least one country(either sending or receving) for search");
                    return;
                }
            }
            if (!string.IsNullOrEmpty(cCountry.Text))
                countryOrderBy.Text = "receivingCountry";
            else if (!string.IsNullOrEmpty(pCountry.Text))
                countryOrderBy.Text = "sendingCountry";
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
            Response.Redirect("ModifySummary.aspx");
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
                            , crossRate.Value, agentCrossRateMargin.Value, customerRate.Value, isUpdated.Value);
                if (dbResult.ErrorCode != "0")
                    exRateTreasuryList = exRateTreasuryList.Where(val => val != id).ToArray();
            }
            exRateTreasuryIds = string.Join(",", exRateTreasuryList);
            GetStatic.WriteSession("exRateTreasuryIds", exRateTreasuryIds);
            Response.Redirect("ModifySummary.aspx");
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

        private void PopulateDdl()
        {
            LoadSendingCountry(ref cCountry, "");
            LoadReceivingCountry(ref pCountry, "");
            //LoadAgent(ref cAgent, cCountry.Text, "");
            //LoadAgent(ref pAgent, pCountry.Text, "");
            //LoadCurrency(ref cCurrency, cCountry.Text, "");
            //LoadCurrency(ref pCurrency, pCountry.Text, "");
        }

        private void LoadSendingCountry(ref DropDownList ddl, string defaultValue)
        {
            var sql = "EXEC proc_countryMaster @flag = 'scl'";
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, "All");
        }

        private void LoadReceivingCountry(ref DropDownList ddl, string defaultValue)
        {
            var sql = "EXEC proc_countryMaster @flag = 'rcl'";
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, "All");
        }

        private void LoadCurrency(ref DropDownList ddl, string countryId, string defaultValue)
        {
            var sql = "EXEC proc_countryCurrency @flag='cl', @countryId=" + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "currencyId", "currencyCode", defaultValue, "All");
        }

        private void LoadAgent(ref DropDownList ddl, string countryId, string defaultValue)
        {
            var sql = "EXEC proc_agentMaster @flag = 'alc', @agentCountryId = " + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", defaultValue, "All");
        }

        private void LoadTranType(ref DropDownList ddl, string countryId, string defaultValue)
        {
            var sql = "EXEC proc_dropDownLists @flag = 'recModeByCountry', @param = " + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "serviceTypeId", "typeTitle", defaultValue, "Any");
        }

        protected void cCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref cAgent, cCountry.Text, "");
            LoadCurrency(ref cCurrency, cCountry.Text, "");
            cCountry.Focus();
        }

        protected void pCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadTranType(ref tranType, pCountry.Text, "");
            LoadAgent(ref pAgent, pCountry.Text, "");
            LoadCurrency(ref pCurrency, pCountry.Text, "");
            pCountry.Focus();
        }

        protected void btnFilterShowHide_Click(object sender, System.Web.UI.ImageClickEventArgs e)
        {
            if (td_Search.Visible)
            {
                td_Search.Visible = false;
                btnFilterShowHide.ImageUrl = "../../../images/icon_show.gif";
            }
            else
            {
                td_Search.Visible = true;
                btnFilterShowHide.ImageUrl = "../../../images/icon_hide.gif";
            }
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

        protected void btnClearData_Click(object sender, EventArgs e)
        {
            rpt_grid.InnerHtml = "";
            btnMarkActive.Visible = false;
            btnMarkInactive.Visible = false;
        }
    }
}