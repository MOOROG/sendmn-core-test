using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationUserPool
{
    public partial class List : Page
    {
        private const string ViewFunctionId = "10101200";
        private const string ForceLogoutFunctionId = "10101210";
        private const string GridName = "grd_userPool";
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private readonly UserPool userPool = UserPool.GetInstance();
        protected static int _pageSize = 10;       

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
                
            }
            LoadGrid();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId );
        }

        private string autoSelect(string str1, string str2)
        {
            if (str1 == str2)
                return "selected=\"selected\"";
            else
                return "";
        }

        private string GetPagingBlock(int _total_record, int _page, int _page_size)
        {
            var str = new StringBuilder("<input type = \"hidden\" name=\"hdd_curr_page\" id = \"hdd_curr_page\" value=\"" + _page.ToString() + "\">");
            str.Append("<div class=\"table-responsive\"> <table class=\"table border=\"0\">");
            str.Append("<tr>");
            str.Append("<td class=\"GridTextNormal\">Result :&nbsp;<b>" + _total_record.ToString() + "</b>&nbsp;records&nbsp;");
            str.Append("<select name=\"ddl_per_page\"  onChange=\"submit_form();\">");
            str.Append("<option value=\"10\"" + autoSelect("10", _page_size.ToString()) + ">10</option>");
            str.Append("<option value=\"20\"" + autoSelect("20", _page_size.ToString()) + ">20</option>");
            str.Append("<option value=\"30\"" + autoSelect("30", _page_size.ToString()) + ">30</option>");
            str.Append("<option value=\"40\"" + autoSelect("40", _page_size.ToString()) + ">40</option>");
            str.Append("<option value=\"50\"" + autoSelect("50", _page_size.ToString()) + ">50</option>");
            str.Append("<option value=\"100\"" + autoSelect("100", _page_size.ToString()) + ">100</option>");
            str.Append("</select>&nbsp;&nbsp;per page");
            str.Append("</td>");
            str.Append("</tr></table></div>");

            return str.ToString();

        }

        private string GetFilterForm(Dictionary<string, LoggedInUser> userList)
        {
            var str = new StringBuilder();
            str.Append("<div class=\"table-responsive\" ><table class=\"table\">");
            string ctlName1 = "userName";
            string ctlName2 = "agentName";
            str.Append("<tr>");
            str.AppendLine(
                    "<td class=\"GridTextNormal\" align=\"left\"><b><span {{style}}>Filtered results</span></b>");
            str.AppendLine("<img style = \"cursor:pointer\" src=\"" + GetStatic.GetUrlRoot() + "/images/clear-icon.png\" border=\"0\" title=\"Clear Filters\" onclick = \"ClearFilter();\" /></td></tr>");
            str.AppendLine("<tr>");
            str.Append("<td  align=\"left\"><label class=\"control-label\">User Name</label><br/>");
            str.Append("<input type=\"text\" id=\"" + ctlName1 + "\" name=\"" + ctlName1 + "\" value=\"" + Request.Form[ctlName1] + "\" class=\"form-control\" style=\"width:100%;\"></td>");
            str.Append("<td  align=\"left\"><label class=\"control-label\">Branch Name</label><br/>");
            str.Append("<input type=\"text\" id=\"" + ctlName2 + "\" name=\"" + ctlName2 + "\" value=\"" + Request.Form[ctlName2] + "\" class=\"form-control\" style=\"width:100%;\"></td>");
            str.Append("</tr>");

            str.Append("<tr>");
            str.Append("<td><input type=\"button\" value=\"Filter\" class=\"btn btn-primary\" onclick=\"submit_form();\">&nbsp;");
            str.AppendLine("<input type = 'button' class=\"btn btn-primary\" value = 'Clear Filters' title = \"Clear Filters\" onclick = \"ClearFilter();\" /></td>");
            str.Append("</tr>");
            str.Append("</table>");
            str.Append("</div>");
            var filterText = GetStatic.ReadFormData(ctlName1, "") != "" || GetStatic.ReadFormData(ctlName2, "") != "" ? "style = 'background-color:yellow'" : "";
            return str.ToString().Replace("{{style}}", filterText);
            return str.ToString();

        }

        protected void btnHidden_Click(object sender, EventArgs e)
        {

        }

        private void Sorting(string sortBy, string sortOrder)
        {
            Dictionary<string, LoggedInUser> userList = userPool.GetLoggedInUsers();
            List<KeyValuePair<string, LoggedInUser>> dv = userList.ToList();
            dv.Sort(
                delegate(KeyValuePair<string, LoggedInUser> firstPair,
                         KeyValuePair<string, LoggedInUser> nextPair)
                    {
                        if (sortBy == "userName")
                            return firstPair.Value.UserName.CompareTo(nextPair.Value.UserName);
                        if (sortBy == "agentName")
                            return firstPair.Value.UserAgentName.CompareTo(nextPair.Value.UserAgentName);
                        return 1;
                    }
                );
            if (sortOrder == "DESC")
            {
                dv.Reverse();
                LoadUserPool(dv);
            }
            else
            {
                LoadUserPool(dv);
            }
        }

        private void LoadGrid()
        {
            /*
            if (string.IsNullOrEmpty(hdnSortBy.Value))
            {
                hdnSortBy.Value = GetStatic.ReadCookie("poolSortBy", "");
                hdnSortOrder.Value = GetStatic.ReadCookie("poolSortOrder_" + hdnSortBy.Value, "");
            }
            var sortBy = hdnSortBy.Value;
            var sortOrder = hdnSortOrder.Value;

            Sorting(sortBy, sortOrder);

            GetStatic.WriteCookie("poolSortBy", sortBy);
            GetStatic.WriteCookie("poolSortOrder_" + sortBy, sortOrder);
             */
            LoadUserPool(null);
        }

        private string ReverseSortOrder(string sortOrder)
        {
            return sortOrder.ToUpper().Trim() == "ASC" ? "DESC" : "ASC";
        }

        private void LoadUserPool(List<KeyValuePair<string, LoggedInUser>> dv)
        {
            var cssClassUserName = "";
            var cssClassAgentName = "";
            var sortBy = GetStatic.ReadCookie("poolSortBy", "");
            var sortOrder = GetStatic.ReadCookie("poolSortOrder_" + sortBy, "ASC");
            if (sortBy == "userName" && sortOrder == "ASC")
                cssClassUserName = "class = \"sortAsc\"";
            else if (sortBy == "userName" && sortOrder == "DESC")
                cssClassUserName = "class = \"sortDesc\"";
            else if (sortBy == "agentName" && sortOrder == "ASC")
                cssClassAgentName = "class = \"sortAsc\"";
            else if (sortBy == "agentName" && sortOrder == "DESC")
                cssClassAgentName = "class = \"sortDesc\"";

            Dictionary<string, LoggedInUser> userList = userPool.GetLoggedInUsers();
            if (dv == null)
                dv = userList.ToList();
            string url ="" + GetStatic.GetUrlRoot() + "/SwiftSystem/UserManagement/ApplicationUserSetup/Manage.aspx";
            var str = new StringBuilder();

            str.Append("<div class=\"table-responsive\" ><table class=\"table\">");
            str.Append("<tr>");
            str.Append("<td class=\"GridTextNormal\" nowrap = \"nowrap\">");
            str.Append(GetFilterForm(userList));
            str.Append("</td></tr></table></div>");

            //start paging block
            string _page_size = "10";
            int _page = 1;
            int tot_record = Convert.ToUInt16(userList.Count);
           
            if (Request.Form["hdd_curr_page"] != null)
                _page = Convert.ToInt32(Request.Form["hdd_curr_page"].ToString());

            if (Request.Cookies["page_size"] != null)
                _page_size = Request.Cookies["page_size"].Value.ToString();

            if (Request.Form["ddl_per_page"] != null)
                _page_size = Request.Form["ddl_per_page"].ToString();

            Response.Cookies["page_size"].Value = _page_size;

            int page_size = Convert.ToUInt16(_page_size);

            str.Append("<div class=\"table-responsive\" > <table class=\"table\">");
            str.Append("<tr>");
            str.Append("<td  class=\"GridTextNormal\" nowrap = \"nowrap\">");
            str.Append(GetPagingBlock(tot_record, _page, page_size));
            str.Append("</td></tr></table></div>");

            //end paging block


            str.Append(
                "<div class=\"table-responsive\" ><table class=\"table table-bordered table-striped table-condensed table-scroll\" id=\"" +
                GridName + "_body\">");
            str.Append("<tr class=\"hdtitle\">");
            str.Append("<th nowrap=\"nowrap\">User Name" + GetJsFilterText(0, "UserName") + "</th>");
            str.Append("<th nowrap=\"nowrap\">Branch Name" + GetJsFilterText(1, "Agent Name") + "</th>");
            str.Append("<th nowrap=\"nowrap\">Login Time" + GetJsFilterText(2, "Login Time") + "</th>");
            str.Append("<th nowrap=\"nowrap\">Duration(Min)" + GetJsFilterText(3, "Duration(Min)") + "</th>");
            str.Append("<th nowrap=\"nowrap\">Login Country" + GetJsFilterText(4, "Login Country") + "</th>");
            str.Append("<th nowrap=\"nowrap\">Login Address" + GetJsFilterText(4, "Login Address") + "</th>");
            str.Append("<th nowrap=\"nowrap\">Browser" + GetJsFilterText(4, "Browser") + "</th>");
            str.Append("<th nowrap=\"nowrap\">IP Address" + GetJsFilterText(5, "IP Address") + "</th>");
            //str.Append("<th nowrap=\"nowrap\">Digital Certificate" + GetJsFilterText(6, "Digital Certificate") + "</th>");
            str.Append("<th nowrap=\"nowrap\">Session ID" + GetJsFilterText(6, "Session ID") + "</th>");
            str.Append("<th></th>");
            str.Append("</tr>");
            int cnt = 0;
            string defValue1 = "";
            string defValue2 = "";
            string ctlName1 = "";
            string ctlName2 = "";
            ctlName1 = "userName";
            ctlName2 = "agentName";
            int i = 1;
            foreach (KeyValuePair<string, LoggedInUser> loggedInUser in dv)
            {
                if (GetStatic.ReadFormData(ctlName1, "") != "" || GetStatic.ReadFormData(ctlName2, "") != "")
                {
                    i++;
                    defValue1 = GetStatic.ReadFormData(ctlName1, "");
                    defValue2 = GetStatic.ReadFormData(ctlName2, "");
                    if (loggedInUser.Value.UserName.ToUpper().Contains(defValue1.ToUpper()) && loggedInUser.Value.UserAgentName.ToUpper().Contains(defValue2.ToUpper()))
                    {
                        str.Append(++cnt % 2 == 1
                                        ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\" >"
                                        : "<tr class=\"evenbg\" onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\">");
                        str.Append("<td>" + loggedInUser.Value.UserName + "</td>");
                        str.Append("<td>" + loggedInUser.Value.UserAgentName + "</td>");
                        str.Append("<td>" + loggedInUser.Value.LoginTime.ToString() + "</td>");
                        str.Append("<td>" + Convert.ToInt32((DateTime.Now - loggedInUser.Value.LoginTime).TotalMinutes) + "</td>");
                        str.Append("<td>" + loggedInUser.Value.LoggedInCountry + "</td>");
                        str.Append("<td>" + loggedInUser.Value.LoginAddress + "</td>");
                        str.Append("<td>" + loggedInUser.Value.Browser + "</td>");
                        str.Append("<td>" + loggedInUser.Value.IPAddress + "</td>");
                        //str.Append("<td>" + loggedInUser.Value.DcInfo + "</td>");
                        str.Append("<td>" + loggedInUser.Value.SessionID + "</td>");
                        if (loggedInUser.Value.UserName != GetStatic.GetUser())
                        {
                            str.Append("<td nowrap='nowrap'>");
                            if (_sl.HasRight(ForceLogoutFunctionId))
                                str.Append("<a href=\"#\" onclick=\"FlushUser('" + loggedInUser.Value.UserName + "');\"><img class = \"showHand\" border = \"0\" title = \"Force Logout\" src=\"" +
                                            GetStatic.GetUrlRoot() + "/images/block-icon.png\" /></a>&nbsp;&nbsp;");
                            //str.Append("<a href=\"#\" onclick=\"UserDetail('" + loggedInUser.Value.UserId + "','" + url + "');\"><img class = \"showHand\" border = \"0\" title = \"View Detail\" src=\"" +
                            //            GetStatic.GetUrlRoot() + "/images/view-detail-icon.png\" /></a>");
                            str.Append("</td>");
                        }
                        else
                            str.Append("<td></td>");
                        str.Append("</tr>");
                    }
                }
                else
                {
                    //Checking paging value
                    if (i > page_size)
                        break;
                    i++;
                    str.Append(++cnt % 2 == 1
                                        ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\" >"
                                        : "<tr class=\"evenbg\" onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\">");
                    str.Append("<td>" + loggedInUser.Value.UserName + "</td>");
                    str.Append("<td>" + loggedInUser.Value.UserAgentName + "</td>");
                    str.Append("<td>" + loggedInUser.Value.LoginTime.ToString() + "</td>");
                    str.Append("<td>" + Convert.ToInt32((DateTime.Now - loggedInUser.Value.LoginTime).TotalMinutes) + "</td>");
                    str.Append("<td>" + loggedInUser.Value.LoggedInCountry + "</td>");
                    str.Append("<td>" + loggedInUser.Value.LoginAddress + "</td>");
                    str.Append("<td>" + loggedInUser.Value.Browser + "</td>");
                    str.Append("<td>" + loggedInUser.Value.IPAddress + "</td>");
                    //str.Append("<td>" + loggedInUser.Value.DcInfo + "</td>");
                    str.Append("<td>" + loggedInUser.Value.SessionID + "</td>");
                    if (loggedInUser.Value.UserName != GetStatic.GetUser())
                    {
                        str.Append("<td nowrap='nowrap'>");
                        if (_sl.HasRight(ForceLogoutFunctionId))
                            str.Append("<a href=\"#\" onclick=\"FlushUser('" + loggedInUser.Value.UserName + "');\"><img class = \"showHand\" border = \"0\" title = \"Force Logout\" src=\"" +
                                        GetStatic.GetUrlRoot() + "/images/block-icon.png\" /></a>&nbsp;&nbsp;");


                        str.Append("<a href=\"#\" onclick=\"UserDetail('" + loggedInUser.Value.UserId + "','" + url + "');\"><img class = \"showHand\" border = \"0\" title = \"View Detail\" src=\"" +
                                    GetStatic.GetUrlRoot() + "/images/view-detail-icon.png\" /></a>");
                        str.Append("</td>");
                    }
                    else
                        str.Append("<td></td>");
                    str.Append("</tr>");
                }
               
            }
            
            str.Append("</table></div>");
            str.Append("<input id=\"btnSubmit\" type=\"submit\" style=\"display: none;\"");
            rpt_grid.InnerHtml = str.ToString();
        }

        protected void btnFlushUser_Click(object sender, EventArgs e)
        {
            userPool.RemoveUser(hddUsername.Value);
            hddUsername.Value = "";
            Response.Redirect("List.aspx");
        }

        private string GetJsFilterText(int colIndex, string colHeading)
        {
            string filterFunction = "ShowFilterForListGrid(this, '" + GridName + "', " + colIndex + ",'" +
                                    colHeading + "');";
            string filterText =
                "<span title =\"Filter\" style = \"clear:both;cursor:pointer;width:50px;float:right\" onclick =\"" +
                filterFunction + "\">&nbsp;</span>";
            return filterText;
        }
        protected void btnManagePageSize_Click(object sender, EventArgs e)
        {
            _pageSize = Convert.ToInt32(Request.Form["nav"]);
        }

        protected void btnFlushAllUser_Click(object sender, EventArgs e)
        {
            userPool.RemoveAllUser();
            GetStatic.PrintSuccessMessage(Page, "All users forcefully logout successfully");
        }
    }
}