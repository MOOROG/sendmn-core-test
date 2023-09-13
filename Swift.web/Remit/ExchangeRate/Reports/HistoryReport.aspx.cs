using System;
using System.Data;
using System.Text;
using System.Web.UI.WebControls;
using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.web.Library;

namespace Swift.web.Remit.ExchangeRate.Reports
{
    public partial class HistoryReport : System.Web.UI.Page
    {
        private ExRateReportDao obj = new ExRateReportDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string GridName = "grd_ert";
        private const string ViewFunctionId = "20111900";
        string chkList = "";

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
            if (!IsPostBack)
            {
                Authenticate();
                PopulateDdl();
                Misc.DisableInput(ref fromDate, DateTime.Today.ToShortDateString());
                Misc.DisableInput(ref toDate, DateTime.Today.ToShortDateString());
                hdnIsFw.Value = GetStatic.ReadQueryString("isFw", "");
            }
            GetStatic.CallBackJs1(Page, "Load Calendars", "LoadCalendars();");
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
            _sdd.CheckAuthentication(ViewFunctionId);
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

            var ds = obj.GetHistoryReportIrh(GetStatic.GetUser(), _page.ToString(), page_size.ToString(), countryOrderBy.Text, sortd, cCountry.Text, cAgent.Text, cBranch.Text, cCurrency.Text, pCountry.Text, pAgent.Text, pCurrency.Text, tranType.Text, GetStatic.GetBoolToChar(filterbyPCountryOnly.Checked), fromDate.Text, toDate.Text);
            var dtPaging = ds.Tables[0];

            var dt = ds.Tables[1];
            var html = new StringBuilder();
            html.Append("<div class=\"responsive-table\">");
            html.Append("<table id=\"rateTable\" class=\"exTable\" width=\"100%\" cellspacing=\"0\" cellpadding=\"2\" border=\"0\">");
            html.Append(loadPagingBlock(dtPaging));
            html.Append("<tr class=\"hdtitle\">");
            html.Append("<th colspan=\"3\" rowspan=\"2\" class=\"headingTH\"><center>Send</center></th>");
            html.Append("<th colspan=\"2\" rowspan=\"2\" class=\"headingTH\"><center>Receive</center></th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\">Service Type</th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\">Send<br/>Curr.</th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\"><center>Receive<br/>Curr.<span id=\"headoffices\" onclick=\"ShowHeadOfficeCol();\" title=\"Show HO Rate Detail\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
            html.Append("<th colspan=\"8\" class=\"headingTH\" ondblclick=\"HideHeadOfficeCol();\" style=\"cursor: pointer;\"><center><span id=\"headofficeh\" onclick=\"HideHeadOfficeCol();\" title=\"Hide HO Rate Detail\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Head Office<span id=\"agentfxs\" onclick=\"ShowAgentFxCol();\" title=\"Show Agent Fx\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
            html.Append("<th rowspan=\"2\" colspan=\"2\" class=\"headingTH\" ondblclick=\"HideAgentFxCol();\" style=\"cursor: pointer;\"><center><span id=\"agentfxh\" onclick=\"HideAgentFxCol();\" title=\"Hide Agent Fx\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Agent FX<span id=\"tolerances\" onclick=\"ShowToleranceCol();\" title=\"Show Tolerance\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
            html.Append("<th colspan=\"3\" class=\"headingTH\" ondblclick=\"HideToleranceCol();\" style=\"cursor: pointer;\"><center><span id=\"toleranceh\" onclick=\"HideToleranceCol();\" title=\"Hide Tolerance\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Tolerance<span id=\"sendingagents\" onclick=\"ShowSendingAgentCol();\" title=\"Show Sending Agent\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
            html.Append("<th colspan=\"6\" class=\"headingTH\" ondblclick=\"HideSendingAgentCol();\" style=\"cursor: pointer;\"><center><span id=\"sendingagenth\" onclick=\"HideSendingAgentCol();\" title=\"Hide Sending Agent\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Sending Agent<span id=\"customertols\" onclick=\"ShowCustomerTolCol();\" title=\"Show Customer Tol.\"><span><img src=\"../../../images/expandright-icon.png\" border=\"0\" /></span></span></center></th>");
            html.Append("<th colspan=\"2\" rowspan=\"2\" class=\"headingTH\" ondblclick=\"HideCustomerTolCol();\" style=\"cursor: pointer;\"><center><span id=\"customertolh\" onclick=\"HideCustomerTolCol();\" title=\"Hide Customer Tol.\"><span><img src=\"../../../images/collapseleft-icon.png\" border=\"0\" /></span></span>Cust. Tol.</center></th>");
            html.Append("<th colspan=\"3\" class=\"headingTH\"><center>Cross Rate</center></th>");
            html.Append("<th rowspan=\"3\" class=\"headingTH\">Status</th>");
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
            html.Append("<th class=\"headingTH\" style=\"min-width: 100px !important;\">Agent</th>");
            html.Append("<th class=\"headingTH\">Branch</th>");
            html.Append("<th class=\"headingTH\">Country</th>");
            html.Append("<th class=\"headingTH\" style=\"min-width: 100px !important;\">Agent</th>");

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
                if (countryOrderBy.Text == "pCountryName")
                {
                    if (countryName != dr["pCountryName"].ToString())
                    {
                        html.Append(
                            "<tr class=\"trcountry\"><td colspan=\"37\" class=\"tdcountry\"><b>Receiving Country : " + GetStatic.GetCountryFlag(dr["pCountryCode"].ToString()) +
                            dr["pCountryName"] + "</b></td></th>");
                        countryName = dr["pCountryName"].ToString();
                    }
                }
                else
                {
                    if (countryName != dr["cCountryName"].ToString())
                    {
                        html.Append(
                            "<tr class=\"trcountry\"><td colspan=\"37\" class=\"tdcountry\"><b>Sending Country : " + GetStatic.GetCountryFlag(dr["cCountryCode"].ToString()) +
                            dr["cCountryName"] + "</b></td></th>");
                        countryName = dr["cCountryName"].ToString();
                    }
                }

                html.Append(++i % 2 == 1 ? "<tr id=\"row_" + id + "\"" + AppendRowSelectionProperty("selectedbg", "oddbg", "GridOddRowOver") + ">" : "<tr id=\"row_" + id + "\"" + AppendRowSelectionProperty("selectedbg", "evenbg", "GridEvenRowOver") + ">");
                html.Append("<td nowrap=\"nowrap\">" + GetStatic.GetCountryFlag(dr["cCountryCode"].ToString()) + dr["cCountryName"] + "</td>");
                html.Append("<td>" + dr["cAgentName"] + "</td>");
                html.Append("<td>" + dr["cBranchName"] + "</td>");
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

                html.Append("<td>" + dr["status"] + "</td>");
                html.Append("<td nowrap='nowrap'>" + dr["modifiedBy"] + " " + dr["modifiedDate"] + "<br/>" + dr["approvedBy"] + " " + dr["approvedDate"] + "</td>");
                html.Append("</tr>");
            }
            html.Append("</table>");
            html.Append("</div>");
            rpt_grid.InnerHtml = html.ToString();
            GetStatic.CallBackJs1(Page, "Show Hide", "ShowHideDetail();");
        }

        private void LoadGridForBranchWise()
        {
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

            var ds = obj.GetExRateReportAdmin(GetStatic.GetUser(), _page.ToString(), page_size.ToString(), countryOrderBy.Text, sortd, cCountry.Text, cAgent.Text, cBranch.Text, cCurrency.Text, pCountry.Text, pAgent.Text, pCurrency.Text, tranType.Text);
            var dtPaging = ds.Tables[0];

            var dt = ds.Tables[1];
            var html = new StringBuilder();
            html.Append("<div class=\"responsive-table\">");
            html.Append("<table id=\"rateTable\" class=\"exTable\" width=\"100%\" cellspacing=\"0\" cellpadding=\"2\" border=\"0\">");
            html.Append(loadPagingBlock(dtPaging));
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
            html.Append("<th colspan=\"4\" rowspan=\"2\" class=\"headingTH\"><center>For RSP</center></th>");

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
            html.Append("<th class=\"headingTH\" style=\"min-width: 100px !important;\">Agent</th>");
            html.Append("<th class=\"headingTH\">Country</th>");
            html.Append("<th class=\"headingTH\" style=\"min-width: 100px !important;\">Agent</th>");

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

            html.Append("<th class=\"thrsp\">Max Tol.</th>");
            html.Append("<th class=\"thrsp\">Tolerance</th>");
            html.Append("<th class=\"thrsp\">Cost</th>");
            html.Append("<th class=\"thrsp\">Margin</th>");

            html.Append("</tr>");

            var i = 0;
            var countryName = "";
            foreach (DataRow dr in dt.Rows)
            {
                var id = dr["exRateTreasuryId"].ToString();
                if (countryOrderBy.Text == "pCountryName")
                {
                    if (countryName != dr["pCountryName"].ToString())
                    {
                        html.Append(
                            "<tr class=\"trcountry\"><td colspan=\"37\" class=\"tdcountry\"><b>Receiving Country : " + GetStatic.GetCountryFlag(dr["pCountryCode"].ToString()) +
                            dr["pCountryName"] + "</b></td></th>");
                        countryName = dr["pCountryName"].ToString();
                    }
                }
                else
                {
                    if (countryName != dr["cCountryName"].ToString())
                    {
                        html.Append(
                            "<tr class=\"trcountry\"><td colspan=\"37\" class=\"tdcountry\"><b>Sending Country : " + GetStatic.GetCountryFlag(dr["cCountryCode"].ToString()) +
                            dr["cCountryName"] + "</b></td></th>");
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

                html.Append(ComposeLabelWithValue((Convert.ToDecimal(dr["maxCrossRate"]) - Convert.ToDecimal(dr["crossRate"])).ToString(), "tdrsp", true));
                html.Append("<td class=\"tdrsp\">" + dr["tolerance"] + "</td>");
                html.Append("<td class=\"tdrsp\">" + dr["cost"] + "</td>");
                html.Append(ComposeLabelWithValue(dr["margin"].ToString(), "tdrsp", true));
                html.Append("<td nowrap='nowrap'>" + dr["modifiedBy"] + " " + dr["modifiedDate"] + "<br/>" + dr["approvedBy"] + " " + dr["approvedDate"] + "</td>");
                html.Append("</tr>");
            }
            html.Append("</table>");
            html.Append("</div>");
            rpt_grid.InnerHtml = html.ToString();
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

        private void PopulateDdl()
        {
            LoadSendingCountry(ref cCountry);
            LoadReceivingCountry(ref pCountry);
            LoadAgent(ref cAgent, cCountry.Text);
            LoadAgent(ref pAgent, pCountry.Text);
            LoadCurrency(ref cCurrency, cCountry.Text);
            LoadCurrency(ref pCurrency, pCountry.Text);
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

        private void LoadCurrency(ref DropDownList ddl, string countryId)
        {
            var sql = "EXEC proc_countryCurrency @flag='cl', @countryId=" + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "currencyId", "currencyCode", "", "All");
        }

        private void LoadAgent(ref DropDownList ddl, string countryId)
        {
            var sql = "EXEC proc_agentMaster @flag = 'alc', @agentCountryId = " + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", "", "All");
        }

        private void LoadBranch(ref DropDownList ddl, string agentId)
        {
            var sql = "EXEC proc_agentMaster @flag = 'bl', @parentId = " + _sdd.FilterString(agentId);
            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", "", "All");
        }

        private void LoadTranType(ref DropDownList ddl, string countryId)
        {
            var sql = "EXEC proc_dropDownLists @flag = 'recModeByCountry', @param = " + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "serviceTypeId", "typeTitle", "", "Any");
        }

        protected void cCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref cAgent, cCountry.Text);
            LoadCurrency(ref cCurrency, cCountry.Text);
            cCountry.Focus();
        }

        protected void pCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadTranType(ref tranType, pCountry.Text);
            LoadAgent(ref pAgent, pCountry.Text);
            LoadCurrency(ref pCurrency, pCountry.Text);
            pCountry.Focus();
        }

        protected void cAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadBranch(ref cBranch, cAgent.Text);
            cBranch.Focus();
        }
    }
}